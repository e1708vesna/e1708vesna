/**
* @description Test class to test the functionality of class FeedCommentHlpr.
*/
@isTest
private class FeedCommentHlprTest {
    
    //Setup an internal and an external user to test with.
    @TestSetup 
    static void testSetup() {
        
        Account acc = ServicesTestUtil.createAccount('TestInc', Constants.RT_ID_ACC_BUSINESS, true);
        Contact con = ServicesTestUtil.createContact(acc.Id, 'External', 'test@example.com', true);
        
        System.runAs( new User(Id = UserInfo.getUserId()) ){ //Workaround for Mixed DML Error
            User internalUser = ServicesTestUtil.createUser('Basic Service', 'ServiceGenericUser', false);
            internalUser.LastName = 'InternalTestUser';
            User externalUser = ServicesTestUtil.createPortalUser(con.Id, false);
            externalUser.LastName = 'ExternalTestUser';
            
            insert new List<User>{internalUser, externalUser};
                
            List<sObject> permissionAssignments = ServicesTestUtil.assignPermissionsToUser(
                new List<User>{internalUser},
                new Set<String> {ServicesTestUtil.SERVICE_AGENT_PERMISSION_SET_GROUP_NAME},
                new Set<String> (),
                false);
            permissionAssignments.addAll(ServicesTestUtil.assignPermissionsToUser(
                new List<User>{externalUser},
                new Set<String> (),
                new Set<String> {ServicesTestUtil.SERVICE_PORTAL_PERMISSION_SET_NAME},
                false));
            insert permissionAssignments;
            
        }
    }
    
    
    //Validate that the logic does not run for internalUsers.
    @isTest
    private static void internalUserNoStatusChange(){
        User internalUser = [SELECT Id FROM User WHERE LastName = 'InternalTestUser' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestInc'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'External'];
        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, con.Id, false);
        c.OwnerId = internalUser.Id;
        c.Status = 'Waiting for Merchant';
        insert c;
        FeedItem feedItem;
        System.runAs(internalUser){
            feedItem = new FeedItem(Body = 'Test FeedItem', ParentId = c.Id, Visibility = 'AllUsers');
            insert FeedItem;
        }
        Test.startTest();
        System.runAs(internalUser){
            insert new FeedComment(FeedItemId = feedItem.Id, CommentBody = 'Test FeedComment');
        }
        Test.stopTest();
        c = [SELECT Id, Status FROM Case WHERE Id =: c.Id LIMIT 1];
        Assert.areEqual('Waiting for Merchant', c.Status, 'The case status should not have been changed for the internal user.');
    }
    
    //validate that a case is set to in progress when waiting on merchant
    @isTest
    private static void externalUserStatusChangeWaitingForMerchant(){        
        User internalUser = [SELECT Id FROM User WHERE LastName = 'InternalTestUser' LIMIT 1];
        User externalUser = [SELECT Id FROM User WHERE LastName = 'ExternalTestUser' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestInc'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'External'];
        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, con.Id, false);
        c.OwnerId = internalUser.Id;
        c.Status = 'Waiting for Merchant';
        insert c;
        FeedItem feedItem;
        System.runAs(internalUser){
            feedItem = new FeedItem(Body = 'Test FeedItem', ParentId = c.Id, Visibility = 'AllUsers');
            insert FeedItem;
        }
        Test.startTest();
        System.runAs(externalUser){
            insert new FeedComment(FeedItemId = feedItem.Id, CommentBody = 'Test FeedComment');
        }
        Test.stopTest();
        c = [SELECT Id, Status FROM Case WHERE Id =: c.Id LIMIT 1];
        Assert.areEqual('In Progress', c.Status, 'The case status should have been changed.');
    }
    
    //validate that a case is set to in progress when Handover
    @isTest
    private static void externalUserStatusChangeHandoverUserOwned(){
        User externalUser = [SELECT Id FROM User WHERE LastName = 'ExternalTestUser' LIMIT 1];
        User internalUser = [SELECT Id FROM User WHERE LastName = 'InternalTestUser' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestInc'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'External'];
        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, con.Id, false);
        c.Status = 'Handover';
        c.OwnerId = internalUser.Id;
        insert c;
        FeedItem feedItem;
        System.runAs(internalUser){
            feedItem = new FeedItem(Body = 'Test FeedItem', ParentId = c.Id, Visibility = 'AllUsers');
            insert FeedItem;
        }
        Test.startTest();
        System.runAs(externalUser){
            insert new FeedComment(FeedItemId = feedItem.Id, CommentBody = 'Test FeedComment');
        }
        Test.stopTest();
        c = [SELECT Id, Status FROM Case WHERE Id =: c.Id LIMIT 1];
        Assert.areEqual('In Progress', c.Status, 'The case status should have been changed.');
    }
    
