/**
 * @description   : UpgradeAssuranceContractItem DAO test class
 * @author (s)    : Brite
 */
@isTest
private class UpgradeAssuranceContractItemDaoTest {
    
    @isTest
    public static void testGetContractItems() {
        List<UpgradeAssuranceContractItem__c> resultList;
        
        // case 1: empty set 
        try {
            resultList = UpgradeAssuranceContractItemDao.getContractItems(new Set<Id>());
            
            system.assertNotEquals(null, resultList, 'Case 1: resultList is null');
            system.assertEquals(0, resultList.size(), 'Case 1: resultList is not empty');
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // case 2: unknown upgrade assurance contract
        resultList = UpgradeAssuranceContractItemDao.getContractItems(new Set<Id> {'a021x0000010N4YAAU'});
        
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 2: resultList is not empty');
        
        // case 3: known contract, but without contract items
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
        resultList = UpgradeAssuranceContractItemDao.getContractItems(new Set<Id> {uac.Id});
        
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 3: resultList is not empty');
        
        // case 4: known contract with contract item
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.today(), null, true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        UpgradeAssuranceContractItem__c uacItem = TestUtil.createUpgradeAssuranceContractItem('contract item', uac.Id, licItem.Id, true);
        
        resultList = UpgradeAssuranceContractItemDao.getContractItems(new Set<Id> {uac.Id});
        
        system.assertNotEquals(null, resultList, 'Case 4: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 4: resultList is not empty');
    }
    
    @isTest
    public static void testGetByLicenseItems() {
        List<UpgradeAssuranceContractItem__c> resultList;
        
        // case 1: empty set
        try {
            resultList = UpgradeAssuranceContractItemDao.getByLicenseItems(new Set<Id> ());
            
            system.assertNotEquals(null, resultList, 'Case 1: resultList is null');
            system.assertEquals(0, resultList.size(), 'Case 1: resultList is not empty');
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // case 2: unknown license item ID
        resultList = UpgradeAssuranceContractItemDao.getByLicenseItems(new Set<Id> {'a021x0000010N4YAAU'});
        
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 2: resultList is not empty');
        
        // case 3: known license item ID
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.today(), null, true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        UpgradeAssuranceContractItem__c uacItem = TestUtil.createUpgradeAssuranceContractItem('contract item', uac.Id, licItem.Id, true);

        resultList = UpgradeAssuranceContractItemDao.getByLicenseItems(new Set<Id> {licItem.Id});
        
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 3: number of results');
    }
    
    @isTest
    public static void testDeleteByLicenseItems() {
        // case 1: empty set 
        try {
            UpgradeAssuranceContractItemDao.deleteByLicenseItems(new Set<Id>());
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // case 2: unknown licenseItem record
        try {
            UpgradeAssuranceContractItemDao.deleteByLicenseItems(new Set<Id> {'a021x0000010N4YAAU'});
        } catch (Exception ex) {
            system.assert(false, 'Case 2: Exception thrown: ' + ex.getMessage());
        }
        
        // case 3: known licenseItem record
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.today(), null, true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        UpgradeAssuranceContractItem__c uacItem = TestUtil.createUpgradeAssuranceContractItem('contract item', uac.Id, licItem.Id, true);
        
        UpgradeAssuranceContractItemDao.deleteByLicenseItems(new Set<Id> {licItem.Id});

        List<UpgradeAssuranceContractItem__c> resultList = [SELECT Id FROM UpgradeAssuranceContractItem__c WHERE LicenseItem__c = :licItem.Id];        
        system.assertEquals(0, resultList.size(), 'Case 3: resultList is not empty');
    }

}