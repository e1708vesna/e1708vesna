/**
* @author Sales
* @group Util
* @description Handles sharing for Share of Wallet(s) & AP Confidential
* records for changes to Account Ownership from / to AM Poolo
*/
public class SOWandAPCISharingUtil {

    private static SOWandAPCISharingUtil instance = null;

    @TestVisible private static final String APEXSHARINGREASONSOW = 'AMPoolSOW__c'; //Sharing Reason for Share of Wallet
    @TestVisible private static final String APEXSHARINGREASONAPC = 'AMPoolAPC__c'; // Sharing Reason for AP Confidential
    @TestVisible private static final String ACCESSLEVEL = 'Edit';
    private Map<Id, Set<Id>> accountToShareOfWallets = new Map<Id, Set<Id>>();
    private Map<Id, Set<Id>> accountToAPConfidentialInformations = new Map<Id, Set<Id>>();
    private Map<String, Id> amPoolToAccountOld = new Map<String, Id>();
    private Map<String, Id> amPoolToAccountNew = new Map<String, Id>();
    private Map<String, Set<Id>> AMPoolToUser = new Map<String, Set<Id>>();
    private List<ShareOfWallet__Share> sowSharesToCreate = new List<ShareOfWallet__Share>();
    private List<APConfidentialInformation__Share> apciSharesToCreate = new List<APConfidentialInformation__Share>();
    private List<ShareOfWallet__Share> sowSharesToDelete = new List<ShareOfWallet__Share>();
    private List<APConfidentialInformation__Share> apciSharesToDelete = new List<APConfidentialInformation__Share>();

    public static SOWandAPCISharingUtil getInstance() {
        if(instance == null) instance = new SOWandAPCISharingUtil();
        return instance;
    }

    public void handleSharing(Map<Id, Account> newAccounts, Map<Id, String> oldAccountOwners) {
        //Filters out all AM Pool names in context
        Set<String> AMPoolNames = filterAMPoolNames(oldAccountOwners, newAccounts);
        if(!AMPoolNames.isEmpty()) {
            //generates a map of account to it's corresponding share of wallet(s) and ap confidential information(s)
            generateAccountToSOWAndAPCIMapping(newAccounts.keySet(), AMPoolNames);
            //generates a map of am pool and it's corresponding members
            createAMPoolToUserMapping(AMPoolNames);
            //generates lists of share of wallet(s) and ap confidential information(s) to insert & delete
            generateSharingLists();
            doDML();
        }
    }

    public void generateSharingLists() {
        Map<Id, Set<Id>> accountToUsersToGrantAccess = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accountToUsersToRevokeAccess = new Map<Id, Set<Id>>();
        for(String amPool : AMPoolToUser.keySet()) {
            Set<Id> userIds = AMPoolToUser.get(amPool);
            Id oldAccountId =  amPoolToAccountOld.get(amPool);
            Id newAccountId = amPoolToAccountNew.get(amPool);
            if(oldAccountId != null) {
                if(accountToUsersToRevokeAccess.containsKey(oldAccountId)) {
                    accountToUsersToRevokeAccess.get(oldAccountId).addAll(userIds);
                }
                else {
                    accountToUsersToRevokeAccess.put(oldAccountId, userIds);
                }
            }
            if(newAccountId != null) {
                if(accountToUsersToGrantAccess.containsKey(newAccountId)) {
                    accountToUsersToGrantAccess.get(newAccountId).addAll(userIds);
                }
                else {
                    accountToUsersToGrantAccess.put(newAccountId, userIds);
                }
            }
        }
        if(!accountToUsersToRevokeAccess.isEmpty()) {
            findSharesToDelete(accountToUsersToRevokeAccess);
        }
        if(!accountToUsersToGrantAccess.isEmpty()) {
            findSharesToCreate(accountToUsersToGrantAccess);
        }
    }

    public void findSharesToCreate(Map<Id, Set<Id>> accountToUserMap) {
        for(Id accountId : accountToUserMap.keySet()) {
            Set<Id> userIds = accountToUserMap.get(accountId);
            Set<Id> sowIds = accountToShareOfWallets.get(accountId);
            Set<Id> apciIds = accountToAPConfidentialInformations.get(accountId);
            if(!sowIds.isEmpty() && !userIds.isEmpty()) {
                generateNewSOWShares(userIds, sowIds);
            }
            if(!apciIds.isEmpty() && !userIds.isEmpty()) {
                generateNewAPCIhares(userIds, apciIds);
            }
        }
    }

    public void generateNewSOWShares(Set<Id> userIds, Set<Id> sowIds) {
        for(Id userId : userIds) {
            for(Id shareOfWalletId : sowIds) {
                ShareOfWallet__Share sowShare = new ShareOfWallet__Share();
                sowShare.UserOrGroupId = userId;
                sowShare.ParentId = shareOfWalletId;
                sowShare.AccessLevel = ACCESSLEVEL;
                sowShare.RowCause = APEXSHARINGREASONSOW;
                sowSharesToCreate.add(sowShare);
            }
        }
    }

    public void generateNewAPCIhares(Set<Id> userIds, Set<Id> apciIds) {
        if(test.isRunningTest()) {
            apciSharesToCreate.clear();
        }
        for(Id userId : userIds) {
            for(Id apConfidentialId : apciIds) {
                APConfidentialInformation__Share APConfidentialShare = new APConfidentialInformation__Share();
                APConfidentialShare.UserOrGroupId = userId;
                APConfidentialShare.ParentId = apConfidentialId;
                APConfidentialShare.AccessLevel = ACCESSLEVEL;
                APConfidentialShare.RowCause = APEXSHARINGREASONAPC;
                apciSharesToCreate.add(APConfidentialShare);
            }
        }
    }

