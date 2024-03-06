/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_Claim
*/
@isTest
public class RHX_TEST_Claim {
	@isTest
	public static void RHX_Testmethod() {
		Claim__c testClaim = (Claim__c)TestDataFactory.createSObject('Claim__c');
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testClaim);
		Test.startTest();
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
		Test.stopTest();
    }
}