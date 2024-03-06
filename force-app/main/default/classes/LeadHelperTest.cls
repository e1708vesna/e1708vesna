/**
 * @author (s)    : Brite
 * @description
 */
@IsTest
private class LeadHelperTest {

@IsTest
    private static void testHandleAfterUpdateTrigger_PartnerWithExistingOpportunity() {
        
        //create account
        Account acc = new Account(
                            Name = 'Barry BV',
                            Industry = 'Retail',
                            SubIndustry__c = 'Other',
                            Website = 'www.barrybv.com',
                            Company_Segment__c = '25 - 50 million',
                            CurrencyIsoCode = 'EUR',
                            BillingCountry = 'Netherlands',
                RecordTypeId = Constants.RT_ID_ACC_BUSINESS,
                Account_Status__c = 'Prospect',
                AccountType__c = 'Merchant',
                            CreatedDate = System.Now() - 10);
        insert acc;
        
        //create contact
        Contact con = new Contact(
                            Salutation = 'Mr',
                            FirstName = 'Tester',
                            LastName = 'Bester',
                            AccountId = acc.id,
                            Title = 'CEO',
                            Email = 'tester@bester.nl',
                            CurrencyIsoCode = 'EUR');
            insert con;
                            
        
        //create oppty
        Opportunity oppty = new Opportunity(
                        Name = 'Test Oppty',
                        RecordTypeId = Constants.RT_ID_OPP_SALES,
                        AccountId = acc.id,
                        Opportunity_Primary_Contact__c = con.Id,
                        Sales_channel__c = 'Ecom',
                        CloseDate = System.today() + 10,
                        StageName = 'SCOTSMAN',
                        CurrencyIsoCode = 'EUR',
        				RegionCountry__c ='NL');
            insert oppty;
        
        // create lead
        Lead ld = new Lead(
                        FirstName = 'Jim',
                        LastName = 'Johnsson', 
                        Email = 'Johnsson@corp.com.fake',
                        Company = 'Johnsson Corp.',
                        Website = 'https://www.adyen.com',
                        Country = 'Netherlands',
                        Title = 'Mister',
                        SalesChannelSingle__c = 'Ecom',
                        Company_Segment__c = '25 - 50 million',
                        //    AccountAssignment__c = UserInfo.getUserId(),
                        MerchantCoreBusinessModel__c = 'Digital',
                        RecordTypeId = Constants.RT_ID_LEAD_PARTNER,
                        ProcessedByLeanData__c = true,
                        Status = 'Open');
        insert ld;

        Test.startTest();
        
        try{
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(ld.Id);
            lc.setAccountId(acc.Id);
            lc.setDoNotCreateOpportunity(False);
            lc.setOpportunityId(oppty.Id);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('You cannot convert a Partner Lead to an Opportunity. Please click on the checkbox indicating that you do not want to create an Opportunity') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
 
        Test.stopTest();

        ld = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedOpportunityId FROM Lead WHERE Id = :ld.Id];
        System.assertEquals(false, ld.IsConverted, 'IsConverted');
        System.assertEquals(null, ld.ConvertedAccountId, 'ConvertedAccountId');
        System.assertEquals(null, ld.ConvertedOpportunityId, 'ConvertedOpportunityId');
    } 
    /*Not applicable anymore
        @IsTest
    private static void testHandleAfterUpdateTrigger_PartnerLeadToNonPartnerAccount() {
        //create account
        Account acc = new Account(
                            Name = 'Barry BV',
                            Industry = 'Retail',
                            SubIndustry__c = 'Other',
                            Website = 'www.barrybv.com',
                            Company_Segment__c = '25 - 50 million',
                            CurrencyIsoCode = 'EUR',
                            BillingCountry = 'Netherlands',
                RecordTypeId = Constants.RT_ID_ACC_BUSINESS,
                Account_Status__c = 'Prospect',
                AccountType__c = 'Merchant',
                            CreatedDate = System.Now() - 10);
                            
            insert acc;
        
        // create lead
        Lead ld = new Lead(
                        FirstName = 'Jim',
                        LastName = 'Johnsson', 
                        Email = 'Johnsson@corp.com.fake',
                        Company = 'Johnsson Corp.',
                        Website = 'https://www.adyen.com',
                        Country = 'Netherlands',
                        Title = 'Mister',
                        SalesChannelSingle__c = 'Ecom',
                        Company_Segment__c = '25 - 50 million',
                        //    AccountAssignment__c = UserInfo.getUserId(),
                        RecordTypeId = Constants.RT_ID_LEAD_PARTNER,
                        MerchantCoreBusinessModel__c = 'Digital',
                        ProcessedByLeanData__c = true,
                        Status = 'Open');
                    
        insert ld;

        Test.startTest();
        Boolean expectedExceptionThrown = false;
        try{
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(ld.Id);
            lc.setAccountId(acc.Id);
            lc.setDoNotCreateOpportunity(True);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
        }
        catch(Exception ex){
            expectedExceptionThrown =  ex.getMessage().contains('You cannot convert a Partner Lead to a non-Partner Account') ? true : false;
            
        }
        System.assertEquals(expectedExceptionThrown, true);
        Test.stopTest();

        ld = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedOpportunityId FROM Lead WHERE Id = :ld.Id];
        System.assertEquals(false, ld.IsConverted, 'IsConverted');
        System.assertEquals(null, ld.ConvertedAccountId, 'ConvertedAccountId');
        System.assertEquals(null, ld.ConvertedOpportunityId, 'ConvertedOpportunityId');

    }*/
    
