/**
* @author Sales
* @group Apex Test
* @description Test Class for AMPoolSOWSharingUtil
*/

/**
* IMPROVEMENTS TBD
* Create Users according to PS / PSG once profiles are cleaned up
* Consolidate test data overrides in a centralized place to reduce duplication & clutter
*/
@isTest
public with sharing class AMPoolSOWSharingUtilTest {

    @testSetup
    public static void createTestData() {

        User runAsUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(runAsUser) {
            Id accountManagerProfile = [SELECT ID FROM Profile WHERE Name = 'Adyen v2 Account Manager'].Id;

            User AMPoolWarsaw = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'FirstName' => 'AM Pool',
                    'LastName' => 'Warsaw',
                    'UserName' => 'ampoolwarsawtest@invalid.com',
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Account Management Pool',
                    'SalesOffice__c' => 'Warsaw',
                    'SalesCountry__c' => 'Poland',
                    'SalesArea__c' => 'Poland',
                    'CommunityNickname' => 'ampoolwarsaw',
                    'ProfileId' => accountManagerProfile,
                    'DoNotRunFlow__c' => true
            });

            User AMPoolAmsterdam = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'FirstName' => 'AM Pool',
                    'LastName' => 'Amsterdam',
                    'UserName' => 'ampoolamsterdamtest@invalid.com',
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Account Management Pool',
                    'SalesOffice__c' => 'Amsterdam',
                    'SalesCountry__c' => 'Netherlands',
                    'SalesArea__c' => 'Netherlands',
                    'CommunityNickname' => 'ampoolams',
                    'ProfileId' => accountManagerProfile,
                    'DoNotRunFlow__c' => true
            });

            User nonAMPoolUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Corporate Sales',
                    'SalesOffice__c' => 'Warsaw',
                    'SalesCountry__c' => 'Poland',
                    'SalesArea__c' => 'Poland',
                    'UserName' => 'testnonampool@invalid.com',
                    'CommunityNickname' => 'corpsalesuser',
                    'ProfileId' => accountManagerProfile,
                    'DoNotRunFlow__c' => true
            });

            User accountManagementPoolUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Account Management Pool',
                    'SalesOffice__c' => 'Warsaw',
                    'SalesCountry__c' => 'Poland',
                    'SalesArea__c' => 'Poland',
                    'SalesTeam__c' => 'Account Management Pool',
                    'UserName' => 'testampoolmanager@invalid.com',
                    'CommunityNickname' => 'ampooluser',
                    'ProfileId' => accountManagerProfile,
                    'DoNotRunFlow__c' => true
            });
        }

        Id businessAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
        Id AMPoolWarsawUser = [SELECT Id FROM User WHERE Username = 'ampoolwarsawtest@invalid.com'].Id;
        Id AMPoolAmsterdamUser = [SELECT Id FROM User WHERE Username = 'ampoolamsterdamtest@invalid.com'].Id;

        //Account Data
        Account amPoolAmsterdamAccount = ((Account) TestDataFactory.createSObject('Account', new Map<String, Object>{
                'BillingCountry' => 'Netherlands',
                'RecordTypeId' => businessAccount,
                'OwnerId' => AMPoolAmsterdamUser
        }, false));
        Account amPoolWarsawAccount = ((Account) TestDataFactory.createSObject('Account', new Map<String, Object>{
                'BillingCountry' => 'Netherlands',
                'RecordTypeId' => businessAccount,
                'OwnerId' => AMPoolWarsawUser
        }, false));
        insert new List<Account>{amPoolAmsterdamAccount, amPoolWarsawAccount};

        //Account Plan Data
        List<AccountPlan__c> accountPlans = new List<AccountPlan__c>();
        for(Account account : [SELECT Id, Owner.Name FROM Account WHERE Owner.FirstName = 'AM Pool']) {
            Map<String, Object> valuesOverrideAccountPlan = new Map<String, Object>{
                    'Account__c' => account.Id
            };
            accountPlans.addAll((List<AccountPlan__c>) TestDataFactory.createSObjectList('AccountPlan__c', valuesOverrideAccountPlan, 5, false));
        }
        insert accountPlans;

        //Share of Wallet Data
        List<ShareOfWallet__c> shareOfWallets = new List<ShareOfWallet__c>();
        for (AccountPlan__c accountPlan : [SELECT Id FROM AccountPlan__c WHERE Account__r.Owner.FirstName = 'AM Pool']) {
            Map<String, Object> valuesOverrideSOW = new Map<String, Object>{
                    'AccountPlan__c ' => accountPlan.Id
            };
            shareOfWallets.addAll((List<ShareOfWallet__c>) TestDataFactory.createSObjectList('ShareOfWallet__c', valuesOverrideSOW, 5, false));
        }
        insert shareOfWallets;
    }

    /**
	 * scenario: SOW & APCI sharing for new Account Management Pool User
	 */
    @isTest
    public static void amPoolSharing_NewUser() {
        Id accountManagerProfile = [SELECT ID FROM Profile WHERE Name = 'Adyen v2 Account Manager'].Id;
        Test.startTest();
        User accountManagementPoolUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                'LastName' => 'AM Pool User - Test',
                'SalesRegion__c' => 'EMEA',
                'SalesTeam__c' => 'Account Management Pool',
                'SalesOffice__c' => 'Warsaw',
                'SalesCountry__c' => 'Poland',
                'SalesArea__c' => 'Poland',
                'SalesTeam__c' => 'Account Management Pool',
                'UserName' => 'testampoolmgr@invalid.com',
                'ProfileId' => accountManagerProfile,
                'DoNotRunFlow__c' => true
        });
        Test.stopTest();

        Map<Id, User> users = new Map<Id, User>([SELECT Id, SalesTeam__c, SalesOffice__c FROM User WHERE LastName = 'AM Pool User - Test']);
        AMPoolSOWSharingUtil shareHelper = AMPoolSOWSharingUtil.getInstance();
        shareHelper.handleSharing(users);

        //Share of Wallet Asserts
        Integer expectedCountSOWShares = [SELECT Id FROM ShareOfWallet__c WHERE AccountPlan__r.Account__r.Owner.LastName = 'Warsaw'].size();
        List<sObject> createdSharesSOW = fetchShares('ShareOfWallet__Share', accountManagementPoolUser.Id);
        Assert.areEqual(expectedCountSOWShares, createdSharesSOW.size(), 'No. of SOW Shares is equal to No. of SOW Records Created');
        Assert.isTrue(checkSharingReason(createdSharesSOW), 'SOW Shares have the correct sharing reason');
        Assert.isTrue(checkAccessLevel(createdSharesSOW), 'SOW Shares have the correct access level');

        //AP Confidential Information Asserts
        Integer expectedCountAPConfidentialShares = [SELECT Id FROM AccountPlan__c WHERE Account__r.Owner.LastName = 'Warsaw'].size();
        List<sObject> createdSharesAPCI= fetchShares('APConfidentialInformation__Share', accountManagementPoolUser.Id);
        Assert.areEqual(expectedCountAPConfidentialShares, createdSharesAPCI.size(), 'No. of APCI Shares is equal to No. of APCI Records Created');
        Assert.isTrue(checkSharingReason(createdSharesAPCI), 'All APCI Shares have the correct sharing reason');
        Assert.isTrue(checkAccessLevel(createdSharesAPCI), 'APCI Shares have the correct access level');
    }

    /**
      * @Scenario: SOW & APCI sharing when a user's sales team is changed to 'Account Management Pool'
      */
    @isTest
    public static void amPoolSharing_UpdateSalesTeamToAMPool() {
        Map<Id, User> nonAMPoolUser = new Map<Id, User>([SELECT Id, SalesTeam__c, SalesOffice__c FROM User WHERE userName = 'testnonampool@invalid.com']);
        Id nonAMPoolUserId = nonAMPoolUser.values()[0].Id;
        Integer sowShareCountBeforeUpdate = fetchShares('ShareOfWallet__Share', nonAMPoolUserId).size();
        Integer apciShareCountBeforeUpdate = fetchShares('APConfidentialInformation__Share', nonAMPoolUserId).size();
        nonAMPoolUser.values()[0].SalesTeam__c = 'Account Management Pool';
        Test.startTest();
        update nonAMPoolUser.values();
        Test.stopTest();

        AMPoolSOWSharingUtil shareHelper = AMPoolSOWSharingUtil.getInstance();
        shareHelper.handleSharing(nonAMPoolUser);

        //Share of Wallet Asserts
        Integer expectedCountSOWShares = [SELECT Id FROM ShareOfWallet__c WHERE AccountPlan__r.Account__r.Owner.LastName = 'Warsaw'].size();
        List<sObject> createdSharesSOW = fetchShares('ShareOfWallet__Share', nonAMPoolUserId);
        Assert.areEqual(0, sowShareCountBeforeUpdate, 'No SOW shares before changing Sales Team to Account Management Pool');
        Assert.areEqual(expectedCountSOWShares, createdSharesSOW.size(), 'No. of SOW Shares is equal to No. of SOW Records Created');
        Assert.isTrue(checkSharingReason(createdSharesSOW), 'All SOW Shares have the correct sharing reason');
        Assert.isTrue(checkAccessLevel(createdSharesSOW), 'SOW Shares have the correct access level');

        //AP Confidential Information Asserts
        Integer expectedCountAPCIShares = [SELECT Id FROM AccountPlan__c WHERE Account__r.Owner.LastName = 'Warsaw'].size();
        List<sObject> createdSharesAPCI= fetchShares('APConfidentialInformation__Share', nonAMPoolUserId);
        Assert.areEqual(0, apciShareCountBeforeUpdate, 'No APCI shares before changing Sales Team to Account Management Pool');
        Assert.areEqual(expectedCountAPCIShares, createdSharesAPCI.size(), 'No. of APCI Shares is equal to No. of APCI Records Created');
        Assert.isTrue(checkSharingReason(createdSharesAPCI), 'All APCI Shares have the correct sharing reason');
        Assert.isTrue(checkAccessLevel(createdSharesAPCI), 'APCI Shares have the correct access level');
    }

    /**
       * @Scenario: SOW & APCI sharing when a user's sales team is changed from 'Account Management Pool' to something else
       */
    @isTest
    public static void amPoolSharing_UpdateSalesTeamFromAMPool() {
        Map<Id, User> userToBeUpdated = new Map<Id, User>([SELECT Id, SalesTeam__c, SalesOffice__c FROM User WHERE UserName = 'testampoolmanager@invalid.com']);
        Id userId = userToBeUpdated.values()[0].Id;
        AMPoolSOWSharingUtil shareHelper = AMPoolSOWSharingUtil.getInstance();
        shareHelper.handleSharing(userToBeUpdated);
        Integer sowShareCountBeforeUpdate = fetchShares('ShareOfWallet__Share', userId).size();
        Integer apciShareCountBeforeUpdate = fetchShares('APConfidentialInformation__Share', userId).size();
        Test.startTest();
        userToBeUpdated.values()[0].SalesTeam__c = 'Account Management';
        update userToBeUpdated.values();
        Test.stopTest();
        shareHelper.handleSharing(userToBeUpdated);

        //Share of Wallet Asserts
        Integer expectedCountSOWShares = [SELECT Id FROM ShareOfWallet__c WHERE AccountPlan__r.Account__r.Owner.LastName = 'Warsaw'].size();
        Integer sowShareCountAfterUpdate = fetchShares('ShareOfWallet__Share', userId).size();
        Assert.areEqual(expectedCountSOWShares, sowShareCountBeforeUpdate, 'Before Update, Count of SOW Shares is equal to Count of SOW Records Created');
        Assert.areEqual(0, sowShareCountAfterUpdate, 'Existing SOW Shares are deleted after changing Sales Team to something else');

        //AP Confidential Information Asserts
        Integer expectedCountAPCIShares = [SELECT Id FROM AccountPlan__c WHERE Account__r.Owner.LastName = 'Warsaw'].size();
        Integer apciShareCountAfterUpdate = fetchShares('APConfidentialInformation__Share', userId).size();
        Assert.areEqual(expectedCountAPCIShares, apciShareCountBeforeUpdate, 'Before Update, Count of APCI Shares is equal to Count of SOW Records Created');
        Assert.areEqual(0, apciShareCountAfterUpdate, 'Existing APCI Shares are deleted after changing Sales Team to something else');
    }

    /**
       * @Scenario: SOW & APCI sharing when an AM Pool user's sales office is changed
       */
    @isTest
    public static void amPoolSharing_UpdateSalesOffice() {
        Map<Id, User> userToBeUpdated = new Map<Id, User>([SELECT Id, SalesTeam__c, SalesOffice__c FROM User WHERE UserName = 'testampoolmanager@invalid.com']);
        Id userId = userToBeUpdated.values()[0].Id;
        AMPoolSOWSharingUtil shareHelper = AMPoolSOWSharingUtil.getInstance();
        shareHelper.handleSharing(userToBeUpdated);

        Test.startTest();
        userToBeUpdated.values()[0].SalesCountry__c = 'Netherlands';
        userToBeUpdated.values()[0].SalesArea__c = 'Netherlands';
        userToBeUpdated.values()[0].SalesOffice__c = 'Amsterdam';
        update userToBeUpdated.values();
        Test.stopTest();
        shareHelper.handleSharing(userToBeUpdated);

        //Share of Wallet Asserts
        List<sObject> shareOfWallets = [SELECT Id FROM ShareOfWallet__c WHERE AccountPlan__r.Account__r.Owner.LastName = 'Amsterdam'];
        Integer sowShareCountAfterUpdate = Utils.fetchRecordAccessMapping(shareOfWallets, userId, 'Id').size();
        Assert.areEqual(shareOfWallets.size(), sowShareCountAfterUpdate, 'After Update, Count of SOW Shares is equal to Count of SOW Records Created');

        //AP Confidential Asserts
        List<sObject> accountPlansWithAPCI = [SELECT Id, APConfidentialInformation__c FROM AccountPlan__c WHERE Account__r.Owner.LastName = 'Amsterdam'];
        Integer apciShareCountAfterUpdate = Utils.fetchRecordAccessMapping(accountPlansWithAPCI, userId, 'APConfidentialInformation__c').size();
        Assert.areEqual(accountPlansWithAPCI.size(), apciShareCountAfterUpdate, 'After Update, Count of APCI Shares is equal to Count of APCI Records Created');
    }

    public static List<sObject> fetchShares(String shareObjectName, String userId) {
        String query = 'SELECT Id, ParentId, RowCause, AccessLevel FROM ' + shareObjectName + ' WHERE UserOrGroupId = :userId';
        List<sObject> shares = Database.query(query);
        return shares;
    }

    public static boolean checkSharingReason(List<sObject> shares) {
        Boolean result = true;
        String objectName = Utils.getSObjectNameFromId(shares[0], 'ParentId');
        String sharingReason = objectName == 'ShareOfWallet__c' ? AMPoolSOWSharingUtil.APEXSHARINGREASONSOW : AMPoolSOWSharingUtil.APEXSHARINGREASONAPC;
        for(sObject share : shares) {
            if(share.get('RowCause') != sharingReason) {
                result = false;
                break;
            }
        }
        return result;
    }

    public static boolean checkAccessLevel(List<sObject> shares) {
        Boolean result = true;
        for(sObject share : shares) {
            if(share.get('AccessLevel') != AMPoolSOWSharingUtil.ACCESSLEVEL) {
                result = false;
                break;
            }
        }
        return result;
    }
}