@isTest
public class PartnerUtilityTest {
    
    /*
    @testSetup
    private static void testSetup(){
        PermissionSet ps = new PermissionSet(Label = 'EditReferralsPermissionSet', Name = 'EditReferralsPermissionSet');
        insert ps;
        System.debug(ps.Id);
        List<SetupEntityAccess> seaList = new List<SetupEntityAccess>();
        
        
        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = [SELECT Id FROM CustomPermission
            WHERE DeveloperName = 'EditReferralOnLead'][0].Id
        );
        seaList.add(sea);
        SetupEntityAccess sea2 = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = [SELECT Id FROM CustomPermission
            WHERE DeveloperName = 'EditReferralOnOpportunity'][0].Id
        );
        seaList.add(sea2);
        SetupEntityAccess sea3 = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = [SELECT Id FROM CustomPermission
            WHERE DeveloperName = 'EditReferralOnAccount'][0].Id
        );
        seaList.add(sea3);
        insert seaList;
        
        // Given mocked Permission Set assigned to user for test
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = UserInfo.getUserId(),
            PermissionSetId = ps.Id
        );
        insert psa;
    }
    
    @isTest
    private static void addReferralOnOpportunity (){
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
            
            Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
            Test.startTest();
            opp.Referral_by_account__c = Partner1.Id;
            opp.PartnerReferralContact__c = partnerContact1.Id;
            update opp;
            List<Partner__c> partnerList = [Select Id, isReferral__c From Partner__c];
            //Scenario 1.0 Add Referral on opportunity -> Partner Created
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].isReferral__c);
            
            
            opp.Referral_by_account__c = null;
            opp.PartnerReferralContact__c = null;
            update opp;
            partnerList = [Select Id, isReferral__c From Partner__c];
            //Scenario 2.2 Clear Referral on opportunity -> Referral checkbox should be cleared, partner deleted -> Because it is the only checkbox.
            System.assertEquals(0, partnerList.size());
            
            Partner__c partner = new Partner__c(Partner__c = Partner2.Id, isCharity__c = true, Account__c = acc.Id, Opportunity__c = opp.Id);
            insert partner;
            opp.Referral_by_account__c = Partner2.Id;
            opp.PartnerReferralContact__c = partnerContact2.Id;
            update opp;
            partnerList = [Select Id, isReferral__c From Partner__c];
            //Scenario 1.1 Referral on opportunity -> Partner updated
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].isReferral__c);
            
            opp.Referral_by_account__c = null;
            opp.PartnerReferralContact__c = null;
            update opp;
            Test.stopTest();
            partnerList = [Select Id, isReferral__c From Partner__c];
            //Scenario 2.1 Clear Referral on opportunity -> Referral checkbox should be cleared
            System.assertEquals(1, partnerList.size());
            System.assertEquals(false, partnerList[0].isReferral__c);
        }
        
    }
    
    @isTest
    private static void changeReferralOnOpportunity (){
        
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

            Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
            
            Partner__c partner = new Partner__c(Partner__c = Partner1.Id, isCharity__c = true, isReferral__c = true, Account__c = acc.Id, Opportunity__c = opp.Id);
            insert partner;
            
            opp = [Select Id, Referral_by_account__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            Test.startTest();
            
            
            
            //Scenario 3.1 Change Referral on opportunity -> Referral checkbox should be cleared, Partner Created, Partner Update
            opp.Referral_by_account__c = Partner2.Id;
            update opp;
            List<Partner__c> partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];
            System.assertEquals(2, partnerList.size());
            for (Partner__c p : partnerList){
                if (p.Partner__c == Partner1.Id){
                    System.assertEquals(false, p.isReferral__c);
                }
                else if (p.Partner__c == Partner2.Id){
                    System.assertEquals(true, p.isReferral__c);
                }
            }
            
            
            //Scenario 3.3 Change Referral on opportunity -> Referral checkbox should be cleared, Partner Updated, partner deleted -> Because it is the only checkbox.
            opp.Referral_by_account__c = Partner1.Id;
            update opp;
            partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].isReferral__c);
            System.assertEquals(Partner1.Id, partnerList[0].Partner__c);
            
            
            
            
            
            
            //Scenario 3.2 Change Referral on opportunity -> Referral checkbox should be cleared, Partner Created, partner deleted -> Because it is the only checkbox.
            partner.IsCharity__c = false; //set partner charity false, so it is only a referral partner
            update partner;
            opp.Referral_by_account__c = Partner2.Id;
            update opp;
            partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].isReferral__c);
            System.assertEquals(Partner2.Id, partnerList[0].Partner__c);
            
            
            
            //Scenario 3.4 Change Referral on opportunity -> Referral checkbox should be cleared, both partners updated
            partnerList[0].isCharity__c = true;
            update partnerList;
            Partner__c oppPartner1 = new Partner__c(Partner__c = Partner1.Id, isCharity__c = true, Account__c = acc.Id, Opportunity__c = opp.Id);
            insert oppPartner1;
            opp.Referral_by_account__c = Partner1.Id;
            update opp;
            Test.stopTest();
            partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];
            
            System.assertEquals(2, partnerList.size());
            for (Partner__c p : partnerList){
                if (p.Partner__c == Partner1.Id){
                    System.assertEquals(true, p.isReferral__c);
                }
                else if (p.Partner__c == Partner2.Id){
                    System.assertEquals(false, p.isReferral__c);
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
            
            Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
            
            
            //Scenario 5 Create new Referral Partner -> Referral on opportunity should be changed
            Partner__c partner = new Partner__c(Partner__c = Partner1.Id, isCharity__c = true, isReferral__c = true, Account__c = acc.Id, Opportunity__c = opp.Id);
            insert partner;
            opp = [Select Id, Referral_by_account__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            System.assertEquals(Partner1.Id, opp.Referral_by_account__c);
            
            
            //Scenario 4 Clear Referral on Partner -> Referral on Opportunity should be cleared
            opp.Referral_by_account__c = null;
            update opp;
            List<Partner__c> partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];            
            System.assertEquals(1, partnerList.size());
            System.assertEquals(false, partnerList[0].isReferral__c);
        }
    }
    
    
    @isTest
    private static void convertLeadNewOpp (){
        
        System.runAs([Select Id From User Where Id=: UserInfo.getUserId()][0]) {
            Account Partner2 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, true);
            Account acc = TestUtil.createAccount('TestAccount', Constants.RT_ID_ACC_PROSPECT_V2, true);
            
            User commUser = TestUtil.createCommunityUser('test', 'Adyen v2 Partner Community User', true);
            Contact commContact = [Select Id, AccountId From Contact WHERE Id = :commUser.ContactId LIMIT 1];
            Account Partner1 = [Select Id From Account WHERE Id = :commContact.AccountId LIMIT 1];
            
            Lead ld = createLead(Partner1.Id, commContact.Id);
            
            LeadPartner__c lpCharity = new LeadPartner__c(Lead__c = ld.Id, Charity__c = true, Partner__c = Partner2.Id);
            List<LeadPartner__c> leadPartnerInsertList = new List<LeadPartner__c>();
            leadPartnerInsertList.add(lpCharity);
            insert leadPartnerInsertList;
            
            
            
            //6.1 Convert Lead, no referral partners should be created, other partners are created
            Test.startTest();
            runDatabaseLeadConvert(ld.Id, null, null, true);
            Test.stopTest();
            ld = [Select Id, ConvertedOpportunityId FROM Lead LIMIT 1];
            System.assertNotEquals(null, ld.ConvertedOpportunityId);
            Opportunity opp = [Select Id, (Select Id, Partner__c, isReferral__c, isCharity__c From Partners__r) From Opportunity Where Id = : ld.ConvertedOpportunityId LIMIT 1];
            System.assertNotEquals(null, opp.Partners__r);
            System.assertEquals(2, opp.Partners__r.size());
            for (Partner__c p : opp.Partners__r){
                if (p.Partner__c == Partner1.Id){
                    System.assertEquals(true, p.IsReferral__c);
                    System.assertEquals(false, p.IsCharity__c);
                }
                else if (p.Partner__c == Partner2.Id){
                    System.assertEquals(false, p.IsReferral__c);
                    System.assertEquals(true, p.IsCharity__c);
                }
                else {
                    System.assertNotEquals(False, false, 'This partner should not exist');
                }
            }
        }
    }
    
    @isTest
    private static void convertLeadExistingOpp (){
        
        System.runAs([Select Id From User Where Id=: UserInfo.getUserId()][0]) {
            Account Partner2 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account Partner3 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account acc = TestUtil.createAccount('TestAccount', Constants.RT_ID_ACC_PROSPECT_V2, false);
            
            
            List<Account> accList = new List<Account>();
            accList.add(Partner2);
            accList.add(Partner3);
            accList.add(acc);
            setPartnerCheckboxes(accList);
            insert accList;
            User commUser = TestUtil.createCommunityUser('test', 'Adyen v2 Partner Community User', true);
            Contact commContact = [Select Id, AccountId From Contact WHERE Id = :commUser.ContactId LIMIT 1];
            Account Partner1 = [Select Id From Account WHERE Id = :commContact.AccountId LIMIT 1];
            
            
            accList.add(Partner1);
            setPartnerCheckboxes(accList);
            update Partner1;
            
            Lead ld = createLead(Partner1.Id, commContact.Id);
            LeadPartner__c lpCharity = new LeadPartner__c(Lead__c = ld.Id, Charity__c = true, Partner__c = Partner2.Id);
            List<LeadPartner__c> leadPartnerInsertList = new List<LeadPartner__c>();
            leadPartnerInsertList.add(lpCharity);
            Test.startTest();
            insert leadPartnerInsertList;
            
            Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
            Partner__c oppPartner1 = new Partner__c(Partner__c = Partner1.Id, isCharity__c = true, isReferral__c = false, Account__c = acc.Id, Opportunity__c = opp.Id);
            Partner__c oppPartner2 = new Partner__c(Partner__c = Partner2.Id, isPlatform__c = true, isReferral__c = false, Account__c = acc.Id, Opportunity__c = opp.Id);
            Partner__c oppPartner3 = new Partner__c(Partner__c = Partner3.Id, isPlatform__c = true, isReferral__c = true, Account__c = acc.Id, Opportunity__c = opp.Id);
            List<partner__c> oppPartnerList = new List<Partner__c>();
            oppPartnerList.add(oppPartner1);
            oppPartnerList.add(oppPartner2);
            oppPartnerList.add(oppPartner3);
            
            insert oppPartnerList;
            
            
            //6.1 Convert Lead, no referral partners created/copied, other partners are merged
            
            runDatabaseLeadConvert(ld.Id, acc.Id, opp.Id, true);
            Test.stopTest();
            ld = [Select Id, ConvertedOpportunityId FROM Lead LIMIT 1];
            System.assertNotEquals(null, ld.ConvertedOpportunityId);
            opp = [Select Id, (Select Id, Partner__c, isReferral__c, isCharity__c, isPlatform__c From Partners__r) From Opportunity Where Id = : ld.ConvertedOpportunityId LIMIT 1];
            System.assertNotEquals(null, opp.Partners__r);
            System.assertEquals(3, opp.Partners__r.size());
            for (Partner__c p : opp.Partners__r){
                if (p.Partner__c == Partner1.Id){
                    System.assertEquals(false, p.IsReferral__c);
                    System.assertEquals(true, p.IsCharity__c);
                }
                else if (p.Partner__c == Partner2.Id){
                    System.assertEquals(false, p.IsReferral__c);
                    System.assertEquals(true, p.IsCharity__c);
                    System.assertEquals(true, p.isPlatform__c);
                }
                else if (p.Partner__c == Partner3.Id){
                    System.assertEquals(true, p.IsReferral__c);
                    System.assertEquals(false, p.IsCharity__c);
                    System.assertEquals(true, p.isPlatform__c);
                }
                else {
                    System.assertNotEquals(False, false, 'This partner should not exist');
                }
            }
        }
    }
    
    
    @isTest
    private static void changeReferralOnAccount (){
        
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
            
            Partner__c partner = new Partner__c(Partner__c = Partner1.Id, isCharity__c = true, isReferral__c = true, Account__c = acc.Id);
            insert partner;
            acc = [Select Id, Referral__c FROM Account WHERE Id = :acc.Id LIMIT 1];
            Test.startTest();
            
            //Scenario 9.1 Change Referral on account -> Referral checkbox should be cleared, Partner Created, Partner Update
            acc.Referral__c = Partner2.Id;
            update acc;
            List<Partner__c> partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];
            System.assertEquals(2, partnerList.size());
            for (Partner__c p : partnerList){
                if (p.Partner__c == Partner1.Id){
                    System.assertEquals(false, p.isReferral__c);
                }
                else if (p.Partner__c == Partner2.Id){
                    System.assertEquals(true, p.isReferral__c);
                }
            }
            
            //Scenario 9.3 Change Referral on account -> Referral checkbox should be cleared, Partner Updated, partner deleted -> Because it is the only checkbox.
            acc.Referral__c = Partner1.Id;
            update acc;
            partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].isReferral__c);
            System.assertEquals(Partner1.Id, partnerList[0].Partner__c);
            
            
            
            //Scenario 9.2 Change Referral on account -> Referral checkbox should be cleared, Partner Created, partner deleted -> Because it is the only checkbox.
            partner.IsCharity__c = false; //Set charity to false, so it is only a referral partner
            update partner;
            acc.Referral__c = Partner2.Id;
            update acc;
            partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].isReferral__c);
            System.assertEquals(Partner2.Id, partnerList[0].Partner__c);
            
            
            
            //Scenario 9.4 Change Referral on account -> Referral checkbox should be cleared, Partner Updated, Partner update
            partnerList[0].isCharity__c = true;
            update partnerList;
            Partner__c accPartner1 = new Partner__c(Partner__c = Partner1.Id, isCharity__c = true, Account__c = acc.Id);
            insert accPartner1;
            
            acc.Referral__c = Partner1.Id;
            update acc;
            Test.stopTest();
            partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];
            System.assertEquals(2, partnerList.size());
            for (Partner__c p : partnerList){
                if (p.Partner__c == Partner1.Id){
                    System.assertEquals(true, p.isReferral__c);
                }
                else if (p.Partner__c == Partner2.Id){
                    System.assertEquals(false, p.isReferral__c);
                }
            }        
        }
    }
    
    
    @isTest
    private static void addReferralOnAccount (){
        
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
            
            Test.startTest();
            //Scenario 7.0 Add Referral on account -> Partner Created
            acc.Referral__c = Partner1.Id;
            acc.PartnerReferralContact__c = PartnerContact1.Id;
            update acc;
            List<Partner__c> partnerList = [Select Id, isReferral__c, Account__c From Partner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].isReferral__c);
            System.assertEquals(acc.Id, partnerList[0].Account__c);
            
            //Scenario 8.2 Clear Referral on account -> Referral checkbox should be cleared, partner deleted -> Because it is the only checkbox.
            acc.Referral__c = null;
            acc.PartnerReferralContact__c = null;
            update acc;
            partnerList = [Select Id, isReferral__c From Partner__c];
            System.assertEquals(0, partnerList.size());
            
            
            
            //Scenario 7.1 Referral on account -> Partner updated
            Partner__c partner = new Partner__c(Partner__c = Partner2.Id, isCharity__c = true, Account__c = acc.Id);
            insert partner;
            acc.Referral__c = Partner2.Id;
            acc.PartnerReferralContact__c = PartnerContact2.Id;
            update acc;
            partnerList = [Select Id, isReferral__c From Partner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(true, partnerList[0].isReferral__c);
            
            
            //Scenario 8.1 Clear Referral on account -> Referral checkbox should be cleared
            acc.Referral__c = null;
            update acc;
            Test.stopTest();
            partnerList = [Select Id, isReferral__c From Partner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(false, partnerList[0].isReferral__c);
        }
        
    }
    
    @isTest
    private static void referralOnPartnerObjectAccount (){
        
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
            //Scenario 5 Create new Referral on Partner -> Referral on Account should be changed
            Partner__c partner = new Partner__c(Partner__c = Partner1.Id, isCharity__c = true, isReferral__c = true, Account__c = acc.Id);
            insert partner;
            acc = [Select Id, Referral__c FROM Account WHERE Id = :acc.Id LIMIT 1];
            System.assertEquals(Partner1.Id, acc.Referral__c);
            
            
            //Clear referral on Account, referral checkbox removed from partner record.
            acc.Referral__c = null;
            update acc;
            List<Partner__c> partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];
            System.assertEquals(1, partnerList.size());
            System.assertEquals(false, partnerList[0].isReferral__c);
        }
    }
    
    @isTest
    private static void convertMultipleLeadExistingOpp (){
        
        System.runAs([Select Id From User Where Id=: UserInfo.getUserId()][0]) {
            Account Partner2 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account Partner3 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account acc = TestUtil.createAccount('TestAccount', Constants.RT_ID_ACC_PROSPECT_V2, false);
                        
            
            List<Account> accList = new List<Account>();
            accList.add(Partner2);
            accList.add(Partner3);
            accList.add(acc);
            setPartnerCheckboxes(accList);
            insert accList;
            Contact partnerContact2 = TestUtil.createContact('Partner', 'partner@example.com', Partner2.Id, true);
            Contact partnerContact3 = TestUtil.createContact('Partner', 'partner@example.com', Partner3.Id, true);
            User commUser = TestUtil.createCommunityUser('test', 'Adyen v2 Partner Community User', true);
            Contact commContact = [Select Id, AccountId From Contact WHERE Id = :commUser.ContactId LIMIT 1];
            Account Partner1 = [Select Id From Account WHERE Id = :commContact.AccountId LIMIT 1];

            
            Lead ld = createLead(Partner1.Id, commContact.Id);
            lead ld2 = createLead(Partner1.Id, commContact.Id);
            
            LeadPartner__c lpCharity = new LeadPartner__c(Lead__c = ld.Id, Charity__c = true, Partner__c = Partner2.Id);
            //LeadPartner__c lpCharity2 = new LeadPartner__c(Lead__c = ld2.Id, Charity__c = true, Partner__c = Partner2.Id);
            List<LeadPartner__c> leadPartnerInsertList = new List<LeadPartner__c>();
            leadPartnerInsertList.add(lpCharity);
            //leadPartnerInsertList.add(lpCharity2);
            insert leadPartnerInsertList;
            
            Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
            Partner__c oppPartner1 = new Partner__c(Partner__c = Partner1.Id, isCharity__c = true, isReferral__c = false, Account__c = acc.Id, Opportunity__c = opp.Id);
            Partner__c oppPartner2 = new Partner__c(Partner__c = Partner2.Id, isPlatform__c = true, isReferral__c = false, Account__c = acc.Id, Opportunity__c = opp.Id);
            Partner__c oppPartner3 = new Partner__c(Partner__c = Partner3.Id, isPlatform__c = true, isReferral__c = true,Account__c = acc.Id,  Opportunity__c = opp.Id);
            List<partner__c> oppPartnerList = new List<Partner__c>();
            oppPartnerList.add(oppPartner1);
            oppPartnerList.add(oppPartner2);
            oppPartnerList.add(oppPartner3);
            Test.startTest();
            insert oppPartnerList;
            
            
            List<Id> leadIds = new List<Id>();
            leadIds.add(ld.Id);
            leadIds.add(ld2.Id);
            runDatabaseLeadListConvert(leadIds, acc.Id, opp.Id, true);
            Test.stopTest();
            ld = [Select Id, ConvertedOpportunityId FROM Lead LIMIT 1];
            System.assertNotEquals(null, ld.ConvertedOpportunityId);
            opp = [Select Id, (Select Id, Partner__c, isReferral__c, isCharity__c, isPlatform__c From Partners__r) From Opportunity Where Id = : ld.ConvertedOpportunityId LIMIT 1];
            System.assertNotEquals(null, opp.Partners__r);
            System.assertEquals(3, opp.Partners__r.size());
            for (Partner__c p : opp.Partners__r){
                if (p.Partner__c == Partner1.Id){
                    System.assertEquals(false, p.IsReferral__c);
                    System.assertEquals(true, p.IsCharity__c);
                }
                else if (p.Partner__c == Partner2.Id){
                    System.assertEquals(false, p.IsReferral__c, 'Expected referral to be false');
                    System.assertEquals(true, p.isPlatform__c, 'Expected platform to be true');
                    System.assertEquals(true, p.IsCharity__c, 'Expected charity to be true');
                }
                else if (p.Partner__c == Partner3.Id){
                    System.assertEquals(true, p.IsReferral__c);
                    System.assertEquals(false, p.IsCharity__c);
                    System.assertEquals(true, p.isPlatform__c);
                }
                else {
                    System.assertNotEquals(False, false, 'This partner should not exist');
                }
            }
        }
    }
    
    @isTest
    private static void mergeAccount (){
        
        System.runAs([Select Id From User Where Id=: UserInfo.getUserId()][0]) {
            Account PartnerAcc2 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, false);
            Account acc = TestUtil.createAccount('TestAccount1', Constants.RT_ID_ACC_PROSPECT_V2, false);
            Account acc2 = TestUtil.createAccount('TestAccount2', Constants.RT_ID_ACC_PROSPECT_V2, false);
            Account partnerAcc1 = TestUtil.createAccount('partner 1', Constants.RT_ID_ACC_PARTNER_V2, false);
            Opportunity opp2 = TestUtil.createOpportunity(acc2.Id, UserInfo.getUserId(), true);
            
            List<Account> accList = new List<Account>();
            accList.add(partnerAcc1);
            accList.add(partnerAcc2);
            accList.add(acc);
            accList.add(acc2);
            setPartnerCheckboxes(accList);
            insert accList;
            Contact partnerContact1 = TestUtil.createContact('Partner', 'partner@example.com', partnerAcc1.Id, true);
            Contact partnerContact2 = TestUtil.createContact('Partner', 'partner@example.com', PartnerAcc2.Id, true);
            Partner__c partner1 = new Partner__c(isCharity__c = true, isPlatform__c = false, Partner__c = partnerAcc1.Id, Account__c = acc.Id);
            Partner__c partner2 = new Partner__c(isCharity__c = false, isPlatform__c = true, Partner__c = partnerAcc1.Id, Account__c = acc2.Id);
            List<Partner__c> lpList = new List<Partner__c>();
            lplist.add(partner1);
            lplist.add(partner2);
            insert lpList; 
            
            Test.startTest();
            Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
            Partner__c oppPartner1 = new Partner__c(Partner__c = PartnerAcc1.Id, isCharity__c = true, isReferral__c = false, Account__c = acc.Id, Opportunity__c = opp.Id);
            Partner__c oppPartner2 = new Partner__c(Partner__c = PartnerAcc2.Id, isPlatform__c = true, isReferral__c = true, Account__c = acc2.Id, Opportunity__c = opp2.Id);
            List<partner__c> oppPartnerList = new List<Partner__c>();
            oppPartnerList.add(oppPartner1);
            oppPartnerList.add(oppPartner2);
            insert oppPartnerList;
            
            
            
            merge acc acc2;
            Test.stopTest();
            List<Partner__c> partnerList = [Select Id, Partner__c, isReferral__c From Partner__c Where Opportunity__c = null];
            System.assertEquals(1, partnerList.size());
            
            partnerList = [Select Id, Partner__c, isReferral__c From Partner__c Where Opportunity__c != null];
            System.assertEquals(2, partnerList.size());
        }
    }
    
    @isTest
    private static void mergeMultipleAccount (){
        
        System.runAs([Select Id From User Where Id=: UserInfo.getUserId()][0]) {
            Account acc = TestUtil.createAccount('TestAccount1', Constants.RT_ID_ACC_PROSPECT_V2, true);
            Account acc2 = TestUtil.createAccount('TestAccount2', Constants.RT_ID_ACC_PROSPECT_V2, false);
            Account acc3 = TestUtil.createAccount('TestAccount3', Constants.RT_ID_ACC_PROSPECT_V2, false);
            List<Account> accountMergeList = new List<Account>();
            accountMergeList.add(acc2);
            accountMergeList.add(acc3);
            insert accountMergeList;
    
            Account partnerAcc1 = TestUtil.createAccount('partner 1', Constants.RT_ID_ACC_PARTNER_V2, false);
            List<Account> accList = new List<Account>();
            accList.add(partnerAcc1);
            setPartnerCheckboxes(accList);
            insert accList;
            
            
            
            
            Partner__c partner1 = new Partner__c(isCharity__c = true, isPlatform__c = false, Partner__c = partnerAcc1.Id, Account__c = acc.Id);
            Partner__c partner2 = new Partner__c(isCharity__c = false, isPlatform__c = true, Partner__c = partnerAcc1.Id, Account__c = acc2.Id);
            Partner__c partner3 = new Partner__c(isCharity__c = true, isPlatform__c = true, Partner__c = partnerAcc1.Id, Account__c = acc3.Id);
            List<Partner__c> pList = new List<Partner__c>();
            pList.add(partner1);
            pList.add(partner2);
            pList.add(partner3);
            
            insert pList; 
            merge acc accountMergeList;
            List<Partner__c> partnerList = [Select Id, Partner__c, isReferral__c From Partner__c];
            System.assertEquals(1, partnerList.size());
        }
    }
    
    @isTest
    private static void mergePartnerAccount (){
        System.runAs([Select Id From User Where Id=: UserInfo.getUserId()][0]) {
            Account MasterAcc1 = TestUtil.createAccount('partner 1', Constants.RT_ID_ACC_PARTNER_V2, false); 
            Account SlaveAcc2 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, false); 
            
            List<Account> accList = new List<Account>();
            accList.add(MasterAcc1);
            accList.add(SlaveAcc2);
            setPartnerCheckboxes(accList);
            insert accList;
            
            
            Account acc = TestUtil.createAccount('TestAccount1', Constants.RT_ID_ACC_PROSPECT_V2, true);
            Partner__c partner1 = new Partner__c(isCharity__c = true, isPlatform__c = false, Partner__c = MasterAcc1.Id, Account__c = acc.Id);
            Partner__c partner2 = new Partner__c(isCharity__c = false, isPlatform__c = true, Partner__c = SlaveAcc2.Id, Account__c = acc.Id);
            List<Partner__c> lpList = new List<Partner__c>();
            lplist.add(partner1);
            lplist.add(partner2);
            insert lpList; 
            
            
            Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
            Partner__c oppPartner1 = new Partner__c(Partner__c = MasterAcc1.Id, isCharity__c = true, isReferral__c = true, Account__c = acc.Id, Opportunity__c = opp.Id);
            Partner__c oppPartner2 = new Partner__c(Partner__c = SlaveAcc2.Id, isPlatform__c = true, isReferral__c = true, Account__c = acc.Id, Opportunity__c = opp.Id);
            List<partner__c> oppPartnerList = new List<Partner__c>();
            oppPartnerList.add(oppPartner1);
            oppPartnerList.add(oppPartner2);
            insert oppPartnerList;
            
            merge MasterAcc1 SlaveAcc2;
            List<Partner__c> partnerList = [Select Id, Partner__c, isReferral__c From Partner__c Where Opportunity__c = null];
            System.assertEquals(1, partnerList.size());
            
            partnerList = [Select Id, Partner__c, isReferral__c From Partner__c Where Opportunity__c != null];
            System.assertEquals(1, partnerList.size());
        }
    }
    //This test is not possible since Partner Leads cant be converted to an account. As the default recordType of the new account is not Partner
    /*
    @isTest
    private static void convertLeadNewAcc (){
        
        System.runAs([Select Id From User Where Id=: UserInfo.getUserId()][0]) {
            Account Partner2 = TestUtil.createAccount('partner 2', Constants.RT_ID_ACC_PARTNER_V2, true);    
            User commUser = TestUtil.createCommunityUser('test', 'Adyen v2 Partner Community User', true);
            Contact commContact = [Select Id, AccountId From Contact WHERE Id = :commUser.ContactId LIMIT 1];
            Account Partner1 = [Select Id From Account WHERE Id = :commContact.AccountId LIMIT 1];
            
            List<Account> accList = new List<Account>();
            accList.add(Partner2);
            accList.add(Partner1);
            setPartnerCheckboxes(accList);
            update accList;
            
            Lead ld = createLead(Partner1.Id, commContact.Id);
            ld.type__c = 'Partner v2';
            ld.RecordTypeId = Constants.RT_ID_LEAD_PARTNER;
            update ld;
            LeadPartner__c lpCharity = new LeadPartner__c(Lead__c = ld.Id, Charity__c = true, Partner__c = Partner2.Id);
            List<LeadPartner__c> leadPartnerInsertList = new List<LeadPartner__c>();
            leadPartnerInsertList.add(lpCharity);
            insert leadPartnerInsertList;
            
            Test.startTest();
            runDatabaseLeadConvert(ld.Id, null, null, false);
            Test.stopTest();
            ld = [Select Id, ConvertedOpportunityId, ConvertedAccountId FROM Lead LIMIT 1];
            System.assertEquals(null, ld.ConvertedOpportunityId);
            System.assertNotEquals(null, ld.ConvertedAccountId);
            Account convertedAcc = [Select Id, (Select Id, Partner__c, isReferral__c, isCharity__c From Partners2__r) From Account Where Id = : ld.ConvertedAccountId LIMIT 1];
            System.assertNotEquals(null, convertedAcc.Partners2__r);
            System.debug(JSON.serializePretty(convertedAcc.Partners2__r));
            //Expected one, because referrals are not copied
            System.assertEquals(2, convertedAcc.Partners2__r.size());
            for (Partner__c p : convertedAcc.Partners2__r){
                if (p.Partner__c == Partner1.Id){
                    System.assertEquals(true, p.IsReferral__c);
                    System.assertEquals(false, p.IsCharity__c);
                }
                else if (p.Partner__c == Partner2.Id){
                    System.assertEquals(false, p.IsReferral__c);
                    System.assertEquals(true, p.IsCharity__c);
                }
                else {
                    System.assertNotEquals(False, false, 'This partner should not exist');
                }
            }
        }
    }*/
    
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
            MerchantCoreBusinessModel__c = 'Digital',
            //    AccountAssignment__c = UserInfo.getUserId(),
            Status               = 'Open',

