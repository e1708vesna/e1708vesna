global class ClaimMemberSharingBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id FROM ClaimMembers__c]);  
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        ClaimMemberSharingUtil utility = ClaimMemberSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        for (sObject e : scope){
            recordIds.add(e.Id);
        }
        utility.storeClaimMember(recordIds);
        utility.commitClaimMembers();
    }
    
    global void finish(Database.BatchableContext BC){
    }
}