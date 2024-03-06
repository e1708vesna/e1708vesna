/*
 * @name AccountCsatTypeHypercareCtrl
 * @author Service
 * @group Lightning Web Controller
 * @description This class contains the  method to retrieve details of an account
 */ 
public with sharing class AccountCsatTypeHypercareCtrl {
    
    /**
     * @description Retrieve details of an account
     * @param recordId Id of the account record to look for, or the id of the related
     *              case or contact record.
     * @return Returns account details if found, otherwise null
     **/
    @AuraEnabled(cacheable=true)
    public static AccountData getAccountData(String recordId) {
        AccountData data = null;

        if (String.isNotBlank(recordId)) {
            if (recordId.startsWith('500')) {
                // record id of case
                List<Case> cases = [
                    SELECT AccountId, IsEscalated
                    FROM Case
                    WHERE Id = :recordId];

                if (!cases.isEmpty()) {
                    Case c = cases[0];
                    data = new AccountData();
                    data.isEscalated = c.IsEscalated;
                    if (c.AccountId != null) {
                        addAccountDetails(c.AccountId, data);
                    }
                }
            } else if (recordId.startsWith('001')) {
                // record id of account
                data = new AccountData();
                data.isEscalated = false;
                addAccountDetails(recordId, data);
            } else if (recordId.startsWith('003')) {
                // record id of contact
                List<Contact> contacts = [
                    SELECT AccountId
                    FROM Contact
                    WHERE Id = :recordId];

                if (!contacts.isEmpty()) {
                    Contact c = contacts[0];
                    data = new AccountData();
                    data.isEscalated = false;
                    if (c.AccountId != null) {
                        addAccountDetails(c.AccountId, data);
                    }
                }
            }
        } 

        return data;
    }

    /**
     * @description Enrich with account details.
     * 
     * @param accountId ID of the account record
     * @param data Details that needs to be enrichted
     */
    private static void addAccountDetails(String accountId, AccountData data) {
        List<Account> accounts = [
            SELECT ServiceLevel__c, CSATScorePercentage__c, Company_Segment__c, AccountType__c, HypercareMode__c, 
                Industry, RecordType.DeveloperName, (SELECT Id, SubType__c FROM PartnerTypes__r)
            FROM Account
            WHERE Id = :accountId];

            if (!accounts.isEmpty()) {
                Account acc = accounts[0];
                
                data.serviceLevel = acc.serviceLevel__c;
                data.csatScorePercentage = acc.CSATScorePercentage__c;
                data.companySegment = acc.Company_Segment__c;
                data.accountType = acc.AccountType__c;
                data.hypercareMode = acc.HypercareMode__c;
                data.industry = acc.Industry;
                data.recordTypeDeveloperName = acc.RecordType.DeveloperName;

                if (!acc.PartnerTypes__r.isEmpty()) {
                    data.partnerSubType = acc.PartnerTypes__r[0].SubType__c; 
                }
            }
    }

    public class AccountData {
        @AuraEnabled
        public String serviceLevel {get; set;}

        @AuraEnabled
        public Decimal csatScorePercentage {get; set;}

        @AuraEnabled
        public String companySegment {get; set;}

        @AuraEnabled
        public String accountType {get; set;}

        @AuraEnabled
        public Boolean hypercareMode {get; set;}

        @AuraEnabled
        public String industry {get; set;}

        @AuraEnabled
        public String recordTypeDeveloperName {get; set;}

        @AuraEnabled
        public String partnerSubType {get; set;}

        @AuraEnabled
        public Boolean isEscalated {get; set;}
    }
}