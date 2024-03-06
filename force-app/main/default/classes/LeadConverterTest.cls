/**
 * @author (s)    : Brite
 * @description
 */
@IsTest
private class LeadConverterTest
{
    @IsTest
    static void testHandleConvertedLeads_NewRecords()
    {
        Lead lead = createLead(null, null);

        Test.startTest();
        runDatabaseLeadConvert(lead.Id);
        Test.stopTest();

        // fetch the records that have been inserted during Test run
        Lead[] insertedLeads              = getInsertedLeads();
        //ConvertedLead__c[] convertedLeads = getConvertedLeads();
        Contact[] contacts                = getContacts();
        Account[] accounts                = getAccounts();
        Opportunity[] opportunities       = getOpportunities();

        // assert the amount of records that have been inserted during Lead Conversion
        System.assertEquals(1, insertedLeads.size());
        //System.assertEquals(0, convertedLeads.size());
        System.assertEquals(1, contacts.size());
        System.assertEquals(1, accounts.size());
        System.assertEquals(1, opportunities.size());

        lead            = insertedLeads.get(0);
        Contact con     = contacts.get(0);
        Account acc     = accounts.get(0);
        Opportunity opp = opportunities.get(0);

        // assert fields have been updated by the LeadConverter
        System.assertEquals(true, con.ConvertedFromLead__c);
        System.assertEquals(true, con.ConvertedAutomationExecuted__c);
        //System.assertEquals(lead.OwnerId, con.ConvertedLeadOwner__c);
        //System.assertEquals(lead.CurrentLeadSource__c, con.ConvertedLeadSource__c);
        System.assertEquals(lead.Current_Campaign__c, con.Converted_Campaign__c);
        System.assertEquals(lead.Current_Lead_Source_Detail__c, con.Converted_Lead_Source_Detail__c);
        System.assertEquals(lead.PartnerSource__c, con.ConvertedPartnerSource__c);
        System.assertEquals(lead.PointsOfEntry__c, con.ConvertedPointsOfEntry__c);
        System.assertEquals(lead.MessagesToSales__c, con.ConvertedMessagesToSales__c);  
        System.assertEquals(lead.CreatedDate, con.LeadCreatedDate__c);
        System.assertEquals(lead.Initial_Campaign__c, con.Initial_Campaign__c);
        System.assertEquals(lead.InitialLeadSource__c, con.InitialLeadSource__c);
        System.assertEquals(lead.Initial_Lead_Source_Detail__c, con.Initial_Lead_Source_Detail__c);
        System.assertEquals(lead.InitialPartnerSource__c, con.InitialPartnerSource__c); 

        // assert fields have been updated by the LeadConverter
        System.assertEquals(true, acc.ConvertedFromLead__c);
        System.assertEquals(true, acc.ConvertedAutomationExecuted__c);
        //System.assertEquals(lead.OwnerId, acc.ConvertedLeadOwner__c);
        System.assert(acc.RecordTypeId == Constants.RT_ID_ACC_BUSINESS );
        System.assert(acc.Account_Status__c == 'Prospect');
        System.assertEquals(lead.CurrencyIsoCode, acc.CurrencyIsoCode);

        // assert fields have been updated by the LeadConverter
        System.assertEquals(true, opp.ConvertedFromLead__c);
        System.assertEquals(true, opp.ConvertedAutomationExecuted__c);
        System.assertEquals(con.Id, opp.Opportunity_Primary_Contact__c);
        //System.assertEquals(lead.OwnerId, opp.ConvertedLeadOwner__c);
        //System.assertEquals(acc.ConvertedFromLead__c, opp.ConvertedOpportunityForNewAccount__c);
        System.assertEquals(Date.today().addDays(180), opp.CloseDate);
        System.assertEquals(Constants.RT_ID_OPP_SALES, opp.RecordTypeId);
        System.assertEquals(lead.Partner_Referral__c, opp.Referral_by_account__c);
        System.assertEquals(true, opp.Is_Sourced_From_Lead__c);
        System.assertEquals(lead.SalesChannelSingle__c, opp.Sales_channel__c);
    }

