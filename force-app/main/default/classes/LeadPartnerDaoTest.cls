/**
 * @description Test class to verify the correctness of the methods in the class PartnerDao.
 * @author BRITE
 */
@isTest
private class LeadPartnerDaoTest {
    
    
    @isTest
    public static void testGetPartnerDetailsByLead() {
        // case 1a: null check
        List<LeadPartner__c> resultList = LeadPartnerDao.getDetailsByLead(null);
        system.assertNotEquals(null, resultList, 'Case 1a: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1a: number of results returned');

        // case 1b: empty set check
        resultList = LeadPartnerDao.getDetailsByLead(new Set<Id> ());
        system.assertNotEquals(null, resultList, 'Case 1b: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1b: number of results returned');
        
        // case 2: known account ID
        Lead ld = TestUtil.createLead();
        Account acc = TestUtil.createAccount('partner 1', Constants.RT_ID_ACC_PARTNER_V2, true);
        LeadPartner__c p = new LeadPartner__c(Partner__c = acc.Id, Charity__c = true, Lead__c = ld.Id);
        insert p;
        
        resultList = LeadPartnerDao.getDetailsByLead(new Set<Id> {ld.Id});
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 2: number of results returned');
        
        // case 3: unknown account ID
        resultList = LeadPartnerDao.getDetailsByLead(new Set<Id> {'0010Q00000EXvFcQAL'});
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 3: number of results returned');
    }
    
}