    public void findSharesToDelete(Map<Id, Set<Id>> accountToUserMap) {
        for(Id accountId : accountToUserMap.keySet()) {
            Set<Id> userIds = accountToUserMap.get(accountId);
            Set<Id> sowIds = accountToShareOfWallets.get(accountId);
            Set<Id> apciIds = accountToAPConfidentialInformations.get(accountId);
            if(!sowIds.isEmpty() && !userIds.isEmpty()) {
                findSOWSharesToDelete(userIds, sowIds);
            }
            if(!apciIds.isEmpty() && !userIds.isEmpty()) {
                findAPCISharesToDelete(userIds, apciIds);
            }
        }
    }

    public void findSOWSharesToDelete(Set<Id> userIds, Set<Id> sowIds) {
        sowSharesToDelete.addAll(
                [SELECT Id FROM ShareOfWallet__Share
                WHERE UserOrGroupId IN :userIds
                AND ParentId IN :sowIds
                AND RowCause = :APEXSHARINGREASONSOW]
        );
    }

    public void findAPCISharesToDelete(Set<Id> userIds, Set<Id> apciIds) {
        apciSharesToDelete.addAll(
            [SELECT Id FROM APConfidentialInformation__Share
            WHERE UserOrGroupId IN :userIds
            AND ParentId IN :apciIds
            AND RowCause = :APEXSHARINGREASONAPC]
        );
    }

    public Set<String> filterAMPoolNames(Map<Id, String> oldAccountOwners, Map<Id, Account> newAccounts) {
        Set<String> poolNames = new Set<String>();
        for(Account account : AccountDAO.getAccountsWithOwnerName(newAccounts.keySet())) {
            if(account.Owner.Name != oldAccountOwners.get(account.Id)) {
                Boolean isPooledNewOwner = Utils.matchRegexExpression(Constants.pooledUserNameRegex, account.Owner.Name);
                Boolean isPooledOldOwner = Utils.matchRegexExpression(Constants.pooledUserNameRegex, oldAccountOwners.get(account.Id));
                if(isPooledOldOwner) {
                    String oldPooledOwner = oldAccountOwners.get(account.Id);
                    poolNames.add(oldPooledOwner);
                    amPoolToAccountOld.put(oldPooledOwner, account.Id);
                }
                if(isPooledNewOwner) {
                    String newPoolOwner = account.Owner.Name;
                    poolNames.add(account.Owner.Name);
                    amPoolToAccountNew.put(newPoolOwner, account.Id);
                }
            }
        }
        return poolNames;
    }

    public void generateAccountToSOWAndAPCIMapping(Set<Id> accountIds, Set<String> AMPoolNames) {
        for(ShareOfWallet__c shareOfWallet : [SELECT Id, AccountPlan__c, AccountPlan__r.Account__c, AccountPlan__r.Account__r.Name, AccountPlan__r.APConfidentialInformation__c
                                              FROM ShareOfwallet__c
                                              WHERE AccountPlan__r.Account__c IN :accountIds]) {
            Id accountId = shareOfWallet.AccountPlan__r.Account__c;
            if(accountToShareOfWallets.containsKey(accountId)) {
                accountToShareOfWallets.get(accountId).add(shareOfWallet.Id);
            }
            else {
                accountToShareOfWallets.put(accountId, new Set<Id> {shareOfWallet.Id});
            }
            if(accountToAPConfidentialInformations.containsKey(accountId)) {
                accountToAPConfidentialInformations.get(accountId).add(shareOfWallet.AccountPlan__r.APConfidentialInformation__c);
            }
            else {
                accountToAPConfidentialInformations.put(accountId, new Set<Id> {shareOfWallet.AccountPlan__r.APConfidentialInformation__c});
            }
        }
    }

    public void createAMPoolToUserMapping(Set<String> poolNames) {
        Map<String, String> regionToAMPool = fetchRegionToAMPoolMapping(poolNames);
        for(User user : [SELECT Id, SalesOffice__c FROM User WHERE SalesTeam__c = 'Account Management Pool' AND SalesOffice__c IN :regionToAMPool.keySet()]) {
            String AMPool = regionToAMPool.get(user.SalesOffice__c);
            if(AMPoolToUser.containsKey(AMPool)) {
                AMPoolToUser.get(AMPool).add(user.Id);
            }
            else {
                AMPoolToUser.put(AMPool, new Set<Id>{user.Id});
            }
        }
    }

    public Map<String, String> fetchRegionToAMPoolMapping(Set<String> poolNames) {
        Map<String, String> regionToAMPool = new Map<String, String>();
        for(AMPoolRegionMapping__mdt setting : [SELECT AMPools__c, Region__c FROM AMPoolRegionMapping__mdt WHERE AMPools__c IN :poolNames]) {
            regionToAMPool.put(setting.Region__c, setting.AMPools__c);
        }
        return regionToAMPool;
    }

    public void doDML() {
        if(!sowSharesToCreate.isEmpty() || !apciSharesToCreate.isEmpty() || !apciSharesToDelete.isEmpty() || !sowSharesToDelete.isEmpty()) {
            try{
                insert sowSharesToCreate;
                insert apciSharesToCreate;
                delete sowSharesToDelete;
                delete apciSharesToDelete;
            }
            catch(Exception e) {
                List<ApexDebugLog.Error> errorLogs = new List<ApexDebugLog.Error>();
                ApexDebugLog.Error errorLog = new ApexDebugLog.Error('UserTrgHandler','performDML', '', e);
                errorLogs.add(errorLog);
                ApexDebugLog.createLog(errorLogs);
            }
        }
    }
}