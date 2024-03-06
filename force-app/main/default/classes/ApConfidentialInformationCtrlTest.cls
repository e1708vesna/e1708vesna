@IsTest
private class ApConfidentialInformationCtrlTest {
    final static String USER1_EMAIL = 'testUser1@test.com';
    final static String USER2_EMAIL = 'testUser2@test.com';

    @TestSetup
    private static void testSetup() {
        Id customerSuccessProfileId = TestUtil.getProfile('Adyen v2 Customer Success');
        List<User> users = new List<User>{
            new User(
                Alias = 'test',
                DoNotRunFlow__c = true,
                Email = USER1_EMAIL,
                EmailEncodingKey = 'UTF-8',
                LastName = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = customerSuccessProfileId,
                SalesRegion__c = 'EMEA',
                SalesCountry__c = 'Belgium',
                SalesArea__c = 'Belgium',
                SalesOffice__c = 'Brussels',
                SalesTeam__c = 'Sales Mid-Market',
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = USER1_EMAIL + System.currentTimeMillis()),
            new User(
                Alias = 'test',
                DoNotRunFlow__c = true,
                Email = USER2_EMAIL,
                EmailEncodingKey = 'UTF-8',
                LastName = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = customerSuccessProfileId,
                SalesRegion__c = 'EMEA',
                SalesCountry__c = 'Belgium',
                SalesArea__c = 'Belgium',
                SalesOffice__c = 'Brussels',
                SalesTeam__c = 'Sales Mid-Market',
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = USER2_EMAIL + System.currentTimeMillis())
        };
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert users;
        }

        Map<String, Object> businessAccountMap = new Map<String, Object>{
            'RecordTypeId' => Constants.RT_ID_ACC_BUSINESS,
            'BillingCountry' => 'Netherlands',
            'OwnerId' => users[0].Id
        };
        List<Account> accounts = new List<Account>{
            (Account) TestDataFactory.createSObject('Account', businessAccountMap, false)
        };
        insert accounts;

        List<AccountPlan__c> accountPlans = new List<AccountPlan__c>{
            (AccountPlan__c) TestDataFactory.createSObject('AccountPlan__c',
                new Map<String,Object>{
                    'Account__c' => accounts[0].Id,
                    'OwnerId' => users[0].Id,
                    'Amount_of_Share_of_Wallet__c' => 2
                }, false)
        };
        insert accountPlans;

