public with sharing class CaseCtrlVesnaTest {
    
    @AuraEnabled(Cacheable=true)
    public static List<Case> getActiveCases() {
         
        List<Case> records = [SELECT Id, Subject, Description, Priority, Origin, Status, Type, SubType__c, ServiceTopic__c, OwnerId
                             FROM Case
                             WHERE Status != 'Completed'];

        System.debug(records);
        return records;
    }
}