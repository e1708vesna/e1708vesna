@isTest
private class TestUpdateFirstReplyTimeBatch {

    @isTest static void testUpdateFirstReplyTime() {
        // Set up test data
        // Create a test Case
        Case testCase = new Case(Subject = 'Test Case', Status = 'New');
        insert testCase;

        // Create test FeedItem and EmailMessage linked to the Case
        FeedItem testFeedItem = new FeedItem(
            ParentId = testCase.Id,
            Body = 'Test Post',
            Type = 'TextPost',
            Visibility = 'AllUsers',
            CreatedDate = DateTime.now().addHours(-1) // 1 hour ago
        );
        insert testFeedItem;

        EmailMessage testEmailMessage = new EmailMessage(
            ParentId = testCase.Id,
            Subject = 'Test Email',
            Incoming = false,
            CreatedDate = DateTime.now() // current time
        );
        insert testEmailMessage;

        Test.startTest();
        // Execute batch
        Database.executeBatch(new UpdateFirstReplyTimeBatch(), 1);
        Test.stopTest();

        // Retrieve the updated case
        Case updatedCase = [SELECT FirstReplyTime__c FROM Case WHERE Id = :testCase.Id];

        // Assertions to verify that the batch class behaves as expected
        System.assertNotEquals(null, updatedCase.FirstReplyTime__c, 'FirstReplyTime__c should not be null');
        System.assertEquals(testFeedItem.SystemModstamp, updatedCase.FirstReplyTime__c, 'FirstReplyTime__c should match the earliest communication time');
    }

}