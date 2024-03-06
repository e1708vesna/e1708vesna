/**
* @author Sales
* @group Test
* @description Test class for UserTrgHandler
* name updating.
*/
@isTest
public class UserTrgHandlerTest {
	
    
    @testSetup
    public static void createTestData() {
        Id accountManagerProfile = [SELECT ID FROM Profile WHERE Name = 'Adyen v2 Account Manager'].Id;
        Id businessAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();

        User AMPoolWarsaw = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                'FirstName' => 'AM Pool',
                'LastName' => 'Warsaw',
                'UserName' => 'testampoolwarsaw@invalid.com',
                'SalesRegion__c' => 'EMEA',
                'SalesTeam__c' => 'Account Management Pool',
                'SalesOffice__c' => 'Warsaw',
                'SalesCountry__c' => 'Poland',
                'SalesArea__c' => 'Poland',
                'UserName' => 'testampool@invalid.com',
                'CommunityNickname' => 'ampoolwarsaw',
                'ProfileId' => accountManagerProfile
        });

        User nonAMPoolUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                'UserName' => 'corporatesalesuser@invalid.com',
                'SalesRegion__c' => 'EMEA',
                'SalesTeam__c' => 'Corporate Sales',
                'SalesOffice__c' => 'Warsaw',
                'SalesCountry__c' => 'Poland',
                'SalesArea__c' => 'Poland',
                'UserName' => 'testnonampool@invalid.com',
                'CommunityNickname' => 'corpsalesuser',
                'ProfileId' => accountManagerProfile
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
                'ProfileId' => accountManagerProfile
        });


        Account AMPoolAccount = (Account) TestDataFactory.createSObject('Account', new Map<String, Object>{
                'BillingCountry' => 'Netherlands',
                'RecordTypeId' => businessAccount,
                'OwnerId' => AMPoolWarsaw.Id
        });

        Map<String, Object> valuesOverrideAccountPlan = new Map<String, Object>{
                'Account__c' => AMPoolAccount.Id
        };
        List<AccountPlan__c> accountPlans = (List<AccountPlan__c>) TestDataFactory.createSObjectList('AccountPlan__c', valuesOverrideAccountPlan, 5);

        for (AccountPlan__c accountPlan : accountPlans) {
            Map<String, Object> valuesOverrideSOW = new Map<String, Object>{
                    'AccountPlan__c ' => accountPlan.Id
            };
            List<ShareOfWallet__c> shareOfWallets = (List<ShareOfWallet__c>) TestDataFactory.createSObjectList('ShareOfWallet__c', valuesOverrideSOW, 5);
        }
    }

    /* @Scenario: SOW Sharing for new Account Management Pool User */
    @isTest
    public static void sowSharingTestNewUser() {
        Id accountManagerProfile = [SELECT ID FROM Profile WHERE Name = 'Adyen v2 Account Manager'].Id;
        Test.startTest();
        User accountManagementPoolUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                'SalesRegion__c' => 'EMEA',
                'SalesTeam__c' => 'Account Management Pool',
                'SalesOffice__c' => 'Warsaw',
                'SalesCountry__c' => 'Poland',
                'SalesArea__c' => 'Poland',
                'SalesTeam__c' => 'Account Management Pool',
                'UserName' => 'testampoolmgr@invalid.com',
                'ProfileId' => accountManagerProfile
        });
        Test.stopTest();
        Integer expectedNumberOfShares = [SELECT Id FROM ShareOfWallet__c].size();
        List<ShareOfWallet__Share> createdShares = [SELECT Id, UserOrGroupId FROM ShareOfWallet__Share WHERE UserOrGroupId = :accountManagementPoolUser.Id];
        Assert.areEqual(expectedNumberOfShares, createdShares.size(), 'No. of SOW Shares is equal to No. of SOW Records Created');
    }

    /* @Scenario: SOW Sharing for update to Sales Team to Account Management Pool */
    @isTest
    public static void sowSharingTestUpdatedUser() {
        User nonAMPoolUser = [SELECT Id, SalesTeam__c FROM User WHERE userName = 'testnonampool@invalid.com'];
        Integer sharesBeforeUpdate = [SELECT Id, UserOrGroupId FROM ShareOfWallet__Share WHERE UserOrGroupId = :nonAMPoolUser.Id].size();
        Integer expectedNumberOfShares = [SELECT Id FROM ShareOfWallet__c].size();
        Test.startTest();
        nonAMPoolUser.SalesTeam__c = 'Account Management Pool';
        update nonAMPoolUser;
        Test.stopTest();
        List<ShareOfWallet__Share> createdShares = [SELECT Id, UserOrGroupId FROM ShareOfWallet__Share WHERE UserOrGroupId = :nonAMPoolUser.Id];
        Assert.areEqual(0, sharesBeforeUpdate, 'No SOW shares before changing Account Team to Account Management Pool');
        Assert.areEqual(expectedNumberOfShares, createdShares.size(), 'No. of SOW Shares is equal to No. of SOW Records Created');
    }

    /* @Scenario: SOW Sharing for deactivated user */
    @isTest
    public static void sowSharingTestDeactivateUser() {
        User accountManagementPoolUser = [SELECT Id, isActive FROM User WHERE username = 'testampoolmanager@invalid.com'];
        Test.startTest();
        accountManagementPoolUser.IsActive = false;
        update accountManagementPoolUser;
        Test.stopTest();
        Integer sharesAfterDeactivation = [SELECT Id, UserOrGroupId FROM ShareOfWallet__Share WHERE UserOrGroupId = :accountManagementPoolUser.Id].size();
        Assert.areEqual(0, sharesAfterDeactivation, 'No SOW shares after the user is deactivated');
    }

    /* @Scenario: SOW Sharing for updating Sales Team to something else than 'Account Management Pool'*/
    @isTest
    public static void sowSharingTestUpdateSalesTeam() {
        Id accountManagerProfile = [SELECT ID FROM Profile WHERE Name = 'Adyen v2 Account Manager'].Id;
        User accountManagementPoolUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                'SalesRegion__c' => 'EMEA',
                'SalesTeam__c' => 'Account Management Pool',
                'SalesOffice__c' => 'Warsaw',
                'SalesCountry__c' => 'Poland',
                'SalesArea__c' => 'Poland',
                'SalesTeam__c' => 'Account Management Pool',
                'UserName' => 'testampoolmgr@invalid.com',
                'ProfileId' => accountManagerProfile
        });
        Integer sharesBeforeUpdate = [SELECT Id, UserOrGroupId FROM ShareOfWallet__Share WHERE UserOrGroupId = :accountManagementPoolUser.Id].size();
        Test.startTest();
        accountManagementPoolUser.SalesTeam__c = 'Account Management';
        update accountManagementPoolUser;
        Test.stopTest();
        Integer sharesAfterUpdate = [SELECT Id, UserOrGroupId FROM ShareOfWallet__Share WHERE UserOrGroupId = :accountManagementPoolUser.Id].size();
        Assert.areEqual(25, sharesBeforeUpdate, 'No. of SOW Shares is equal to No. of SOW Records Created');
        Assert.areEqual(0, sharesAfterUpdate, 'No SOW Shares after Sales Team is changed');
    }
	
    /* @Scenario: SOW Sharing for updating Sales Region */
    @isTest
    public static void sowSharingTestUpdateSalesRegion() {
        Id accountManagerProfile = [SELECT ID FROM Profile WHERE Name = 'Adyen v2 Account Manager'].Id;
        User accountManagementPoolUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                'SalesRegion__c' => 'EMEA',
                'SalesTeam__c' => 'Account Management Pool',
                'SalesOffice__c' => 'Warsaw',
                'SalesCountry__c' => 'Poland',
                'SalesArea__c' => 'Poland',
                'SalesTeam__c' => 'Account Management Pool',
                'UserName' => 'testampoolmgr@invalid.com',
                'ProfileId' => accountManagerProfile
        });
        Integer sharesBeforeUpdate = [SELECT Id, UserOrGroupId FROM ShareOfWallet__Share WHERE UserOrGroupId = :accountManagementPoolUser.Id].size();
        Test.startTest();
        accountManagementPoolUser.SalesTeam__c = 'Account Management';
        update accountManagementPoolUser;
        Test.stopTest();
        Integer sharesAfterUpdate = [SELECT Id, UserOrGroupId FROM ShareOfWallet__Share WHERE UserOrGroupId = :accountManagementPoolUser.Id].size();
        Assert.areEqual(25, sharesBeforeUpdate, 'No. of SOW Shares is equal to No. of SOW Records Created');
        Assert.areEqual(0, sharesAfterUpdate, 'No SOW Shares after Sales Team is changed');
    }


}