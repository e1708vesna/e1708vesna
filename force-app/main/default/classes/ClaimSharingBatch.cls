global class ClaimSharingBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id FROM Claim__c]);  
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        ClaimSharingUtil utility = ClaimSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        for (sObject e : scope){
            recordIds.add(e.Id);
        }
        utility.storeClaims(recordIds);
        utility.commitClaims();
    }
    
    global void finish(Database.BatchableContext BC){
    }
}