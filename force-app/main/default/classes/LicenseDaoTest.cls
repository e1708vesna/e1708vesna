/**
 * @description   : License DAO test class
 * @author (s)    : BRITE
 */
@isTest
private class LicenseDaoTest {
    
    @isTest
    private static void testGetById() {
        List<License__c> resultList;

        // case 1: empty set 
        try {
            resultList = LicenseDao.getById(new Set<Id>());
            
            system.assertNotEquals(null, resultList, 'Case 1: resultList is empty');
            system.assertEquals(0, resultList.size(), 'Case 1: resultList is empty');
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // case 2: unknown license
        resultList = LicenseDao.getById(new Set<Id> {'a021x0000010N4YAAU'});
        
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 2: resultList is not empty');  
        
        // case 3: known license
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', recIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        
        resultList = LicenseDao.getById(new Set<Id> {lic.Id});
        
        system.assertNotEquals(null, resultList, 'Case 4: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 4: resultList is not empty');

        resultList = LicenseDao.getLicenseById(new Set<Id> {lic.Id});
        
        system.assertNotEquals(null, resultList, 'Case 4: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 4: resultList is not empty');
    }
    
    @isTest
    private static void testGetLicenseItems() {
        List<LicenseItem__c> resultList;
        
        // case 1: empty set 
        try {
            resultList = LicenseDao.getLicenseItems(new Set<Id>());
            
            system.assertNotEquals(null, resultList, 'Case 1: resultList is null');
            system.assertEquals(0, resultList.size(), 'Case 1: resultList is not empty');
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // case 2: unknown license
        resultList = LicenseDao.getLicenseItems(new Set<Id> {'a021x0000010N4YAAU'});
        
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 2: resultList is not empty');
        
        // case 3: known license, but without license items
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', recIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        
        resultList = LicenseDao.getLicenseItems(new Set<Id> {lic.Id});
        
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 3: resultList is not empty');
        
        // case 4: known license with license item
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.today(), null, true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        
        resultList = LicenseDao.getLicenseItems(new Set<Id> {lic.Id});
        
        system.assertNotEquals(null, resultList, 'Case 4: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 4: resultList is not empty');
    }

    @isTest
    private static void testGetByChannelPartner() {
        List<License__c> resultList;

        // create test data
        Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());
        Account channelPartnerAcc = new Account(Name = 'channelpartner', RecordTypeId = recIdChannelPartner);
        Account endCustomerAcc = new Account(Name = 'endCustomer', RecordTypeId = recIdEndCustomer);
		insert new List<Account> {channelPartnerAcc, endCustomerAcc};

        License__c lic = TestUtil.createLicense('lic1001', endCustomerAcc.Id, false);
        lic.ChannelPartner__c = channelPartnerAcc.Id;
        insert lic;
        
        // case 1: empty set 
        try {
            resultList = LicenseDao.getByChannelPartner(new Set<Id>());
            
            system.assertNotEquals(null, resultList, 'Case 1: resultList is null');
            system.assertEquals(0, resultList.size(), 'Case 1: resultList is not empty');
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // case 2: unknown channel partner
        resultList = LicenseDao.getByChannelPartner(new Set<Id> {'a021x0000010N4YAAU'});
        
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 2: resultList is not empty');
        
        // case 3: known channel partner
        resultList = LicenseDao.getByChannelPartner(new Set<Id> {channelPartnerAcc.Id});
        
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 3: resultList is not empty');
    }

    @isTest
    private static void testGetByIdWithUACDetails() {
        List<License__c> resultList;

        // create test data
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());
        Id rtIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName(UpgradeAssuranceContractHelper.RT_DEV_NAME_PENDING_CONTRACT, UpgradeAssuranceContract__c.getSObjectType());
        
        Account endCustomerAcc = TestUtil.createAccount('endCustomer', recIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', endCustomerAcc.Id, true);

        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(rtIdPendingContract, lic.Id, false);
        uac.StartDate__c = Date.newInstance(Date.today().year(), 1, 1);
        uac.StartDateLine__c = uac.StartDate__c;
        uac.CombinedBillingAmount__c = 150;
        insert uac;

        resultList = LicenseDao.getByIdWithUACDetails(new Set<Id> {lic.Id});
        lic = resultList[0];
        System.assertEquals(1, lic.UpgradeAssurances__r.size(), 'Before activation: Number of linked upgrade assurance contracts');
        System.assertEquals(0, lic.TotalUACValue__c, 'Before activation: TotalUACValue__c');
        System.assertEquals(1, lic.NumberOpenUACs__c, 'Before activation: NumberOpenUACs__c');

        // activate UAC
        Id activatedContractRt = RecordTypeUtil.getRecordTypeIdByDevName(UpgradeAssuranceContractHelper.RT_DEV_NAME_ACTIVATED_CONTRACT, UpgradeAssuranceContract__c.getSObjectType());
        uac.Stage__c = 'Order';
        uac.RecordTypeId = activatedContractRt;
        uac.Approved__c = true;
        uac.RequestUnlock__c = !uac.RequestUnlock__c;
        update uac;

        resultList = LicenseDao.getByIdWithUACDetails(new Set<Id> {lic.Id});
        lic = resultList[0];
        System.assertEquals(1, lic.UpgradeAssurances__r.size(), 'After activation: Number of linked upgrade assurance contracts');
        System.assertEquals(150, lic.TotalUACValue__c, 'After activation: TotalUACValue__c');
        System.assertEquals(0, lic.NumberOpenUACs__c, 'After activation: NumberOpenUACs__c');

        uac = lic.UpgradeAssurances__r[0];
        System.assertEquals(150, uac.CombinedBillingAmount__c, 'CombinedBillingAmount__c on Upgrade Assurance Contract');
    }
    
}