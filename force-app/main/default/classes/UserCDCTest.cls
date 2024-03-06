/**
* @author Brite / Sales
* @group Apex Test
* @description Test Class for UserCDC Trigger
*/

/**
* IMPROVEMENTS TBD
* Maybe remove it completely since dedicated test classes for Utils would cover the trigger as well?
* Remove Profile References & Replace with PS / PSG
* Consolidate Overrides in a single place for maintainability / readability
* Decide: Do we need asserts because there is a separate class dedicated per scenario?
*/

@isTest
public class UserCDCTest {

    @TestSetup
    public static void createData() {
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
        }

        Id businessAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
        Id AMPoolWarsawUser = [SELECT Id FROM User WHERE Username = 'ampoolwarsawtest@invalid.com'].Id;
        Account AMPoolAccount = (Account) TestDataFactory.createSObject('Account', new Map<String, Object>{
                'BillingCountry' => 'Netherlands',
                'RecordTypeId' => businessAccount,
                'OwnerId' => AMPoolWarsawUser
        });

        Map<String, Object> valuesOverrideAccountPlan = new Map<String, Object>{
                'Account__c' => AMPoolAccount.Id
        };
        List<AccountPlan__c> accountPlans = (List<AccountPlan__c>) TestDataFactory.createSObjectList('AccountPlan__c', valuesOverrideAccountPlan, 5);

        List<ShareOfWallet__c> shareOfWallets = new List<ShareOfWallet__c>();
        for (AccountPlan__c accountPlan : accountPlans) {
            Map<String, Object> valuesOverrideSOW = new Map<String, Object>{
                    'AccountPlan__c ' => accountPlan.Id
            };
            shareOfWallets.addAll((List<ShareOfWallet__c>) TestDataFactory.createSObjectList('ShareOfWallet__c', valuesOverrideSOW, 5, false));
        }
        insert shareOfWallets;
    }
    
    @isTest private static void testManagerChange(){
        Account acc = TestUtil.createAccount('testAcc', true, true);
        User testUser1 = TestUtil.createUser();
        User managerUser = TestUtil.createUser();
        User managerUser2 = TestUtil.createUser();
        testUser1.ManagerId = managerUser.Id;
        update testUser1;
        
        ExceptionRequest__c req = new ExceptionRequest__c(Account__c = acc.Id, ExpectedMonthlyGrossMargin__c = 1000, NoOpportunityRecord__c = TRUE);
        insert req;
        ExceptionRequestMember__c reqMember = new ExceptionRequestMember__c(ExceptionRequest__c = req.Id, User__c = testUser1.Id);
        insert reqMember;
        Test.enableChangeDataCapture();
        Test.getEventBus().deliver();
        //Setup test Data        
        List<ExceptionRequest__Share> shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId =: req.Id AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals('Read', userAccess(managerUser.Id, shareList));
        Test.startTest();
        testUser1.ManagerId = managerUser2.Id;
        update testUser1;
        Test.stopTest();
        Test.getEventBus().deliver();
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId =: req.Id AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals('Read', userAccess(managerUser2.Id, shareList));
        System.assertEquals('None', userAccess(managerUser.Id, shareList));
        // Deliver test change events
        // Assert de sharing changes
    }

    @isTest
    public static void testAMPoolUserCreation() {
        Id accountManagerProfile = [SELECT ID FROM Profile WHERE Name = 'Adyen v2 Account Manager'].Id;
        Test.enableChangeDataCapture();
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
        Test.getEventBus().deliver();
    }

    @isTest
    public static void testAMPoolUserUpdate_SalesTeam() {
        Id accountManagerProfile = [SELECT ID FROM Profile WHERE Name = 'Adyen v2 Account Manager'].Id;
        Test.enableChangeDataCapture();
        Test.startTest();
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
        Test.getEventBus().deliver();
        nonAMPoolUser.SalesTeam__c = 'Account Management Pool';
        update nonAMPoolUser;
        Test.getEventBus().deliver();
        Test.stopTest();
    }
    
    @isTest
    public static void testAMPoolUserUpdate_SalesOffice() {
       Id accountManagerProfile = [SELECT ID FROM Profile WHERE Name = 'Adyen v2 Account Manager'].Id;
       Test.enableChangeDataCapture();
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
       Test.getEventBus().deliver();
       accountManagementPoolUser.SalesCountry__c = 'Italy';
       accountManagementPoolUser.SalesArea__c = 'Italy';
       accountManagementPoolUser.SalesOffice__c = 'Milan';
       update accountManagementPoolUser;
       Test.getEventBus().deliver();
       Test.stopTest();
    }
    
    private static string userAccess(Id userId, List<ExceptionRequest__Share> shareList){
        for (ExceptionRequest__Share share : shareList){
            if (share.UserOrGroupId == userId) {
                if (share.AccessLevel == 'Read'){
                    return 'Read';
                }
                if (share.AccessLevel == 'Edit'){
                    return 'Edit';
                }
                if (share.AccessLevel == 'All'){
                    return 'All';
                }
            }
        }
        return 'None';
    }
}