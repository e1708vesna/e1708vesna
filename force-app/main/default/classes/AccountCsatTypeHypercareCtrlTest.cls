/**
 * @description Test class to verify the correctness of the methods in the controller class AccountCsatTypeHypercareCtrl.
 * @author BRITE
 */
@isTest
private class AccountCsatTypeHypercareCtrlTest {

    @isTest
    static void getAccountDataTestMerchantAccount() {
        Account merchantAccount = ServicesTestUtil.createAccount('Merchant', Constants.RT_ID_ACC_BUSINESS, false);
        merchantAccount.ServiceLevel__c = 'VIP';
        merchantAccount.CSATScorePercentage__c = 40;
        merchantAccount.Company_Segment__c = '5 - 10 million';
        merchantAccount.AccountType__c = 'Merchant';
        merchantAccount.HypercareMode__c = true;
        merchantAccount.Industry = 'Transportation & Mobility';
        insert merchantAccount;

        Test.startTest();
        AccountCsatTypeHypercareCtrl.AccountData data = AccountCsatTypeHypercareCtrl.getAccountData(merchantAccount.Id);
        Test.stopTest();

        System.assertEquals(merchantAccount.ServiceLevel__c, data.serviceLevel, 'Service level');
        System.assertEquals(merchantAccount.CSATScorePercentage__c, data.csatScorePercentage, 'CSAT score percentage');
        System.assertEquals(merchantAccount.Company_Segment__c, data.companySegment, 'Company segment');
        System.assertEquals(merchantAccount.AccountType__c, data.accountType, 'Account type');
        System.assertEquals(merchantAccount.HypercareMode__c, data.hypercareMode, 'Hypercare mode');
        System.assertEquals(merchantAccount.Industry, data.industry, 'Industry');
        System.assertEquals(false, data.isEscalated, 'Is escalated');
    }

    @isTest
    static void getAccountDataTestPartnerAccount() {
        Account partnerAccount = ServicesTestUtil.createAccount('Merchant', Constants.RT_ID_ACC_BUSINESS, false);
        partnerAccount.ServiceLevel__c = 'VIP';
        partnerAccount.CSATScorePercentage__c = 40;
        partnerAccount.Company_Segment__c = '5 - 10 million';
        partnerAccount.AccountType__c = 'Partner';
        partnerAccount.HypercareMode__c = true;
        partnerAccount.Industry = 'Entertainment & Amusement';
        insert partnerAccount;

        ServicesTestUtil.createPartnerType(partnerAccount.id, 'Service', 'System Integrators', 'Potential', true);

        Test.startTest();
        AccountCsatTypeHypercareCtrl.AccountData data = AccountCsatTypeHypercareCtrl.getAccountData(partnerAccount.Id);
        Test.stopTest();

        System.assertEquals(partnerAccount.Company_Segment__c, data.companySegment, 'Company segment');
        System.assertEquals(partnerAccount.AccountType__c, data.accountType, 'Account type');
        System.assertEquals(partnerAccount.Industry, data.industry, 'Industry');
        System.assertEquals('System Integrators', data.partnerSubType, 'Partner subtype');
    }

    @isTest
    static void getAccountDataTestContact() {
        Account merchantAccount = ServicesTestUtil.createAccount('Merchant', Constants.RT_ID_ACC_BUSINESS, false);
        merchantAccount.ServiceLevel__c = 'VIP';
        merchantAccount.CSATScorePercentage__c = 40;
        merchantAccount.Company_Segment__c = '5 - 10 million';
        merchantAccount.AccountType__c = 'Merchant';
        merchantAccount.HypercareMode__c = false;
        merchantAccount.Industry = 'Transportation & Mobility';
        insert merchantAccount;

        Contact merchantContact = ServicesTestUtil.createContact(merchantAccount.Id, 'Jones', 'jones@somecompany.fake', true);

        Test.startTest();
        AccountCsatTypeHypercareCtrl.AccountData data = AccountCsatTypeHypercareCtrl.getAccountData(merchantContact.Id);
        Test.stopTest();

        System.assertEquals(merchantAccount.ServiceLevel__c, data.serviceLevel, 'Service level');
        System.assertEquals(merchantAccount.CSATScorePercentage__c, data.csatScorePercentage, 'CSAT score percentage');
        System.assertEquals(merchantAccount.Company_Segment__c, data.companySegment, 'Company segment');
        System.assertEquals(merchantAccount.AccountType__c, data.accountType, 'Account type');
        System.assertEquals(merchantAccount.HypercareMode__c, data.hypercareMode, 'Hypercare mode');
        System.assertEquals(merchantAccount.Industry, data.industry, 'Industry');
        System.assertEquals(false, data.isEscalated, 'Is escalated');
    }

    @isTest
    static void getAccountDataTestCase() {
        Account merchantAccount = ServicesTestUtil.createAccount('Merchant', Constants.RT_ID_ACC_BUSINESS, false);
        merchantAccount.ServiceLevel__c = 'VIP';
        merchantAccount.CSATScorePercentage__c = 40;
        merchantAccount.Company_Segment__c = '5 - 10 million';
        merchantAccount.AccountType__c = 'Merchant & Partner';
        merchantAccount.HypercareMode__c = false;
        merchantAccount.Industry = 'Transportation & Mobility';
        insert merchantAccount;

        Case merchantCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, merchantAccount.Id, null, false);
        merchantCase.Subject = 'Some subject';
        merchantCase.Priority = 'Medium';
        merchantCase.IsEscalated = true;
        insert merchantCase;

        Test.startTest();
        AccountCsatTypeHypercareCtrl.AccountData data = AccountCsatTypeHypercareCtrl.getAccountData(merchantCase.Id);
        Test.stopTest();

        System.assertEquals(merchantAccount.ServiceLevel__c, data.serviceLevel, 'Service level');
        System.assertEquals(merchantAccount.CSATScorePercentage__c, data.csatScorePercentage, 'CSAT score percentage');
        System.assertEquals(merchantAccount.Company_Segment__c, data.companySegment, 'Company segment');
        System.assertEquals(merchantAccount.AccountType__c, data.accountType, 'Account type');
        System.assertEquals(merchantAccount.HypercareMode__c, data.hypercareMode, 'Hypercare mode');
        System.assertEquals(merchantAccount.Industry, data.industry, 'Industry');
        System.assertEquals(merchantCase.IsEscalated, data.isEscalated, 'Is escalated');
    }

    @isTest
    static void getAccountDataTestCaseWithoutAccount() {
        Case merchantCase = new Case (
            Subject = 'Some subject',
            Priority = 'Medium',
            IsEscalated = true
        );
        insert merchantCase;

        Test.startTest();
        AccountCsatTypeHypercareCtrl.AccountData data = AccountCsatTypeHypercareCtrl.getAccountData(merchantCase.Id);
        Test.stopTest();

        System.assertEquals(null, data.serviceLevel, 'Service level');
        System.assertEquals(null, data.csatScorePercentage, 'CSAT score percentage');
        System.assertEquals(null, data.companySegment, 'Company segment');
        System.assertEquals(null, data.accountType, 'Account type');
        System.assertEquals(null, data.hypercareMode, 'Hypercare mode');
        System.assertEquals(null, data.industry, 'Industry');
        System.assertEquals(merchantCase.IsEscalated, data.isEscalated, 'Is escalated');
    }

}