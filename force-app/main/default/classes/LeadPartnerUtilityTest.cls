@isTest
public class LeadPartnerUtilityTest {
/*
    
    @testSetup
    private static void testSetup(){
        PermissionSet ps = new PermissionSet(Label = 'EditReferralOnLeadPermissionSet', Name = 'EditReferralOnLeadPermissionSet');
        insert ps;
        System.debug(ps.Id);
        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = [SELECT Id FROM CustomPermission
            WHERE DeveloperName = 'EditReferralOnLead'][0].Id
        );
        insert sea;
        
        // Given mocked Permission Set assigned to user for test
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = UserInfo.getUserId(),
            PermissionSetId = ps.Id
        );
        insert psa;
    }
    //Scenarios
    //*1.0 Add Referral on Lead -> Partner Created
    //*1.1 Referral on Lead -> Partner updated
    //*2.1 Clear Referral on Lead -> Referral checkbox should be cleared
    //*2.2 Clear Referral on Lead -> Referral checkbox should be cleared, partner deleted -> Because it is the only checkbox.
    //*3.1 Change Referral on Lead -> Referral checkbox should be cleared, Partner Created, Partner Update
    //*3.2 Change Referral on Lead -> Referral checkbox should be cleared, Partner Created, partner deleted -> Because it is the only checkbox.
    //*3.3 Change Referral on Lead -> Referral checkbox should be cleared, Partner Updated, partner deleted -> Because it is the only checkbox.
    //*3.4 Change Referral on Lead -> Referral checkbox should be cleared, Partner Updated, Partner update
    //*4 Clear Referral on Partner -> Referral on Lead should be cleared
    //*5 Create new Referral on Partner -> Referral on Lead should be changed
    
    @isTest
    private static void addReferralOnLead (){
        System.runAs(new User(Id = UserInfo.getUserId())){
            Account Partner1 = TestUtil.createAccount('partner 1', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account Partner2 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account acc = TestUtil.createAccount('TestAccount', Constants.RT_ID_ACC_PROSPECT_V2, false);
            List<Account> accList = new List<Account>();
            accList.add(Partner1);
            accList.add(Partner2);
            accList.add(acc);
            setPartnerCheckboxes(accList);
            insert accList;
            
        	Contact partnerContact1 = TestUtil.createContact('PartnerContact1', 'partner@example.com', Partner1.Id, true);
        	Contact partnerContact2 = TestUtil.createContact('Partner2Contact', 'partner@exampleeeee.com', Partner2.Id, true);
            Lead ld = createLead(Partner1.Id, partnerContact1.Id);
            
            
            //Scenario 1.0 Add Referral on Lead -> Partner Created
            ld.Partner_Referral__c = Partner1.Id;
            ld.PartnerContact__c = partnerContact1.Id;
            System.assertEquals([SELECT ID, AccountId FROM Contact Where Id =: partnerContact1.Id][0].AccountId, Partner1.Id);
            update ld;
            List<LeadPartner__c> partnerList = [Select Id, Partner__c, Referral__c From LeadPartner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].Referral__c);
            
            
            //Scenario 2.2 Clear Referral on Lead -> Referral checkbox should be cleared, partner deleted -> Because it is the only checkbox.
            ld.Partner_Referral__c = null;
            ld.PartnerContact__c = null;
            update ld;
            partnerList = [Select Id, Referral__c From LeadPartner__c];
            System.assertEquals(0, partnerList.size());
            
            
            
            
            //Scenario 1.1 Referral on Lead -> Partner updated
            LeadPartner__c partner = new LeadPartner__c(Partner__c = Partner2.Id, Charity__c = true, Lead__c = ld.Id);
            insert partner;
            ld.Partner_Referral__c = Partner2.Id;
            ld.PartnerContact__c = partnerContact2.Id;
            update ld;
            partnerList = [Select Id, Referral__c From LeadPartner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].Referral__c);
            
            
            
            //Scenario 2.1 Clear Referral on Lead -> Referral checkbox should be cleared
            ld.Partner_Referral__c = null;
            ld.PartnerContact__c = null;
            update ld;
            partnerList = [Select Id, Referral__c From LeadPartner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(false, partnerList[0].Referral__c);
        }
        
    }
    
    @isTest
    private static void changeReferralOnLead (){
        System.runAs([Select Id From User Where Id=: UserInfo.getUserId()][0]) {

            Account Partner1 = TestUtil.createAccount('partner 1', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account Partner2 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account acc = TestUtil.createAccount('TestAccount', Constants.RT_ID_ACC_PROSPECT_V2, false);
            List<Account> accList = new List<Account>();
            accList.add(Partner1);
            accList.add(Partner2);
            accList.add(acc);
            setPartnerCheckboxes(accList);
            insert accList;
            
            Contact partnerContact1 = TestUtil.createContact('Partner', 'partner@example.com', Partner1.Id, true);
        	Contact partnerContact2 = TestUtil.createContact('Partner', 'partner@example.com', Partner2.Id, true);
            Lead ld = createLead(Partner1.Id, partnerContact1.Id);
            LeadPartner__c partner = [Select Id, Charity__c, Referral__c FROM LeadPartner__c WHERE Lead__c = :ld.Id LIMIT 1];
            partner.Charity__c = true;
            update partner;
            
            
            //Scenario 3.1 Change Referral on Lead -> Referral checkbox should be cleared, Partner Created, Partner Update
            ld = [Select Id, Partner_referral__c FROM Lead WHERE Id = :ld.Id LIMIT 1];
            ld.Partner_referral__c = Partner2.Id;
            ld.PartnerContact__c = PartnerContact2.Id;
            update ld;
            List<LeadPartner__c> partnerList = [Select Id, Partner__c, Referral__c From LeadPartner__c];
            System.assertEquals(2, partnerList.size());
            for (LeadPartner__c p : partnerList){
                if (p.Partner__c == Partner1.Id){
                    System.assertEquals(false, p.Referral__c);
                }
                else if (p.Partner__c == Partner2.Id){
                    System.assertEquals(true, p.Referral__c);
                }
            }
            
            //Scenario 3.3 Change Referral on Lead -> Referral checkbox should be cleared, Partner Updated, partner deleted -> Because it is the only checkbox.
            ld.Partner_referral__c = Partner1.Id;
            ld.PartnerContact__c = partnerContact1.Id;
            update ld;
            partnerList = [Select Id, Partner__c, Referral__c From LeadPartner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].Referral__c);
            System.assertEquals(Partner1.Id, partnerList[0].Partner__c);
            
            
            
            
            //Scenario 3.2 Change Referral on Lead -> Referral checkbox should be cleared, Partner Created, partner deleted -> Because it is the only checkbox.
            partner.Charity__c = false; //Charity to false so it is only a referral Partner
            update partner;
            ld.Partner_referral__c = Partner2.Id;
            ld.PartnerContact__c = partnerContact2.Id;
            update ld;
            partnerList = [Select Id, Partner__c, Referral__c From LeadPartner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].Referral__c);
            System.assertEquals(Partner2.Id, partnerList[0].Partner__c);
            
            
            
            
            //Scenario 3.4 Change Referral on Lead -> Referral checkbox should be cleared, Partner Updated, Partner update
            partnerList[0].Charity__c = true;
            update partnerList;
            LeadPartner__c ldPartner1 = new LeadPartner__c(Partner__c = Partner1.Id, Charity__c = true, Lead__c = ld.Id);
            insert ldPartner1;
            ld.Partner_referral__c = Partner1.Id;
            ld.PartnerContact__c = partnerContact1.Id;
            update ld;
            partnerList = [Select Id, Partner__c, Referral__c From LeadPartner__c];
            System.assertEquals(2, partnerList.size());
            for (LeadPartner__c p : partnerList){
                if (p.Partner__c == Partner1.Id){
                    System.assertEquals(true, p.Referral__c);
                }
                else if (p.Partner__c == Partner2.Id){
                    System.assertEquals(false, p.Referral__c);
                }
            }        
        }
    }
    
    @isTest
    private static void referralOnPartnerObject (){
        System.runAs([Select Id From User Where Id=: UserInfo.getUserId()][0]) {
            Account Partner1 = TestUtil.createAccount('partner 1', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account Partner2 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account acc = TestUtil.createAccount('TestAccount', Constants.RT_ID_ACC_PROSPECT_V2, false);
            
            List<Account> accList = new List<Account>();
            accList.add(Partner1);
            accList.add(Partner2);
            accList.add(acc);
            setPartnerCheckboxes(accList);
            insert accList;
            Contact partnerContact1 = TestUtil.createContact('Partner', 'partner@example.com', Partner1.Id, true);
        	Contact partnerContact2 = TestUtil.createContact('Partner', 'partner@example.com', Partner2.Id, true);
            //Scenario 5 Create new Lead with referral Partner -> Referral on Lead should be changed
            Lead ld = createLead(Partner1.Id, partnerContact1.ID);
            LeadPartner__c partner = [Select Id, Charity__c, Referral__c FROM LeadPartner__c WHERE Lead__c = :ld.Id LIMIT 1];
            partner.Charity__c = true;
            update partner;
            ld = [Select Id, Partner_referral__c FROM Lead WHERE Id = :ld.Id LIMIT 1];
            System.assertEquals(Partner1.Id, ld.Partner_referral__c);
            
            
            //Clear referral on partner record, Lead should be updated.
            ld.Partner_referral__c = null;
            ld.PartnerContact__c = null;
            update ld;
            List<LeadPartner__c> partnerList = [Select Id, Partner__c, Referral__c From LeadPartner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(false, partnerList[0].Referral__c);
        }
    }
    
    @isTest
    private static void mergeLead (){
        Lead ld = createLead(null, null);
        Lead ld2 = createLead(null, null);
        Account partnerAcc1 = TestUtil.createAccount('partner 1', Constants.RT_ID_ACC_PARTNER_V2, false);
        List<Account> accList = new List<Account>();
        accList.add(partnerAcc1);
        setPartnerCheckboxes(accList);
        insert accList;
        LeadPartner__c partner1 = new LeadPartner__c(Charity__c = true, Platform__c = false, Partner__c = partnerAcc1.Id, Lead__c = ld.Id);
        LeadPartner__c partner2 = new LeadPartner__c(Charity__c = false, Platform__c = true, Partner__c = partnerAcc1.Id, Lead__c = ld2.Id);
        List<LeadPartner__c> lpList = new List<LeadPartner__c>();
        lplist.add(partner1);
        lplist.add(partner2);
        insert lpList; 
        merge ld ld2;
        List<LeadPartner__c> partnerList = [Select Id, Partner__c, Referral__c From LeadPartner__c];
        System.assertEquals(1, partnerList.size());
    }
    
    @isTest
    private static void mergeMultipleLead (){
        Lead ld = createLead(null, null);
        
        List<Lead> leadMergeList = new List<Lead>();
        Lead ld2 = TestUtil.createLead ('Random1', Constants.RT_ID_LEAD_INBOUND2, false);
        Lead ld3 = TestUtil.createLead ('Unrelated2', Constants.RT_ID_LEAD_INBOUND2, false);
        leadMergeList.add(ld2);
        leadMergeList.add(ld3);
        insert leadMergeList;
        
        
        
        Account partnerAcc1 = TestUtil.createAccount('partner 1', Constants.RT_ID_ACC_PARTNER_V2, false);
        List<Account> accList = new List<Account>();
        accList.add(partnerAcc1);
        setPartnerCheckboxes(accList);
        insert accList;
        LeadPartner__c partner1 = new LeadPartner__c(Charity__c = true, Platform__c = false, Partner__c = partnerAcc1.Id, Lead__c = ld.Id);
        LeadPartner__c partner2 = new LeadPartner__c(Charity__c = false, Platform__c = true, Partner__c = partnerAcc1.Id, Lead__c = ld2.Id);
        LeadPartner__c partner3 = new LeadPartner__c(Charity__c = true, Platform__c = true, Partner__c = partnerAcc1.Id, Lead__c = ld3.Id);
        List<LeadPartner__c> lpList = new List<LeadPartner__c>();
        lplist.add(partner1);
        lplist.add(partner2);
        lplist.add(partner3);
        insert lpList; 
        
        merge ld leadMergeList;
        List<LeadPartner__c> partnerList = [Select Id, Partner__c, Referral__c From LeadPartner__c];
        System.assertEquals(1, partnerList.size());
    }
    
    
    /**
     * Create and insert a new Lead record
     *
     * @param accId The Partner_Referral to set for the Lead. Can be NULL.
     * @param conId The PartnerContact to set for the Lead. Can be NULL.
     *
     * @return
     *//*
    private static Lead createLead(Id accId, Id conId)
    {
        Id leadRtId = Constants.RT_ID_LEAD_INBOUND2;
        Lead lead = new Lead(
            FirstName            = 'Jim',
            LastName             = 'Johnsson',
            Company              = 'Johnsson Corp.',
            Title                = 'Manager',
            Type__c              = 'Merchant',
            Email                = 'Johnsson@corp.com.fake',
            Website              = 'https://www.adyen.com',
            Industry             = 'Retail',
            SubIndustry__c       = 'Other',
            Street               = 'Fakestreet 1',
            PostalCode           = '1234AB',
            Country              = 'Netherlands',
            SalesChannelSingle__c= 'Mobile',
            Company_Segment__c   = '25 - 50 million',
            Partner_Referral__c  = accId,
            PartnerContact__c    = conId,
            Status               = 'Open',
            RecordTypeId         = leadRtId
        );

        insert lead;

        return lead;
    }
    
    private static void setPartnerCheckboxes(List<Account> accountList){
        for (Account acc : accountList){
            acc.Platform__c = true;
            acc.Consulting__c = true;
            acc.SystemsIntegrator__c = true;
        }
    }
    
    
    
        */
}