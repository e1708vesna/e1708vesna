public class ClaimMemberSharingUtil {
    
	@TestVisible private static String testProcessInstanceJson = null;
    
    
	@TestVisible private static final String APEXSHARINGREASON = 'EligibleSalesLead__c';
	@TestVisible private static final String APPROVER_APEXSHARINGREASON = 'Approver__c';
    private static ClaimMemberSharingUtil instance = null;
    public Set<Id> claimMembersToRecalculate {get;private set;}
 
    
    private ClaimMemberSharingUtil(){
        claimMembersToRecalculate = new Set<Id>();
    }
    
    /**
     * Static method to retreive the instance of the class, this ensures there is always only one instance per transaction.
     * @return instance of AccountTeamMemberKeeperHelper.
     * */
    public static ClaimMemberSharingUtil getInstance(){
        if(instance == null) instance = new ClaimMemberSharingUtil();
        return instance;
    }
    
    /**
     * This method stores the current AccountTeamMembers in memory, so they can be inserted later.
     * This method should be called in the before update trigger for each account of which the owner changed.
     * @param accountIds Set of accountIds of which the AccountTeamMembers should be stored.
     * */
    public void storeClaimMember(Set<Id> claimMemberIds){
        claimMembersToRecalculate.addAll(claimMemberIds);
    }
    
    
    /**
     * This method commits (reinserts) the stored AccountTeamMembers.
     * This method should be called in the after update trigger for each account of which the owner changed.
     * @param accountIds Set of accountIds of which the AccountTeamMembers should be reinserted.
     * */
    public void commitClaimMembers(){
        if (claimMembersToRecalculate == null || claimMembersToRecalculate.isEmpty()) {
        	return;
        }
        List<ClaimMembers__c> claimMemberList = [SELECT Id, Account__c, EligibleSalesLead__c, AssignedApproverId__c FROM ClaimMembers__c WHERE Id in: claimMembersToRecalculate];
        Set<Id> accountIds = new Set<Id>();
        for (ClaimMembers__c cm : claimMemberList){
            if (cm.Account__c != null) {
            	accountIds.add(cm.Account__c);
            }
        }
        claimMemberList = [SELECT Id, Account__c, EligibleSalesLead__c, AssignedApproverId__c FROM ClaimMembers__c WHERE Id in: claimMembersToRecalculate OR Account__c in: accountIds];
        Map<String, Map<Id, Map<Id, ClaimMembers__Share>>> oldSharesByReason = getCurrentShares(claimMemberList);
        
        
        Map<Id, Map<Id, ClaimMembers__Share>> cmToOldShareMapSalesLead = oldSharesByReason.get(APEXSHARINGREASON);
        Map<Id, Map<Id, ClaimMembers__Share>> cmToOldShareMapApprover = oldSharesByReason.get(APPROVER_APEXSHARINGREASON);
        Map<Id, Map<Id, ClaimMembers__Share>> cmToNewShareMapSalesLead = getNewShares(claimMemberList);
        Map<Id, Map<Id, ClaimMembers__Share>> cmToNewShareMapApprover = getNewSharesApprovers(claimMemberList);
             
        
        List<ClaimMembers__Share> upsertList = new List<ClaimMembers__Share>(); //Will be populated by cleanseShares method
        List<ClaimMembers__Share> deleteList = new List<ClaimMembers__Share>(); //Will be populated by cleanseShares method
        
        //find difference between the shares and update sharing
        ApexSharingUtils.cleanseShares(cmToOldShareMapSalesLead, cmToNewShareMapSalesLead, upsertList, deleteList);
        ApexSharingUtils.cleanseShares(cmToOldShareMapApprover, cmToNewShareMapApprover, upsertList, deleteList);
        
        
        
        delete deleteList;
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        Database.UpsertResult[] lsr = Database.upsert(upsertList, false);
        
        // Create counter
        Integer i=0;
        
        // Process the save results
        for(Database.UpsertResult sr : lsr){
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default 
                // access level are not allowed. 
                // These sharing records are not required and thus an insert exception is 
                // acceptable. 
                System.debug('Error occured');
                System.debug(err.getStatusCode());
                if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&  err.getMessage().contains('AccessLevel')){
                    //User already has access to this record.
                    
                }
                else if (err.getStatusCode() == StatusCode.INACTIVE_OWNER_OR_USER && err.getMessage().contains('inactive user')){
                    //OPeration performed with inactive user, do nothing.
                }
                else if (err.getStatusCode() == StatusCode.MALFORMED_ID && err.getMessage().contains('id value of incorrect type')){
                    //OPeration performed with incorrect userId, do nothing.
                }
                
                else {
                    // Throw an error when the error is not related to trivial access level.
                    throw new IllegalArgumentException( //any excpetion will do
                        'An error occured during sharing calculation of the ClaimMember with Id: ' + upsertList[i].ParentId + '. Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
                
            }
            i++;
        }   
        
        
        
        
    }
    
    /*
     * get the preferred share records of a SoW records
	 * @param Map<Id, Map<Id, Claim__Share>> Map of claims to Sharing records to be filled by the function
     * @return Map<Id, Map<Id, ClaimMembers__Share>> Map of claimMember to Sharing records
     */
    @TestVisible private Map<Id, Map<Id, ClaimMembers__Share>> getNewSharesApprovers(List<ClaimMembers__c> claimMemberList){
        //Who needs access to this claimMember: This eligible saleslead
        //Eligble saleslead related to the same account.
        //
        //Create map: usersByAccount
        Map<Id, Map<Id, ClaimMembers__Share>> claimMemberToShares = new Map<Id, Map<Id, ClaimMembers__Share>>();
        Map<Id, Set<Id>> usersByAccount = new  Map<Id, Set<Id>>();
        Map<Id, ProcessInstance> processInstanceByClaimMember = new Map<Id, ProcessInstance>();
        List<ProcessInstance> piList;
        if (!String.isBlank(testProcessInstanceJson)){
            piList = (List<ProcessInstance>) JSON.deserialize(testProcessInstanceJson, List<ProcessInstance>.Class);
        }
        else {
          piList = [SELECT Id, TargetObjectId, (SELECT Id, StepStatus, ActorId, OriginalActorId FROM StepsAndWorkitems) from ProcessInstance Where TargetObjectId in: claimMemberList];
        }
        for (ProcessInstance pi : piList){
                processInstanceByClaimMember.put(pi.TargetObjectId, pi);
            }
        //Add 
        for(ClaimMembers__c cm : claimMemberList){
            if (processInstanceByClaimMember.containsKey(cm.Id) && processInstanceByClaimMember.get(cm.Id).StepsAndWorkitems != null) {
                for (ProcessInstanceHistory pih : processInstanceByClaimMember.get(cm.Id).StepsAndWorkitems) {
                    if (cm.Account__c != null) {
                        if (pih.ActorId != null) {
                            if (!usersByAccount.containsKey(cm.Account__c)){
                                usersByAccount.put(cm.Account__c, new Set<Id>());
                            }
                            usersByAccount.get(cm.Account__c).add(pih.ActorId);
                        }
                        
                        if (pih.OriginalActorId != null) {
                            if (!usersByAccount.containsKey(cm.Account__c)){
                                usersByAccount.put(cm.Account__c, new Set<Id>());
                            }
                            usersByAccount.get(cm.Account__c).add(pih.OriginalActorId);
                        }
                    }
                    /*else {//if not an account, but there is an approval process, create a share
                        if (pih.ActorId != null) {
                            if (!claimMemberToShares.containsKey(cm.Id)){
                                claimMemberToShares.put(cm.Id, new Map<Id, ClaimMembers__Share>());
                            }
                            claimMemberToShares.get(cm.Id).put(cm.EligibleSalesLead__c, new ClaimMembers__Share(UserOrGroupId = pih.ActorId, ParentId = cm.Id, AccessLevel = 'Read', RowCause = APPROVER_APEXSHARINGREASON));
                        }
                        if (pih.OriginalActorId != null) {
                            if (!claimMemberToShares.containsKey(cm.Id)){
                                claimMemberToShares.put(cm.Id, new Map<Id, ClaimMembers__Share>());
                            }
                            claimMemberToShares.get(cm.Id).put(cm.EligibleSalesLead__c, new ClaimMembers__Share(UserOrGroupId = pih.OriginalActorId, ParentId = cm.Id, AccessLevel = 'Read', RowCause = APPROVER_APEXSHARINGREASON));
                        }
                    }*/
                }
            }
        }
        //calculate shares based on account
        for(ClaimMembers__c cm : claimMemberList){
            if (cm.Account__c != null && usersByAccount.containsKey(cm.Account__c)){
                for (Id userId : usersByAccount.get(cm.Account__c)){
                    if (!claimMemberToShares.containsKey(cm.Id)){
                        claimMemberToShares.put(cm.Id, new Map<Id, ClaimMembers__Share>());
                    }
                    claimMemberToShares.get(cm.Id).put(userId, new ClaimMembers__Share(UserOrGroupId = userId, ParentId = cm.Id, AccessLevel = 'Read', RowCause = APPROVER_APEXSHARINGREASON));   
                }
            }
        }
        return claimMemberToShares;
    }
    
    /*
     * get the preferred share records of a SoW records
	 * @param Map<Id, Map<Id, Claim__Share>> Map of claims to Sharing records to be filled by the function
     * @return Map<Id, Map<Id, ClaimMembers__Share>> Map of claimMember to Sharing records
     */
    @TestVisible private Map<Id, Map<Id, ClaimMembers__Share>> getNewShares(List<ClaimMembers__c> claimMemberList){
        //Who needs access to this claimMember: This eligible saleslead
        //Eligble saleslead related to the same account.
        //
        //Create map: usersByAccount
        Map<Id, Map<Id, ClaimMembers__Share>> claimMemberToShares = new Map<Id, Map<Id, ClaimMembers__Share>>();
        Map<Id, Set<Id>> usersByAccount = new  Map<Id, Set<Id>>();
        
        //Add 
        for(ClaimMembers__c cm : claimMemberList){
            if (cm.Account__c != null) {
                if (cm.EligibleSalesLead__c != null) {
                    if (!usersByAccount.containsKey(cm.Account__c)){
                        usersByAccount.put(cm.Account__c, new Set<Id>());
                    }
                    usersByAccount.get(cm.Account__c).add(cm.EligibleSalesLead__c);
                }
                if (cm.AssignedApproverId__c != null && (cm.AssignedApproverId__c.length() == 18 || cm.AssignedApproverId__c.length() == 15)) {
                    if (!usersByAccount.containsKey(cm.Account__c)){
                        usersByAccount.put(cm.Account__c, new Set<Id>());
                    }
                	usersByAccount.get(cm.Account__c).add(cm.AssignedApproverId__c);
                }
            }
            //if not an account, but there is an eligbleSaleslead, create a share
            if (cm.Account__c == null){
                if (cm.EligibleSalesLead__c != null){//Add Eligble Sales Lead
                    if (!claimMemberToShares.containsKey(cm.Id)){
                        claimMemberToShares.put(cm.Id, new Map<Id, ClaimMembers__Share>());
                    }
                    claimMemberToShares.get(cm.Id).put(cm.EligibleSalesLead__c, new ClaimMembers__Share(UserOrGroupId = cm.EligibleSalesLead__c, ParentId = cm.Id, AccessLevel = 'Read', RowCause = APEXSHARINGREASON));
                }
                if (cm.AssignedApproverId__c != null && (cm.AssignedApproverId__c.length() == 18 || cm.AssignedApproverId__c.length() == 15)){//Add Assigned Approver
                    if (!claimMemberToShares.containsKey(cm.Id)){
                        claimMemberToShares.put(cm.Id, new Map<Id, ClaimMembers__Share>());
                    }
                    claimMemberToShares.get(cm.Id).put(cm.AssignedApproverId__c, new ClaimMembers__Share(UserOrGroupId = cm.AssignedApproverId__c, ParentId = cm.Id, AccessLevel = 'Read', RowCause = APEXSHARINGREASON));
                }
            }
        }
        //calculate shares based on account
        for(ClaimMembers__c cm : claimMemberList){
            if (cm.Account__c != null && usersByAccount.containsKey(cm.Account__c)){
                for (Id userId : usersByAccount.get(cm.Account__c)){
                    if (!claimMemberToShares.containsKey(cm.Id)){
                        claimMemberToShares.put(cm.Id, new Map<Id, ClaimMembers__Share>());
                    }
                    claimMemberToShares.get(cm.Id).put(userId, new ClaimMembers__Share(UserOrGroupId = userId, ParentId = cm.Id, AccessLevel = 'Read', RowCause = APEXSHARINGREASON));   
                }
            }
        }
        return claimMemberToShares;
    }
    
    
    /*
     * get the current share records of SoW records
     * @param Set<Id> sowIds Ids of SoW records to process
     * @return Map<Id, Map<Id, ClaimMembers__Share>> Map of Sow to Sharing records
     */
    @TestVisible private Map<String, Map<Id, Map<Id, ClaimMembers__Share>>> getCurrentShares(List<ClaimMembers__c> claimMemberList){
        Map<String, Map<Id, Map<Id, ClaimMembers__Share>>> sharesBySharingReason = new Map<String, Map<Id, Map<Id, ClaimMembers__Share>>>();
        //Query ClaimMembers__share information and populate claimMemberToShares
        sharesBySharingReason.put(APEXSHARINGREASON, new Map<Id, Map<Id, ClaimMembers__Share>>());
        sharesBySharingReason.put(APPROVER_APEXSHARINGREASON, new Map<Id, Map<Id, ClaimMembers__Share>>());
        for (ClaimMembers__Share share : [SELECT UserOrGroupId, RowCause, ParentId, Id, AccessLevel FROM ClaimMembers__Share c WHERE ParentId in: claimMemberList AND (RowCause =: APEXSHARINGREASON OR RowCause =: APPROVER_APEXSHARINGREASON)]){
            Map<Id, Map<Id, ClaimMembers__Share>> claimMemberToShares = sharesBySharingReason.get(share.RowCause);
            if (!claimMemberToShares.containsKey(share.ParentId)){
                claimMemberToShares.put(share.ParentId, new Map<Id, ClaimMembers__Share>());
            }
            claimMemberToShares.get(share.ParentId).put(share.UserOrGroupId, share);
        }
        return sharesBySharingReason;
    }
    
    
}