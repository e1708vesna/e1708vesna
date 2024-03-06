/*
 * @author Sales
 * @group Apex Test
 * @description Test Class for ChatterPostFeedDisplayCtrl
 */
/*
 * IMPROVEMENTS TBD
 * Code has 100% coverage but some test cases are missing which SHOULD be included
 * Creation of User Data - Internal User & Portal User
 * Using System.runAs() to create FeedItem & FeedComment data
 * Test Case for testing display user name calculation depending on 'Visibility' of FeedItem
 */

@isTest
public class ChatterPostFeedDisplayCtrlTest {

    public static Integer FEED_ITEM_COUNT = 5;
    public static Integer FEED_COMMENT_COUNT = 2;

    @TestSetup
    public static void createData() {

        //Account Data
        Account businessAccount = (Account)TestDataFactory.createSObject('Account', new Map<String, Object>{
            'Name' => 'Test Business Account',
            'RecordTypeId' => Constants.RT_ID_ACC_BUSINESS,
            'BillingCountry' => 'Netherlands',
            'ServiceLevel__c' => 'VIP',
            'CSATScorePercentage__c' => 40,
            'Company_Segment__c' => '5 - 10 million',
            'AccountType__c' => 'Merchant & Partner',
            'HypercareMode__c' => false,
            'Industry' => 'Transportation & Mobility'
        });

        //Case Data
        Case merchantCaseWithFeedItem = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, businessAccount.Id, null, false);
        merchantCaseWithFeedItem.Subject = 'Test - Merchant Case has related Chatter Posts';
        merchantCaseWithFeedItem.Priority = 'Medium';
        merchantCaseWithFeedItem.IsEscalated = true;

        Case merchantCaseWithoutFeedItem = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, businessAccount.Id, null, false);
        merchantCaseWithoutFeedItem.Subject = 'Test - Merchant Case has no related Chatter Posts';
        merchantCaseWithoutFeedItem.Priority = 'Medium';
        merchantCaseWithoutFeedItem.IsEscalated = true;

        insert new List<Case>{merchantCaseWithFeedItem, merchantCaseWithoutFeedItem};

        //FeedItem Data
        List<FeedItem> feedItems = TestDataFactory.createSObjectList('FeedItem', new Map<String, Object> {
                'Body' => 'Test Chatter Post Body',
                'ParentId' => merchantCaseWithFeedItem.Id,
                'Visibility' => 'AllUsers'
        }, FEED_ITEM_COUNT, false);
        feedItems.addAll((List<FeedItem>)TestDataFactory.createSObjectList('FeedItem', new Map<String, Object> {
                'Body' => 'Test Chatter Post Body',
                'ParentId' => merchantCaseWithFeedItem.Id,
                'Visibility' => 'InternalUsers'
        }, 2, false));
        insert feedItems;

        //FeedComment Data
        TestDataFactory.createSObjectList('FeedComment', new Map<String, Object> {
                'CommentBody' => 'Test Feed Comment Body',
                'FeedItemId' => feedItems[0].Id
        }, FEED_COMMENT_COUNT);
    }

    /**
	 * scenario: passing a case id which has related chatter posts
	 */
    @IsTest
    public static void fetchChatterPosts_postsAvailable() {
        Id caseId = [SELECT Id FROM Case WHERE Subject = 'Test - Merchant Case has related Chatter Posts' LIMIT 1].Id;
        Integer feedItemsCount = 0;
        Test.startTest();
        List<ChatterPostFeedDisplayCtrl.FeedItemWrapper> feedItems = ChatterPostFeedDisplayCtrl.fetchChatterPosts(caseId);
        feedItemsCount = feedItems.size();
        Test.stopTest();
        Assert.isNotNull(feedItems, 'Feed Items fetched as expected');
        Assert.areEqual(FEED_ITEM_COUNT + FEED_COMMENT_COUNT, feedItemsCount, 'Count of total Feed Items fetched is as expected');
        Assert.areEqual(FEED_COMMENT_COUNT, feedItemsCount - FEED_ITEM_COUNT, 'Count of Feed Comments fetched is as expected');
        Assert.areEqual(FEED_ITEM_COUNT, feedItemsCount - FEED_COMMENT_COUNT, 'Count of Feed Items fetched is as expected');
    }

    /**
	 * scenario: passing a case id which has no related chatter posts
	 */
    @IsTest
    public static void fetchChatterPosts_postsAbsent() {
        Id caseId = [SELECT Id FROM Case WHERE Subject = 'Test - Merchant Case has no related Chatter Posts' LIMIT 1].Id;
        Exception expectedException;
        Test.startTest();
        try {
            ChatterPostFeedDisplayCtrl.fetchChatterPosts(caseId);
            Assert.fail('Exception Expected');
        }
        catch(Exception e) {
            expectedException = e;
        }
        Test.stopTest();
        Assert.isNotNull(expectedException, 'Exception thrown as expected');
        Assert.areEqual(AuraHandledException.class.getName(), expectedException.getTypeName(), 'AuraHandledException is expected');
    }
}