    @IsTest
    private static void testHandleAfterUpdateTrigger_PartnerManagerNonReferralLead() {
        
        User partnerUser   = TestUtil.createUser3Profile('Adyen v2 Partnership', true);
         System.runAs(partnerUser){
             
         //create account
        Account acc = new Account(
                            Name = 'Barry BV',
                            Industry = 'Retail',
                            SubIndustry__c = 'Other',
                            Website = 'www.barrybv.com',
                            Company_Segment__c = '25 - 50 million',
                            CurrencyIsoCode = 'EUR',
                            BillingCountry = 'Netherlands',
                RecordTypeId = Constants.RT_ID_ACC_BUSINESS,
                Account_Status__c = 'Prospect',
                AccountType__c = 'Merchant',
                            CreatedDate = System.Now() - 10);
        insert acc;
        
        //create contact
        Contact con = new Contact(
                            Salutation = 'Mr',
                            FirstName = 'Tester',
                            LastName = 'Bester',
                            AccountId = acc.id,
                            Title = 'CEO',
                            Email = 'tester@bester.nl',
                            CurrencyIsoCode = 'EUR');
            insert con;
                            
        //create oppty
        Opportunity oppty = new Opportunity(
                        Name = 'Test Oppty',
                        RecordTypeId = Constants.RT_ID_OPP_SALES,
                        AccountId = acc.id,
                        //Created_from_Lead__c = true,
                        Opportunity_Primary_Contact__c = con.Id,
                        Sales_channel__c = 'Ecom',
                        CloseDate = System.today() + 10,
                        CreatedDate = System.Now() - 10,
                        StageName = 'SCOTSMAN',
                        CurrencyIsoCode = 'EUR',
        				RegionCountry__c ='NL');
            insert oppty;
        
        // create lead
        Lead ld = new Lead(
                        FirstName = 'Jim',
                        LastName = 'Johnsson', 
                        Email = 'Johnsson@corp.com.fake',
                        Company = 'Johnsson Corp.',
                        Website = 'https://www.adyen.com',
                        Country = 'Netherlands',
                        Title = 'Mister',
                        SalesChannelSingle__c = 'Ecom',
                        Company_Segment__c = '1 - 5 million',
                        Industry = 'Retail',
                        SubIndustry__c = 'Other',
                        Partner_Referral__c = null,
                        MerchantCoreBusinessModel__c = 'Platforms',
                        SubBusinessModel__c = 'Marketplaces',
                        //    AccountAssignment__c = UserInfo.getUserId(),
                        RecordTypeId = Constants.RT_ID_LEAD_INBOUND2,
                        ProcessedByLeanData__c = true,
                        Status = 'Open');
        insert ld;
        
        Test.startTest();
       
            
        try{
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(ld.Id);
            lc.setAccountId(acc.Id);
            lc.setDoNotCreateOpportunity(False);
            lc.setOpportunityId(oppty.Id);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            system.debug('Partner Referral: ' + ld.Partner_Referral__c);
        }
        catch(Exception ex){
            String error = ex.getMessage();
            system.debug('Error is: ' + error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains('You can not convert a non-referral Lead, please transfer ownership of this Lead to Sales.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        Test.stopTest();
        

        ld = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedOpportunityId, Status FROM Lead WHERE Id = :ld.Id];
        System.assertEquals(false, ld.IsConverted, 'IsConverted');
        System.assertEquals(null, ld.ConvertedAccountId, 'ConvertedAccountId');
        System.assertEquals(null, ld.ConvertedOpportunityId, 'ConvertedOpportunityId');
         }
    } 
    
    @IsTest
    private static void testHandleAfterUpdateTrigger_SalesSupportNonReferralLead() {
        
        User partnerUser   = TestUtil.createUser3Profile('Adyen v2 Salessupport', true);
        System.runAs(partnerUser){
            
            //create account
            Account acc = new Account(
                Name = 'Barry BV',
                Industry = 'Retail',
                SubIndustry__c = 'Other',
                Website = 'www.barrybv.com',
                Company_Segment__c = '25 - 50 million',
                CurrencyIsoCode = 'EUR',
                BillingCountry = 'Netherlands',
                RecordTypeId = Constants.RT_ID_ACC_BUSINESS,
                Account_Status__c = 'Prospect',
                AccountType__c = 'Merchant',
                CreatedDate = System.Now() - 10);
            insert acc;
            
            //create contact
            Contact con = new Contact(
                            Salutation = 'Mr',
                            FirstName = 'Tester',
                            LastName = 'Bester',
                            AccountId = acc.id,
                            Title = 'CEO',
                            Email = 'tester@bester.nl',
                            CurrencyIsoCode = 'EUR');
            insert con;
                            
        //create oppty
        Opportunity oppty = new Opportunity(
                        Name = 'Test Oppty',
                        RecordTypeId = Constants.RT_ID_OPP_SALES,
                        AccountId = acc.id,
                        Opportunity_Primary_Contact__c = con.Id,
                        Sales_channel__c = 'Ecom',
                        CloseDate = System.today() + 10,
                        CreatedDate = System.Now() - 10,
                        StageName = 'SCOTSMAN',
                        CurrencyIsoCode = 'EUR',
        				RegionCountry__c ='NL');
            insert oppty;
        
        // create lead
        Lead ld = new Lead(
                        FirstName = 'Jim',
                        LastName = 'Johnsson', 
                        Email = 'Johnsson@corp.com.fake',
                        Company = 'Johnsson Corp.',
                        Website = 'https://www.adyen.com',
                        Country = 'Netherlands',
                        Title = 'Mister',
                        SalesChannelSingle__c = 'Ecom',
                        Company_Segment__c = '1 - 5 million',
                        Industry = 'Retail',
                        SubIndustry__c = 'Other',
                        Partner_Referral__c = null,
                        MerchantCoreBusinessModel__c = 'Platforms',
                        SubBusinessModel__c = 'Marketplaces',
                        //    AccountAssignment__c = UserInfo.getUserId(),
                        RecordTypeId = Constants.RT_ID_LEAD_INBOUND2,
                        ProcessedByLeanData__c = true,
                        Status = 'Open');
        insert ld;
        
        Test.startTest();
       
            
        try{
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(ld.Id);
            lc.setAccountId(acc.Id);
            lc.setDoNotCreateOpportunity(False);
            lc.setOpportunityId(oppty.Id);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('You cannot convert a non-Referral Lead to an Opportunity. Please click on the checkbox indicating that you do not want to create an Opportunity') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        Test.stopTest();
        

        ld = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedOpportunityId, Status FROM Lead WHERE Id = :ld.Id];
        System.assertEquals(true, ld.IsConverted, 'IsConverted');
        System.assertNotEquals(null, ld.ConvertedAccountId, 'ConvertedAccountId');
        System.assertNotEquals(null, ld.ConvertedOpportunityId, 'ConvertedOpportunityId');
         }
    } 

    @IsTest
    private static void testHandleAfterUpdateTrigger_IsNotPartner() {
        // create lead
        Lead ld = new Lead(
                        FirstName = 'Jim',
                        LastName = 'Johnsson', 
                        Email = 'Johnsson@corp.com.fake',
                        Company = 'Johnsson Corp.',
                        Website = 'https://www.adyen.com',
                        Country = 'Netherlands',
                        Industry = 'Retail',
                        SubIndustry__c = 'Other',
                        Title = 'Manager',
                        SalesChannelSingle__c = 'Ecom',
                        Company_Segment__c = '0 - 1 million',
                        MerchantCoreBusinessModel__c = 'Platforms',
                        SubBusinessModel__c = 'Marketplaces',
                        //    AccountAssignment__c = UserInfo.getUserId(),
                        RecordTypeId = Constants.RT_ID_LEAD_INBOUND2,
                        ProcessedByLeanData__c = true,
                        Status = 'Open');
        insert ld;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);

        //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        //lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setConvertedStatus('Converted');

        Test.startTest();
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();

        System.assert(lcr.isSuccess());

        ld = [SELECT Id, IsConverted, ConvertedOpportunityId FROM Lead WHERE Id = :ld.Id];
        System.assertEquals(true, ld.IsConverted, 'IsConverted');
        System.assertNotEquals(null, ld.ConvertedOpportunityId, 'ConvertedOpportunityId');
    }
 
    //Partner Community Users are not used anymore.
    /*@IsTest
    private static void testOwnershipChangeFields() {
        Test.startTest();
        
        Id rtPartnerV2     = Constants.RT_ID_ACC_PARTNER_V2;
        List<User> usrList = [SELECT Id, AccountId, ContactId FROM User WHERE UserType != 'Standard' AND IsActive = TRUE AND Account.RecordTypeId = :rtPartnerV2 LIMIT 1];
        User partnerUser   = (!usrList.isEmpty()) ? usrList[0] : TestUtil.createCommunityUser('Steen', 'Adyen v2 Partner Community User', true);
        
        Test.stopTest();

        // Triggers the Lead trigger
        System.runAs(partnerUser) {
            TestUtil.createLead();
        }

        // Check fields
        usrList      = [SELECT Id, AccountId, ContactId, Account.OwnerId FROM User WHERE Id = :partnerUser.Id];
        Id accId     = usrList[0].AccountId;
        Account acc2 = [SELECT OwnerId FROM Account WHERE Id = :accId];
        Lead ld      = [SELECT Id, OwnerId, Partner_Referral__c FROM Lead];
        
        System.assertEquals(usrList[0].AccountId, ld.Partner_Referral__c, 'Lead Partner_Referral__c should have been set with the AccountId of the Partner User');
        System.assertEquals(acc2.OwnerId, ld.OwnerId, 'Lead OwnerId should have changed to Partner User Account Owner');
    }*/
    
    @isTest
    private static void beforeLeadConversion(){
        Account acc = new Account(
                            Name = 'Barry BV',
                            Industry = 'Retail',
                            SubIndustry__c = 'Other',
                            Company_Segment__c = '25 - 50 million',
                            CurrencyIsoCode = 'EUR',
                            BillingCountry = 'Netherlands',
                RecordTypeId = Constants.RT_ID_ACC_BUSINESS,
                Account_Status__c = 'Prospect',
                AccountType__c = 'Merchant',
                            CreatedDate = System.Now() - 10);
        insert acc;
        
        //create contact
        Contact con = new Contact(
                            Salutation = 'Mr',
                            FirstName = 'Tester',
                            LastName = 'Bester',
                            AccountId = acc.id,
                            Title = 'CEO',
                            Email = 'tester@bester.nl',
                            CurrencyIsoCode = 'EUR');
        insert con;
        // create lead
        Lead ld = new Lead(
                        FirstName = 'Jim',
                        LastName = 'Johnsson', 
                        Email = 'Johnsson@corp.com.fake',
                        Company = 'Johnsson Corp.',
                        Website = 'https://www.adyen.com',
                        Title = 'Mister',
                        SalesChannelSingle__c = 'Ecom',
                        MerchantCoreBusinessModel__c = 'Platforms',
                        SubBusinessModel__c = 'Marketplaces',
                        //    AccountAssignment__c = UserInfo.getUserId(),
                        RecordTypeId = Constants.RT_ID_LEAD_INBOUND2,
                        ProcessedByLeanData__c = true,
                        Status = 'Open');
        insert ld;

        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);
        lc.setAccountId(acc.Id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();

        ld = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedOpportunityId, Country FROM Lead WHERE Id = :ld.Id];
        System.assertEquals(true, ld.IsConverted, 'IsConverted');
        System.assertEquals(acc.Id, ld.ConvertedAccountId, 'ConvertedAccountId');
        System.assertNotEquals(null, ld.ConvertedOpportunityId, 'ConvertedOpportunityId');
        System.assertEquals('Netherlands', ld.Country);
    }
    
