//Who can see the requests:
// Manager of one of the members on the account
// Exception Request Members
// Assigned Approver
// Actual Approver
// 
// 

//Scenarios to test:
    // 1 New ExceptionRequest
    // delete Request
    // undelete Request
    // 2 new Member
    // 4 delete Member
    // 5 undelete Member
    // 5 set AssignedApprover
    // 6 Change AssignedApprover
    // 7 Remove AssignedApprover
    // 5 set ActualApprover
    // 6 Change ActualApprover
    // 7 Remove ActualApprover
    // 9 Change Manager -> Done in other testClass
    // 10 Remove Manager -> Done in other testClass
    // 11 Delete of account -> Not implemented
    // 12 Undelete of Account -> Not implemented


@isTest
public class ExceptionRequestSharingUtilTest {
    
    @isTest
    private static void testSharing(){
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
        System.assertEquals(2, shareList.size());
        System.assertEquals('Read', userAccess(testUser1.Id, req1.Id, shareList));
        System.assertEquals('Read', userAccess(testUser1.Id, req2.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //delete member
        delete reqMember;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(0, shareList.size());
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //AssignedApprover
        req1.AssignedApproverId__c = approver1.Id;
        update req1;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(2, shareList.size());
        System.assertEquals('Read', userAccess(approver1.Id, req1.Id, shareList));
        System.assertEquals('Read', userAccess(approver1.Id, req2.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //Change AssignedApprover
        req1.AssignedApproverId__c = approver2.Id;
        update req1;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(2, shareList.size());
        System.assertEquals('Read', userAccess(approver2.Id, req1.Id, shareList));
        System.assertEquals('Read', userAccess(approver2.Id, req2.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //Remove AssignedApprover
        req1.AssignedApproverId__c = null;
        update req1;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(0, shareList.size());
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //ActualApprover
        req1.ActualApproverId__c = approver1.Id;
        update req1;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(2, shareList.size());
        System.assertEquals('Read', userAccess(approver1.Id, req1.Id, shareList));
        System.assertEquals('Read', userAccess(approver1.Id, req2.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        Test.startTest();
        //Change ActualApprover
        req1.ActualApproverId__c = approver2.Id;
        update req1;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(2, shareList.size());
        System.assertEquals('Read', userAccess(approver2.Id, req1.Id, shareList));
        System.assertEquals('Read', userAccess(approver2.Id, req2.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //delete Request
        delete req2;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(1, shareList.size());
        System.assertEquals('Read', userAccess(approver2.Id, req1.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //undelete Request
        undelete req2;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(2, shareList.size());
        System.assertEquals('Read', userAccess(approver2.Id, req1.Id, shareList));
        System.assertEquals('Read', userAccess(approver2.Id, req2.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //Remove Account
        req2.Account__c = null;
        update req2;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(1, shareList.size());
        System.assertEquals('Read', userAccess(approver2.Id, req1.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //Change Account
        req2.Account__c = acc.Id;
        update req2;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(2, shareList.size());
        System.assertEquals('Read', userAccess(approver2.Id, req1.Id, shareList));
        System.assertEquals('Read', userAccess(approver2.Id, req2.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();

            
        //Remove ActualApprover
        req1.ActualApproverId__c = null;
        update req1;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(0, shareList.size());
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //undelete member
        undelete reqMember;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId in: reqList AND RowCause = 'ExceptionRequestSharing__c'];
        System.assertEquals(2, shareList.size());
        System.assertEquals('Read', userAccess(testUser1.Id, req1.Id, shareList));
        System.assertEquals('Read', userAccess(testUser1.Id, req2.Id, shareList));
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        
        
        ExceptionRequestSharingUtil.testProcessInstanceJson = 
            '[ {' +
            '  "attributes" : {' +
            '    "type" : "ProcessInstance",' +
            '    "url" : "/services/data/v54.0/sobjects/ProcessInstance/04g3W000000w0RrQAI"' +
            '  },' +
            '  "Id" : "' + req1.Id + '",' +
            '  "TargetObjectId" : "' + req1.Id + '",' +
            '  "StepsAndWorkitems" : {' +
            '    "totalSize" : 1,' +
            '    "done" : true,' +
            '    "records" : [ {' +
            '      "attributes" : {' +
            '        "type" : "ProcessInstanceHistory",' +
            '        "url" : "/services/data/v54.0/sobjects/ProcessInstanceHistory/04h3W000001gYY0QAM"' +
            '      },' +
            '      "ProcessInstanceId" : "04g3W000000w0RrQAI",' +
            '      "Id" : "04h3W000001gYY0QAM",' +
            '      "StepStatus" : "Started",' +
            '      "ActorId" : "' + approver1.Id + '",' +
            '      "OriginalActorId" : "' + approver2.Id + '"' +
            '    }]' +
            '  }' +
            '}]'; 
        ExceptionRequestSharingUtil.getInstance().storeRecords(new set<Id>{req1.Id});
        ExceptionRequestSharingUtil.getInstance().commitRecords();
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM ExceptionRequest__Share WHERE ParentId =: req1.Id AND RowCause = :ExceptionRequestSharingUtil.APPROVER_APEXSHARINGREASON];
        System.assertEquals(2, shareList.size());
        ExceptionRequestSharingUtil.getInstance().recordsToRecalculate.clear();
        Test.stopTest();
        
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