/**
 * @description Test class for testing functionality of class OpportunityHelper
 * @author BRITE
 */
@isTest
private class OpportunityHelperTest {

    @isTest
    public static void testUpdateFieldsOnInsert() {
        // test opportunity name
        // case 1: null/empty list check
        try {
            OpportunityHelper.updateFieldsOnInsert(null);
            OpportunityHelper.updateFieldsOnInsert(new List<Opportunity> ());
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }

        Account acc = new Account(Name = 'Test Account7', BillingCountry = 'United States', Account_Status__c = Constants.ACC_STATUS_LIVEANDTRANSACTING);
        insert acc;
        
        // case 3: no account linked, no sales channel, no region
        DateTime currDateTime = DateTime.now();
        Date closeDate = currDateTime.date().addDays(30);
        Opportunity opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, Sales_channel__c = 'Ecom', AccountId = acc.Id, RegionCountry__c  = 'NL');
        insert opp;
        
        //opp = [SELECT Name FROM Opportunity WHERE Id = :opp.Id];
        //system.assertEquals('Default name -  - Ecom - ' + currDateTime.year(), opp.Name, 'Case 3: Name');
        
        // case 4: all fields populated, but but account name exceeds 50 chars
        acc = new Account(Name = 'This is an account with a very very very long name so the opportunity name will be too long to fit in the Name field', BillingCountry = 'United States',
                                 Account_Status__c = Constants.ACC_LIST_STATUS_NEWBUSINESS[0], RecordTypeId = Constants.RT_ID_ACC_BUSINESS);
        insert acc;
        opp = new Opportunity (Name = 'Default name', AccountId = acc.Id, Sales_channel__c = 'Mobile', Region__c = 'US', StageName = 'SCOTSMAN', CloseDate = closeDate, RegionCountry__c  = 'NL');
        insert opp;
        
