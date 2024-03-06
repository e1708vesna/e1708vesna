/**
* @author Sales
* @group Util
* @description Handles sharing for Share of Wallet(s) & AP Confidential
* records for AM Pool User creation / modification
*/
public class AMPoolSOWSharingUtil {

    private static AMPoolSOWSharingUtil instance = null;
    @TestVisible private static final String APEXSHARINGREASONSOW = 'AMPoolSOW__c'; //Sharing Reason for Share of Wallet
    @TestVisible private static final String APEXSHARINGREASONAPC = 'AMPoolAPC__c'; // Sharing Reason for AP Confidential
    @TestVisible private static final String ACCESSLEVEL = 'Edit';
    private Map<String, List<Id>> regionToUserId = new Map<String, List<Id>>();
    private Map<String, String> AMPoolToRegion = new Map<String, String>();
    private List<ShareOfWallet__c> shareOfWallets = new List<ShareOfWallet__c>();
    private Map<String, Set<Id>> AMPoolToSOW = new Map<String, Set<Id>>();
    private Map<String, Set<Id>> AMPoolToAPConfidential = new Map<String, Set<Id>>();
    private List<ShareOfWallet__share> sowSharesToCreate = new List<ShareOfWallet__share>();
    private List<APConfidentialInformation__Share> apciSharesToCreate = new List<APConfidentialInformation__Share>();
    private List<ApexDebugLog.Error> errorLogs = new List<ApexDebugLog.Error>();

    public static AMPoolSOWSharingUtil getInstance() {
        if(instance == null) instance = new AMPoolSOWSharingUtil();
        return instance;
    }

    public void handleSharing(Map<Id, User> AMPoolUsers) {
        system.debug('handling sow sharing for new / modified users...');
        Set<String> userIds = (Set<String>)JSON.deserialize(JSON.serialize(AMPoolUsers.keySet()), Set<String>.class);
        system.debug('user ids from am pool sharing -- ' + userIds);
        deleteExistingShares(userIds);
        createMappings(AMPoolUsers);
        if (!AMPoolToSOW.isEmpty()) {
            system.debug('am pool to sow mapping is not empty --');
            system.debug(AMPoolToSOW);
            createSOWShares();
        }
        if(!AMPoolToAPConfidential.isEmpty()) {
            system.debug('am pool to apc mapping is not empty --');
            system.debug(AMPoolToAPConfidential);
            createAPConfidentialShares();
        }
        performDML();
    }

    public void deleteExistingShares(Set<String> userIds) {
        system.debug('deleting existing shares...');
        Set<String> rowCauses = new Set<String>{APEXSHARINGREASONSOW, APEXSHARINGREASONAPC};
        List<sObject> existingShares = new List<sObject>();
        system.debug('user ids from am pool sharing util -- ' + userIds);
        delete [SELECT Id FROM ShareOfWallet__Share WHERE UserOrGroupId IN :userIds AND RowCause IN :rowCauses];
        delete [SELECT Id FROM APConfidentialInformation__Share WHERE UserOrGroupId IN :userIds AND RowCause IN :rowCauses];
    }

    public void createMappings(Map<Id, User> newUsers) {
        system.debug('creating mappings..');
        generateUserRegionMap(newUsers);
        system.debug(regionToUserId);
        Set<String> applicableRegions = regionToUserId.keySet();
        if(regionToUserId != null) {
            generateAMPoolToRegionMapping(applicableRegions);
            system.debug(AMPoolToRegion);
            if(AMPoolToRegion != null) {
                fetchShareOfWallets(applicableRegions, newUsers.keySet());
                system.debug(shareOfWallets);
                generateAMPoolToSOWMapping();
                generateAMPoolToAPConfidentialMapping();
            }
        }
    }

    public void performDML() {
        system.debug('performing dml -- hope it works');
        if(!sowSharesToCreate.isEmpty() || !apciSharesToCreate.isEmpty()) {
            try{
                insert sowSharesToCreate;
                insert apciSharesToCreate;
            }
            catch(Exception e) {
                system.debug('exception -- ' + e.getmessage());
                ApexDebugLog.Error errorLog = new ApexDebugLog.Error('UserTrgHandler','performDML', '', e);
                errorLogs.add(errorLog);
            }
        }
        if(!errorLogs.isEmpty()) {
            ApexDebugLog.createLog(errorLogs);
        }
    }



