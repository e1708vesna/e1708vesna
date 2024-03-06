/**
 * @description Test class to verify the correctness of the methods in the class AccountDao.
 * @author BRITE
 */
@isTest
private class AccountDaoTest {
    
    @isTest
    public static void testGetDetails() {
        // case 1a: null check
        List<Account> resultList = AccountDao.getDetails(null);
        system.assertNotEquals(null, resultList, 'Case 1a: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1a: number of results returned');

        // case 1b: empty set check
        resultList = AccountDao.getDetails(new Set<Id> ());
        system.assertNotEquals(null, resultList, 'Case 1b: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1b: number of results returned');
        
        // case 2: known account ID
        Account acc = TestUtil.createAccount('Test acc', true, true);
        resultList = AccountDao.getDetails(new Set<Id> {acc.Id});
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 2: number of results returned');
        
        // case 3: unknown account ID
        resultList = AccountDao.getDetails(new Set<Id> {'0010Q00000EXvFcQAL'});
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 3: number of results returned');
    }
}