        insert new List<ShareOfWallet__c>{
            (ShareOfWallet__c) TestDataFactory.createSObject('ShareOfWallet__c',
                new Map<String,Object> {
                    'AccountPlan__c' => accountPlans[0].Id,
                    'OwnerId' => users[0].Id,
                    'CurrentAdyenMarginMonth__c' => 10,
                    'VolumeMonthOnAdyen__c' => 50,
                    'VolumeMonth__c' => 50
                }, false),
            (ShareOfWallet__c) TestDataFactory.createSObject('ShareOfWallet__c',
                new Map<String,Object> {
                    'AccountPlan__c' => accountPlans[0].Id,
                    'OwnerId' => users[0].Id,
                    'CurrentAdyenMarginMonth__c' => 20,
                    'VolumeMonthOnAdyen__c' => 100,
                    'VolumeMonth__c' => 100
                }, false)
        };
    }

    /**
     * Call to getUserRecordAccess(List<Id>, null) using an empty List<Id>
     * @result An empty list is returned as result
     */
    @IsTest
    private static void testUserRecordAccessEmptyParams() {
        Assert.areEqual(0, ApConfidentialInformationCtrl.getUserRecordAccess(new List<Id>(), null).size(), 'The returned list should be empty');
    }

    /**
     * Test method is run as a test user
     * Call to getUserRecordAccess(List<Id>, null) with a list of ShareOfWallet Ids owned by the test user
     * @result The returned list contains an item for each of the owned records
     * @result The test user has read access to each of the record
     */
    @IsTest
    private static void testUserRecordAccessEmptyApci() {
        List<UserRecordAccess> results = new List<UserRecordAccess>();

        User userWithPermissions = [SELECT Id FROM User WHERE Email = :USER1_EMAIL];
        List<Id> sowIds = Utils.toList(Utils.getSet([SELECT Id FROM ShareOfWallet__c WHERE OwnerId = :userWithPermissions.Id], 'Id'));

        System.runAs(userWithPermissions) {
            results = ApConfidentialInformationCtrl.getUserRecordAccess(sowIds, null);
        }

        Assert.areEqual(sowIds.size(), results.size(), 'The list of returned records is not of the expected size');
        for(UserRecordAccess access : results) {
            Assert.isTrue(access.HasReadAccess, 'User should have access to this set of records');
        }
    }

    /**
     * Test method is run as a test user
     * Call to getUserRecordAccess(List<Id>, null) with a list of ShareOfWallet Ids owned by a different test user
     * @result The returned list contains an item for each of the owned records
     * @result The test user does not have read access to any of the record
     */
    @IsTest
    private static void testUserRecordNoAccessEmptyApci() {
        List<UserRecordAccess> results = new List<UserRecordAccess>();
        User userWithPermissions;
        User userWithoutPermissions;

        for(User u :[SELECT Id, Email FROM User WHERE Email IN :new Set<String>{USER1_EMAIL, USER2_EMAIL}]) {
            if(u.Email == USER1_EMAIL) {
                userWithPermissions = u;
            } else if(u.Email == USER2_EMAIL) {
                userWithoutPermissions = u;
            }
        }

        List<Id> sowIds = Utils.toList(Utils.getSet([SELECT Id FROM ShareOfWallet__c WHERE OwnerId = :userWithPermissions.Id], 'Id'));

        System.runAs(userWithoutPermissions) {
            results = ApConfidentialInformationCtrl.getUserRecordAccess(sowIds, null);
        }

        Assert.areEqual(sowIds.size(), results.size(), 'The list of returned records is not of the expected size');
        for(UserRecordAccess access : results) {
            Assert.isFalse(access.HasReadAccess, 'User should not have access to this set of records');
        }
    }

    /**
     * Test method is run as a test user
     * Call to getUserRecordAccess(List<Id>, apci.Id) with an empty list of ShareOfWallet Ids, and an apci owned the test user
     * @result The returned list contains a single item related to the apci record
     * @result The test user has read access to the record
     */
    @IsTest
    private static void testUserRecordAccessEmptySow() {
        List<UserRecordAccess> results = new List<UserRecordAccess>();
        User userWithPermissions = [SELECT Id FROM User WHERE Email = :USER1_EMAIL];
        List<AccountPlan__c> accountPlans = [SELECT Id, APConfidentialInformation__c FROM AccountPlan__c WHERE OwnerId = :userWithPermissions.Id];

        System.runAs(userWithPermissions) {
            results = ApConfidentialInformationCtrl.getUserRecordAccess(new List<Id>(), accountPlans[0].APConfidentialInformation__c);
        }

        Assert.areEqual(1, results.size(), 'One record expected, more returned');
        for(UserRecordAccess access : results) {
            Assert.isTrue(access.HasReadAccess, 'User should have access to this set of records');
        }
    }

    /**
     * Test method is run as a test user
     * Call to getUserRecordAccess(List<Id>, apci.Id) with an empty list of ShareOfWallet Ids, and an apci owned by a different test user
     * @result The returned list contains a single item related to the apci record
     * @result The test user does not have read access to the record
     */
    @IsTest
    private static void testUserRecordNoAccessEmptySow() {
        List<UserRecordAccess> results = new List<UserRecordAccess>();
        User userWithPermissions;
        User userWithoutPermissions;

        for(User u :[SELECT Id, Email FROM User WHERE Email IN :new Set<String>{USER1_EMAIL, USER2_EMAIL}]) {
            if(u.Email == USER1_EMAIL) {
                userWithPermissions = u;
            } else if(u.Email == USER2_EMAIL) {
                userWithoutPermissions = u;
            }
        }
        List<AccountPlan__c> accountPlans = [SELECT Id, APConfidentialInformation__c FROM AccountPlan__c WHERE OwnerId = :userWithPermissions.Id];

        System.runAs(userWithoutPermissions) {
            results = ApConfidentialInformationCtrl.getUserRecordAccess(new List<Id>(), accountPlans[0].APConfidentialInformation__c);
        }

        Assert.areEqual(1, results.size(), 'One record expected, more returned');
        for(UserRecordAccess access : results) {
            Assert.isFalse(access.HasReadAccess, 'User should not have access to this set of records');
        }
    }

    /**
     * Test method is run as a test user
     * Call to getUserRecordAccess(List<Id>, apci.Id) with a list of ShareOfWallet Ids and apci owned by the test user
     * @result The returned list contains an item for each of the owned records
     * @result The test user has read access to each of the record
     */
    @IsTest
    private static void testUserRecordAccess() {
        List<UserRecordAccess> results = new List<UserRecordAccess>();

        User userWithPermissions = [SELECT Id FROM User WHERE Email = :USER1_EMAIL];
        List<AccountPlan__c> accountPlans = [SELECT Id, APConfidentialInformation__c FROM AccountPlan__c WHERE OwnerId = :userWithPermissions.Id];
        List<Id> sowIds = Utils.toList(Utils.getSet([SELECT Id FROM ShareOfWallet__c WHERE OwnerId = :userWithPermissions.Id], 'Id'));

        System.runAs(userWithPermissions) {
            results = ApConfidentialInformationCtrl.getUserRecordAccess(sowIds, accountPlans[0].APConfidentialInformation__c);
        }

        Assert.areEqual(sowIds.size() + 1, results.size(), 'The list of returned records is not of the expected size');
        for(UserRecordAccess access : results) {
            Assert.isTrue(access.HasReadAccess, 'User should have access to this set of records');
        }
    }

    /**
     * Test method is run as a test user
     * Call to getUserRecordAccess(List<Id>, apci.Id) with a list of ShareOfWallet Ids and apci owned by a different test user
     * @result The returned list contains an item for each of the records
     * @result The test user does not have read access to any of the record
     */
    @IsTest
    private static void testUserRecordNoAccess() {
        List<UserRecordAccess> results = new List<UserRecordAccess>();
        User userWithPermissions;
        User userWithoutPermissions;

        for(User u :[SELECT Id, Email FROM User WHERE Email IN :new Set<String>{USER1_EMAIL, USER2_EMAIL}]) {
            if(u.Email == USER1_EMAIL) {
                userWithPermissions = u;
            } else if(u.Email == USER2_EMAIL) {
                userWithoutPermissions = u;
            }
        }

        List<AccountPlan__c> accountPlans = [SELECT Id, APConfidentialInformation__c FROM AccountPlan__c WHERE OwnerId = :userWithPermissions.Id];
        List<Id> sowIds = Utils.toList(Utils.getSet([SELECT Id FROM ShareOfWallet__c WHERE OwnerId = :userWithPermissions.Id], 'Id'));

        System.runAs(userWithoutPermissions) {
            results = ApConfidentialInformationCtrl.getUserRecordAccess(sowIds, accountPlans[0].APConfidentialInformation__c);
        }

        Assert.areEqual(sowIds.size() + 1, results.size(), 'The list of returned records is not of the expected size');
        for(UserRecordAccess access : results) {
            Assert.isFalse(access.HasReadAccess, 'User should not have access to this set of records');
        }
    }

    /**
     * Call to getShareOfWalletSummary(Id) with the Id of an existing record
     * @result All the metrics are calculated correctly
     */
    @IsTest
    private static void testShareOfWalletSummary() {
        Decimal currentMargin = 0;
        Decimal volumeMonthAdyen = 0;
        Decimal volumeMonth = 0;

        List<AccountPlan__c> accountPlans = [
            SELECT Id, (
                SELECT CurrentAdyenMarginMonth__c,
                VolumeMonthOnAdyen__c,
                VolumeMonth__c
                FROM ShareOfWallets__r
            ) FROM AccountPlan__c];

        for(ShareOfWallet__c shareOfWallet : accountPlans[0].ShareOfWallets__r) {
            currentMargin += shareOfWallet.CurrentAdyenMarginMonth__c;
            volumeMonthAdyen += shareOfWallet.VolumeMonthOnAdyen__c;
            volumeMonth += shareOfWallet.VolumeMonth__c;
        }

        Test.startTest();
        List<AggregateResult> results = ApConfidentialInformationCtrl.getShareOfWalletSummary(accountPlans[0].Id);
        Test.stopTest();

        Assert.areEqual(currentMargin, results[0].get('currentMargin'), 'The "Current Margin" summary is not calculated correctly');
        Assert.areEqual(volumeMonthAdyen, results[0].get('volumeMonthAdyen'), 'The "Monthly Volume on Adyen" summary is not calculated correctly');
        Assert.areEqual(volumeMonth, results[0].get('volumeMonth'), 'The "Monthly Volume" summary is not calculated correctly');
    }
}