@isTest(SeeAllData=true)
public class RHX_TEST_LicenseItem {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM LicenseItem__c LIMIT 1];
        if(sourceList.size() == 0) {
	        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
	        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
	        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
            sourceList.add(
                    new LicenseItem__c(License__c=lic.Id)
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}