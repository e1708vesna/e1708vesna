/**
 * @description   : UpgradeAssuranceContract DAO test class
 * @author (s)    : Brite
 */
@isTest
private class UpgradeAssuranceContractDaoTest {
    
    @isTest
    public static void testGetByLicenseId() {
        List<UpgradeAssuranceContract__c> resultList;
        
        // case 1: empty set 
        try {
            resultList = UpgradeAssuranceContractDao.getByLicenseId(new Set<Id>());
            
            system.assertNotEquals(null, resultList, 'Case 1: resultList is null');
            system.assertEquals(0, resultList.size(), 'Case 1: resultList is not empty');
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // case 2: unknown upgrade assurance contract
        resultList = UpgradeAssuranceContractDao.getByLicenseId(new Set<Id> {'a021x0000010N4YAAU'});
        
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 2: resultList is not empty');
        
        // case 3: known contract
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
        resultList = UpgradeAssuranceContractDao.getByLicenseId(new Set<Id> {lic.Id});
        
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 3: resultList is not empty');
    }
    
}