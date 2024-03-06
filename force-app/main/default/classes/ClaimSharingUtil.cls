public class ClaimSharingUtil {
    @TestVisible private static String testProcessInstanceJson = null;
    @TestVisible private static final String APEXSHARINGREASON = 'EligibleSalesLead__c';
    @TestVisible private static final String APPROVER_APEXSHARINGREASON = 'Approver__c';
    
    private static ClaimSharingUtil instance = null;
    public Set<Id> claimsToRecalculate {get;private set;}
    
    
    private ClaimSharingUtil(){
        claimsToRecalculate = new Set<Id>();
    }
    
    /**
* Static method to retreive the instance of the class, this ensures there is always only one instance per transaction.
* @return instance of AccountTeamMemberKeeperHelper.
* */
    public static ClaimSharingUtil getInstance(){
        if(instance == null) instance = new ClaimSharingUtil();
        return instance;
    }
    
    /**
* This method stores the current AccountTeamMembers in memory, so they can be inserted later.
* This method should be called in the before update trigger for each account of which the owner changed.
* @param accountIds Set of accountIds of which the AccountTeamMembers should be stored.
* */
    public void storeClaims(Set<Id> claimIds){
        claimsToRecalculate.addAll(claimIds);
    }
    
    
    /**
* This method commits (reinserts) the stored AccountTeamMembers.
* This method should be called in the after update trigger for each account of which the owner changed.
* @param accountIds Set of accountIds of which the AccountTeamMembers should be reinserted.
* */
    public void commitClaims(){
        if (claimsToRecalculate == null || claimsToRecalculate.isEmpty()) {
            return;
        }
        Map<Id, Map<Id, Claim__Share>> claimToOldShareMap;
        Map<Id, Map<Id, Claim__Share>> claimToNewShareMap;
        
        
        //Get all Accounts, get all claimmembers, get all eligble salesleads by Account
        List<Claim__c> claimList = [SELECT Id, Account__c FROM Claim__c WHERE Id in : claimsToRecalculate];
        List<ClaimMembers__c> claimMemberList = [SELECT Id, Account__c, EligibleSalesLead__c, AssignedApproverId__c FROM ClaimMembers__c WHERE Account__c in (SELECT Account__c FROM Claim__c WHERE Id in : claimsToRecalculate AND Account__c != null) ];

        
        Map<String, Map<Id, Map<Id, Claim__Share>>> oldSharesByReason = getCurrentSharesClaims(claimsToRecalculate);
        
        
        Map<Id, Map<Id, Claim__Share>> claimToOldShareMapSalesLead = oldSharesByReason.get(APEXSHARINGREASON);
        Map<Id, Map<Id, Claim__Share>> claimToOldShareMapApprover = oldSharesByReason.get(APPROVER_APEXSHARINGREASON);
        Map<Id, Map<Id, Claim__Share>> claimToNewShareMapSalesLead = getNewShares(claimList, claimMemberList);
        Map<Id, Map<Id, Claim__Share>> claimToNewShareMapApprover = getNewSharesApprovers(claimList, claimMemberList);
        
        
        
        List<Claim__Share> upsertList = new List<Claim__Share>(); //Will be populated by cleanseShares method
        List<Claim__Share> deleteList = new List<Claim__Share>(); //Will be populated by cleanseShares method
        
        //find difference between the shares and update sharing
        ApexSharingUtils.cleanseShares(claimToOldShareMapSalesLead, claimToNewShareMapSalesLead, upsertList, deleteList);
        ApexSharingUtils.cleanseShares(claimToOldShareMapApprover, claimToNewShareMapApprover, upsertList, deleteList);
        
        
        
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
* @param Map<Id, Map<Id, Claim__Share>> Map of claims to Sharing records to be filled by the function
* @return Map<Id, Map<Id, ClaimMembers__Share>> Map of claimMember to Sharing records
*/
    @TestVisible private Map<Id, Map<Id, Claim__Share>> getNewSharesApprovers(List<Claim__c> claimList, List<ClaimMembers__c> claimMemberList){
        //Who needs access to this claimMember: This eligible saleslead
        //Eligble saleslead related to the same account.
        //
        //Create map: usersByAccount
        Map<Id, Map<Id, Claim__Share>> claimToShares = new Map<Id, Map<Id, Claim__Share>>();
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
         
        //Add List<ClaimMembers__c> claimMemberList
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
                    else {//if not an account, but there is an approval process and a claim, create a share
                        /*if (pih.ActorId != null && cm.Claim__c != null) {
                            if (!claimMemberToShares.containsKey(cm.Claim__r.Id)){
                                claimMemberToShares.put(cm.Claim__r.Id, new Map<Id, Claim__Share>());
                            }
                            claimMemberToShares.get(cm.Claim__r.Id).put(cm.EligibleSalesLead__c, new Claim__Share(UserOrGroupId = pih.ActorId, ParentId = cm.Claim__r.Id, AccessLevel = 'Read', RowCause = APPROVER_APEXSHARINGREASON));
                            //Can this produce duplicate shares in case of multiple claimmembers related to 1 claim without an account?
                        }*/
                    }
                }
            }
        }
        //calculate shares based on account
        for(Claim__c claim : claimList){
            if (claim.Account__c != null && usersByAccount.containsKey(claim.Account__c)){
                for (Id userId : usersByAccount.get(claim.Account__c)){
                    if (!claimToShares.containsKey(claim.Id)){
                        claimToShares.put(claim.Id, new Map<Id, Claim__Share>());
                    }
                    claimToShares.get(claim.Id).put(userId, new Claim__Share(UserOrGroupId = userId, ParentId = claim.Id, AccessLevel = 'Read', RowCause = APPROVER_APEXSHARINGREASON));   
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
    @TestVisible private static Map<Id, Map<Id, Claim__Share>> getNewShares(List<Claim__c> claimList, List<ClaimMembers__c> claimMemberList){
        
        //get all eligble salesleads by Account
        Map<Id, Set<Id>> usersByAccount = new  Map<Id, Set<Id>>();
        
        //Create a mp of eligbleSalesLead by account 
        for(ClaimMembers__c cm : claimMemberList){
            if (cm.Account__c != null){ 
                if (cm.EligibleSalesLead__c != null) {
                    if (!usersByAccount.containsKey(cm.Account__c)){
                        usersByAccount.put(cm.Account__c, new Set<Id>());
                    }
                    usersByAccount.get(cm.Account__c).add(cm.EligibleSalesLead__c);
                }
                if (cm.AssignedApproverId__c != null && (cm.AssignedApproverId__c.length() == 18 || cm.AssignedApproverId__c.length() == 15)){
                    if (!usersByAccount.containsKey(cm.Account__c)){
                        usersByAccount.put(cm.Account__c, new Set<Id>());
                    }
                    usersByAccount.get(cm.Account__c).add(cm.AssignedApproverId__c);
                }
            }
        }
        
        Map<Id, Map<Id, Claim__Share>> claimToShares = new Map<Id, Map<Id, Claim__Share>>();
        
        For (Claim__c claim : claimList) {
            if(claim.Account__c != null && usersByAccount.containsKey(claim.Account__c)) {
                Set<Id> eligbleSalesLeads = usersByAccount.get(claim.Account__c);
                if (eligbleSalesLeads != null) {
                    for (Id userId : eligbleSalesLeads){
                        if (!claimToShares.containsKey(claim.Id)){
                            claimToShares.put(claim.Id, new Map<Id, Claim__Share>());
                        }
                        if (!claimToShares.get(claim.Id).containsKey(userId)){
                            claimToShares.get(claim.Id).put(userId ,new Claim__share(UserOrGroupId = userId, ParentId = claim.Id, AccessLevel = 'Read', RowCause = APEXSHARINGREASON));
                        }
                    }
                }
            }
        }
        return claimToShares;
    }
    
    
    
    
    /*
* get the current share records of SoW records
* @param Set<Id> sowIds Ids of SoW records to process
* @return Map<Id, Map<Id, Claim__Share>> Map of Sow to Sharing records
*/
    /*@TestVisible private static Map<Id, Map<Id, Claim__Share>> getCurrentSharesClaims(Set<Id> claimIds){
Map<Id, Map<Id, Claim__Share>> claimToShares = new Map<Id, Map<Id, Claim__Share>>();
//Query Claim__share information and populate claimToShares
for (Claim__Share share : [SELECT UserOrGroupId, RowCause, ParentId, Id, AccessLevel FROM Claim__Share c WHERE ParentId in: claimIds AND RowCause =: APEXSHARINGREASON]){
if (claimToShares.containsKey(share.ParentId)){
claimToShares.get(share.ParentId).put(share.UserOrGroupId, share);
}
else {
Map<Id, Claim__Share> userToShareMap = new Map<Id, Claim__Share>();
userToShareMap.put(share.UserOrGroupId, share);
claimToShares.put(share.ParentId, userToShareMap);
}

}
return claimToShares;
}
*/
    /*
* get the current share records of SoW records
* @param Set<Id> sowIds Ids of SoW records to process
* @return Map<Id, Map<Id, Claim__Share>> Map of Sow to Sharing records
*/
    @TestVisible private Map<String, Map<Id, Map<Id, Claim__Share>>> getCurrentSharesClaims(Set<Id> claimIds){
        Map<String, Map<Id, Map<Id, Claim__Share>>> sharesBySharingReason = new Map<String, Map<Id, Map<Id, Claim__Share>>>();
        //Query ClaimMembers__share information and populate claimMemberToShares
        sharesBySharingReason.put(APEXSHARINGREASON, new Map<Id, Map<Id, Claim__Share>>());
        sharesBySharingReason.put(APPROVER_APEXSHARINGREASON, new Map<Id, Map<Id, Claim__Share>>());
        for (Claim__Share share : [SELECT UserOrGroupId, RowCause, ParentId, Id, AccessLevel FROM Claim__Share c WHERE ParentId in: claimIds AND (RowCause =: APEXSHARINGREASON OR RowCause =: APPROVER_APEXSHARINGREASON)]){
            Map<Id, Map<Id, Claim__Share>> claimMemberToShares = sharesBySharingReason.get(share.RowCause);
            if (!claimMemberToShares.containsKey(share.ParentId)){
                claimMemberToShares.put(share.ParentId, new Map<Id, Claim__Share>());
            }
            claimMemberToShares.get(share.ParentId).put(share.UserOrGroupId, share);
        }
        return sharesBySharingReason;
    }
}