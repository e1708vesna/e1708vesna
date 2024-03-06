/**
* @author Sales
* @group Trigger Handler
* @description Handler class for User Trigger
*/
public class UserTrgHandler {

    @TestVisible private static final String APEXSHARINGREASON = 'AMPool__c';

    public static void handleSOWSharing(Map<Id, User> newUsers, Map<Id, User> oldUsers) {
        if(oldUsers == null) {
            createSOWShares(newUsers);
        }
        else {
            System.debug('Updating SOW Shares...');
            updateSOWShares(newUsers, oldUsers);
        }
    }

    public static void createSOWShares(Map<Id, User> newUsers) {
        List<ShareOfWallet__Share> sharesToCreate = new List<ShareOfWallet__Share>();
        Map<String, List<Id>> regionToUserId = generateUserRegionMap(newUsers);
        if(regionToUserId != null) {
            Set<String> applicableRegions = regionToUserId.keySet();
            Map<String, String> AMPoolToRegion = generateAMPoolToRegionMapping(applicableRegions);
            if(AMPoolToRegion.keyset().size() > 0) {
                Map<String, List<Id>> AMPoolToSOWMapping = generateAMPoolToSOWMapping(applicableRegions);
                for(String AMPool : AMPoolToSOWMapping.keySet()) {
                    String region = AMPoolToRegion.get(AMPool);
                    List<Id> shareOfWalletIds = AMPoolToSOWMapping.get(AMPool);
                    List<Id> usersToBeShared = regionToUserId.get(region);
                    for(Id userId : usersToBeShared) {
                        for(Id sowId : shareOfWalletIds) {
                            ShareOfWallet__Share sowShare = new ShareOfWallet__Share();
                            sowShare.UserOrGroupId = userId;
                            sowShare.ParentId = sowId;
                            sowShare.AccessLevel = 'Read';
                            sowShare.RowCause = APEXSHARINGREASON;
                            sharesToCreate.add(sowShare);
                        }
                    }
                }
            }
            else {
                //placeholder for creating warning logs for missing custom metadata
            }
        }
        if(sharesToCreate.isEmpty() == false) {
            try {
                insert sharesToCreate;
            }
            catch(Exception e) {
                ApexDebugLog.Error errorLog = new ApexDebugLog.Error('UserTrgHandler','createSOWShares', '', e);
            }
        }
    }

    public static void updateSOWShares(Map<Id, User> newUsers, Map<Id, User> oldUsers) {
        Map<Id, User> newAMPoolUsers = new Map<Id, User>();
        Map<Id, User> oldAMPoolUsers = new Map<Id, User>();
        Map<Id, User> deactivatedUsers = new Map<Id, User>();
        for(Id userId : newUsers.keySet()) {
            User newUser = newUsers.get(userId);
            User oldUser = oldUsers.get(userId);
            if(newUser.isActive == false) {
                deactivatedUsers.put(userId, newUser);
            }
            else if(newUser.SalesTeam__c == 'Account Management Pool') {
                System.debug('sales team for the user is am pool');
                if(oldUser.SalesTeam__c != 'Account Management Pool') {
                    newAMPoolUsers.put(userId, newUser);
                }
                else if(oldUser.SalesOffice__c != newUser.SalesOffice__c){
                    System.debug('sales office has been changed');
                    newAMPoolUsers.put(userId, newUser);
                    oldAMPoolUsers.put(userId, oldUser);
                }
            }
            else if(oldUser.SalesTeam__c == 'Account Management Pool') {
                if(newUser.SalesTeam__c != 'Account Management Pool') {
                    System.debug('sales team changed to something else');
                    oldAMPoolUsers.put(userId, oldUser);
                }
            }
          }

        try {
            if(newAMPoolUsers.size() != 0) {
               createSOWShares(newAMPoolUsers); 
            }
            if(oldAMPoolUsers.size() != 0) {
                deleteSOWShares(oldAMPoolUsers, false);
            }
            if(deactivatedUsers.size() != 0) {
              	deleteSOWShares(deactivatedUsers, true);  
            }
        }
        catch(Exception e) {
            ApexDebugLog.Error errorLog = new ApexDebugLog.Error('UserTrgHandler','updateSOWShares', '', e);
        }

    }