        opp = [SELECT Name, Type FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals('Default name - This is an account with a very very very long name - Mobile - ' + currDateTime.year(), opp.Name, 'Case 4: Name');
        
        Test.startTest();
        
        // case 5: all fields populated normally
        acc = new Account(Name = 'Test my Account', BillingCountry = 'United States', Account_Status__c = Constants.ACC_STATUS_LIVEANDTRANSACTING);
        insert acc;
        opp = new Opportunity (Name = 'Default name', AccountId = acc.Id, Sales_channel__c = 'Mobile', Region__c = 'US', StageName = 'SCOTSMAN', CloseDate = closeDate, RegionCountry__c  = 'NL');
        insert opp;
        
        opp = [SELECT Name, Type FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals('Default name - Test my Account - Mobile - ' + currDateTime.year(), opp.Name, 'Case 5: Name');
        /* JVG20190101: Verify the new behaviour; why is the status 'new business'?
        system.assertNotEquals(Constants.OPP_TYPE_NEWBUSINESS, opp.Type, 'Case 5: Type <> new business');
        */
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateFieldsOnUpdate() {
        // test opportunity name
        /*
        DateTime currDateTime = DateTime.now();
        Account acc = new Account(Name = 'This is an account with a very very very long name so the opportunity name will be too long to fit in the Name field', BillingCountry = 'United States',
                                 Account_Status__c = Constants.ACC_LIST_STATUS_NEWBUSINESS[0]);
        insert acc;
        Date closeDate = currDateTime.date().addDays(30);
        Opportunity opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, Sales_channel__c = 'Ecom', AccountId = acc.Id); 
        insert opp;
        
        // case 1: null/empty list check
        try {
            OpportunityHelper.updateFieldsOnUpdate(null, null);
            OpportunityHelper.updateFieldsOnUpdate(new List<Opportunity> (), null);
            OpportunityHelper.updateFieldsOnUpdate(new List<Opportunity> {opp}, null);
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // case 3: link account
        update new Opportunity(Id = opp.Id, AccountId = acc.Id);
        
        opp = [SELECT Id, Name, AccountId, Region__c, Sales_channel__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals('Default name - This is an account with a very very very long name - Ecom - ' + currDateTime.year(), opp.Name, 'Case 3: Name');
        
        // case 4: change account to shorter name
        acc.Name = 'Test Account';
        update acc;
        
        opp = [SELECT Id, Name, AccountId, Region__c, Sales_channel__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals('Default name - Test Account - Ecom - ' + currDateTime.year(), opp.Name, 'Case 4: Name');
        
        // case 6: change sales channel
        opp.Sales_channel__c = 'Mobile';
        update opp;
        
        opp = [SELECT Id, Name, AccountId, Region__c, Sales_channel__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals('Default name - Test Account - Mobile - ' + currDateTime.year(), opp.Name, 'Case 6: Name');
        
        // case 7: null check on updateOpportunityName
        try {
            OpportunityHelper.updateOpportunityName(null, null);
            OpportunityHelper.updateOpportunityName(new List<Account> (), null);
            OpportunityHelper.updateOpportunityName(new List<Account> {acc}, null);
        } catch (Exception ex) {
            system.assert(false, 'Case 7: Exception thrown: ' + ex.getMessage());
        }
        */
    }
    
    /* @isTest
    Commenting this method as it no more used 
    public static void testSetOpportunitySource() {
        DateTime currDateTime = DateTime.now();
        Account acc = new Account(Name = 'Test Account', BillingCountry = 'United States',
                                 Account_Status__c = Constants.ACC_LIST_STATUS_NEWBUSINESS[0]);
        //Brite16Oct2019 changed disabled recordtype id Constants.RT_ID_ACC_PARTNER to Constants.RT_ID_ACC_PARTNER_V2
        Account refAcc = new Account(Name = 'Referral Account', BillingCountry = 'United States', Type = Constants.ACC_TYPE_PARTNER, RecordTypeId = Constants.RT_ID_ACC_PARTNER_V2);
        insert new List<Account> {acc, refAcc};
        
        Date closeDate = currDateTime.date().addDays(30);
        
        Account tmpAcc = [SELECT Id, RecordTypeId, RecordType.Name FROM Account WHERE Id = :refAcc.Id];
        system.assertEquals(Constants.RT_ID_ACC_PARTNER_V2, tmpAcc.RecordTypeId, 'Record type of referral has been changed: ' + tmpAcc);
        
      
                // case 1: lead source = digital marketing
        Opportunity opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                                            RecordTypeId = Constants.RT_ID_OPP_SALES, AccountId = acc.Id); 
        insert opp;
        
        opp = [SELECT Id, Opportunity_Source__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(Constants.OPP_OPPSOURCE_DIGITMARKETING, opp.Opportunity_Source__c, 'Case 1: Opportunity_Source__c');
        
        // case 2a: lead source = partner
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LEADSOURCE_PARTNER,
                               RecordTypeId = Constants.RT_ID_OPP_SALES, AccountId = acc.Id); 
        insert opp;
        
        opp = [SELECT Id, Opportunity_Source__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(Constants.OPP_OPPSOURCE_PARTNERSHIP, opp.Opportunity_Source__c, 'Case 2a: Opportunity_Source__c');
        
        // case 2b: referral by account - type = partner
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, Referral_by_account__c = refAcc.Id,
                               RecordTypeId = Constants.RT_ID_OPP_SALES, AccountId = acc.Id); 
        insert opp;
        
        opp = [SELECT Id, Opportunity_Source__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(Constants.OPP_OPPSOURCE_PARTNERSHIP, opp.Opportunity_Source__c, 'Case 2b: Opportunity_Source__c');
        
        // case 3: lead source = event
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_EVENT[0],
                               RecordTypeId = Constants.RT_ID_OPP_SALES, AccountId = acc.Id); 
        insert opp;
        
        opp = [SELECT Id, Opportunity_Source__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(Constants.OPP_OPPSOURCE_EVENTS, opp.Opportunity_Source__c, 'Case 3: Opportunity_Source__c');
        
        // case 4: lead source = referral
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_REFERRAL[0],
                               RecordTypeId = Constants.RT_ID_OPP_SALES, AccountId = acc.Id); 
        insert opp;
        
        opp = [SELECT Id, Opportunity_Source__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(Constants.OPP_OPPSOURCE_REFERRAL, opp.Opportunity_Source__c, 'Case 4: Opportunity_Source__c');
        
        // case 5: lead source = inbound call
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LEADSOURCE_INBOUNDCALL,
                               RecordTypeId = Constants.RT_ID_OPP_SALES, AccountId = acc.Id); 
        insert opp;
        
        opp = [SELECT Id, Opportunity_Source__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(Constants.OPP_OPPSOURCE_INBOUNDCALL, opp.Opportunity_Source__c, 'Case 5: Opportunity_Source__c');
        
        // case 6: lead source = sales - self generated
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_SALESSELFGEN[1],
                               RecordTypeId = Constants.RT_ID_OPP_SALES, AccountId = acc.Id); 
        insert opp;
        
        opp = [SELECT Id, Opportunity_Source__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(Constants.OPP_OPPSOURCE_SALESSELFGEN, opp.Opportunity_Source__c, 'Case 6: Opportunity_Source__c');
        
        // case 7: lead source not populated
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, RecordTypeId = Constants.RT_ID_OPP_SALES, AccountId = acc.Id); 
        insert opp;
        
        opp = [SELECT Id, Opportunity_Source__c, LeadSource FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(Constants.OPP_OPPSOURCE_SALESSELFGEN, opp.Opportunity_Source__c, 'Case 7: Opportunity_Source__c');
        
        // case 8: update of lead source
        opp.LeadSource = Constants.OPP_LEADSOURCE_INBOUNDCALL;
        update opp;
        
        opp = [SELECT Id, Opportunity_Source__c FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(Constants.OPP_OPPSOURCE_INBOUNDCALL, opp.Opportunity_Source__c, 'Case 8: Opportunity_Source__c');
    }*/

    
    /*@isTest
    public static void testSetStageDate() {
        Opportunity opp = new Opportunity();
        Date dateToday = Date.today();
        Date dateTwoDaysAgo = dateToday.addDays(-2);
        
 
         // case 1a: stage = SCOTSMAN - date already set
        opp.stageName = 'SCOTSMAN';
        opp.ScotsmanDate__c = dateTwoDaysAgo;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateTwoDaysAgo, opp.ScotsmanDate__c, 'Case 2a: SCOTSMAN Date');
        
        // case 1b: stage = SCOTSMAN - date not set
        opp.ScotsmanDate__c = null;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateToday, opp.ScotsmanDate__c, 'Case 2b: SCOTSMAN Date');
        

        // case 2a: stage = Proposal/RFP Sent - date already set
        opp.stageName = 'Proposal/RFP Sent';
        opp.Detailed_Proposal_Sent_Date__c = dateTwoDaysAgo;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateTwoDaysAgo, opp.Detailed_Proposal_Sent_Date__c, 'Case 4a: Proposal/RFP Sent Date');

        // case 2b: stage = Proposal/RFP Sent - date not set
        opp.Detailed_Proposal_Sent_Date__c = null;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateToday, opp.Detailed_Proposal_Sent_Date__c, 'Case 4b: Proposal/RFP Sent Date');

        // case 3a: stage = Negotiation - date already set
        opp.stageName = 'Negotiation';
        opp.Negotiation_Date__c = dateTwoDaysAgo;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateTwoDaysAgo, opp.Negotiation_Date__c, 'Case 7a: Negotiation Date');

        // case 3b: stage = Negotiation - date not set
        opp.Negotiation_Date__c = null;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateToday, opp.Negotiation_Date__c, 'Case 7b: Negotiation Date');
        
        // case 4a: stage = Commitment - date already set
        opp.stageName = 'Commitment';
        opp.Commitment_Date__c = dateTwoDaysAgo;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateTwoDaysAgo, opp.Commitment_Date__c, 'Case 8a: Commitment Date');

        // case 4b: stage = Commitment - date not set
        opp.Commitment_Date__c = null;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateToday, opp.Commitment_Date__c, 'Case 8b: Commitment Date');

        // case 5a: stage = Contract signed - date already set
        opp.stageName = 'Contract signed';
        opp.Contract_Signed_Date__c = dateTwoDaysAgo;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateTwoDaysAgo, opp.Contract_Signed_Date__c, 'Case 9a: Contract signed Date');

        // case 5b: stage = Contract signed - date not set
        opp.Contract_Signed_Date__c = null;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateToday, opp.Contract_Signed_Date__c, 'Case 9b: Contract signed Date');
        
        // case 6a: stage = Transacting - date already set
        opp.stageName = 'Transacting';
        opp.Live_Stage_Date__c = dateTwoDaysAgo;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateTwoDaysAgo, opp.Live_Stage_Date__c, 'Case 11a: Transacting Date');

        // case 6b: stage = Transacting - date not set
        opp.Live_Stage_Date__c = null;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateToday, opp.Live_Stage_Date__c, 'Case 11b: Transacting Date');
        
        // case 7a: stage = Closed Lost - date already set
        opp.stageName = 'Closed Lost';
        opp.Closed_Lost_Date__c = dateTwoDaysAgo;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateTwoDaysAgo, opp.Closed_Lost_Date__c, 'Case 12a: Closed Lost Date');

        // case 7b: stage = Closed Lost - date not set
        opp.Closed_Lost_Date__c = null;
        OpportunityHelper.setStageDate(opp);
        system.assertEquals(dateToday, opp.Closed_Lost_Date__c, 'Case 12b: Closed Lost Date');
        
        // case 8: set date via insert trigger
        DateTime currDateTime = DateTime.now();
        Account acc = new Account(Name = 'My Test Company', BillingCountry = 'United States',
                                 Account_Status__c = Constants.ACC_LIST_STATUS_NEWBUSINESS[0]);
        insert acc;
        Date closeDate = currDateTime.date().addDays(30);
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, AccountId = acc.Id, RecordTypeId = Constants.RT_ID_OPP_SALES, RegionCountry__c  = 'NL');
        insert opp;
        
        opp = [SELECT Id, StageName, ScotsmanDate__c, Negotiation_Date__c FROM Opportunity WHERE ID = :opp.Id];
        system.assertNotEquals(null, opp.ScotsmanDate__c, 'Case 9: date after insert - Scotsman_Date__c');
        system.assertEquals(null, opp.Negotiation_Date__c, 'Case 9: date after insert - Negotiation_Date__c');
        
        // case 9: set date via update trigger
        opp.StageName = 'Negotiation';
        opp.EstimatedATV__c  = 4000;
        opp.NumberOfTransactionsAMonth__c = 5;
        opp.Total_Gross_Margin_Services_Products__c = 123;
        opp.PartnersInvolvedForThisOpp__c = 'No';
        opp.FullExpectedMonthlyGrossMargin__c = 500;
        opp.FullMarginExpectedDate__c = currDateTime.date().addDays(30);
        update opp;
        
        opp = [SELECT Id, StageName, Negotiation_Date__c FROM Opportunity WHERE ID = :opp.Id];
        system.assertNotEquals(null, opp.Negotiation_Date__c, 'Case 14: date after update');
    }*/
    
    @isTest
    public static void testRecordTypeAndOwnerUpdateAfterConversion() {
        
        /* JVG 20190101: Verify the assignment of record types */
        DateTime currDateTime = DateTime.now();
        //Brite 16Oktober2019 replaced all RT_ID_ACC_MERCHANT by RT_ID_ACC_COMPETITOR
        Account acc = new Account(Name = 'Test Account', BillingCountry = 'United States', RecordTypeId = Constants.RT_ID_ACC_COMPETITOR,
                                 Account_Status__c = Constants.ACC_LIST_STATUS_NEWBUSINESS[0]);
        insert acc;
        
        Date closeDate = currDateTime.date().addDays(30);
        
        // case 1: sales channel = POS => record type should be set to opportunity POS
        Opportunity opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                                           AccountId = acc.Id, RecordTypeId = Constants.RT_ID_OPP_SALES, Sales_channel__c = 'POS', ConvertedFromLead__c = true, RegionCountry__c  = 'NL');
        insert opp;
        
        System.debug('1');
        opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id = :opp.Id];
        //system.assertEquals(Constants.RT_ID_OPP_POS, opp.RecordTypeId, 'Case 1: Record type Id');
        
        // case 2: sales channel = Ecom => record type should be set to opportunity Ecom
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                               AccountId = acc.Id, RecordTypeId = Constants.RT_ID_OPP_SALES, Sales_channel__c = 'Ecom', ConvertedFromLead__c = true, RegionCountry__c  = 'NL');
        insert opp;
        
