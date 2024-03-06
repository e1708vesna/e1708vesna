/**
 * @description Test class to verify the correctness of the methods in the class CaseDao.
 * @author BRITE
 */
@isTest
private class CaseDaoTest {
    
    @isTest
    public static void testGetDetails() {
        // case 1a: null check
        List<Case> resultList = CaseDao.getDetails(null);
        system.assertNotEquals(null, resultList, 'Case 1a: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1a: number of results returned');

        // case 1b: empty set check
        resultList = CaseDao.getDetails(new Set<Id> ());
        system.assertNotEquals(null, resultList, 'Case 1b: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1b: number of results returned');
        
        // case 2: known case ID
        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, null, null, true);
        c.Id = '5007E00000D1zwXQAR';
        update c;
        resultList = CaseDao.getDetails(new Set<Id> {c.Id});
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 2: number of results returned');
        
        // case 3: unknown account ID
        resultList = CaseDao.getDetails(new Set<Id> {'5007E01100D1zwXQAR'});
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 3: number of results returned');
    }    

}