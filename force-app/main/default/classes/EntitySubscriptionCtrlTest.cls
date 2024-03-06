@isTest
private class EntitySubscriptionCtrlTest {

    // Utility method to create test data for EntitySubscription
    private static List<EntitySubscription> createTestSubscriptions() {
        // Create test records for each object type that the main class handles
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        Contact testContact = new Contact(LastName='Test', AccountId=testAccount.Id);
        insert testContact;

        Case testCase = new Case(Subject='Test Case', Status='New');
        insert testCase;

        // Subscribe the current user to these records
        List<EntitySubscription> subs = new List<EntitySubscription>{
            new EntitySubscription(ParentId = testAccount.Id, SubscriberId = UserInfo.getUserId()),
            new EntitySubscription(ParentId = testContact.Id, SubscriberId = UserInfo.getUserId()),
            new EntitySubscription(ParentId = testCase.Id, SubscriberId = UserInfo.getUserId())
        };
        insert subs;
        
        return subs;
    }

    /*
     * Verifies that the JSON configuration for columns is correctly returned for various object types.
     */
    @isTest static void testGetColumnConfigurations() {
        String objectType = 'Case'; // Focusing on 'Case' object type
        Test.startTest();
        String jsonConfig = EntitySubscriptionCtrl.getColumnConfigurations(objectType);
        Test.stopTest();

        Assert.areNotEqual(null, jsonConfig, 'The returned JSON should not be null.');
        Assert.isTrue(jsonConfig.contains('Case'), 'JSON should contain object type info.');
        Assert.isTrue(jsonConfig.contains('CaseNumber'), 'JSON should contain field CaseNumber for Case.');
    }

    /*
     * Validates the retrieval of records followed by the current user based on object type and search keyword.
     */
    @isTest static void testGetFollowedRecords() {
        List<EntitySubscription> testSubs = createTestSubscriptions();

        Test.startTest();
        List<EntitySubscriptionCtrl.FollowedRecord> followedRecords = EntitySubscriptionCtrl.getFollowedRecords('Case', '');
        Test.stopTest();

        Assert.areNotEqual(null, followedRecords, 'Followed records list should not be null.');
        Assert.areEqual(1, followedRecords.size(), 'Should return one followed Case record.');
        Assert.areEqual(testSubs[0].ParentId, followedRecords[0].recordId, 'The record ID should match the test subscription.');
    }

    /*
     * Checks the functionality for retrieving a summary of Case records followed by the user.
     */
    @isTest static void testGetFollowedRecordsInfo() {
        createTestSubscriptions(); // Creating test subscriptions for Case

        Test.startTest();
        Map<String, Object> recordsInfo = EntitySubscriptionCtrl.getFollowedRecordsInfo();
        Test.stopTest();

        Assert.areNotEqual(null, recordsInfo, 'Records info should not be null.');
        Assert.isTrue(recordsInfo.containsKey('total'), 'Info map should contain the total count.');
        Assert.isTrue(recordsInfo.containsKey('byObject'), 'Info map should contain the count by object.');
    }

    /*
     * Ensures that the functionality to unfollow Case records works correctly and affects only specified records.
     */
    @isTest static void testUnfollowRecords() {
        List<EntitySubscription> testSubs = createTestSubscriptions();

        Test.startTest();
        EntitySubscriptionCtrl.unfollowRecords(new List<Id>{testSubs[0].Id});
        Test.stopTest();

        Integer remainingCount = [SELECT Count() FROM EntitySubscription WHERE Id = :testSubs[0].Id];
        Assert.areEqual(0, remainingCount, 'The record should be unfollowed.');
        Integer otherSubsCount = [SELECT Count() FROM EntitySubscription WHERE Id IN :new List<Id>{testSubs[1].Id}];
        Assert.isFalse(otherSubsCount == 0, 'Other subscriptions should not be affected.');
    }

}