public class AmClaimSharingUtil {
    @TestVisible private static String testProcessInstanceJson = null;
    @TestVisible private static final String APEXSHARINGREASON = 'AmClaimSharing__c';
    @TestVisible private static final String APPROVER_APEXSHARINGREASON = 'Approver__c';
    private static AmClaimSharingUtil instance = null;
    public Set<Id> recordsToRecalculate {get;private set;}
    
    
    private AmClaimSharingUtil(){
        recordsToRecalculate = new Set<Id>();
    }
    
    /**
* Static method to retreive the instance of the class, this ensures there is always only one instance per transaction.
* @return instance of AmClaimSharingUtil.
* */
    public static AmClaimSharingUtil getInstance(){
        if(instance == null) instance = new AmClaimSharingUtil();
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
        Map<Id, Map<Id, AMClaim__Share>> recordIdToOldShareMap;
        Map<Id, Map<Id, AMClaim__Share>> recordIdToNewShareMap;
        
        
		Map<String, Map<Id, Map<Id, AMClaim__Share>>> oldSharesByReason = getCurrentShares(recordsToRecalculate);
        
        
        Map<Id, Map<Id, AMClaim__Share>> claimToOldShareMapSalesLead = oldSharesByReason.get(APEXSHARINGREASON);
        Map<Id, Map<Id, AMClaim__Share>> claimToOldShareMapApprover = oldSharesByReason.get(APPROVER_APEXSHARINGREASON);
        Map<Id, Map<Id, AMClaim__Share>> claimToNewShareMapSalesLead = getNewShares(recordsToRecalculate);
        Map<Id, Map<Id, AMClaim__Share>> claimToNewShareMapApprover = getNewSharesApprovers(recordsToRecalculate);
             
        
        List<AMClaim__Share> upsertList = new List<AMClaim__Share>(); //Will be populated by cleanseShares method
        List<AMClaim__Share> deleteList = new List<AMClaim__Share>(); //Will be populated by cleanseShares method
        
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
	 * @param Map<Id, Map<Id, AMClaim__Share>> Map of claims to Sharing records to be filled by the function
     * @return Map<Id, Map<Id, AMClaim__Share>> Map of claimMember to Sharing records
     */
    @TestVisible private Map<Id, Map<Id, AMClaim__Share>> getNewSharesApprovers(Set<Id> recordIds){
        //Who needs access to this claimMember: This eligible saleslead
        //Eligble saleslead related to the same account.
        //
        //Create map: usersByAccount
        Map<Id, Map<Id, AMClaim__Share>> claimToShares = new Map<Id, Map<Id, AMClaim__Share>>();
        Map<Id, ProcessInstance> processInstanceByClaim = new Map<Id, ProcessInstance>();
        List<ProcessInstance> piList;
        if (!String.isBlank(testProcessInstanceJson)){
            piList = (List<ProcessInstance>) JSON.deserialize(testProcessInstanceJson, List<ProcessInstance>.Class);
        }
        else {
          piList = [SELECT Id, TargetObjectId, (SELECT Id, StepStatus, ActorId, OriginalActorId FROM StepsAndWorkitems) from ProcessInstance Where TargetObjectId in: recordIds];
        }
        for (ProcessInstance pi : piList){
                processInstanceByClaim.put(pi.TargetObjectId, pi);
            }
        //Add 
        for(Id claimId : recordIds){
            Set<Id> userIds = new set<Id>();
            if (processInstanceByClaim.containsKey(claimId) && processInstanceByClaim.get(claimId).StepsAndWorkitems != null) {
                for (ProcessInstanceHistory pih : processInstanceByClaim.get(claimId).StepsAndWorkitems) {
                    if (pih.ActorId != null) {
                        userIds.add(pih.ActorId);
                    }
                    
                    if (pih.OriginalActorId != null) {
                        userIds.add(pih.OriginalActorId);
                    }
                }
            }
            for (Id userId : userIds){
                if (!claimToShares.containsKey(claimId)){
                    claimToShares.put(claimId, new Map<Id, AMClaim__Share>());
                }
                claimToShares.get(claimId).put(userId, new AMClaim__Share(UserOrGroupId = userId, ParentId = claimId, AccessLevel = 'Read', RowCause = APPROVER_APEXSHARINGREASON));   
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
    @TestVisible private static Map<Id, Map<Id, AMClaim__Share>> getNewShares(Set<Id> recordIds){
        
        //Get all Accounts, Of that account get all members, get all managers, get all actual approver, get all current approver
        List<AMClaim__c> claimList = [SELECT Id, ActualApproverId__c, AssignedApproverId__c FROM AMClaim__c WHERE Id in : recordIds];
        Map<Id, Map<Id, AMClaim__Share>> recordToShares = new Map<Id, Map<Id, AMClaim__Share>>();
        Map<Id, Set<Id>> usersByRecordId = new Map<Id, Set<Id>>();
        //Create a map of users by account 
        for(AMClaim__c amClaim : claimList){
            if (amClaim.ActualApproverId__c != null) {
                if (!recordToShares.containsKey(amClaim.Id)){
                    recordToShares.put(amClaim.Id, new Map<Id, AMClaim__Share>());
                }
                if (!recordToShares.get(amClaim.Id).containsKey(amClaim.ActualApproverId__c)){
                    recordToShares.get(amClaim.Id).put(amClaim.ActualApproverId__c ,new AMClaim__Share(UserOrGroupId = amClaim.ActualApproverId__c, ParentId = amClaim.Id, AccessLevel = 'Read', RowCause = APEXSHARINGREASON));
                }
            }
            if (amClaim.AssignedApproverId__c != null) {
                if (!recordToShares.containsKey(amClaim.Id)){
                    recordToShares.put(amClaim.Id, new Map<Id, AMClaim__Share>());
                }
                if (!recordToShares.get(amClaim.Id).containsKey(amClaim.AssignedApproverId__c)){
                    recordToShares.get(amClaim.Id).put(amClaim.AssignedApproverId__c ,new AMClaim__Share(UserOrGroupId = amClaim.AssignedApproverId__c, ParentId = amClaim.Id, AccessLevel = 'Read', RowCause = APEXSHARINGREASON));
                }
            }
        }
        return recordToShares;
    }
    
    
    
    /*
     * get the current share records of SoW records
     * @param Set<Id> sowIds Ids of SoW records to process
     * @return Map<Id, Map<Id, AMClaim__Share>> Map of Sow to Sharing records
     */
    @TestVisible private Map<String, Map<Id, Map<Id, AMClaim__Share>>> getCurrentShares(Set<Id> recordIds){
        Map<String, Map<Id, Map<Id, AMClaim__Share>>> sharesBySharingReason = new Map<String, Map<Id, Map<Id, AMClaim__Share>>>();
        //Query ClaimMembers__share information and populate claimMemberToShares
        sharesBySharingReason.put(APEXSHARINGREASON, new Map<Id, Map<Id, AMClaim__Share>>());
        sharesBySharingReason.put(APPROVER_APEXSHARINGREASON, new Map<Id, Map<Id, AMClaim__Share>>());
        for (AMClaim__Share share : [SELECT UserOrGroupId, RowCause, ParentId, Id, AccessLevel FROM AMClaim__Share c WHERE ParentId in: recordIds AND (RowCause =: APEXSHARINGREASON OR RowCause =: APPROVER_APEXSHARINGREASON)]){
            Map<Id, Map<Id, AMClaim__Share>> claimMemberToShares = sharesBySharingReason.get(share.RowCause);
            if (!claimMemberToShares.containsKey(share.ParentId)){
                claimMemberToShares.put(share.ParentId, new Map<Id, AMClaim__Share>());
            }
            claimMemberToShares.get(share.ParentId).put(share.UserOrGroupId, share);
        }
        return sharesBySharingReason;
    }
    
}