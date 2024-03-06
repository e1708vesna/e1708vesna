/*
 * @name caseAccountDetailFormCtrl
 * @author Service
 * @group Lightning Web Controller
 * @description This class contains the  method to retrieve details of an account
 */ 
public with sharing class CaseAccountDetailFormCtrl {
    
    /**
     * @description Retrieve details of an account
     * @param recordId Id of the related case record.
     * @return Returns account details if found, otherwise null
     **/
    @AuraEnabled(cacheable=true)
    public static AccountData getAccountData(String caseId) {
        AccountData data = null;

        if (String.isNotBlank(caseId)) {
            Case c = [
                SELECT AccountId, Account.BusinessAsUsual__c
                FROM Case
                WHERE Id = :caseId];

            if (c.AccountId != null) {
                data = new AccountData();
                data.recordId = c.AccountId;
                data.businessAsUsual = c.Account.BusinessAsUsual__c;
            }
        } 

        return data;
    }

    public class AccountData {
        @AuraEnabled
        public Id recordId {get; set;}
        @AuraEnabled
        public String businessAsUsual {get; set;}
    }
    
}