        System.debug('2');
        opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id = :opp.Id];
        //system.assertEquals(Constants.RT_ID_OPP_ECOM, opp.RecordTypeId, 'Case 2: Record type Id');
        
        Test.startTest();
        // case 3: sales channel = Mobile => record type should be set to opportunity Ecom
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                               AccountId = acc.Id, RecordTypeId = Constants.RT_ID_OPP_SALES, Sales_channel__c = 'Mobile', ConvertedFromLead__c = true, RegionCountry__c  = 'NL');
        
        insert opp;
        
        System.debug('3');
        opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id = :opp.Id];
        //system.assertEquals(Constants.RT_ID_OPP_ECOM, opp.RecordTypeId, 'Case 3: Record type Id');
        // case 4: sales channel = Ecom, but opportunity is not created from lead => record type should not be changed
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                               AccountId = acc.Id, RecordTypeId = Constants.RT_ID_OPP_SALES, Sales_channel__c = 'POS', ConvertedFromLead__c = false, RegionCountry__c  = 'NL');
        insert opp;
        
        System.debug('4');
        opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id = :opp.Id];
        //system.assertEquals(Constants.RT_ID_OPP_SALES, opp.RecordTypeId, 'Case 4: Record type Id');
        
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'Adyen Salesforce Administrator' LIMIT 1][0].Id;
        User usr = [SELECT Id FROM User WHERE IsActive = true AND ID != :UserInfo.getUserId() AND ProfileId = :ProfileId LIMIT 1];
        
        // case 5: verify if field 'ConvertedFromLead__c' is set to true after conversion
        Lead ld = new Lead(RecordTypeId = Constants.RT_ID_LEAD_INBOUND2, FirstName = 'Fred', LastName = 'Jones', Email = 'f.jones@jones.com.fake', Company = 'Jones & Co.', 
                           Website = 'joneswebsite.fake', Country = 'Belgium', Industry = 'Retail', SubIndustry__c = 'Other', Status = 'Open');
        insert ld;
        System.debug('5');
       // ld.AccountAssignment__c = usr.Id; // on insert this field will be overwritten
        //update ld;
        
        /*Flow runs into 101 query exception!! 
        ld = [SELECT Id, AccountAssignment__c FROM Lead WHERE Id = :ld.Id];
        //system.assertEquals(usr.Id, ld.AccountAssignment__c, 'Case 5: assigned user on lead has been changed');
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true AND ApiName = 'Converted' LIMIT 1];
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(ld.Id);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        //system.assert(lcr.isSuccess(), 'Case 5: lead conversion not successful: ' + lcr.getErrors());
        
        opp = [SELECT Id, ConvertedFromLead__c, OwnerAfterLeadConversion__c, OwnerId FROM Opportunity WHERE Id = :lcr.getOpportunityId()];
        Flow runs into 101 query exception!! */

        //system.assert(opp.ConvertedFromLead__c, 'Case 5: ConvertedFromLead__c not set to true');
        //system.assertEquals(usr.Id, opp.OwnerAfterLeadConversion__c, 'Case 5: OwnerAfterLeadConversion__c');
        //@TODO DvtH20190125 temporary disabled on request
        //system.assertEquals(usr.Id, opp.OwnerId, 'Case 5: OwnerId');
        
        // case 6: owner of the opportunity has an Adyen v2 profile
        //usr = [SELECT Id FROM User WHERE IsActive = true AND ID != :UserInfo.getUserId() AND Profile.Name LIKE 'Adyen v2%' LIMIT 1];
        //opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
        //                       AccountId = acc.Id, RecordTypeId = Constants.RT_ID_OPP_SALES, Sales_channel__c = 'Ecom', ConvertedFromLead__c = true, OwnerAfterLeadConversion__c = usr.Id); 
        //insert opp;
        
        //opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id = :opp.Id];
        //system.assertEquals(Constants.RT_ID_OPP_SALES, opp.RecordTypeId, 'Case 6: Record type Id');
        Test.stopTest();
    }
    
    @isTest
    public static void testSetCloseDate() {
        DateTime currDateTime = DateTime.now();
        //Brite 16Oktober2019 replaced all RT_ID_ACC_MERCHANT by RT_ID_ACC_COMPETITOR
        Account acc = new Account(Name = 'Test Account', BillingCountry = 'United States', RecordTypeId = Constants.RT_ID_ACC_COMPETITOR,
                                 Account_Status__c = Constants.ACC_LIST_STATUS_NEWBUSINESS[0]);
        insert acc;
        
        Date closeDate = currDateTime.date().addDays(30);
        
        // case 1: insert opportunity (not converted) -> don't overwrite close date
        Opportunity opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                                           AccountId = acc.Id, RecordTypeId = Constants.RT_ID_OPP_SALES, Sales_channel__c = 'POS', Is_Sourced_From_Lead__c = false, RegionCountry__c  = 'NL');
        insert opp;
        
        opp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(closeDate, opp.CloseDate, 'Case 1: CloseDate');
        
        // case 2: insert via converted lead -> set close date
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                               AccountId = acc.Id, RecordTypeId = Constants.RT_ID_OPP_SALES, Sales_channel__c = 'POS', Is_Sourced_From_Lead__c = true, RegionCountry__c  = 'NL');
        insert opp;
        
        opp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :opp.Id];
        system.assertNotEquals(closeDate, opp.CloseDate, 'Case 2: CloseDate');
        
        // case 3: update opportunity that was being created via lead conversion before -> don't overwrite close date (should only be done at insert)
        opp.CloseDate = closeDate;
        update opp;

        opp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(closeDate, opp.CloseDate, 'Case 3: CloseDate');
    }
    
    @isTest(SeeAllData=true)
    public static void testAssignmentPricebook2() {
        DateTime currDateTime = DateTime.now();
        Id RT_OPP_GIVING = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('AdyenGivingOpportunity').getRecordTypeId();
        //Brite 16Oktober2019 replaced all RT_ID_ACC_MERCHANT by RT_ID_ACC_COMPETITOR
        Account acc = new Account(Name = 'UnitTest Account', BillingCountry = 'United States', RecordTypeId = Constants.RT_ID_ACC_COMPETITOR,
                                 Account_Status__c = Constants.ACC_LIST_STATUS_NEWBUSINESS[0]);
        insert acc;
        
        Date closeDate = currDateTime.date().addDays(30);
        
        // case 1: pricebook2 set to EUR
        Opportunity opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                                           RecordTypeId = RT_OPP_GIVING, Sales_channel__c = 'POS', CurrencyIsoCode = 'EUR', AccountId = acc.Id, RegionCountry__c  = 'NL');
        insert opp;
        
        opp = [SELECT Id, Pricebook2Id, Pricebook2.Name FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals('[Don\'t Use] Adyen EUR Price Book', opp.Pricebook2.Name, 'Case 1: pricebook2');
        
        // case 2: pricebook2 set to USD
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                               RecordTypeId = RT_OPP_GIVING, Sales_channel__c = 'POS', CurrencyIsoCode = 'USD', AccountId = acc.Id, RegionCountry__c  = 'NL');
        insert opp;
        
        opp = [SELECT Id, Pricebook2Id, Pricebook2.Name FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals('[Don\'t Use] Adyen USD Price Book', opp.Pricebook2.Name, 'Case 2: pricebook2');
        Test.startTest();
        
        // case 3: pricebook2 set to GBP
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                               RecordTypeId = RT_OPP_GIVING, Sales_channel__c = 'POS', CurrencyIsoCode = 'GBP', AccountId = acc.Id, RegionCountry__c  = 'NL');
        insert opp;
        
        opp = [SELECT Id, Pricebook2Id, Pricebook2.Name FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals('[Don\'t Use] Adyen GBP Price Book', opp.Pricebook2.Name, 'Case 3: pricebook2');
        
        // case 4: pricebook2 not set for other currencies
        opp = new Opportunity (Name = 'Default name', StageName = 'SCOTSMAN', CloseDate = closeDate, LeadSource = Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING[0],
                               RecordTypeId = RT_OPP_GIVING, Sales_channel__c = 'POS', CurrencyIsoCode = 'AUD', AccountId = acc.Id, RegionCountry__c  = 'NL');
        insert opp;
        
        opp = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id];
        system.assertEquals(null, opp.Pricebook2Id, 'Case 4: pricebook2 for AUD');
        Test.stopTest();
    }
    
    @isTest
    public static void testDetermineOpportunityName() {
        String resultName = OpportunityHelper.determineOpportunityName('New opportunity', 'Adyen Amsterdam', 'POS', 2019);
        system.assertEquals('New opportunity - Adyen Amsterdam - POS - 2019', resultName, 'Case 1');

        resultName = OpportunityHelper.determineOpportunityName('New opportunity - Adyen Amsterdam - POS - 2019', 'Adyen N.V.', 'POS', 2019);
        system.assertEquals('New opportunity - Adyen N.V. - POS - 2019', resultName, 'Case 2');

        resultName = OpportunityHelper.determineOpportunityName('- Adyen Amsterdam - POS - 2019', 'Adyen N.V.', 'POS', 2019);
        system.assertEquals('Opportunity - Adyen N.V. - POS - 2019', resultName, 'Case 2');
    }
    
}