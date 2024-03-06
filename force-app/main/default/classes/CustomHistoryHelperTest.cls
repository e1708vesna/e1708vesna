@isTest
public class CustomHistoryHelperTest {

    @isTest static void deleteAndUndeleteCustomHistory() {
		Lead ld = TestUtil.createLead();
        History__c h = new History__c(ParentId__c = ld.Id, RecordId__c = ld.Id, NewValue__c = 'New', OldValue__c = 'old', fieldName__c = 'TestField');
        insert h;
        System.assertEquals(1, [SELECT Id FROM History__c WHERE ParentId__c =: ld.Id].size());
        CustomHistoryHelper.deleteRelatedCustomHistory(new List<Lead>{ld});
        System.assertEquals(0, [SELECT Id FROM History__c WHERE ParentId__c =: ld.Id].size());
        CustomHistoryHelper.undeleteRelatedCustomHistory(new List<Lead>{ld});
        System.assertEquals(1, [SELECT Id FROM History__c WHERE ParentId__c =: ld.Id].size());
	}
}