    @IsTest
    private static void regionUpdateOnInsert(){
        
        // create lead
        Lead ld = new Lead(
                        FirstName = 'Jim',
                        LastName = 'Johnsson', 
                        Email = 'Johnsson@corp.com.fake',
                        Company = 'Johnsson Corp.',
                        Website = 'https://www.adyen.com',
                        Title = 'Mister',
                        SalesChannelSingle__c = 'Ecom',
                        CountryCode = 'BE',
                        MerchantCoreBusinessModel__c = 'Platforms',
                        SubBusinessModel__c = 'Marketplaces',
                        RecordTypeId = Constants.RT_ID_LEAD_INBOUND2,
                        ProcessedByLeanData__c = true,
                        Status = 'Open');
        
         //create custom setting record
        Regions__c regions = new Regions__c();
                        regions.Name = 'Belgium';
                        regions.Country__c = 'Belgium';
                        regions.Country_Code__c = 'BE';
                        regions.Queue__c = 'AMS';
                        regions.Region__c = 'EMEA';
                        regions.Sales_Office__c = 'Belgium';
                        insert regions;
      
        Test.startTest();
        insert ld;
        ld = [SELECT Region__c, Queue__c, SalesOffice__c FROM Lead WHERE Id = :ld.Id];
        Test.stopTest();
        
        System.assertEquals('EMEA', ld.Region__c);
        System.assertEquals('AMS', ld.Queue__c);
        System.assertEquals('Belgium', ld.SalesOffice__c);
    }
    