    public static void deleteSOWShares(Map<Id, User> oldUsers, Boolean deleteAll) {
        System.debug('deleting sow shares');
        List<ShareOfWallet__Share> sharesToDelete = new List<ShareOfWallet__Share>();
        if(deleteAll) {
            sharesToDelete = [SELECT Id
                              FROM ShareOfWallet__Share
                              WHERE UserOrGroupId IN :oldUsers.keySet() AND RowCause = :APEXSHARINGREASON];
        }
        else {
            Map<String, List<Id>> regionToUserId = generateUserRegionMap(oldUsers);
            Set<String> applicableRegions = regionToUserId.keySet();
            Map<String, List<Id>> AMPoolToSOWMapping = generateAMPoolToSOWMapping(applicableRegions);
            Set<Id> sowIdsToDelete = new Set<Id>();
            for(List<Id> sowIds : AMPoolToSOWMapping.values()) {
                sowIdsToDelete.addAll(sowIds);
            }
            sharesToDelete = [SELECT Id
                              FROM ShareOfWallet__Share
                              WHERE UserOrGroupId IN :oldUsers.keySet() AND RowCause = :APEXSHARINGREASON AND ParentId IN :sowIdsToDelete];
        }
        try {
            delete sharesToDelete;
        }
        catch(Exception e) {
            ApexDebugLog.Error errorLog = new ApexDebugLog.Error('UserTrgHandler','deleteSOWShares', '', e);
        }

    }

    public static Map<String, List<Id>> generateUserRegionMap(Map<Id, User> users) {
        Map<String, List<Id>> regionToUserId = new Map<String, List<Id>>();
        for(User user : users.values()) {
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
        if(regionToUserId.keySet().size() > 0) {
            return regionToUserId;
        }
        else {
            return null;
        }
    }

    public static Map<String, String> generateAMPoolToRegionMapping(Set<String> regions) {
        Map<String, String> AMPoolToRegion = new Map<String, String>();
        for(AMPoolRegionMapping__mdt mapping : [SELECT AMPools__c, Region__c
                                                FROM AMPoolRegionMapping__mdt
                                                WHERE Region__c IN :regions]) {
            List<String> AMPools = mapping.AMPools__c.split(',');
            for(String AMPool : AMPools) {
                AMPoolToRegion.put(AMPool, mapping.Region__c);
            }
        }
        if(AMPoolToRegion.keySet().size() > 0) {
            return AMPoolToRegion;
        }
        else {
            return null;
        }

    }

    public static Map<String, List<Id>> generateAMPoolToSOWMapping(Set<String> regions) {
        Map<String, List<Id>> AMPoolToSOWMapping = new Map<String, List<Id>>();
        Set<String> AMPoolNames = getAMPoolNames(regions);
        for(ShareOfWallet__c sow : [SELECT Id, AccountPlan__c, AccountPlan__r.Account__r.Owner.Name
                                    FROM ShareOfwallet__c
                                    WHERE AccountPlan__r.Account__r.Owner.Name IN :AMPoolNames]) {
            String AMPoolName = sow.AccountPlan__r.Account__r.Owner.Name;
            if(AMPoolToSOWMapping.containsKey(AMPoolName)) {
                AMPoolToSOWMapping.get(AMPoolName).add(sow.Id);
            }
            else {
                AMPoolToSOWMapping.put(AMPoolName, new List<Id>{sow.Id});
            }
        }
       return  AMPoolToSOWMapping;


    }

    public static Set<String> getAMPoolNames(Set<String> regions) {
        Map<String, List<String>> regionToAMPool = generateRegionToAMPoolMapping(regions);
        Set<String> AMPoolNames = new Set<String>();
        for(List<String> AMPools : regionToAMPool.values()) {
            for(String AMPool : AMPools) {
                AMPoolNames.add(AMPool);
            }
        }
        return AMPoolNames;
    }

    public static Map<String, List<String>> generateRegionToAMPoolMapping(Set<String> regions) {
        Map<String, List<String>> regionToAMPool = new Map<String, List<String>>();
        for(AMPoolRegionMapping__mdt mapping : [SELECT AMPools__c, Region__c
        FROM AMPoolRegionMapping__mdt
        WHERE Region__c IN :regions]) {
            List<String> AMPools = mapping.AMPools__c.split(',');
            regionToAMPool.put(mapping.Region__c, AMPools);
        }
        return regionToAMPool;
    }
}