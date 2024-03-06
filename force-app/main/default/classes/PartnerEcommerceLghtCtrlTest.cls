@isTest
public class PartnerEcommerceLghtCtrlTest {

    @isTest
    private static void testInit(){
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(TestUtil.createAccount('Found1', Constants.RT_ID_ACC_PARTNER_V2, False));
        testAccounts.add(TestUtil.createAccount('Found2', Constants.RT_ID_ACC_PARTNER_V2, False));
        testAccounts.add(TestUtil.createAccount('Existing', Constants.RT_ID_ACC_PARTNER_V2, False));
        testAccounts[0].Platform__c = true;
        testAccounts[2].Platform__c = true;
        insert testAccounts;
        
        List<EcomAccountMapping__c> mapping = new List<EcomAccountMapping__c>();
        mapping.add( new EcomAccountMapping__c(Name = 'Found1', PartnerName__c = 'Found1', AccountId__c = testAccounts[0].Id));
        mapping.add( new EcomAccountMapping__c(Name = 'Found1v2', PartnerName__c = 'Found1v2', AccountId__c = testAccounts[0].Id));
        mapping.add( new EcomAccountMapping__c(Name = 'Found2', PartnerName__c = 'Found2', AccountId__c = testAccounts[1].Id));
        mapping.add( new EcomAccountMapping__c(Name = 'NotFound1', PartnerName__c = 'NotFound1', AccountId__c = 'N/A'));
        mapping.add( new EcomAccountMapping__c(Name = 'Existing', PartnerName__c = 'Existing', AccountId__c = testAccounts[2].Id));
        insert mapping;
        
        Lead ld = TestUtil.createLead ('lead', Constants.RT_ID_LEAD_INBOUND2, false);
        ld.ECOMMERCE_PLATFORM__c = 'Found1;Found2;NotFound1;NotFound2;Existing';
        ld.POS_Software__c = 'Found1v2;Found2;NotFound1;NotFound2;Existing';
        insert ld;
        
        delete [Select Id From LeadPartner__c]; //Remove the partners that where created by the Lead Trigger
        insert new LeadPartner__c(Lead__c = ld.Id, Partner__c = testAccounts[2].Id, Platform__c = true);
        
        PartnerEcommerceLghtCtrl.WrapperClass wc = PartnerEcommerceLghtCtrl.getEcommercePartnerss(ld.Id);
        
        System.debug('partnerData size: ' + wc.partnerData.size());
        System.assertEquals(2, wc.partnerData.size());
        System.debug('partnersNotFound size: ' + wc.partnersNotFound.size());
        System.assertEquals(2, wc.partnersNotFound.size());
        System.debug('partnersExisting size: ' + wc.partnersExisting.size());
        System.assertEquals(1, wc.partnersExisting.size());
    }
    
    @isTest
    private static void upsertPartners(){
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(TestUtil.createAccount('Found1', Constants.RT_ID_ACC_PARTNER_V2, False));
        testAccounts.add(TestUtil.createAccount('Found2', Constants.RT_ID_ACC_PARTNER_V2, False));
        testAccounts.add(TestUtil.createAccount('Existing', Constants.RT_ID_ACC_PARTNER_V2, False));
        testAccounts[0].Platform__c = true;
        testAccounts[2].Platform__c = true;
        insert testAccounts;
        
        Lead ld = TestUtil.createLead ('lead', Constants.RT_ID_LEAD_INBOUND2, false);
        insert ld;
        insert new LeadPartner__c(Lead__c = ld.Id, Partner__c = testAccounts[2].Id, Charity__c = true);
        
        String recordId = ld.Id;
        List<Map<String, Object>> accList = new List<Map<String, Object>>();
        accList.add(new Map<String, Object>{
            'accountId' => testAccounts[0].Id
                }
                   );
        accList.add(new Map<String, Object>{
            'accountId' => testAccounts[2].Id
                }
                   );
        
        PartnerEcommerceLghtCtrl.insertPartners(recordId, accList);
        
    }
}