    public void createSOWShares() {
        sowSharesToCreate.clear();
        for (String AMPool : AMPoolToSOW.keySet()) {
            String region = AMPoolToRegion.get(AMPool);
            system.debug(AMPoolToRegion.get(AMPool));
            Set<Id> shareOfWalletIds = AMPoolToSOW.get(AMPool);
            List<Id> usersToBeShared = regionToUserId.get(region);
            for (Id userId : usersToBeShared) {
                for (Id sowId : shareOfWalletIds) {
                    ShareOfWallet__Share sowShare = new ShareOfWallet__Share();
                    sowShare.UserOrGroupId = userId;
                    sowShare.ParentId = sowId;
                    sowShare.AccessLevel = ACCESSLEVEL;
                    sowShare.RowCause = APEXSHARINGREASONSOW;
                    sowSharesToCreate.add(sowShare);
                }
            }
        }
    }

    public void createAPConfidentialShares() {
        apciSharesToCreate.clear();
        for(String AMPool : AMPoolToAPConfidential.keySet()) {
            String region = AMPoolToRegion.get(AMPool);
            Set<Id> APConfidentialIds = AMPoolToAPConfidential.get(AMPool);
            List<Id> usersToBeShared = regionToUserId.get(region);
            for (Id userId : usersToBeShared) {
                for (Id apConfidentialId : APConfidentialIds) {
                    APConfidentialInformation__Share APConfidentialShare = new APConfidentialInformation__Share();
                    APConfidentialShare.UserOrGroupId = userId;
                    APConfidentialShare.ParentId = apConfidentialId;
                    APConfidentialShare.AccessLevel = ACCESSLEVEL;
                    APConfidentialShare.RowCause = APEXSHARINGREASONAPC;
                    apciSharesToCreate.add(APConfidentialShare);
                }
            }
        }
    }

    public void generateUserRegionMap(Map<Id, User> users) {
        system.debug('generating user region map -- ');
        regionToUserId.clear();
        for(User user : users.values()) {
            System.debug(user.SalesTeam__c);
            if(user.SalesTeam__c == 'Account Management Pool') {
                if(regionToUserId.containsKey(user.SalesOffice__c)) {
                    regionToUserId.get(user.SalesOffice__c).add(user.Id);
                }
                else {
                    List<Id> userIds = new List<Id>{user.Id};
                    regionToUserId.put(user.SalesOffice__c, userIds);
                }
            }
        }
        system.debug(regionToUserId);
    }

    public void generateAMPoolToRegionMapping(Set<String> regions) {
        AMPoolToRegion.clear();
        for(AMPoolRegionMapping__mdt mapping : [SELECT AMPools__c, Region__c FROM AMPoolRegionMapping__mdt WHERE Region__c IN :regions]) {
            List<String> AMPools = mapping.AMPools__c.split(',');
            for(String AMPool : AMPools) {
                AMPoolToRegion.put(AMPool, mapping.Region__c);
            }
        }
    }

    public void generateAMPoolToSOWMapping() {
        AMPoolToSOW.clear();
        for(ShareOfWallet__c sow : shareOfWallets) {
            String AMPoolName = sow.AccountPlan__r.Account__r.Owner.Name;
            if(AMPoolToSOW.containsKey(AMPoolName)) {
                AMPoolToSOW.get(AMPoolName).add(sow.Id);
            }
            else {
                AMPoolToSOW.put(AMPoolName, new Set<Id>{sow.Id});
            }
        }
    }

    public void generateAMPoolToAPConfidentialMapping() {
        AMPoolToAPConfidential.clear();
        for(ShareOfWallet__c sow : shareOfWallets) {
            Id APConfidentialId = sow.AccountPlan__r.APConfidentialInformation__c;
            String AMPoolName = sow.AccountPlan__r.Account__r.Owner.Name;
            if(AMPoolToAPConfidential.containsKey(AMPoolName)) {
                AMPoolToAPConfidential.get(AMPoolName).add(APConfidentialId);
            }
            else {
                AMPoolToAPConfidential.put(AMPoolName, new Set<Id>{APConfidentialId});
            }
        }
    }

    public Set<String> getAMPoolNames(Set<String> regions) {
        Set<String> AMPoolNames = new Set<String>();
        for(String AMPool : AMPoolToRegion.keySet()) {
            String region = AMPoolToRegion.get(AMPool);
            if(regions.contains(region)) {
                AMPoolNames.add(AMPool);
            }
        }
        return AMPoolNames;
    }

    public void fetchShareOfWallets(Set<String> regions, Set<Id> userIds) {
        Set<String> AMPoolNames = getAMPoolNames(regions);
        shareOfWallets = [SELECT Id, AccountPlan__c, AccountPlan__r.Account__r.Owner.Name, AccountPlan__r.APConfidentialInformation__c
                          FROM ShareOfwallet__c
                          WHERE AccountPlan__r.Account__r.Owner.Name IN :AMPoolNames];
    }
}