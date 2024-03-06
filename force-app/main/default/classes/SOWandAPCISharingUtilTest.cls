/**
* @author Sales
* @group Apex Test
* @description Test Class for SOWandAPCISharingUtil
*/
@isTest
public class SOWandAPCISharingUtilTest {

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
                    'CommunityNickname' => 'ampWarsaw',
                    'ProfileId' => accountManagerProfile,
                    'ManagerId' => UserInfo.getUserId()
            }, false);

            User AMPoolAmsterdam = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'FirstName' => 'AM Pool',
                    'LastName' => 'Amsterdam',
                    'UserName' => 'ampoolamsterdamtest@invalid.com',
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Account Management Pool',
                    'SalesOffice__c' => 'Amsterdam',
                    'SalesCountry__c' => 'Netherlands',
                    'SalesArea__c' => 'Netherlands',
                    'CommunityNickname' => 'ampNetherland',
                    'ProfileId' => accountManagerProfile,
                    'ManagerId' => UserInfo.getUserId()
            }, false);

            User nonAMPoolUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'UserName' => 'testnonampool@invalid.com',
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Corporate Sales',
                    'SalesOffice__c' => 'Warsaw',
                    'SalesCountry__c' => 'Poland',
                    'SalesArea__c' => 'Poland',
                    'CommunityNickname' => 'corpsalesuser',
                    'ProfileId' => accountManagerProfile
            }, false);


            User amPoolWarsawUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Account Management Pool',
                    'SalesOffice__c' => 'Warsaw',
                    'SalesCountry__c' => 'Poland',
                    'SalesArea__c' => 'Poland',
                    'SalesTeam__c' => 'Account Management Pool',
                    'UserName' => 'ampoolwarsawuser@invalid.com',
                    'CommunityNickname' => 'ampooluserwarsaw',
                    'ProfileId' => accountManagerProfile
            }, false);


            User amPoolAmsterdamUser = (User) TestDataFactory.createSObject('User', new Map<String, Object> {
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Account Management Pool',
                    'SalesOffice__c' => 'Amsterdam',
                    'SalesCountry__c' => 'Netherlands',
                    'SalesArea__c' => 'Netherlands',
                    'SalesTeam__c' => 'Account Management Pool',
                    'UserName' => 'ampoolamsterdamuser@invalid.com',
                    'CommunityNickname' => 'ampooluseramsterdam',
                    'ProfileId' => accountManagerProfile
            }, false);

            insert new List<User>{
                    AMPoolWarsaw, AMPoolAmsterdam, nonAMPoolUser, amPoolWarsawUser, amPoolAmsterdamUser
            };

        }

        Id warsawPoolUser = [SELECT Id FROM User WHERE Username = 'ampoolwarsawuser@invalid.com'].Id;
        Id amsterdamPoolUser = [SELECT Id FROM User WHERE Username = 'ampoolamsterdamuser@invalid.com'].Id;

        //Account Data
        List<Account> accounts = new List<Account>();
        Account accountWithDedicatedOwner = ((Account) TestDataFactory.createSObject('Account', new Map<String, Object>{
                'BillingCountry' => 'Netherlands',
                'RecordTypeId' => Constants.RT_ID_ACC_BUSINESS,
                'Name' => 'Account - Dedicated Owner'
        }));

        //Account Plan Data
        AccountPlan__c accountPlan = ((AccountPlan__c) TestDataFactory.createSObject('AccountPlan__c', new Map<String, Object>{
                'Account__c' => accountWithDedicatedOwner.Id
        }));


        //Share of Wallet Data
        List<ShareOfWallet__c> shareOfWallets = new List<ShareOfWallet__c>();
        for (Integer i = 0; i < 5; i++) {
            Map<String, Object> valuesOverrideSOW = new Map<String, Object>{
                    'AccountPlan__c ' => accountPlan.Id
            };
            shareOfWallets.add((ShareOfWallet__c) TestDataFactory.createSObject('ShareOfWallet__c', valuesOverrideSOW, false));
        }
        insert shareOfWallets;
    }


    /**
     * @Scenario: SOW & APCI sharing when account's ownership changes from dedicated owner to pooled owner
     */
    @isTest
    public static void amPoolSharing_DedicatedToAMPool() {
        Account account = [SELECT Id, OwnerId FROM Account LIMIT 1];
        Id newUserId = [SELECT Id FROM User WHERE Username = 'ampoolwarsawtest@invalid.com'].Id;
        Id amPoolWarsawUserId = [SELECT Id FROM User WHERE UserName = 'ampoolwarsawuser@invalid.com'].Id;
        Integer numSOWSharesBeforeUpdate = fetchShares('ShareOfWallet__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONSOW).size();
        Integer numAPCISharesBeforeUpdate = fetchShares('APConfidentialInformation__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONAPC).size();
        Test.startTest();
        account.OwnerId = newUserId;
        update account;
        Test.stopTest();

        //Share of Wallet Asserts
        Integer expectedCountSOWShares = [SELECT Id FROM ShareOfWallet__c WHERE AccountPlan__r.Account__c = :account.Id].size();
        List<sObject> sowSharesAfterUpdate = fetchShares('ShareOfWallet__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONSOW);
        Assert.areEqual(expectedCountSOWShares, sowSharesAfterUpdate.size(), 'No. of SOW Shares is equal to No. of SOW Records');
        Assert.areEqual(numSOWSharesBeforeUpdate, 0);
        Assert.isTrue(Utils.checkSharingReason(sowSharesAfterUpdate), 'SOW Shares have the correct sharing reason');
        Assert.isTrue(Utils.checkAccessLevel(sowSharesAfterUpdate, SOWandAPCISharingUtil.ACCESSLEVEL), 'SOW Shares have the correct access level');

        //AP Confidential Information Asserts
        Integer expectedCountAPConfidentialShares = [SELECT Id FROM AccountPlan__c WHERE Account__c = :account.Id].size();
        List<sObject> apciSharesAfterUpdate = fetchShares('APConfidentialInformation__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONAPC);
        Assert.areEqual(numAPCISharesBeforeUpdate, 0);
        Assert.areEqual(expectedCountAPConfidentialShares, apciSharesAfterUpdate.size(), 'No. of APCI Shares is equal to No. of APCI Records Created');
        Assert.isTrue(Utils.checkSharingReason(apciSharesAfterUpdate), 'All APCI Shares have the correct sharing reason');
        Assert.isTrue(Utils.checkAccessLevel(apciSharesAfterUpdate, SOWandAPCISharingUtil.ACCESSLEVEL), 'APCI Shares have the correct access level');
    }

    /**
     * @Scenario: SOW & APCI sharing when account's ownership changes from one pooled owner to another
     */
    @IsTest
    public static void amPoolSharing_AMPoolOwnershipChange() {
        Account account = [SELECT Id, OwnerId FROM Account LIMIT 1];
        Id newUserIdWarsaw = [SELECT Id FROM User WHERE Username = 'ampoolwarsawtest@invalid.com'].Id;
        Id newUserIdAmsterdam = [SELECT Id FROM User WHERE Username = 'ampoolamsterdamtest@invalid.com'].Id;
        Id amPoolWarsawUserId = [SELECT Id FROM User WHERE UserName = 'ampoolwarsawuser@invalid.com'].Id;
        Id amPoolAmsterdamUserId = [SELECT Id FROM User WHERE UserName = 'ampoolamsterdamuser@invalid.com'].Id;
        Test.startTest();
        account.OwnerId = newUserIdAmsterdam; //change the account owner to am pool amsterdam
        update account;
        Integer numSOWSharesBeforeUpdateWarsaw = fetchShares('ShareOfWallet__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONSOW).size();
        Integer numAPCISharesBeforeUpdateWarsaw = fetchShares('APConfidentialInformation__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONAPC).size();
        account.OwnerId = newUserIdWarsaw; //change the account owner to am pool warsaw
        update account;
        Test.stopTest();

        //Share of Wallet Asserts
        Integer expectedCountSOWShares = [SELECT Id FROM ShareOfWallet__c WHERE AccountPlan__r.Account__c = :account.Id].size();
        Integer numSOWSharesAmsterdam = fetchShares('ShareOfWallet__share', amPoolAmsterdamUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONSOW).size();
        List<sObject> sowSharesAfterUpdateWarsaw = fetchShares('ShareOfWallet__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONSOW);
        Assert.areEqual(numSOWSharesAmsterdam, 0, 'All SOW shares for AM Pool Amsterdam User deleted');
        Assert.areEqual(numSOWSharesBeforeUpdateWarsaw, 0, 'No SOW shares for AM Pool Warsaw user before change to AM Pool Warsaw');
        Assert.areEqual(expectedCountSOWShares, sowSharesAfterUpdateWarsaw.size(), 'No. of SOW Shares is equal to No. of SOW Records for AM Pool Warsaw User');
        Assert.isTrue(Utils.checkSharingReason(sowSharesAfterUpdateWarsaw), 'SOW Shares have the correct sharing reason');
        Assert.isTrue(Utils.checkAccessLevel(sowSharesAfterUpdateWarsaw, SOWandAPCISharingUtil.ACCESSLEVEL), 'SOW Shares have the correct access level');

        //AP Confidential Information Asserts
        Integer numAPCISharesAmsterdam = fetchShares('APConfidentialInformation__share', amPoolAmsterdamUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONAPC).size();
        Integer expectedCountAPConfidentialShares = [SELECT Id FROM AccountPlan__c WHERE Account__c = :account.Id].size();
        List<sObject> apciSharesAfterUpdate = fetchShares('APConfidentialInformation__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONAPC);
        Assert.areEqual(numAPCISharesAmsterdam, 0, 'All APCI shares for AM Pool Amsterdam User deleted');
        Assert.areEqual(numAPCISharesBeforeUpdateWarsaw, 0, 'No APCI shares for AM Pool Warsaw user before change to AM Pool Warsaw');
        Assert.areEqual(expectedCountAPConfidentialShares, apciSharesAfterUpdate.size(), 'No. of APCI Shares is equal to No. of APCI Records Created');
        Assert.isTrue(Utils.checkSharingReason(apciSharesAfterUpdate), 'All APCI Shares have the correct sharing reason');
        Assert.isTrue(Utils.checkAccessLevel(apciSharesAfterUpdate, SOWandAPCISharingUtil.ACCESSLEVEL), 'APCI Shares have the correct access level');
    }

    /**
     * @Scenario: SOW & APCI sharing when account's ownership changes from pooled owner to dedicated owner
     */
    @IsTest
    public static void amPoolSharing_AMPoolToDedicatedOwner() {
        Account account = [SELECT Id, OwnerId FROM Account LIMIT 1];
        Id newUserIdWarsaw = [SELECT Id FROM User WHERE Username = 'ampoolwarsawtest@invalid.com'].Id;
        Id newUserIdDedicatedUser = [SELECT Id FROM User WHERE Username = 'testnonampool@invalid.com'].Id;
        Id amPoolWarsawUserId = [SELECT Id FROM User WHERE UserName = 'ampoolwarsawuser@invalid.com'].Id;
        Test.startTest();
        account.OwnerId = newUserIdWarsaw; //change the account owner to am pool warsaw
        update account;
        Integer numSOWSharesAfterUpdate = fetchShares('ShareOfWallet__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONSOW).size();
        Integer numAPCISharesAfterUpdate = fetchShares('APConfidentialInformation__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONAPC).size();
        account.OwnerId = newUserIdDedicatedUser; //change the account owner to a dedicated user
        update account;
        Test.stopTest();

        //Share of Wallet Asserts
        Integer expectedCountSOWShares = [SELECT Id FROM ShareOfWallet__c WHERE AccountPlan__r.Account__c = :account.Id].size();
        Integer numSOWSharesWarsaw = fetchShares('ShareOfWallet__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONSOW).size();
        Assert.areEqual(expectedCountSOWShares, numSOWSharesAfterUpdate, 'SOW share count as expected after changing from dedicated owner to Pool');
        Assert.areEqual(numSOWSharesWarsaw, 0, 'All SOW shares for AM Pool Warsaw User deleted after reverting to dedicated owner');

        //AP Confidential Information Asserts
        Integer expectedCountAPConfidentialShares = [SELECT Id FROM AccountPlan__c WHERE Account__c = :account.Id].size();
        Integer numAPCISharesWarsaw = fetchShares('APConfidentialInformation__share', amPoolWarsawUserId, AMPoolSOWSharingUtil.APEXSHARINGREASONAPC).size();
        Assert.areEqual(expectedCountAPConfidentialShares, numAPCISharesAfterUpdate, 'APCI share count as expected after changing from dedicated owner to Pool');
        Assert.areEqual(numAPCISharesWarsaw, 0, 'All APCI shares for AM Pool Amsterdam User deleted');
    }

    public static List<sObject> fetchShares(String shareObjectName, String userId, String rowCause) {
        String query = 'SELECT Id, ParentId, RowCause, AccessLevel FROM ' + shareObjectName + ' WHERE UserOrGroupId = :userId AND RowCause = :rowCause';
        List<sObject> shares = Database.query(query);
        return shares;
    }

}