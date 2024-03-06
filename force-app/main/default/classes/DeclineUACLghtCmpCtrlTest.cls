/**
 * @description   : Account DAO test class
 * @author (s)    : Brite
 */
@isTest
private class DeclineUACLghtCmpCtrlTest {

	@isTest
	private static void declineUACTest() {
        Integer thisYear = Date.today().Year();
        
        // case 1: Create UpgradeAssuranceContract
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        //Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        
        //primary test data
        License__c lic = TestUtil.createLicense('lic1002', acc.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear,1,1), Date.newInstance(thisYear,12,31), true);
        MSRP__c msrp2 = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear+1,1,1), Date.newInstance(thisYear+1,12,31), true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(rtIdClonedContract, lic.Id, false);
        uac.AdditionalConditions__c = false;
        uac.StartDate__c = Date.newInstance(uac.StartDate__c.year(), uac.StartDate__c.month(), 1);

        insert uac;

        Test.startTest();
        system.assertEquals(false, DeclineUACLghtCmpCtrl.isDeclined(uac.Id), 'Case 1: Not declined yet');
        
        DeclineUACLghtCmpCtrl.declineUAC(uac.Id, true);

        system.assertEquals(true, DeclineUACLghtCmpCtrl.isDeclined(uac.Id), 'Case 2: Should be declined');
        UpgradeAssuranceContract__c uacTmp = DeclineUACLghtCmpCtrl.getUac(uac.Id);
        system.assertEquals(true, uacTmp.Declined__c, 'Case 2: Should be declined');

        Test.stopTest();
    }

	@isTest
	private static void declineNotAllowedUACTest() {
        Integer thisYear = Date.today().Year();
        
        // case 1: Create UpgradeAssuranceContract
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        //Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        
        //primary test data
        License__c lic = TestUtil.createLicense('lic1002', acc.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear,1,1), Date.newInstance(thisYear,12,31), true);
        MSRP__c msrp2 = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear+1,1,1), Date.newInstance(thisYear+1,12,31), true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(rtIdClonedContract, lic.Id, false);
        uac.AdditionalConditions__c = false;
        uac.StartDate__c = Date.newInstance(uac.StartDate__c.year(), uac.StartDate__c.month(), 1);
        uac.EndDate__c = Date.newInstance(uac.StartDate__c.year() + 1, uac.StartDate__c.month(), 1);
        insert uac;

        Test.startTest();
        system.assertEquals(false, DeclineUACLghtCmpCtrl.isDeclined(uac.Id), 'Case 1: Not declined yet');
        
        DeclineUACLghtCmpCtrl.declineUAC(uac.Id, true);

        system.assertEquals(false, DeclineUACLghtCmpCtrl.isDeclined(uac.Id), 'Case 2: Cannot be declined');

        Test.stopTest();
    }

}