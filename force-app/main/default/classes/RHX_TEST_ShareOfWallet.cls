/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_ShareOfWallet
*/
@isTest
public class RHX_TEST_ShareOfWallet {
	@isTest
	public static void RHX_Testmethod() {
		Account testAccount = (Account)TestDataFactory.createSObject('Account', new Map<String, Object> {
				'BillingCountry' => 'Colombia'
		});
		AccountPlan__c testAccountPlan = (AccountPlan__c)TestDataFactory.createSObject('AccountPlan__c', new Map<String, Object> {
				'Account__c' => testAccount.Id
		});
		ShareOfWallet__c testShareOfWallet = (ShareOfWallet__c)TestDataFactory.createSObject('ShareOfWallet__c', new Map<String, Object> {
				'AccountPlan__c' => testAccountPlan.Id
				});
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(new ShareOfWallet__c());
        Test.startTest();
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
		Test.stopTest();
    }
}