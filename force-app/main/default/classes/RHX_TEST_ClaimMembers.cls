/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_ClaimMembers
*/
@isTest
public class RHX_TEST_ClaimMembers {
	@isTest
	public static void RHX_Testmethod() {
		ClaimMembers__c testClaimMember = (ClaimMembers__c)TestDataFactory.createSObject('ClaimMembers__c');
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testClaimMember);
		Test.startTest();
    	rh2.ParentUtil.UpsertRollupTestRecords(sourceList);
		Test.stopTest();
    }
}