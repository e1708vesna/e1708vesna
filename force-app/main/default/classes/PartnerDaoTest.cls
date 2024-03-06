/**
 * @description Test class to verify the correctness of the methods in the class PartnerDao.
 * @author BRITE
 */
@isTest
private class PartnerDaoTest {
    
    
    @isTest
    public static void testGetPartnerDetailsByOpportunity() {
        // case 1a: null check
        List<Partner__c> resultList = PartnerDao.getDetailsByOpportunity(null);
        system.assertNotEquals(null, resultList, 'Case 1a: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1a: number of results returned');

        // case 1b: empty set check
        resultList = PartnerDao.getDetailsByOpportunity(new Set<Id> ());
        system.assertNotEquals(null, resultList, 'Case 1b: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1b: number of results returned');
        
        // case 2: known account ID
        Account acc = TestUtil.createAccount('partner 1', Constants.RT_ID_ACC_PARTNER_V2, true);
        Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
        Partner__c p = new Partner__c(Partner__c = acc.Id, isCharity__c = true, Opportunity__c = opp.Id);
        insert p;
        
        resultList = PartnerDao.getDetailsByOpportunity(new Set<Id> {opp.Id});
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 2: number of results returned');
        
        // case 3: unknown account ID
        resultList = PartnerDao.getDetailsByOpportunity(new Set<Id> {'0010Q00000EXvFcQAL'});
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 3: number of results returned');
    }
    
}