    /**
	 * test scenario: trying to convert 
	 * partner lead with 0 partner types
	 * expected result: validation error thrown
	 */
    @isTest
    public static void validatePartnerType_noPartnerTypes() {
        Account account = new Account(
                            Name = 'Barry BV',
                            Industry = 'Retail',
                            SubIndustry__c = 'Other',
                            Company_Segment__c = '25 - 50 million',
                            CurrencyIsoCode = 'EUR',
                            BillingCountry = 'Netherlands',
                			RecordTypeId = Constants.RT_ID_ACC_BUSINESS,
                			Account_Status__c = 'Prospect',
                			AccountType__c = 'Merchant',
                            CreatedDate = System.Now() - 10);
        insert account;
        
        Lead partnerLead = new Lead(
                        	FirstName = 'Jim',
                            LastName = 'Johnsson', 
                            Email = 'Johnsson@corp.com.fake',
                            Company = 'Johnsson Corp.',
                            Website = 'https://www.adyen.com',
                            Country = 'Netherlands',
                            Title = 'Mister',
                            SalesChannelSingle__c = 'Ecom',
                            Company_Segment__c = '25 - 50 million',
                        	RecordTypeId = Constants.RT_ID_LEAD_PARTNER,
                        	MerchantCoreBusinessModel__c = 'Digital',
                        	ProcessedByLeanData__c = true,
                        	Status = 'Open');
                    
        insert partnerLead;
        
        Test.startTest();
        try{
            Database.LeadConvert convertLead = new Database.LeadConvert();
            convertLead.setLeadId(partnerLead.Id);
            convertLead.setAccountId(account.Id);
            convertLead.setDoNotCreateOpportunity(true);
            convertLead.setConvertedStatus('Converted');
            Database.LeadConvertResult convertLeadResult = Database.convertLead(convertLead);
            Assert.fail('Validation Error Expected');
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.LeadPartnerTypeValidation) ? true : false;
            Assert.isTrue(expectedExceptionThrown, 'expected exception is thrown');
        }
        Test.stopTest();

