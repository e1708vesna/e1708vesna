@isTest
public class HistoryRelatedListLghtCtrlTest {
    
    @isTest
    private static void getRecordInfoTest(){
        Account acc = TestUtil.createAccount('Test', true, true);
        Opportunity opp = TestUtil.createOpportunity(
            acc.Id,
            UserInfo.getUserId(), true);
        
        insert new OpportunityFieldHistory(OpportunityId = opp.Id, Field = 'Monthly_Volume__c'); //Note: This has to be a field with active history tracking. No lookup field
        
        delete [Select Id From History__c]; //Clear history records that have been created by automation 
        insert new History__c(ParentId__c = opp.Id, RecordId__c = opp.Id, OldValue__c = 'Old');
        insert new History__c(ParentId__c = opp.Id, RecordId__c = opp.Id, OldValue__c = 'Old', ObjectName__c = 'Opportunity Team Member');
        
        insert new OpportunityFieldHistory(OpportunityId = opp.Id, Field = 'Monthly_Volume__c'); //Note: This has to be a field with active history tracking. No lookup field
        
        Map<String, object> returnMap = HistoryRelatedListLghtCtrl.getRecordInfoFiltered(opp.Id, '', false);
        System.assertEquals('Opportunity', returnMap.get('objectName'), 'Object should be of type Opportunity');
        System.assertEquals(2, ((List<object>)returnMap.get('records')).size(), 'Two history records should have been returned');
        
        
        Map<String, object> returnMap2 = HistoryRelatedListLghtCtrl.getRecordInfoFiltered(opp.Id, 'Opportunity Team Member', false);
        System.assertEquals('Opportunity', returnMap2.get('objectName'), 'Object should be of type Opportunity');
        System.assertEquals(1, ((List<object>)returnMap2.get('records')).size(), 'One history record should have been returned');
        
        Map<String, object> returnMap3 = HistoryRelatedListLghtCtrl.getRecordInfoFiltered(opp.Id, 'All', true);
        System.assertEquals(4, ((List<object>)returnMap3.get('records')).size(), 'Four history record should have been returned');
    }
}