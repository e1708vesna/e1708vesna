@isTest
public class PartnerTypeMergeUtilityTest {

    
    @isTest
    private static void mergeAccounts(){
        //Insert test data
        List<Account> accList = new List<Account>();
        Account masterAcc = TestUtil.createAccount('PartnerAccountMaster', false, false);
        Account slaveAcc = TestUtil.createAccount('PartnerAccountSlave', false, false);
        Account merchAcc1 = TestUtil.createAccount('MerchantAccount1', true, false);
        Account merchAcc2 = TestUtil.createAccount('MerchantAccount2', true, false);
        accList.add(masterAcc);
		accList.add(slaveAcc);
		accList.add(merchAcc1);
		accList.add(merchAcc2);
        insert accList;
        
        List<PartnerType__c> partnerTypes = new List<PartnerType__c>();
        partnerTypes.add(new PartnerType__c(Account__c = masterAcc.Id, Type__c = 'Value Added Service (VAS)', SubType__c = 'Order Management Systems (OMS)'));
        partnerTypes.add(new PartnerType__c(Account__c = slaveAcc.Id, Type__c = 'Value Added Service (VAS)', SubType__c = 'Order Management Systems (OMS)'));
        partnerTypes.add(new PartnerType__c(Account__c = slaveAcc.Id, Type__c = 'Value Added Service (VAS)', SubType__c = 'Tax Calculation'));
        insert partnerTypes;
        List<Relationship__c> relationShips = new List<Relationship__c>();
        relationShips.add(new Relationship__c(Account__c = merchAcc1.Id, PartnerType__c = partnerTypes[0].Id));
        relationShips.add(new Relationship__c(Account__c = merchAcc1.Id, PartnerType__c = partnerTypes[1].Id));
        relationShips.add(new Relationship__c(Account__c = merchAcc2.Id, PartnerType__c = partnerTypes[1].Id));
        insert relationShips;
        
        //Merge master and slave accounts
        merge masterAcc slaveAcc;
        
        List<PartnerType__c> resultingPartnerTypes = [SELECT Id,
                     Account__c,
                     Lead__c,
                     Type__c,
                     SubType__c,
                     UniqueIdentifier__c,
                     (SELECT Id,
                      Account__c,
                      Lead__c,
                      Opportunity__c
                      FROM Relationships__r)
                     FROM PartnerType__c Where Account__c =: masterAcc.Id Or Account__c =: slaveAcc.Id];
        System.assertEquals(2, resultingPartnerTypes.size(), 'Expected 2 PartnerTypes.');
        for (PartnerType__c pt : resultingPartnerTypes){
            system.assertEquals(masterAcc.Id, pt.Account__c);
            if (pt.SubType__c == 'Order Management Systems (OMS)'){
                System.assertEquals(2, pt.Relationships__r.size(), 'Expected 2 Relationship records.');
            }
            else if (pt.SubType__c == 'Tax Calculation'){
                System.assertEquals(0, pt.Relationships__r.size(), 'Expected 2 Relationship records.');
            }
            else {
                System.assert(False); //Should not occur.
            }
        }
    }
    
    @isTest
    private static void mergeLeads(){
        //Insert test data
        List<Lead> ldList = new List<Lead>();
        Lead masterLd = TestUtil.createLead('PartnerLeadMaster', Constants.RT_ID_LEAD_PARTNER, false);
        Lead slaveLd = TestUtil.createLead('PartnerLeadSlave', Constants.RT_ID_LEAD_PARTNER, false);
        ldList.add(masterLd);
		ldList.add(slaveLd);
        insert ldList;
        
        List<PartnerType__c> partnerTypes = new List<PartnerType__c>();
        partnerTypes.add(new PartnerType__c(Lead__c = masterLd.Id, Type__c = 'Value Added Service (VAS)', SubType__c = 'Order Management Systems (OMS)'));
        partnerTypes.add(new PartnerType__c(Lead__c = slaveLd.Id, Type__c = 'Value Added Service (VAS)', SubType__c = 'Order Management Systems (OMS)'));
        partnerTypes.add(new PartnerType__c(Lead__c = slaveLd.Id, Type__c = 'Value Added Service (VAS)', SubType__c = 'Tax Calculation'));
        insert partnerTypes;
        
        //Merge master and slave accounts
        merge masterLd slaveLd;
        
        List<PartnerType__c> resultingPartnerTypes = [SELECT Id,
                     Account__c,
                     Lead__c,
                     Type__c,
                     SubType__c,
                     UniqueIdentifier__c,
                     (SELECT Id,
                      Account__c,
                      Lead__c,
                      Opportunity__c
                      FROM Relationships__r)
                     FROM PartnerType__c Where Lead__c =: masterLd.Id Or Lead__c =: slaveLd.Id];
        System.assertEquals(2, resultingPartnerTypes.size(), 'Expected 2 PartnerTypes.');
        Integer OMSCounter = 0;
        Integer TaxCounter = 0;
        for (PartnerType__c pt : resultingPartnerTypes){
            system.assertEquals(masterLd.Id, pt.Lead__c);
            if (pt.SubType__c == 'Order Management Systems (OMS)'){
                OMSCounter++;
            }
            else if (pt.SubType__c == 'Tax Calculation'){
                taxCounter++;
            }
            else {
                System.assert(False); //Should not occur.
            }
        }
        system.assertEquals(1, OMSCounter);
        system.assertEquals(1, TaxCounter);
    }
}