    private static void externalUserStatusChangeHandoverQueueOwned(){
        User externalUser = [SELECT Id FROM User WHERE LastName = 'ExternalTestUser' LIMIT 1];
        User internalUser = [SELECT Id FROM User WHERE LastName = 'InternalTestUser' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestInc'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'External'];
        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, con.Id, false);
        c.Status = 'Handover';
        c.OwnerId = [SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Case' LIMIT 1].QueueId;
        insert c;
        //Share the case with the internal user
        insert new CaseShare(CaseAccessLevel = 'edit', caseId = c.Id, RowCause = 'Manual', UserOrGroupId = internalUser.Id);
        
        FeedItem feedItem;
        System.runAs(internalUser){
            feedItem = new FeedItem(Body = 'Test FeedItem', ParentId = c.Id, Visibility = 'AllUsers');
            insert FeedItem;
        }
        Test.startTest();
        System.runAs(externalUser){
            insert new FeedComment(FeedItemId = feedItem.Id, CommentBody = 'Test FeedComment');
        }
        Test.stopTest();
        c = [SELECT Id, Status FROM Case WHERE Id =: c.Id LIMIT 1];
        Assert.areEqual('Waiting for Merchant', c.Status, 'The case status should have been changed while owned by a queue.');
    }
    
    
    @isTest
    private static void externalUserCommentOnNonReopenableClosedCase(){
        User externalUser = [SELECT Id FROM User WHERE LastName = 'ExternalTestUser' LIMIT 1];
        User internalUser = [SELECT Id FROM User WHERE LastName = 'InternalTestUser' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestInc'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'External'];        
        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, con.Id, false);
        c.OwnerId = internalUser.Id;
        c.Status = 'Completed';
        c.WaitingOnMerchantDateTime__c = DateTime.now().addDays(-72);
        insert c;
        
        FeedItem feedItem;
        System.runAs(internalUser){
            feedItem = new FeedItem(Body = 'Test FeedItem', ParentId = c.Id, Visibility = 'AllUsers');
            insert FeedItem;
        }
        Boolean validationErrorOccured = false;
        
        Test.startTest();
        System.runAs(externalUser){
            try {
                insert new FeedComment(FeedItemId = feedItem.Id, CommentBody = 'Test FeedComment');
            }
            catch (System.DmlException e){
                if (e.getMessage().contains(System.Label.FeedCommentCaseCannotBeReopened)){
                    validationErrorOccured = true;
                }
                else {
                    Throw e;
                }
            }
        }
        Test.stopTest();
        Assert.isTrue(validationErrorOccured, 'Expected a validation error to occur.');
    }
    
    @isTest
    private static void externalUserCommentOnReopenableClosedCase(){
        User externalUser = [SELECT Id FROM User WHERE LastName = 'ExternalTestUser' LIMIT 1];
        User internalUser = [SELECT Id FROM User WHERE LastName = 'InternalTestUser' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestInc'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'External'];        
        insert new CaseSetting__c(SetupOwnerId=UserInfo.getOrganizationId(), CaseReopenTimeLimit__c=800);
        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, con.Id, false);
        c.Status = 'Completed';
        c.OwnerId = internalUser.Id;
        insert c;
        
        FeedItem feedItem;
        System.runAs(internalUser){
            feedItem = new FeedItem(Body = 'Test FeedItem', ParentId = c.Id, Visibility = 'AllUsers');
            insert FeedItem;
        }
        Boolean validationErrorOccured = false;
        
        Test.startTest();
        System.runAs(externalUser){
            insert new FeedComment(FeedItemId = feedItem.Id, CommentBody = 'Test FeedComment');
        }
        Test.stopTest();
        Assert.isFalse(validationErrorOccured, 'Case should have been reopened.');
        c = [SELECT Id, Status, Reopened__c FROM Case WHERE Id =: c.Id LIMIT 1];
        Assert.areEqual(c.Status, 'In Progress', 'Expected case status to be In Progress');
        Assert.isTrue(c.Reopened__c, 'Case should be marked as reopened.'); 
    }
    
}