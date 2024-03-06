public without sharing class Constants {

    private static Map<String,Schema.RecordTypeInfo> rtLeadByDevNameMap  = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
    private static Map<String,Schema.RecordTypeInfo> rtAccByDevNameMap   = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    private static Map<String,Schema.RecordTypeInfo> rtConByDevNameMap   = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
    private static Map<String,Schema.RecordTypeInfo> rtOppByDevNameMap   = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
    private static Map<String, Schema.RecordTypeInfo> rtCaseByDevNameMap = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    private static Map<String,Schema.RecordTypeInfo> rtClaimByDevNameMap = Schema.SObjectType.Claim__c.getRecordTypeInfosByDeveloperName();
    private static Map<String,Schema.RecordTypeInfo> rtClaimMemberByDevNameMap = Schema.SObjectType.ClaimMembers__c.getRecordTypeInfosByDeveloperName();
    private static Map<String,Schema.RecordTypeInfo> rtHandoverByDevNameMap = Schema.SObjectType.Handover__c.getRecordTypeInfosByDeveloperName();
    
    // record types
    public static Id RT_ID_LEAD_INBOUND2       = rtLeadByDevNameMap.get('InboundLeadV2').getRecordTypeId();
    public static Id RT_ID_LEAD_PARTNER        = rtLeadByDevNameMap.get('PartnerLead').getRecordTypeId();    
    //public static Id RT_ID_ACC_PARTNER         = rtAccByDevNameMap.get('Partner_Account').getRecordTypeId();
    public static Id RT_ID_ACC_PARTNER_V2      = rtAccByDevNameMap.get('PartnerAccountv2').getRecordTypeId();
    //public static Id RT_ID_ACC_PROSPECT_V2     = rtAccByDevNameMap.get('ProspectAccount').getRecordTypeId();
    //public static Id RT_ID_ACC_SYSINTEGRATOR   = rtAccByDevNameMap.get('System_Integrator').getRecordTypeId();
    //public static Id RT_ID_ACC_SUSPECT_V2   = rtAccByDevNameMap.get('SuspectAccount').getRecordTypeId();
    public static Id RT_ID_ACC_BUSINESS  = rtAccByDevNameMap.get('Business_Account').getRecordTypeId();
    
    public static Id RT_ID_ACC_COMPETITOR      = rtAccByDevNameMap.get('Competitor').getRecordTypeId();
    //public static Id RT_ID_ACC_MERCHANT        = rtAccByDevNameMap.get('Other_account').getRecordTypeId();
    public static Id RT_ID_ACC_Live        		= rtAccByDevNameMap.get('LiveAccount').getRecordTypeId();
    
    // public static Id RT_ID_CON_VALID           = rtConByDevNameMap.get('Valid_Record_Type').getRecordTypeId();
    //public static Id RT_ID_OPP_ECOM            = rtOppByDevNameMap.get('Adyen_E_Com')?.getRecordTypeId();
    //public static Id RT_ID_OPP_POS             = rtOppByDevNameMap.get('Adyen_POS')?.getRecordTypeId();
    public static Id RT_ID_OPP_AM             = rtOppByDevNameMap.get('AccountManagementOpportunity').getRecordTypeId();
    public static Id RT_ID_OPP_SALES           = rtOppByDevNameMap.get('SalesOpportunity').getRecordTypeId();
    public static Id RT_ID_ADYEN_SALES_PROCESS = rtOppByDevNameMap.get('Adyen_Sales_Process')?.getRecordTypeId();

    public static Id RT_ID_CLAIM_EXCEPTION = rtClaimByDevNameMap.get('Exception').getRecordTypeId();
    public static Id RT_ID_CLAIM_REGULAR   = rtClaimByDevNameMap.get('Regular').getRecordTypeId();
    
    public static Id RT_ID_CLAIMMEMBER_EXCEPTION = rtClaimMemberByDevNameMap.get('Exception').getRecordTypeId();
    public static Id RT_ID_CLAIMMEMBER_REGULAR   = rtClaimMemberByDevNameMap.get('Regular').getRecordTypeId();
    
    public static Id RT_ID_HANDOVER_CX = rtHandoverByDevNameMap.get('SalesToCx').getRecordTypeId();
    
    
    public static Id RT_ID_LEAD_V2 = rtLeadByDevNameMap.get('InboundLeadV2').getRecordTypeId();

    public static final Id RT_ID_CASE_SERVICECASE = rtCaseByDevNameMap.get('ServiceCase').getRecordTypeId();
    public static final Id RT_ID_CASE_INTERNALCASE = rtCaseByDevNameMap.get('InternalCase').getRecordTypeId();
    public static final Id RT_ID_CASE_SUPPORTCASE = rtCaseByDevNameMap.get('Support').getRecordTypeId();
    
    // account
    public static List<String> ACC_LIST_STATUS_NEWBUSINESS = new List<String> {
                                                                        'Prospect',
                                                                        'Suspect', 
                                                                        'Onboarding', 
                                                                        'Live', 
                                                                        'Transacting',
                                                                        'Churning', 
                                                                        'Churned'};
    public static String ACC_STATUS_LIVEANDTRANSACTING = 'Live';
    public static String ACC_TYPE_PARTNER = 'Partner';
    public static String ACC_TYPE_CONSULTANT = 'Consultant';
    
    // opportunity
    public static String OPP_TYPE_NEWBUSINESS = 'New Business';
    public static String OPP_TYPE_ACCOUNTMGMT = 'Account Management';
    public static String OPP_TYPE_SALESMNGR = 'Sales Manager Upsell';
    public static List<String> OPP_LIST_LEADSOURCE_DIGITMARKETING = new List<String> {
                                                                        '3rd Party Email Send',
                                                                        '3rd Party Lead Acquisition',
                                                                        'Brand Campaign',
                                                                        'Contact Sales Form',
                                                                        'Content Download',
                                                                        'Content Syndication',
                                                                        'Demo Request',
                                                                        'Inbound Email',
                                                                        'Newsletter Signup',
                                                                        'Test account signup',
                                                                        'Webinar'};
    public static Set<Id> OPP_RECORDTYPES_CLAIMMEMBERCREATION = new Set<Id> {
                                                                        RT_ID_OPP_SALES
                                                                            };
    public static String OPP_LEADSOURCE_PARTNER = 'Partner Referral';
    public static List<String> OPP_LIST_LEADSOURCE_EVENT = new List<String> {'Event - Adyen Hosted', 'Event - External'};
    public static List<String> OPP_LIST_LEADSOURCE_REFERRAL = new List<String> {'Employee Referral', 'Investor or Analyst Referral', 'Merchant Referral'};
    public static String OPP_LEADSOURCE_INBOUNDCALL = 'Inbound Call';
    public static List<String> OPP_LIST_LEADSOURCE_SALESSELFGEN = new List<String> {
                                                                    'Public Relations',
                                                                    'Self-generated',
                                                                    'Data Import',
                                                                    'Customer Success',
                                                                    'Outbound Email',
                                                                    'Other'};
    public static String OPP_OPPSOURCE_DIGITMARKETING = 'Digital Marketing';
    public static String OPP_OPPSOURCE_PARTNERSHIP = 'Partnerships';
    public static String OPP_OPPSOURCE_EVENTS = 'Events';
    public static String OPP_OPPSOURCE_REFERRAL = 'Referral';
    public static String OPP_OPPSOURCE_INBOUNDCALL = 'Inbound Call';
    public static String OPP_OPPSOURCE_SALESSELFGEN = 'Sales Self-Generated';

    public static String blockLeadSyncErrorMessage = 'Lead cannot be created since it has not been fully enriched as indicated by Marketo !';

    public static String pooledUserNameRegex = 'AM\\s(Pool|Pod)';
}