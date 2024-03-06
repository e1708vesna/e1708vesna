/**
* @author Sales
* @group Test
* @description Test class for AccountPlanReviewNotificationBatch
*/
@isTest
public with sharing class AccountPlanReviewNotificationBatchTest {

    @testSetup
    public static void createData() {

        //User Data
        User runAsUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(runAsUser) {
            Id accountManagerProfile = [SELECT ID FROM Profile WHERE Name = 'Adyen v2 Account Manager'].Id;

            List<User> testUsers = new List<User>();

            User manager = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Account Management Pool',
                    'SalesOffice__c' => 'Warsaw',
                    'SalesCountry__c' => 'Poland',
                    'SalesArea__c' => 'Poland',
                    'SalesTeam__c' => 'Account Management Pool',
                    'UserName' => 'testmanager@invalid.com',
                    'CommunityNickname' => 'testmanager',
                    'ProfileId' => accountManagerProfile
            }, false);
            testUsers.add(manager);

            User accountPlanOwner = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'UserName' => 'accountplanowner@invalid.com',
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Corporate Sales',
                    'SalesOffice__c' => 'Warsaw',
                    'SalesCountry__c' => 'Poland',
                    'SalesArea__c' => 'Poland',
                    'CommunityNickname' => 'apowner',
                    'ProfileId' => accountManagerProfile,
                    'ManagerId' => manager.Id
            }, false);
            testUsers.add(accountPlanOwner);


            User unmanagedUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'LastName' => 'Unmanaged',
                    'UserName' => 'unmanagedowner@invalid.com',
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Corporate Sales',
                    'SalesOffice__c' => 'Warsaw',
                    'SalesCountry__c' => 'Poland',
                    'SalesArea__c' => 'Poland',
                    'CommunityNickname' => 'apunmanaged',
                    'ProfileId' => accountManagerProfile,
                    'ManagerId' => manager.Id
            }, false);
            testUsers.add(unmanagedUser);

            User AMPoolOwner = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'FirstName' => 'AM Pool',
                    'LastName' => 'Amsterdam',
                    'UserName' => 'ampoolamsterdam@invalid.com',
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Corporate Sales',
                    'SalesOffice__c' => 'Amsterdam',
                    'SalesCountry__c' => 'Netherlands',
                    'SalesArea__c' => 'Netherlands',
                    'CommunityNickname' => 'ampoolams',
                    'ProfileId' => accountManagerProfile
            }, false);
            testUsers.add(AMPoolOwner);

            User APACPODUser = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
                    'FirstName' => 'AM Pod',
                    'LastName' => 'APAC',
                    'UserName' => 'ampodapac@invalid.com',
                    'SalesRegion__c' => 'EMEA',
                    'SalesTeam__c' => 'Corporate Sales',
                    'SalesOffice__c' => 'Warsaw',
                    'SalesCountry__c' => 'Poland',
                    'SalesArea__c' => 'Poland',
                    'CommunityNickname' => 'ampoolapac',
                    'ProfileId' => accountManagerProfile
            }, false);
            testUsers.add(APACPODUser);

            insert testUsers;
        }

        //Account Data
        List<Account> testAccounts = new List<Account>();
        Map<String, Object> accountOverrideValues = new Map<String, Object>{
                'RecordTypeId' => Constants.RT_ID_ACC_BUSINESS,
                'BillingCountry' => 'Colombia',
                'Industry' => 'Retail',
                'SubIndustry__c' => 'Other',
                'Company_Segment__c' => '25 - 50 million',
                'MerchantCoreBusinessModel__c' => 'Platforms',
                'SubBusinessModel__c' => 'Marketplaces',
                'Account_Status__c' => 'Transacting',
                'BO_Status__c' => 'Active',
                'IsTransacting__c' => true
        };
        List<Account> dedicatedUserAccounts = (List<Account>)TestDataFactory.createSObjectList('Account', accountOverrideValues, 20, false);
        testAccounts.addAll(dedicatedUserAccounts);

        Id AMPool = [SELECT Id FROM User WHERE UserName = 'ampoolamsterdam@invalid.com'].Id;
        Map<String, Object> accountOverrideValuesAMPool = new Map<String, Object>{
                'RecordTypeId' => Constants.RT_ID_ACC_BUSINESS,
                'BillingCountry' => 'Colombia',
                'Industry' => 'Retail',
                'SubIndustry__c' => 'Other',
                'Company_Segment__c' => '25 - 50 million',
                'MerchantCoreBusinessModel__c' => 'Platforms',
                'SubBusinessModel__c' => 'Marketplaces',
                'Account_Status__c' => 'Transacting',
                'BO_Status__c' => 'Active',
                'IsTransacting__c' => true,
                'OwnerId' => AMPool
        };
        List<Account> AMPoolUserAccounts = (List<Account>)TestDataFactory.createSObjectList('Account', accountOverrideValuesAMPool, 10, false);
        testAccounts.addAll(AMPoolUserAccounts);

        Id AMPod = [SELECT Id FROM User WHERE UserName = 'ampodapac@invalid.com'].Id;
        Map<String, Object> accountOverrideValuesPod = new Map<String, Object>{
                'RecordTypeId' => Constants.RT_ID_ACC_BUSINESS,
                'BillingCountry' => 'Colombia',
                'Industry' => 'Retail',
                'SubIndustry__c' => 'Other',
                'Company_Segment__c' => '25 - 50 million',
                'MerchantCoreBusinessModel__c' => 'Platforms',
                'SubBusinessModel__c' => 'Marketplaces',
                'Account_Status__c' => 'Transacting',
                'BO_Status__c' => 'Active',
                'IsTransacting__c' => true,
                'OwnerId' => AMPod
        };
        List<Account> PodUsers = (List<Account>)TestDataFactory.createSObjectList('Account', accountOverrideValuesPod, 10, false);
        testAccounts.addAll(PodUsers);

        insert testAccounts;
    }


    /* @Scenario: First Notification for Account Plans (completed 365 days of no review today) */
    @IsTest
    public static void sendNotifications_ReminderDateNotSet() {
        Id accountPlanOwner = [SELECT Id FROM User WHERE UserName = 'accountplanowner@invalid.com'].Id;
        createAccountPlans(Date.Today().addYears(-1), null, accountPlanOwner, UserInfo.getUserId());
        Test.startTest();
        AccountPlanReviewNotificationBatch testBatch = new AccountPlanReviewNotificationBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();
        Boolean reminderCheck = checkReminderDatePopulation();
        Assert.isTrue(reminderCheck, 'ReviewReminderDate__c has been populated and is 14 days from today');
    }

    /* @Scenario: First Notification has already been sent, next notification is today */
    @IsTest
    public static void sendNotifications_ReminderDateToday() {
        Id accountPlanOwner = [SELECT Id FROM User WHERE UserName = 'accountplanowner@invalid.com'].Id;
        createAccountPlans(Date.Today().addYears(-1), Date.today(), accountPlanOwner, UserInfo.getUserId());
        Test.startTest();
        AccountPlanReviewNotificationBatch testBatch = new AccountPlanReviewNotificationBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();
        Boolean reminderCheck = checkReminderDatePopulation();
        Assert.isTrue(reminderCheck, 'ReviewReminderDate__c has been populated and is 14 days from today');
    }

    /* @Scenario: First Notification has already been sent, but next reminder date is not today */
    @IsTest
    public static void sendNotifications_ReminderDateNotToday() {
        Id accountPlanOwner = [SELECT Id FROM User WHERE UserName = 'accountplanowner@invalid.com'].Id;
        createAccountPlans(Date.Today().addDays(367), Date.today().addDays(15), accountPlanOwner, UserInfo.getUserId());
        Test.startTest();
        AccountPlanReviewNotificationBatch testBatch = new AccountPlanReviewNotificationBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();
        Boolean reminderCheck = checkReminderFieldChange();
        Assert.isFalse(reminderCheck, 'ReviewReminderDate__c has not been updated');
    }

    /* @Scenario: First Notification sent and Account Plan Reviewed, but next reminder date is not empty */
    //@@info: This can happen because we are not clearing out 'ReviewReminderDate__c' when the Account Plan
    //gets reviewed. So, it can happen that DaysNotReviewed__c == 365 but ReviewReminderDate__c is some
    //invalid date. This is a temporary feature, so the field is not cleared out in the trigger
    @IsTest
    public static void sendNotifications_ReminderDateNotCleared() {
        Id accountPlanOwner = [SELECT Id FROM User WHERE UserName = 'accountplanowner@invalid.com'].Id;
        createAccountPlans(Date.Today().addYears(-1), Date.today().addDays(15), accountPlanOwner, UserInfo.getUserId());
        Test.startTest();
        AccountPlanReviewNotificationBatch testBatch = new AccountPlanReviewNotificationBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();
        Boolean reminderCheck = checkReminderFieldChange();
        Assert.isTrue(reminderCheck, 'ReviewReminderDate__c has been updated');
    }

    /* @Scenario: Notification should not be sent if the Account Plan's Owner is Unmanaged */
    @IsTest
    public static void sendNotifications_UnmanagedOwner() {
        Id accountPlanOwner = [SELECT Id FROM User WHERE UserName = 'unmanagedowner@invalid.com'].Id;
        createAccountPlans(Date.Today().addYears(-1), null, accountPlanOwner, UserInfo.getUserId());
        Test.startTest();
        AccountPlanReviewNotificationBatch testBatch = new AccountPlanReviewNotificationBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();
        Boolean reminderCheck = checkReminderDatePopulation();
        Assert.isFalse(reminderCheck, 'ReviewReminderDate__c has not been populated');
    }

    /* @Scenario: Notification should not be sent if the owner of the account related to the Account Plan is an AM Pool User */
    @IsTest
    public static void sendNotifications_APOwnedByAMPool() {
        Id accountPlanOwner = [SELECT Id FROM User WHERE UserName = 'accountplanowner@invalid.com'].Id;
        Id AMPoolOwner = [SELECT Id FROM User WHERE UserName = 'ampoolamsterdam@invalid.com'].Id;
        createAccountPlans(Date.Today().addYears(-1), null, accountPlanOwner, AMPoolOwner);
        Test.startTest();
        AccountPlanReviewNotificationBatch testBatch = new AccountPlanReviewNotificationBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();
        Boolean reminderCheck = checkReminderDatePopulation();
        Assert.isFalse(reminderCheck, 'ReviewReminderDate__c has not been populated');
    }

    /* @Scenario: Notification should not be sent if the owner of the account related to the Account Plan is a Pod User */
    @IsTest
    public static void sendNotifications_APOwnedByPod() {
        Id accountPlanOwner = [SELECT Id FROM User WHERE UserName = 'accountplanowner@invalid.com'].Id;
        Id APACPodOwner = [SELECT Id FROM User WHERE UserName = 'ampodapac@invalid.com'].Id;
        createAccountPlans(Date.Today().addYears(-1), null, accountPlanOwner, APACPodOwner);
        Test.startTest();
        AccountPlanReviewNotificationBatch testBatch = new AccountPlanReviewNotificationBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();
        Boolean reminderCheck = checkReminderDatePopulation();
        Assert.isFalse(reminderCheck, 'ReviewReminderDate__c has not been populated');
    }

    /* @Scenario: Scheduling the Batch Job */
    @IsTest
    public static void sendNotifications_Scheduler() {
        String CRON_EXP = '0 0 0 3 9 ? 2024';
        Test.startTest();
        String jobId = System.schedule('AccountPlanReviewNotificationTest', CRON_EXP, new AccountPlanReviewNotificationScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger
                          WHERE id = :jobId];
        Test.stopTest();
        Assert.areEqual(0, ct.TimesTriggered, 'The job has not run yet');
        Assert.areEqual('2024-09-03 00:00:00', String.valueOf(ct.NextFireTime), 'Next firing time is as expected');
    }


    /* @Description creates account plans with the dates needed for the test scenario
     * @Param lastReviewedDate date on which the Account Plan was last reviewed
     * @Param reviewReminderDate date on which the next reminder needs to be sent
     * @Return none
     */
    public static void createAccountPlans(Date lastReviewedDate, Date reviewReminderDate, Id accountPlanOwner, Id accountOwner) {
        List<AccountPlan__c> accountPlans = new List<AccountPlan__c>();
        for (Account account : [SELECT Id FROM Account WHERE OwnerId = :accountOwner LIMIT 20]) {
            AccountPlan__c accountPlan = (AccountPlan__c) TestDataFactory.createSObject('AccountPlan__c', new Map<String, Object>{
                    'Account__c' => account.Id,
                    'LastReviewedDate__c' => lastReviewedDate,
                    'ReviewReminderDate__c' => reviewReminderDate,
                    'OwnerId' => accountPlanOwner
            }, false);
            accountPlans.add(accountPlan);
        }
        insert accountPlans;
    }

    /* @Description checks if the reminder date has been set to
     * 14 days from now for all the account plans in the test
     * @Param none
     * @Return Boolean true if all dates have been populated correctly, false otherwise
     */
    public static Boolean checkReminderDatePopulation() {
        Boolean allPopulated = true;
        Date expectedReminderDate = Date.Today().addDays(14);
        List<AccountPlan__c> accountPlans = [SELECT Id, ReviewReminderDate__c FROM AccountPlan__c];
        for(AccountPlan__c accountPlan : accountPlans) {
            if(accountPlan.ReviewReminderDate__c == null && accountPlan.ReviewReminderDate__c != expectedReminderDate) {
                allPopulated = false;
                break;
            }
        }
        return allPopulated;
    }

    /* @Description checks if the reminder date has been modified for all the account plans in the test
     * @Param none
     * @Return Boolean true if none of the dates have been modified, false otherwise
     */
    public static Boolean checkReminderFieldChange() {
        Boolean reminderChanged = false;
        Date wrongReminderDate = Date.Today().addDays(14);
        List<AccountPlan__c> accountPlans = [SELECT Id, ReviewReminderDate__c FROM AccountPlan__c];
        for(AccountPlan__c accountPlan : accountPlans) {
            if(accountPlan.ReviewReminderDate__c == wrongReminderDate) {
                reminderChanged = true;
                break;
            }
        }
        return reminderChanged;
    }
}