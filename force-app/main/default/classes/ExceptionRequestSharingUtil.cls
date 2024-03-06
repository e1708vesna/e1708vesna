public class ExceptionRequestSharingUtil {
    @TestVisible private static String testProcessInstanceJson = null;
    @TestVisible private static final String APEXSHARINGREASON = 'ExceptionRequestSharing__c';
    @TestVisible private static final String APPROVER_APEXSHARINGREASON = 'Approver__c';
    private static ExceptionRequestSharingUtil instance = null;
    public Set<Id> recordsToRecalculate {get;private set;}
    
    
    private ExceptionRequestSharingUtil(){
        recordsToRecalculate = new Set<Id>();
    }
    
    /**
* Static method to retreive the instance of the class, this ensures there is always only one instance per transaction.
* @return instance of ExceptionRequestSharingUtil.
* */
    public static ExceptionRequestSharingUtil getInstance(){
        if(instance == null) instance = new ExceptionRequestSharingUtil();
        return instance;
    }
    
    /**
* This method stores the current AccountTeamMembers in memory, so they can be inserted later.
* This method should be called in the before update trigger for each account of which the owner changed.
* @param accountIds Set of accountIds of which the AccountTeamMembers should be stored.
* */
    public void storeRecords(Set<Id> recordIds){
        recordsToRecalculate.addAll(recordIds);
    }
    
    
    /**
* This method commits (reinserts) the stored AccountTeamMembers.
* This method should be called in the after update trigger for each account of which the owner changed.
* @param accountIds Set of accountIds of which the AccountTeamMembers should be reinserted.
* */
    public void commitRecords(){
        if (recordsToRecalculate == null || recordsToRecalculate.isEmpty()) {
        	return;
        }
        
        
        List<ExceptionRequest__c> originalRequestList = [SELECT Id, Account__c FROM ExceptionRequest__c WHERE Id in : recordsToRecalculate];
        Set<Id> accountIds = new Set<Id>();
        for (ExceptionRequest__c er : originalRequestList){
            if (er.Account__c != null){
                accountIds.add(er.Account__c);
            }
        }
        List<ExceptionRequest__c> totalRequestList = [SELECT ID, Account__c, ActualApproverId__c, AssignedApproverId__c, (SELECT Id, User__c, User__r.ManagerId FROM ExceptionRequestMembers__r) FROM ExceptionRequest__c WHERE Account__c in: accountIds];
        Map<String, Map<Id, Map<Id, ExceptionRequest__Share>>> oldSharesByReason = getCurrentShares(recordsToRecalculate);
        Map<Id, Map<Id, ExceptionRequest__Share>> erToOldShareMapSalesLead = oldSharesByReason.get(APEXSHARINGREASON);
        Map<Id, Map<Id, ExceptionRequest__Share>> erToOldShareMapApprover = oldSharesByReason.get(APPROVER_APEXSHARINGREASON);
        Map<Id, Map<Id, ExceptionRequest__Share>> erToNewShareMapSalesLead = getNewShares(originalRequestList, totalRequestList);
        Map<Id, Map<Id, ExceptionRequest__Share>> erToNewShareMapApprover = getNewSharesApprovers(originalRequestList, totalRequestList);
        
        
        
        
        List<ExceptionRequest__Share> upsertList = new List<ExceptionRequest__Share>(); //Will be populated by cleanseShares method
        List<ExceptionRequest__Share> deleteList = new List<ExceptionRequest__Share>(); //Will be populated by cleanseShares method
        
        //find difference between the shares and update sharing
        ApexSharingUtils.cleanseShares(erToOldShareMapSalesLead, erToNewShareMapSalesLead, upsertList, deleteList);
        ApexSharingUtils.cleanseShares(erToOldShareMapApprover, erToNewShareMapApprover, upsertList, deleteList);
        
        
        
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
                if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&  err.getMessage().contains('AccessLevel')){
                    //User already has access to this record.
                    
                }
                else if (err.getStatusCode() == StatusCode.INACTIVE_OWNER_OR_USER && err.getMessage().contains('inactive user')){
                    //OPeration performed with inactive user, do nothing.
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
                         'An error occured during sharing calculation of the Claim with Id: ' + upsertList[i].ParentId + '. Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            i++;
        }   
        
        
        
        
    }
    
    
    /*
     * get the preferred share records of a SoW records
	 * @param Map<Id, Map<Id, ExceptionRequest__Share>> Map of claims to Sharing records to be filled by the function
     * @return Map<Id, Map<Id, ExceptionRequest__Share>> Map of claimMember to Sharing records
     */
    @TestVisible private Map<Id, Map<Id, ExceptionRequest__Share>> getNewSharesApprovers(List<ExceptionRequest__c> originalRequestList, List<ExceptionRequest__c> totalRequestList){
        //Who needs access to this claimMember: This eligible saleslead
        //Eligble saleslead related to the same account.
        //
        //Create map: usersByAccount
        Map<Id, Map<Id, ExceptionRequest__Share>> claimToShares = new Map<Id, Map<Id, ExceptionRequest__Share>>();
        Map<Id, ProcessInstance> processInstanceByClaim = new Map<Id, ProcessInstance>();
        Map<Id, Set<Id>> usersByAccount = new  Map<Id, Set<Id>>();
        List<ProcessInstance> piList;
        if (!String.isBlank(testProcessInstanceJson)){
            piList = (List<ProcessInstance>) JSON.deserialize(testProcessInstanceJson, List<ProcessInstance>.Class);
        }
        else {
          piList = [SELECT Id, TargetObjectId, (SELECT Id, StepStatus, ActorId, OriginalActorId FROM StepsAndWorkitems) from ProcessInstance Where TargetObjectId in: totalRequestList];
        }
        for (ProcessInstance pi : piList){
                processInstanceByClaim.put(pi.TargetObjectId, pi);
            }
        //Add 
        for(ExceptionRequest__c request : totalRequestList){
            Set<Id> userIds = new set<Id>();
            if (processInstanceByClaim.containsKey(request.Id) && processInstanceByClaim.get(request.Id).StepsAndWorkitems != null) {
                for (ProcessInstanceHistory pih : processInstanceByClaim.get(request.Id).StepsAndWorkitems) {
                    if (pih.ActorId != null) {
                        if (!usersByAccount.containsKey(request.Account__c)){
                            usersByAccount.put(request.Account__c, new Set<Id>());
                        }
                        usersByAccount.get(request.Account__c).add(pih.ActorId);
                    }
                    
                    if (pih.OriginalActorId != null) {
                        if (!usersByAccount.containsKey(request.Account__c)){
                            usersByAccount.put(request.Account__c, new Set<Id>());
                        }
                        usersByAccount.get(request.Account__c).add(pih.OriginalActorId);
                    }
                }
            }
            
        } //calculate shares based on account
        
        
        
        for(ExceptionRequest__c request : originalRequestList){
            if (request.Account__c != null && usersByAccount.containsKey(request.Account__c)){
                Set<Id> usersWithAccess = usersByAccount.get(request.Account__c);
                if (usersWithAccess != null) {
                    for (Id userId : usersWithAccess){
                        if (!claimToShares.containsKey(request.Id)){
                            claimToShares.put(request.Id, new Map<Id, ExceptionRequest__Share>());
                        }
                        if (!claimToShares.get(request.Id).containsKey(userId)){
                            claimToShares.get(request.Id).put(userId ,new ExceptionRequest__Share(UserOrGroupId = userId, ParentId = request.Id, AccessLevel = 'Read', RowCause = APPROVER_APEXSHARINGREASON));
                        }  
                    }
                }
            }
        }
        return claimToShares;
    }
        
        /*
* get the preferred share records of a SoW records
* @param Set<Id> claim Ids of Claim records to process
* @param Map<Id, Map<Id, Claim__Share>> Map of claims to Sharing records to be filled by the function
* @return Map<Id, Map<Id, Claim__Share>> Map of claimMember to Sharing records
*/
    @TestVisible private static Map<Id, Map<Id, ExceptionRequest__Share>> getNewShares(List<ExceptionRequest__c> originalRequestList, List<ExceptionRequest__c> totalRequestList){
        
        Map<Id, Set<Id>> usersByAccount = new  Map<Id, Set<Id>>();
        Map<Id, Map<Id, ExceptionRequest__Share>> recordToShares = new Map<Id, Map<Id, ExceptionRequest__Share>>();
        
        //Create a map of users by account 
        for(ExceptionRequest__c eRequest : totalRequestList){
            if (eRequest.Account__c != null){ 
                if (eRequest.ActualApproverId__c != null) {
                    if (!usersByAccount.containsKey(eRequest.Account__c)){
                        usersByAccount.put(eRequest.Account__c, new Set<Id>());
                    }
                    usersByAccount.get(eRequest.Account__c).add(eRequest.ActualApproverId__c);
                }
                if (eRequest.AssignedApproverId__c != null) {
                    System.debug('AssignedApprover found: ' + eRequest.AssignedApproverId__c);
                    if (!usersByAccount.containsKey(eRequest.Account__c)){
                        usersByAccount.put(eRequest.Account__c, new Set<Id>());
                    }
                    usersByAccount.get(eRequest.Account__c).add(eRequest.AssignedApproverId__c);
                }
                for (ExceptionRequestMember__c erMember : eRequest.ExceptionRequestMembers__r){
                    if (erMember.User__c != null) {
                        if (!usersByAccount.containsKey(eRequest.Account__c)){
                            usersByAccount.put(eRequest.Account__c, new Set<Id>());
                        }
                        usersByAccount.get(eRequest.Account__c).add(erMember.User__c);
                        
                        if (erMember.User__r.ManagerId != null) {
                            if (!usersByAccount.containsKey(eRequest.Account__c)){
                                usersByAccount.put(eRequest.Account__c, new Set<Id>());
                            }
                            usersByAccount.get(eRequest.Account__c).add(erMember.User__r.ManagerId);
                        }
                    }
                    
                }
            }
        }
        For (ExceptionRequest__c eRequest : originalRequestList) {
            if(eRequest.Account__c != null && usersByAccount.containsKey(eRequest.Account__c)) {
                Set<Id> usersWithAccess = usersByAccount.get(eRequest.Account__c);
                if (usersWithAccess != null) {
                    for (Id userId : usersWithAccess){
                        if (!recordToShares.containsKey(eRequest.Id)){
                            recordToShares.put(eRequest.Id, new Map<Id, ExceptionRequest__Share>());
                        }
                        if (!recordToShares.get(eRequest.Id).containsKey(userId)){
                            recordToShares.get(eRequest.Id).put(userId ,new ExceptionRequest__Share(UserOrGroupId = userId, ParentId = eRequest.Id, AccessLevel = 'Read', RowCause = APEXSHARINGREASON));
                        }
                    }
                }
            }
        }
        return recordToShares;
    }
    
    
    
    /*
     * get the current share records of SoW records
     * @param Set<Id> sowIds Ids of SoW records to process
     * @return Map<Id, Map<Id, ExceptionRequest__Share>> Map of Sow to Sharing records
     */
    @TestVisible private Map<String, Map<Id, Map<Id, ExceptionRequest__Share>>> getCurrentShares(Set<Id> recordIds){
        Map<String, Map<Id, Map<Id, ExceptionRequest__Share>>> sharesBySharingReason = new Map<String, Map<Id, Map<Id, ExceptionRequest__Share>>>();
        //Query ClaimMembers__share information and populate claimMemberToShares
        sharesBySharingReason.put(APEXSHARINGREASON, new Map<Id, Map<Id, ExceptionRequest__Share>>());
        sharesBySharingReason.put(APPROVER_APEXSHARINGREASON, new Map<Id, Map<Id, ExceptionRequest__Share>>());
        for (ExceptionRequest__Share share : [SELECT UserOrGroupId, RowCause, ParentId, Id, AccessLevel FROM ExceptionRequest__Share c WHERE ParentId in: recordIds AND (RowCause =: APEXSHARINGREASON OR RowCause =: APPROVER_APEXSHARINGREASON)]){
            Map<Id, Map<Id, ExceptionRequest__Share>> claimMemberToShares = sharesBySharingReason.get(share.RowCause);
            if (!claimMemberToShares.containsKey(share.ParentId)){
                claimMemberToShares.put(share.ParentId, new Map<Id, ExceptionRequest__Share>());
            }
            claimMemberToShares.get(share.ParentId).put(share.UserOrGroupId, share);
        }
        return sharesBySharingReason;
    }
}