        Lead expectedLead = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedOpportunityId FROM Lead WHERE Id = :partnerLead.Id];
        Assert.isFalse(expectedLead.IsConverted, 'Partner Lead was not converted');
      }
    
    /**
	 * test scenario: trying to convert partner 
	 * lead with either type/subtype not filled
	 * expected result: validation error thrown
	 */
    /*@isTest
    public static void validatePartnerTypes_fieldNotFilled() {
        system.debug('validatePartnerTypes_fieldNotFilled');
        Account account = new Account(
                            Name = 'Barry BV',
                            Industry = 'Retail',
                            SubIndustry__c = 'Other',
                            Company_Segment__c = '25 - 50 million',
                            CurrencyIsoCode = 'EUR',
                            BillingCountry = 'Netherlands',
                			RecordTypeId = Constants.RT_ID_ACC_BUSINESS,
                			Account_Status__c = 'Prospect',
                			AccountType__c = 'Merchant',
                            CreatedDate = System.Now() - 10);
        insert account;
        
        Lead partnerLead = new Lead(
                        	FirstName = 'Jim',
                            LastName = 'Johnsson', 
                            Email = 'Johnsson@corp.com.fake',
                            Company = 'Johnsson Corp.',
                            Website = 'https://www.adyen.com',
                            Country = 'Netherlands',
                            Title = 'Mister',
                            SalesChannelSingle__c = 'Ecom',
                            Company_Segment__c = '25 - 50 million',
                        	RecordTypeId = Constants.RT_ID_LEAD_PARTNER,
                        	MerchantCoreBusinessModel__c = 'Digital',
                        	ProcessedByLeanData__c = true,
                        	Status = 'Open',
        					NumberOfPartnerTypes__c = 1);
                    
        insert partnerLead;
        
        List<PartnerType__c> partnerTypes = new List<PartnerType__c>();
        PartnerType__c partnerTypeNotFilled = new PartnerType__c(
            									Lead__c  = partnerLead.Id, 
            									Type__c = 'Technology');
        PartnerType__c partnerTypeFilled = new PartnerType__c(
            									Lead__c  = partnerLead.Id, 
            									Type__c = 'Technology', 
            									SubType__c = 'Billing');
        partnerTypes.add(partnerTypeNotFilled);
        partnerTypes.add(partnerTypeFilled);
        insert partnerTypes;
        
        Test.startTest();
        try{
            Database.LeadConvert convertLead = new Database.LeadConvert();
            convertLead.setLeadId(partnerLead.Id);
            convertLead.setAccountId(account.Id);
            convertLead.setDoNotCreateOpportunity(true);
            convertLead.setConvertedStatus('Converted');
            Database.LeadConvertResult convertLeadResult = Database.convertLead(convertLead);
            Assert.fail('Validation Error Expected');
         }
        catch(Exception e){
			system.debug(e.getmessage() + ' ** partner type validation message');
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.LeadPartnerTypeValidation) ? true : false;
            Assert.isTrue(expectedExceptionThrown, 'expected exception is thrown');
        }
        Test.stopTest();

        Lead expectedLead = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedOpportunityId FROM Lead WHERE Id = :partnerLead.Id];
        Assert.isFalse(expectedLead.IsConverted, 'Partner Lead was not converted');
    }*/
    
    /**
	 * test scenario: trying to convert partner 
	 * lead with associated partner types and
	 * partner type's type/subtype filled
	 * expected result: lead converts successfully
	 */
    @isTest
    public static void validatePartnerTypes_partnerTypesFilled() {
        Account account = new Account(
                            Name = 'Barry BV',
                            Industry = 'Retail',
                            SubIndustry__c = 'Other',
                            Company_Segment__c = '25 - 50 million',
                            CurrencyIsoCode = 'EUR',
                            BillingCountry = 'Netherlands',
                			RecordTypeId = Constants.RT_ID_ACC_BUSINESS,
                			Account_Status__c = 'Prospect',
                			AccountType__c = 'Merchant',
                            CreatedDate = System.Now() - 10);
        insert account;
        
        Lead partnerLead = new Lead(
                        	FirstName = 'Jim',
                            LastName = 'Johnsson', 
                            Email = 'Johnsson@corp.com.fake',
                            Company = 'Johnsson Corp.',
                            Website = 'https://www.adyen.com',
                            Country = 'Netherlands',
                            Title = 'Mister',
                            SalesChannelSingle__c = 'Ecom',
                            Company_Segment__c = '25 - 50 million',
                        	RecordTypeId = Constants.RT_ID_LEAD_PARTNER,
                        	MerchantCoreBusinessModel__c = 'Digital',
                        	ProcessedByLeanData__c = true,
                        	Status = 'Open',
        					NumberOfPartnerTypes__c = 1);
                    
        insert partnerLead;
        
        PartnerType__c partnerTypeFilled = new PartnerType__c(
            									Lead__c  = partnerLead.Id, 
            									Type__c = 'Technology', 
            									SubType__c = 'Billing', 
            									Account__c = account.Id);
        insert partnerTypeFilled;
        
        Test.startTest();
        Database.LeadConvert convertLead = new Database.LeadConvert();
        convertLead.setLeadId(partnerLead.Id);
        convertLead.setAccountId(account.Id);
        convertLead.setDoNotCreateOpportunity(true);
        convertLead.setConvertedStatus('Converted');
        Database.LeadConvertResult convertLeadResult = Database.convertLead(convertLead);
        Test.stopTest();

        Lead expectedLead = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedOpportunityId FROM Lead WHERE Id = :partnerLead.Id];
        Assert.isTrue(expectedLead.IsConverted, 'Partner Lead was converted successfully');
        Assert.areEqual(account.Id, expectedLead.convertedAccountId, 'Partner Lead was converted to the expected account');
    }

    /**
	 * scenario: marketo trying to insert incomplete leads in Salesforce
	 */
    @IsTest
    public static void blockIncompleteLeadCreation() {
        Test.startTest();
        try {
            TestDataFactory.createSObjectList('Lead', LeadTestDataOverrides.inboundLeadBlockSync, 20, false);
        }
        catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Constants.blockLeadSyncErrorMessage) ? true : false;
            Assert.isTrue(expectedExceptionThrown, 'expected exception is thrown');
        }
        Test.stopTest();
    }
}