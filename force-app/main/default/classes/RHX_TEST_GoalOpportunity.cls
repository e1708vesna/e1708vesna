/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_GoalOpportunity
*/
@isTest
public class RHX_TEST_GoalOpportunity {
	@isTest
	public static void RHX_Testmethod() {
		GoalOpportunity__c testGoalOpportunity = (GoalOpportunity__c)TestDataFactory.createSObject('GoalOpportunity__c');
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testGoalOpportunity);
        Test.startTest();
        rh2.ParentUtil.UpsertRollupTestRecords(sourceList);
        Test.stopTest();
    }
}