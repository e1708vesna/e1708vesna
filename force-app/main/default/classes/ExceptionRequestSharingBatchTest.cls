@isTest
public class ExceptionRequestSharingBatchTest {
    
    @isTest private static void testBatch(){
        Account acc = TestUtil.createAccount('testAcc', true, true);
        User testUser1 = TestUtil.createUser('t1', false);
        User testUser2 = TestUtil.createUser('t2', false);
        User approver1 = TestUtil.createUser('t3', false);
        User approver2 = TestUtil.createUser('t4', false);
        List<User> testUsers = new List<User>();
        testUsers.add(testUser1);
        testUsers.add(testUser2);
        testUsers.add(approver1);
        testUsers.add(approver2);
        insert testUsers;
        ExceptionRequest__c req1 = new ExceptionRequest__c(Account__c = acc.Id, ExpectedMonthlyGrossMargin__c = 1000, NoOpportunityRecord__c = TRUE);
        ExceptionRequest__c req2 = new ExceptionRequest__c(Account__c = acc.Id, ExpectedMonthlyGrossMargin__c = 1000, NoOpportunityRecord__c = TRUE);
        List<ExceptionRequest__c> reqList = new List<ExceptionRequest__c>();
        reqList.add(req1);
        reqList.add(req2);
        insert reqList;
        
        //New Exception Request
        List<ExceptionRequest__Share> shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(0, shareList.size());
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        //new Member
        ExceptionRequestMember__c reqMember = new ExceptionRequestMember__c(ExceptionRequest__c = req1.Id, User__c = testUser1.Id);
        insert reqMember;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        delete shareList;
        Test.startTest();
        Database.executeBatch(new ExceptionRequestSharingBatch());
        Test.stopTest();
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(2, shareList.size());
        System.assertEquals('Read', userAccess(testUser1.Id, req1.Id, shareList));
        System.assertEquals('Read', userAccess(testUser1.Id, req2.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
    }
    
    private static string userAccess(Id userId, Id parentId, List<ExceptionRequest__Share> shareList){
        for (ExceptionRequest__Share share : shareList){
            if (share.UserOrGroupId == userId) {
                return share.Accesslevel;
            }
        }
        return 'None';
    }
}