/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_AdditionalProduct
*/
@isTest
public class RHX_TEST_AdditionalProduct {
	@isTest
	public static void RHX_Testmethod() {
		AdditionalProduct__c testAdditionalProduct = (AdditionalProduct__c)TestDataFactory.createSObject('AdditionalProduct__c');
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testAdditionalProduct);
		Test.startTest();
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
		Test.stopTest();
    }
}