            RecordTypeId         = leadRtId,
            ProcessedByLeanData__c = true
        );

        insert lead;

        return lead;
    }*/
    
    /**
     * Convert the given Lead to initiate the AfterUpdate of the Lead Trigger
     *
     * @param leadId
     *
     * @return
     *//*
    private static Database.LeadConvertResult runDatabaseLeadConvert(Id leadId, Id accountId, Id opportunityId, boolean createOpportunity)
    {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setConvertedStatus('Converted');
        if (accountId != null) {
            lc.setAccountId(accountId);
        }
        if (opportunityId != null) {
            lc.setOpportunityId(opportunityId);
        }
        lc.donotcreateopportunity = createOpportunity ? false : true;
        Database.LeadConvertResult lcr = Database.convertLead(lc); // initiate AfterUpdate of the Lead Trigger

        return lcr;
    }
    */
    /**
     * Convert the given Lead to initiate the AfterUpdate of the Lead Trigger
     *
     * @param leadId
     *
     * @return
     *//*
    private static List<Database.LeadConvertResult> runDatabaseLeadListConvert(List<Id> leadIds, Id accountId, Id opportunityId, boolean createOpportunity)
    {
        
        List<Database.LeadConvert> lcList = new List<Database.LeadConvert>();
        
        for (Id leadId : leadIds){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setConvertedStatus('Converted');
            if (accountId != null) {
                lc.setAccountId(accountId);
            }
            if (opportunityId != null) {
                lc.setOpportunityId(opportunityId);
            }
            lc.donotcreateopportunity = createOpportunity ? false : true;
            lcList.add(lc);
        }
        List<Database.LeadConvertResult> lcr = Database.convertLead(lcList); // initiate AfterUpdate of the Lead Trigger

        return lcr;
    }
    
    private static void setPartnerCheckboxes(List<Account> accountList){
        for (Account acc : accountList){
            acc.Platform__c = true;
            acc.Consulting__c = true;
            acc.SystemsIntegrator__c = true;
        }
    }*/
    
    
        
}