@isTest
public class RunAssignmentRules_Test {
    
    @testSetup
    static void loadData(){
        Lead l = new Lead(
            FirstName = 'Jack',
            LastName = 'Test',
            Company = 'Test company BV',
            Country = 'Netherlands',
            RecordTypeId = Constants.RT_ID_LEAD_INBOUND2,
            Title = 'Title',
            SalesChannelSingle__c = 'Ecom',
            Status = 'Open'
        );
        insert l;
    }
    
    @isTest
    static void testLead(){
        //instantiate List to pass to @InvocableMethod
        List<Id> ids = new List<Id>();
        
        //query for test data and add to List
        Lead l = [SELECT Id, OwnerId FROM Lead];
        ids.add(l.Id);
        
        //call @InvocableMethod
        test.startTest();
        RunAssignmentRules.assignLeads(ids);
        test.stopTest();
        
        //verify that Lead was re-assigned
        Lead res = [SELECT Id, OwnerId FROM Lead];
        System.assert(l.OwnerId != res.OwnerId, res);
    }
}