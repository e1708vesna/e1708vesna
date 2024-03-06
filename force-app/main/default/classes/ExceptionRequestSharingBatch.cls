global class ExceptionRequestSharingBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id FROM ExceptionRequest__c]);  
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        ExceptionRequestSharingUtil utility = ExceptionRequestSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        for (sObject e : scope){
            recordIds.add(e.Id);
        }
        utility.storeRecords(recordIds);
        utility.commitRecords();
    }
    
    global void finish(Database.BatchableContext BC){
    }
}