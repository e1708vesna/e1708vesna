/**
* @author Sales
* @group Test Data Overrides
* @description overrides to be passed into TestDataFactory
* for test data creation. can be reused for Lead Data Creation
*/
@isTest
public with sharing class LeadTestDataOverrides {

    public static Contact referralContact = createReferralContact();

    /* PARTNER LEAD OVERRIDES */
    public static Map<String, Object> partnerLeadAllDataWithPT = new Map<String, Object>{
            'RecordTypeId' => Constants.RT_ID_LEAD_PARTNER,
            'Status' => 'Open',
            'Country' => 'Netherlands',
            'Website' => 'validation@partnerlead.com',
            'Title' => 'TestTitle',
            'NumberOfPartnerTypes__c' => 1,
            'Email' => 'test@invalid.com',
            'FirstName' => 'PartnerLead',
            'LastName' => 'AllData-WithPT',
            'CurrentLeadSource__c' => 'Online Advertising',
            'Current_Campaign__c' => 'Test Current Campaign',
            'Current_Lead_Source_Detail__c' => 'Test Current Lead Source Detail',
            'PartnerSource__c' => 'Test Partner Source',
            'MessagesToSales__c' => 'Test Messages to Sales',
            'PointsOfEntry__c' => 'Test Points of Entry',
            'Initial_Campaign__c' => 'Test Initial Campaign',
            'InitialLeadSource__c' => 'Direct',
            'Initial_Lead_Source_Detail__c' => 'Test Initial Lead Source Detail',
            'InitialPartnerSource__c' => 'Test Initial Partner Source',
            'SAL_Date__c' => Date.today().addDays(-20),
            'MQL_Date__c' => Date.today().addDays(-20),
            'BehaviorScore__c' => 20.2,
            'LeadOrigin__c' => 'Outbound',
            'Partner_Referral__c' => referralContact.AccountId,
            'PartnerContact__c' => referralContact.Id
    };

    public static Map<String, Object> partnerLeadAllDataNoPT= new Map<String, Object>{
            'RecordTypeId' => Constants.RT_ID_LEAD_PARTNER,
            'Status' => 'Open',
            'Website' => 'validation@partnerlead.com',
            'Title' => 'TestTitle',
            'NumberOfPartnerTypes__c' => 0,
            'FirstName' => 'PartnerLead',
            'LastName' => 'AllData-NoPT'
    };

    public static Map<String, Object> partnerLeadIncompleteDataWithPT = new Map<String, Object>{
            'RecordTypeId' => Constants.RT_ID_LEAD_PARTNER,
            'Status' => 'Open',
            'NumberOfPartnerTypes__c' => 1,
            'LastName' => 'PartnerLead-WrongData-WithPT',
            'Country' => 'Netherlands',
            'FirstName' => 'PartnerLead'
    };

    /* PARTNER LEAD OVERRIDES */

    /*INBOUND LEAD OVERRIDES*/
    public static Map<String, Object> inboundLeadIncompleteData = new Map<String, Object> {
            'RecordTypeId' => Constants.RT_ID_LEAD_INBOUND2,
            'Status' => 'Open',
            'LastName' => 'InboundLead-WrongData',
            'Country' => 'Netherlands',
            'FirstName' => 'Test',
            'Email' => 'test@test.com'
    };

    public static Map<String, Object> inboundLeadAllData = new Map<String, Object> {
            'Title' => 'CEO',
            'RecordTypeId' => Constants.RT_ID_LEAD_INBOUND2,
            'Country' => 'Netherlands',
            'Status' => 'Open',
            'Website' => 'inboundleadincompletedata@test.com',
            'LastName' => 'InboundLead-AllData',
            'FirstName' => 'InboundLead',
            'Email' => 'test@invalid.com',
            'Company_Segment__c' => '1 - 5 million',
            'SalesChannelSingle__c' => 'Adyen for Platforms',
            'Industry' => 'Delivery Services',
            'SubIndustry__c' => 'Food Delivery',
            'MerchantCoreBusinessModel__c' => 'Platforms',
            'SubBusinessModel__c' => 'Marketplaces',
            'BehaviorScore__c' => 30,
            'CurrentLeadSource__c' => 'Direct',
            'Current_Lead_Source_Detail__c' => 'Test Current Lead Source Detail',
            'PreferredLanguage__c' => 'English'
    };

    public static Map<String, Object> inboundReferralLeadAllData = new Map<String, Object> {
            'RecordTypeId' => Constants.RT_ID_LEAD_INBOUND2,
            'Country' => 'Netherlands',
            'Status' => 'Open',
            'Website' => 'inboundleadincompletedata@test.com',
            'LastName' => 'InboundLead-AllData',
            'FirstName' => 'InboundLead',
            'Email' => 'test@invalid.com',
            'Company_Segment__c' => '1 - 5 million',
            'SalesChannelSingle__c' => 'Adyen for Platforms',
            'Industry' => 'Delivery Services',
            'SubIndustry__c' => 'Food Delivery',
            'MerchantCoreBusinessModel__c' => 'Platforms',
            'SubBusinessModel__c' => 'Marketplaces',
            'Partner_Referral__c' => referralContact.AccountId,
            'PartnerContact__c' => referralContact.Id
    };

    public static Map<String, Object> inboundLeadBlockSync = new Map<String, Object> {
            'RecordTypeId' => Constants.RT_ID_LEAD_INBOUND2,
            'Country' => 'Netherlands',
            'Status' => 'Open',
            'Website' => 'inboundleadincompletedata@test.com',
            'LastName' => 'InboundLead-AllData',
            'FirstName' => 'InboundLead',
            'Email' => 'test@invalid.com',
            'DoNotSyncToSFDC__c' => true
    };
    /*INBOUND LEAD OVERRIDES*/

    /* ACCOUNT OVERRIDES */
    public static Map<String, Object> businessAccount = new Map<String, Object>{
            'RecordTypeId' => Constants.RT_ID_ACC_BUSINESS,
            'BillingCountry' => 'Colombia',
            'Industry' => 'Retail',
            'SubIndustry__c' => 'Other',
            'Company_Segment__c' => '25 - 50 million',
            'MerchantCoreBusinessModel__c' => 'Platforms',
            'SubBusinessModel__c' => 'Marketplaces',
            'Name' => 'ConvertedBusinessAccount',
            'ConvertedAutomationExecuted__c' => true,
            'Website' => 'test@test.com'
    };

    public static Map<String, Object> businessAccountWithoutDependents = new Map<String, Object>{
            'RecordTypeId' => Constants.RT_ID_ACC_BUSINESS,
            'BillingCountry' => 'Colombia',
            'Company_Segment__c' => '25 - 50 million',
            'Name' => 'ConvertedBusinessAccount-WithoutDependents',
            'ConvertedAutomationExecuted__c' => true
    };

    public static Map<String, Object> partnerAccount = new Map<String, Object>{
            'Name' => 'PartnerAccount',
            'RecordTypeId' => Constants.RT_ID_ACC_PARTNER_V2,
            'BillingCountry' => 'Colombia',
            'Industry' => 'Retail',
            'SubIndustry__c' => 'Other',
            'Company_Segment__c' => '25 - 50 million',
            'MerchantCoreBusinessModel__c' => 'Platforms',
            'SubBusinessModel__c' => 'Marketplaces',
            'Country' => 'Netherlands',
            'ConvertedAutomationExecuted__c' => true
    };
    /* ACCOUNT OVERRIDES */

    /* OPPORTUNITY OVERRIDES */
    public static Map<String, Object> opportunity = new Map<String, Object> {
        'Sales_channel__c' => 'Ecom',
        'RegionCountry__c' => 'NL',
        'Name' => 'ConvertedOpportunity',
        'ConvertedAutomationExecuted__c' => true
    };
    /* OPPORTUNITY OVERRIDES */

    /*CONTACT OVERRIDES*/
    public static Map<String, Object> contact = new Map<String, Object> {
            'FirstName' => 'Test',
            'LastName' => 'ConvertedContact',
            'Title' => 'TestTitle',
            'Email' => 'test@test.com',
            'Account.Name' => 'PartnerAccount',
            'Account.RecordTypeId' => Constants.RT_ID_ACC_PARTNER_V2,
            'Account.BillingCountry' => 'Colombia',
            'Account.Industry' => 'Retail',
            'Account.SubIndustry__c' => 'Other',
            'Account.Company_Segment__c' => '25 - 50 million',
            'Account.MerchantCoreBusinessModel__c' => 'Platforms',
            'Account.SubBusinessModel__c' => 'Marketplaces',
            'BehaviorScore__c' => 10,
            'ConvertedAutomationExecuted__c' => true
    };
    /*CONTACT OVERRIDES*/

    @isTest
    public static Contact createReferralContact() {
        //Account partnerAccount = (Account)TestDataFactory.createSObject('Account', partnerAccount);
        return (Contact)TestDataFactory.createSObject('Contact', new Map<String, Object> {
                'FirstName' => 'Test',
                'LastName' => 'ReferralContact',
                'Title' => 'TestTitle',
                'Email' => 'test@test.com',
                'Account.Name' => 'PartnerAccount',
                'Account.RecordTypeId' => Constants.RT_ID_ACC_PARTNER_V2,
                'Account.BillingCountry' => 'Colombia',
                'Account.Industry' => 'Retail',
                'Account.SubIndustry__c' => 'Other',
                'Account.Company_Segment__c' => '25 - 50 million',
                'Account.MerchantCoreBusinessModel__c' => 'Platforms',
                'Account.SubBusinessModel__c' => 'Marketplaces'
        });
    }

}