    @IsTest
    static void testHandleConvertedLeads_FieldValidation()
    {
        System.runAs(TestUtil.createUser()) {
            Lead lead = createLead(null, null);
            //lead.country = null;
            lead.Company_Segment__c = null;
            lead.Website = null;
            lead.Title = null;
            lead.Email = null;
            lead.MerchantCoreBusinessModel__c = null;
            lead.SubBusinessModel__c = null;
            lead.SalesChannelSingle__c = null;
            lead.Industry = null;
            lead.SubIndustry__c = null;
            //lead.FirstName = null;
            //lead.Company = null;
            update lead;
            String errorMessage = '';
            Test.startTest();
            try {
                runDatabaseLeadConvert(lead.Id);
            }
            catch (Exception e){
                errorMessage = e.getMessage();
            }
            Test.stopTest();
            system.assertEquals(false, String.isBlank(errorMessage), 'Expected an error to occur');
            //system.assertEquals(true, errorMessage.contains('Please check the following fields before converting this lead:'));
        }
    }
    
    
    @IsTest
    static void testHandleConvertedLeads_NewRecordsAsync()
    {
        Lead lead = createLead(null, null);

        Test.startTest();
        runDatabaseLeadConvertAsync(lead.Id);
        Test.stopTest();

        // fetch the records that have been inserted during Test run
        Lead[] insertedLeads              = getInsertedLeads();
        //ConvertedLead__c[] convertedLeads = getConvertedLeads();
        Contact[] contacts                = getContacts();
        Account[] accounts                = getAccounts();
        Opportunity[] opportunities       = getOpportunities();

        // assert the amount of records that have been inserted during Lead Conversion
        System.assertEquals(1, insertedLeads.size());
        //System.assertEquals(0, convertedLeads.size());
        System.assertEquals(1, contacts.size());
        System.assertEquals(1, accounts.size());
        System.assertEquals(1, opportunities.size());

        lead            = insertedLeads.get(0);
        Contact con     = contacts.get(0);
        Account acc     = accounts.get(0);
        Opportunity opp = opportunities.get(0);

        // assert fields have been updated by the LeadConverter
        System.assertEquals(true, con.ConvertedFromLead__c);
        System.assertEquals(true, con.ConvertedAutomationExecuted__c);
        //System.assertEquals(lead.OwnerId, con.ConvertedLeadOwner__c);
        System.assertEquals(lead.CurrentLeadSource__c, con.ConvertedLeadSource__c);
        System.assertEquals(lead.Current_Campaign__c, con.Converted_Campaign__c);
        System.assertEquals(lead.Current_Lead_Source_Detail__c, con.Converted_Lead_Source_Detail__c);
        System.assertEquals(lead.PartnerSource__c, con.ConvertedPartnerSource__c);
        System.assertEquals(lead.PointsOfEntry__c, con.ConvertedPointsOfEntry__c);
        System.assertEquals(lead.MessagesToSales__c, con.ConvertedMessagesToSales__c);        
        System.assertEquals(lead.CreatedDate, con.LeadCreatedDate__c);
        System.assertEquals(lead.Initial_Campaign__c, con.Initial_Campaign__c);
        System.assertEquals(lead.InitialLeadSource__c, con.InitialLeadSource__c);
        System.assertEquals(lead.Initial_Lead_Source_Detail__c, con.Initial_Lead_Source_Detail__c);        
        System.assertEquals(lead.InitialPartnerSource__c, con.InitialPartnerSource__c);

        // assert fields have been updated by the LeadConverter
        System.assertEquals(true, acc.ConvertedFromLead__c);
        System.assertEquals(true, acc.ConvertedAutomationExecuted__c);
        //System.assertEquals(lead.OwnerId, acc.ConvertedLeadOwner__c);
        System.assert(acc.RecordTypeId == Constants.RT_ID_ACC_BUSINESS);
        System.assert(acc.Account_Status__c == 'Prospect');
        System.assertEquals(lead.CurrencyIsoCode, acc.CurrencyIsoCode);

        // assert fields have been updated by the LeadConverter
        System.assertEquals(true, opp.ConvertedFromLead__c);
        System.assertEquals(true, opp.ConvertedAutomationExecuted__c);
        System.assertEquals(con.Id, opp.Opportunity_Primary_Contact__c);
        //System.assertEquals(lead.OwnerId, opp.ConvertedLeadOwner__c);
        //System.assertEquals(acc.ConvertedFromLead__c, opp.ConvertedOpportunityForNewAccount__c);
        System.assertEquals(Date.today().addDays(180), opp.CloseDate);
        System.assertEquals(Constants.RT_ID_OPP_SALES, opp.RecordTypeId);
        System.assertEquals(lead.Partner_Referral__c, opp.Referral_by_account__c);
        System.assertEquals(true, opp.Is_Sourced_From_Lead__c);
        System.assertEquals(lead.SalesChannelSingle__c, opp.Sales_channel__c);
    }
    
