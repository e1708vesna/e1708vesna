/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_Get_Feedback
*/
@isTest
public class RHX_TEST_Get_Feedback {
    @isTest
    public static void RHX_Testmethod() {
        Get_Feedback__c testFeedback = (Get_Feedback__c)TestDataFactory.createSObject('Get_Feedback__c');
        
        List<sObject> sourceList = new List<sObject> ();
        sourceList.add(testFeedback);
        Test.startTest();
        rh2.ParentUtil.UpsertRollupTestRecords(sourceList);
        Test.stopTest();
        }
}