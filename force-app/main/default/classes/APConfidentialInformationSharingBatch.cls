global class APConfidentialInformationSharingBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id FROM APConfidentialInformation__c]);  
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Id> recordIds = new Set<Id>();
        for (sObject e : scope){
            recordIds.add(e.Id);
        }
        APConfidentialInformationSharingUtils.insertUpdateDeleteCiShare(recordIds);
    }
    
    global void finish(Database.BatchableContext BC){
    }
}