    @IsTest
    static void testHandleConvertedLeads_ExistingRecords()
    {
        Account acc     = TestUtil.createAccount('Test Company & Co.', false, true);
        TestUtil.createPartnerType(acc, true);
        Contact con     = TestUtil.createContact('Jones', 'jones@testcomp.com.fake', acc.Id, true);
        Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);

        Lead lead = createLead(acc.Id, con.Id);

        Test.startTest();
        runDatabaseLeadConvert(lead.Id);
        Test.stopTest();

        Lead[] insertedLeads              = getInsertedLeads();
        //ConvertedLead__c[] convertedLeads = getConvertedLeads();
        Contact[] contacts                = getContacts();
        Account[] accounts                = getAccounts();
        Opportunity[] opportunities       = getOpportunities();

        System.assertEquals(1, insertedLeads.size());
        //System.assertEquals(1, convertedLeads.size());
        System.assertEquals(2, contacts.size());
        System.assertEquals(2, accounts.size());
        System.assertEquals(2, opportunities.size());

        lead                           = insertedLeads.get(0);
        //ConvertedLead__c convertedLead = convertedLeads.get(0);

        //System.assertEquals(lead.FirstName + ' ' + lead.LastName, convertedLead.Name);
        //System.assertEquals(lead.Id, convertedLead.LeadName__c);
        //System.assertEquals(lead.ConvertedOpportunityId, convertedLead.Opportunity__c);
        //System.assertEquals(lead.Partner_Referral__c, convertedLead.PartnerReferral__c);
    }
    
    @IsTest
    static void testHandleConvertedLeads_ExistingChannelType()
    {
        Account acc     = TestUtil.createAccount('Test Company & Co.', false, true);
        TestUtil.createPartnerType(acc, true);
        Contact con     = TestUtil.createContact('Jones', 'jones@testcomp.com.fake', acc.Id, true);
        Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
        String ptType = 'Technology';
        String ptSubType = 'Ecommerce Platforms';
        String ptSubTypeNew = 'Billing ';
        PartnerType__c[] ptList = new List<PartnerType__c>();
        ptList.add(new PartnerType__c(Account__c = acc.ID, Type__c = ptType , SubType__c = ptSubType));
        Lead lead = createLead(null, null);
        ptList.add(new PartnerType__c(Lead__c = lead.ID, Type__c = ptType , SubType__c = ptSubType));
        ptList.add(new PartnerType__c(Lead__c = lead.ID, Type__c = ptType , SubType__c = ptSubTypeNew));
        insert ptList;
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setAccountId(acc.Id);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();

        Lead[] insertedLeads              = getInsertedLeads();
        //ConvertedLead__c[] convertedLeads = getConvertedLeads();
        Account[] accounts                = getAccounts();
        ptList = [SELECT Id, Type__c, SubType__c FROM PartnerType__c Where Account__c =: acc.Id];
        System.assertEquals(2, ptList.size());
        

    }

    
    
    @IsTest
    static void testHandleConvertedLeads_NewRelationshipOnNewAccount()
    {
        Account acc     = TestUtil.createAccount('Test Company & Co.', false, true);
        TestUtil.createPartnerType(acc, true);
        Contact con     = TestUtil.createContact('Jones', 'jones@testcomp.com.fake', acc.Id, true);
        Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
        String ptType = 'Technology';
        String ptSubType = 'Ecommerce Platforms';
        String ptSubTypeNew = 'Billing ';
        PartnerType__c[] ptList = new List<PartnerType__c>();
        ptList.add(new PartnerType__c(Account__c = acc.ID, Type__c = ptType , SubType__c = ptSubType));
        insert ptList;
        Lead lead = createLead(null, null);
        List<Relationship__c> rShipList = new List<Relationship__c>();
        rShipList.add(new Relationship__c(Lead__c = lead.ID, PartnerType__c = ptList[0].Id));
        insert rShipList;
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();

        Lead[] insertedLeads              = getInsertedLeads();
        //ConvertedLead__c[] convertedLeads = getConvertedLeads();
        Account[] accounts                = getAccounts();
        rShipList = [SELECT Id FROM Relationship__c Where Account__c =: insertedLeads[0].ConvertedAccountId];
        System.assertEquals(2, rShipList.size()); //1 for account, 1 for opportunity
    }
    
    @IsTest
    static void testHandleConvertedLeads_NewRelationshipOnExistingAccount()
    {
        Account acc     = TestUtil.createAccount('Test Company & Co.', false, true);
        TestUtil.createPartnerType(acc, true);
        Account accMerchant = TestUtil.createAccount('Test Company & Co2.', true, true);
        Contact con     = TestUtil.createContact('Jones', 'jones@testcomp.com.fake', acc.Id, true);
        Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
        String ptType = 'Technology';
        String ptSubType = 'Ecommerce Platforms';
        String ptSubTypeNew = 'Billing ';
        PartnerType__c[] ptList = new List<PartnerType__c>();
        ptList.add(new PartnerType__c(Account__c = acc.ID, Type__c = ptType , SubType__c = ptSubType));
        insert ptList;
        Lead lead = createLead(null, null);
        List<Relationship__c> rShipList = new List<Relationship__c>();
        rShipList.add(new Relationship__c(Lead__c = lead.ID, PartnerType__c = ptList[0].Id));
        insert rShipList;
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setAccountId(accMerchant.Id);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();

        Lead[] insertedLeads              = getInsertedLeads();
        //ConvertedLead__c[] convertedLeads = getConvertedLeads();
        Account[] accounts                = getAccounts();
        rShipList = [SELECT Id FROM Relationship__c Where Account__c =: insertedLeads[0].ConvertedAccountId];
        System.assertEquals(2, rShipList.size()); //1 for account, 1 for opportunity
    }
    
    @IsTest
    static void testHandleConvertedLeads_ExistingRelationshipExistingAccount()
    {
        Account acc     = TestUtil.createAccount('Test Company & Co.', false, true);
        TestUtil.createPartnerType(acc, true);
        Account accMerchant = TestUtil.createAccount('Test Company & Co2.', true, true);
        Contact con     = TestUtil.createContact('Jones', 'jones@testcomp.com.fake', acc.Id, true);
        Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), true);
        String ptType = 'Technology';
        String ptSubType = 'Ecommerce Platforms';
        String ptSubTypeNew = 'Billing ';
        PartnerType__c[] ptList = new List<PartnerType__c>();
        ptList.add(new PartnerType__c(Account__c = acc.ID, Type__c = ptType , SubType__c = ptSubType));
        insert ptList;
        Lead lead = createLead(null, null);
        List<Relationship__c> rShipList = new List<Relationship__c>();
        rShipList.add(new Relationship__c(Lead__c = lead.ID, PartnerType__c = ptList[0].Id));
        rShipList.add(new Relationship__c(Account__c = accMerchant.ID, PartnerType__c = ptList[0].Id));
        insert rShipList;
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setAccountId(accMerchant.Id);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();

        Lead[] insertedLeads              = getInsertedLeads();
        //ConvertedLead__c[] convertedLeads = getConvertedLeads();
        Account[] accounts                = getAccounts();
        rShipList = [SELECT Id FROM Relationship__c Where Account__c =: insertedLeads[0].ConvertedAccountId];
        System.assertEquals(2, rShipList.size()); //1 for account, 1 for opportunity
    }

    
    
    
    /**
     * Create and insert a new Lead record
     *
     * @param accId The Partner_Referral to set for the Lead. Can be NULL.
     * @param conId The PartnerContact to set for the Lead. Can be NULL.
     *
     * @return
     */
    private static Lead createLead(Id accId, Id conId)
    {
        Id leadRtId = Constants.RT_ID_LEAD_INBOUND2;
        Lead lead = new Lead(
            FirstName                    = 'Jim',
            LastName                     = 'Johnsson',
            Company                      = 'Johnsson Corp.',
            Title                        = 'Manager',
            Type__c                      = 'Merchant',
            Email                        = 'Johnsson@corp.com.fake',
            Website                      = 'https://www.adyen.com',
            Industry                     = 'Retail',
            SubIndustry__c               = 'Other',
            Street                       = 'Fakestreet 1',
            PostalCode                   = '1234AB',
            Country                      = 'Netherlands',
            SalesChannelSingle__c        = 'Mobile',
            Company_Segment__c           = '25 - 50 million',
            Partner_Referral__c          = accId,
            PartnerContact__c            = conId,
            PointsOfEntry__c             = 'Some Points of Entry',
            MessagesToSales__c           = 'Some Messages to Sales',
            Status                       = 'Open',
            MerchantCoreBusinessModel__c = 'Platforms',
            SubBusinessModel__c          = 'Marketplaces',
/**         CurrentLeadSource__c         = 'Partner',*/
            RecordTypeId                 = leadRtId,
            ProcessedByLeanData__c       = true
        );

        insert lead;

        return lead;
    }

    /**
     * Convert the given Lead to initiate the AfterUpdate of the Lead Trigger
     *
     * @param leadId
     *
     * @return
     */
    private static Database.LeadConvertResult runDatabaseLeadConvert(Id leadId)
    {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setConvertedStatus('Converted');

        Database.LeadConvertResult lcr = Database.convertLead(lc); // initiate AfterUpdate of the Lead Trigger

        return lcr;
    }

    
    /**
     * Convert the given Lead to initiate the AfterUpdate of the Lead Trigger in asynchronous context
     *
     * @param leadId
     *
     * @return
     */
    @future
    private static void runDatabaseLeadConvertAsync(Id leadId)
    {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setConvertedStatus('Converted');

        Database.LeadConvertResult lcr = Database.convertLead(lc); // initiate AfterUpdate of the Lead Trigger

    }
    
    
    /**
     * Fetch all Leads that were inserted during the Test run
     *
     * @return
     */
    private static Lead[] getInsertedLeads()
    {
        return [
            SELECT
                Id,
                FirstName,
                LastName,
                /*ConvertedLead__c,*/
                ConvertedContactId,
                ConvertedAccountId,
                ConvertedOpportunityId,
                Type__c,
                Partner_Referral__c,
                PartnerContact__c,
                OwnerId,
                CurrencyIsoCode,
                CurrentLeadSource__c,
                Current_Campaign__c,
                Current_Lead_Source_Detail__c,
                PartnerSource__c,
                PointsOfEntry__c,
                MessagesToSales__c,
                CreatedDate,
                Initial_Campaign__c,
                InitialLeadSource__c,
                Initial_Lead_Source_Detail__c,
                InitialPartnerSource__c,
                LeadDescription__c,
                SalesChannelSingle__c,
                MerchantCoreBusinessModel__c,
                SubBusinessModel__c
            FROM Lead
        ];
    }

    /**
     * Fetch all ConvertedLeads that were inserted during the Test run
     *
     * @return
     */
    /*private static ConvertedLead__c[] getConvertedLeads()
    {
        return [SELECT Name, LeadName__c, Opportunity__c, PartnerReferral__c FROM ConvertedLead__c];
    }*/

    /**
     * Fetch all Contacts that were inserted during the Test run
     *
     * @return
     */
    private static Contact[] getContacts()
    {
        return [
            SELECT
                ConvertedFromLead__c,
                ConvertedAutomationExecuted__c,
                /*ConvertedLeadOwner__c,*/
                ConvertedLeadSource__c,
                Converted_Campaign__c,
                Converted_Lead_Source_Detail__c,
                ConvertedPartnerSource__c,
                ConvertedMessagesToSales__c,
                ConvertedPointsOfEntry__c,
                LeadCreatedDate__c,
                Initial_Campaign__c,
                InitialLeadSource__c,
                Initial_Lead_Source_Detail__c,
                InitialPartnerSource__c,
                OwnerId
            FROM Contact
        ];
    }

    /**
     * Fetch all Accounts that were inserted during the Test run
     *
     * @return
     */
    private static Account[] getAccounts()
    {
        return [
            SELECT
                ConvertedFromLead__c,
                ConvertedAutomationExecuted__c,
                /*ConvertedLeadOwner__c,*/
                RecordTypeId,
                Account_Status__c,
                CurrencyIsoCode,
                OwnerId
            FROM Account
        ];
    }

    /**
     * Fetch all Opportunities that were inserted during the Test run
     *
     * @return
     */
    private static Opportunity[] getOpportunities()
    {
        return [
            SELECT
                ConvertedFromLead__c,
                ConvertedAutomationExecuted__c,
                Opportunity_Primary_Contact__c,
                /*ConvertedLeadOwner__c,*/
                OwnerId,
                ConvertedOpportunityForNewAccount__c,
                CloseDate,
                Pricebook2Id,
                RecordTypeId,
                Referral_by_account__c,
                Is_Sourced_From_Lead__c,
                Sales_channel__c
            FROM Opportunity
        ];
    }
    
}