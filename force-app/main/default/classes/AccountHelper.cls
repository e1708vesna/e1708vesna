/**
 * @description TriggerHelper for the business logic on account database actions
 * @author BRITE
 */
public without sharing class AccountHelper {
    public static Map<Id, Id> accountStatusByAccountIdBeforeTrigger = new Map<Id, String>();
    public static Set<Id> relatedSOWIdSet = new Set<Id>();
    public static Map<Id, String> oldAccountOwners = new Map<Id, String>();

    public static void collectOldAccountStatus(List<account> oldAccList){
        for (Account acc : oldAccList){
            if (!accountStatusByAccountIdBeforeTrigger.containsKey(acc.Id)) {
                accountStatusByAccountIdBeforeTrigger.put(acc.Id, acc.Account_Status__c);
            }
        }
    }

    /**
     * @description Update CurrencyIsoCode based on the billing country.
     *              Runs before insert and update of an account.
     *
     * @param newAccList List of new/updated account records
     */
    public static void updateCurrencyIsoCode(List<Account> newAccList) {
        if (newAccList == null || newAccList.isEmpty()) {
            return;
        }

        for (Account acc : newAccList) {
            switch on (acc.BillingCountryCode) {
                when 'US' {
                    acc.CurrencyIsoCode = 'USD';
                }
                when 'CA' {
                    acc.CurrencyIsoCode = 'CAD';
                }
                when 'GB' {
                    acc.CurrencyIsoCode = 'GBP';
                }
                when 'IE' {
                    acc.CurrencyIsoCode = 'GBP';
                }
                when 'AU' {
                    acc.CurrencyIsoCode = 'AUD';
                }
                when 'BR' {
                    acc.CurrencyIsoCode = 'BRL';
                }
            }
        }
    }





    /**
     * @description Set record type to 'Partner Account v2' when record is created with field IsPartner__c set to true.
     *              Runs before insert of a new account.
     *
     * @param newAccList List of created account records
     */
    public static void updateAccountType(List<Account> newAccList) {
        if (newAccList != null && !newAccList.isEmpty()) {

            for (Account acc : newAccList) {
                if (acc.IsPartner__c) {
                    acc.Type = 'Partner v2';
                }
            }
        }
    }

    public static void handleBeforeDeleteTrigger(List<Account> oldAccList){
        Set<Id> changedAccountIdSet = new Set<Id>();
        /*Duplication*/
        List<ShareOfWallet__c> sowList = [Select Id FROM ShareOfWallet__c Where AccountPlan__c in (Select Id From AccountPlan__c Where Account__c in : oldAccList)];
        Set<Id> sowIds = (new Map<Id,SObject>(sowList)).keySet();
        relatedSOWIdSet.addAll(sowIds);
        /*Duplication*/


        //ClaimMember Sharing
        Set<Id> claimMembersIds = new Set<Id>();
        ClaimMemberSharingUtil shareHelper = ClaimMemberSharingUtil.getInstance();
        claimMembersIds.addAll((new Map<Id,ClaimMembers__c>([SELECT Id FROM ClaimMembers__c WHERE Account__c in: oldAccList])).keySet());
        if (claimMembersIds.size() > 0 ) {
            shareHelper.storeClaimMember(claimMembersIds);
        }

        //Claim Sharing
        Set<Id> claimIds = new Set<Id>();
        ClaimSharingUtil claimShareHelper = ClaimSharingUtil.getInstance();
        claimIds.addAll((new Map<Id,Claim__c>([SELECT Id FROM Claim__c WHERE Account__c in: oldAccList])).keySet());
        if (claimIds.size() > 0 ) {
            claimShareHelper.storeClaims(claimIds);
        }
    }

    public static void handleAfterDeleteTrigger(List<Account> oldAccList){

        //Share of wallet sharing
        Set<Id> masterRecordIdSet = new Set<Id>();
        for (Account acc : oldAccList){
            if (acc.MasterRecordId != null){
                masterRecordIdSet.add(acc.MasterRecordId);
            }
        }
        /*Duplication*/
        List<ShareOfWallet__c> sowList = [Select Id FROM ShareOfWallet__c Where AccountPlan__c in (Select Id From AccountPlan__c Where Account__c in : masterRecordIdSet)];
        Set<Id> sowIds = (new Map<Id,SObject>(sowList)).keySet();
        relatedSOWIdSet.addAll(sowIds);
        /*Duplication*/
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(relatedSOWIdSet);

        //Claim Member sharing
        ClaimMemberSharingUtil shareHelper = ClaimMemberSharingUtil.getInstance();
        shareHelper.commitClaimMembers();

        //Claim  sharing
        ClaimSharingUtil claimShareHelper = ClaimSharingUtil.getInstance();
        claimShareHelper.commitClaims();
    }

    public static void afterUndeleteHandler(List<Account> newAccList){
        /*Duplication*/
        List<ShareOfWallet__c> sowList = [Select Id FROM ShareOfWallet__c Where AccountPlan__c in (Select Id From AccountPlan__c Where Account__c in : newAccList)];
        Set<Id> sowIds = (new Map<Id,SObject>(sowList)).keySet();
        /*Duplication*/
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(sowIds);

        //ClaimMember Sharing
        Set<Id> claimMembersIds = new Set<Id>();
        ClaimMemberSharingUtil shareHelper = ClaimMemberSharingUtil.getInstance();
        claimMembersIds.addAll((new Map<Id,ClaimMembers__c>([SELECT Id FROM ClaimMembers__c WHERE Account__c in: newAccList])).keySet());
        if (claimMembersIds.size() > 0 ) {
            shareHelper.storeClaimMember(claimMembersIds);
            shareHelper.commitClaimMembers();
        }

        //Claim Sharing
        Set<Id> claimIds = new Set<Id>();
        ClaimSharingUtil claimShareHelper = ClaimSharingUtil.getInstance();
        claimIds.addAll((new Map<Id,Claim__c>([SELECT Id FROM Claim__c WHERE Account__c in: newAccList])).keySet());
        if (claimIds.size() > 0 ) {
            claimShareHelper.storeClaims(claimIds);
            claimShareHelper.commitClaims();
        }
    }

    public static void updateOwnerRelatedObjects(List<Account> newAccList, Map<Id, Account> oldAccMap){
        Set<String> profileNames = new Set<String>{'Adyen v2 Account Manager', 'Adyen v2 Account Manager Lead'};
        Set<Id> ownerIds = new Set<Id>();
        Map<Id, Id> accToOwnerMap = new Map<Id, Id>();
        List<AccountPlan__c> apUpdateList = new List<AccountPlan__c>();
        List<ShareOfWallet__c> sowUpdateList = new List<ShareOfWallet__c>();
        List<Account> accOwnerChange = new List<Account>();
        for (Account acc : newAccList){
            if (acc.OwnerId != oldAccMap.get(acc.Id).OwnerId){
                accOwnerChange.add(acc);
                ownerIds.add(acc.OwnerId);
            }
        }
        //Grab Profile of Users
        Map<Id, User> userMap = new Map<Id, User>([Select Id, Profile.Name From User Where Id in: ownerIds AND Profile.Name in: profileNames]);
        for (Account acc : accOwnerChange){
            if (userMap.ContainsKey(acc.OwnerId)){
                accToOwnerMap.put(acc.Id, acc.OwnerId);
            }
        }

        //Grab all Account Plans and related SoW and APConfidentialInformation
        List<AccountPlan__c> apList = [Select Id, Account__c, OwnerId, (Select Id, OwnerId From ShareOfWallets__r) From AccountPlan__c Where Account__c in: accToOwnerMap.keySet()];
        for (AccountPlan__c ap : apList){
            if (accToOwnerMap.get(ap.Account__c) != ap.OwnerId ){
                ap.OwnerId = accToOwnerMap.get(ap.Account__c);
                apUpdateList.add(ap);
            }
            for (ShareOfWallet__c sow : ap.ShareOfWallets__r){
                if (accToOwnerMap.get(ap.Account__c) != sow.OwnerId ){
                    sow.OwnerId = accToOwnerMap.get(ap.Account__c);
                    sowUpdateList.add(sow);
                }
            }
        }

        if (!apUpdateList.isEmpty()) {
            update apUpdateList;
        }
        if (!sowUpdateList.isEmpty()) {
            update sowUpdateList;
        }
    }

    public static void collectAccountTeamMembers(List<Account> newAccList, Map<Id, Account> oldAccMap){
        Set<Id> accountIdsOwnerChange = new Set<Id>();
        for (Account acc : newAccList){
            if (acc.OwnerId != oldAccMap.get(acc.Id).OwnerId){
                accountIdsOwnerChange.add(acc.id);
            }
        }
        if (accountIdsOwnerChange.size() > 0){
            AccountTeamMemberKeeperHelper.getInstance().storeAccountTeamMembers(accountIdsOwnerChange);
        }
    }

    public static void reinsertAccountTeamMembers(List<Account> newAccList, Map<Id, Account> oldAccMap){

        Set<Id> accountIdsOwnerChange = new Set<Id>();
        for (Account acc : newAccList){
            if (acc.OwnerId != oldAccMap.get(acc.Id).OwnerId){
                accountIdsOwnerChange.add(acc.id);
            }
        }
        if (accountIdsOwnerChange.size() > 0){
            AccountTeamMemberKeeperHelper.getInstance().commitAccountTeamMembers(accountIdsOwnerChange);
        }
    }

    public static void encodeAccountLiveLink(List<Account> newAccList) {
        if (newAccList != null && !newAccList.isEmpty()) {
            for (Account acc : newAccList) {
                if(!String.isBlank(acc.Adyen_Platform_Account_Code__c)){

                    Blob adyenCompanyName = Blob.valueof('Company.' + acc.Adyen_Platform_Account_Code__c);
                    String encodedKey = 'B1-' + EncodingUtil.base64Encode(adyenCompanyName);
                    //Base64 and URLSafe Base64 causes different results in BO account keys, to be safe dropping =
                    acc.BO_EncodedAccountKey__c = encodedKey.removeEnd('=');
                }
            }
        }
    }

    public static void collectOldAccountOwners(Map<Id, Account> oldAccounts) {
        for(Account account : AccountDAO.getAccountsWithOwnerName(oldAccounts.keySet())) {
            oldAccountOwners.put(account.Id, account.Owner.Name);
        }
    }

    public static void shareSOWAndAPCRecords(Map<Id, Account> newAccounts) {
        SOWandAPCISharingUtil sharer = new SOWandAPCISharingUtil();
        sharer.handleSharing(newAccounts, oldAccountOwners);
    }
}