@isTest
public class AmClaimSharingUtilTest {
//Who can see the requests:
// Assigned Approver
// Actual Approver

//Scenarios to test:
    // 1 New AM Claim
    // 2 undelete AM Claim
    // 3 set AssignedApprover
    // 4 Change AssignedApprover
    // 5 Remove AssignedApprover
    // 6 set ActualApprover
    // 6 Change ActualApprover
    // 8 Remove ActualApprover


    @isTest
    private static void testSharing(){
        Account acc = TestUtil.createAccount('testAcc', true, true);
        User testUser1 = TestUtil.createUser('t1', false);
        User approver1 = TestUtil.createUser('t3', false);
        User approver2 = TestUtil.createUser('t4', false);
        List<User> testUsers = new List<User>();
        testUsers.add(testUser1);
        testUsers.add(approver1);
        testUsers.add(approver2);
        insert testUsers;
        AMClaim__c claim = new AMClaim__c();
        insert claim;
        
        //New Am Claim
        List<AMClaim__Share> shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM AMClaim__Share WHERE ParentId =: claim.Id AND RowCause = 'AmClaimSharing__c'];
        System.assertEquals(0, shareList.size());
        AmClaimSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //Set Assigned Approver
        claim.AssignedApproverId__c = approver1.Id;
        update claim;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM AMClaim__Share WHERE ParentId =: claim.Id AND RowCause = 'AmClaimSharing__c'];
        System.assertEquals(1, shareList.size());
        System.assertEquals('Read', userAccess(approver1.Id, claim.Id, shareList));
        AmClaimSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //Change Assigned Approver
        claim.AssignedApproverId__c = approver2.Id;
        update claim;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM AMClaim__Share WHERE ParentId =: claim.Id AND RowCause = 'AmClaimSharing__c'];
        System.assertEquals(1, shareList.size());
        System.assertEquals('Read', userAccess(approver2.Id, claim.Id, shareList));
        AmClaimSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //Remove AssignedApprover
        claim.AssignedApproverId__c = null;
        update claim;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM AMClaim__Share WHERE ParentId =: claim.Id AND RowCause = 'AmClaimSharing__c'];
        System.assertEquals(0, shareList.size());
        AmClaimSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //Set Actual Approver
        claim.ActualApproverId__c = approver1.Id;
        update claim;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM AMClaim__Share WHERE ParentId =: claim.Id AND RowCause = 'AmClaimSharing__c'];
        System.assertEquals(1, shareList.size());
        System.assertEquals('Read', userAccess(approver1.Id, claim.Id, shareList));
        AmClaimSharingUtil.getInstance().recordsToRecalculate.clear();
        
        System.debug('*************************************');
        System.debug(Json.serializePretty(AmClaimSharingUtil.getInstance().recordsToRecalculate));
        System.debug('*************************************');
            //delete Claim
        delete claim;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM AMClaim__Share WHERE ParentId =: claim.Id AND RowCause = 'AmClaimSharing__c'];
        System.assertEquals(0, shareList.size());
        AmClaimSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //undelete Request
        undelete claim;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM AMClaim__Share WHERE ParentId =: claim.Id AND RowCause = 'AmClaimSharing__c'];
        System.assertEquals(1, shareList.size());
        System.assertEquals('Read', userAccess(approver1.Id, claim.Id, shareList));
        AmClaimSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //Change Actual Approver
        claim.ActualApproverId__c = approver2.Id;
        update claim;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM AMClaim__Share WHERE ParentId =: claim.Id AND RowCause = 'AmClaimSharing__c'];
        System.assertEquals(1, shareList.size());
        System.assertEquals('Read', userAccess(approver2.Id, claim.Id, shareList));
        AmClaimSharingUtil.getInstance().recordsToRecalculate.clear();
        
        //Remove Actual Approver
        claim.ActualApproverId__c = null;
        update claim;
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM AMClaim__Share WHERE ParentId =: claim.Id AND RowCause = 'AmClaimSharing__c'];
        System.assertEquals(0, shareList.size());
        AmClaimSharingUtil.getInstance().recordsToRecalculate.clear();
        
        AmClaimSharingUtil.testProcessInstanceJson = 
            '[ {' +
            '  "attributes" : {' +
            '    "type" : "ProcessInstance",' +
            '    "url" : "/services/data/v54.0/sobjects/ProcessInstance/04g3W000000w0RrQAI"' +
            '  },' +
            '  "Id" : "' + claim.Id + '",' +
            '  "TargetObjectId" : "' + claim.Id + '",' +
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
        AmClaimSharingUtil.getInstance().storeRecords(new set<Id>{claim.Id});
        AmClaimSharingUtil.getInstance().commitRecords();
        shareList = [SELECT Id, UserOrGroupId, AccessLevel FROM AMClaim__Share WHERE ParentId =: claim.Id AND RowCause = :AmClaimSharingUtil.APPROVER_APEXSHARINGREASON];
        System.assertEquals(2, shareList.size());
        AmClaimSharingUtil.getInstance().recordsToRecalculate.clear();
        
        
    }
    
    private static string userAccess(Id userId, Id parentId, List<AmClaim__Share> shareList){
        for (AmClaim__Share share : shareList){
            if (share.UserOrGroupId == userId) {
                return share.Accesslevel;
            }
        }
        return 'None';
    }
    
    
    
    
}