/**
 * @description Test class to verify the correctness of the methods in the class LeadDao.
 * @author BRITE
 */
@isTest
private class LeadDaoTest {
    
    @isTest
    public static void testGetLeadConversionDetails() {
        // case 1a: null check
        List<Lead> resultList = LeadDao.getLeadConversionDetails(null);
        system.assertNotEquals(null, resultList, 'Case 1a: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1a: number of results returned');

        // case 1b: empty set check
        resultList = LeadDao.getLeadConversionDetails(new Set<Id> ());
        system.assertNotEquals(null, resultList, 'Case 1b: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1b: number of results returned');
        
        // case 2: known ID
        Lead ld = TestUtil.createLead();
        
        resultList = LeadDao.getLeadConversionDetails(new Set<Id> {ld.Id});
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 2: number of results returned');
        
        // case 3: unknown ID
        resultList = LeadDao.getLeadConversionDetails(new Set<Id> {'0010Q00000EXvFcQAL'});
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 3: number of results returned');
    }
    
    
}