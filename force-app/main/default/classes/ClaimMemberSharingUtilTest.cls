@isTest
public class ClaimMemberSharingUtilTest {
    
    //Scenarios to test:
    // 1 New claimmember
    // 2 Update ClaimMember
    // 		2.1 Update of eligble saleslead
    // 		2.2 Update of Account__c
    // 		2.3 Update AssignedApproverId__c
    // 3 Delete ClaimMember
    // 4 Undelete ClaimMember
    // 5 Delete of account
    // 6 Undelete of Account
    
    
    @isTest
    private static void createClaimMember (){
        User testUser1 = TestUtil.createUser();
        User testUser2 = TestUtil.createUser();
        User testUser3 = TestUtil.createUser();
        Id currentUserId = UserInfo.getUserId();
        Account acc = TestUtil.createAccount('TestAcc1', true, false);
        Account acc2 = TestUtil.createAccount('TestAcc2', true, false);
        List<Account> accList = new List<Account>();
        accList.add(acc);
        accList.add(acc2);
        insert accList;
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        
        //Scenario 1: Insert ClaimMember
        ClaimMembers__c cm1 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser1.Id, EligibleSalesLead__c = currentUserId);
        ClaimMembers__c cm2 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser2.Id);
        insert new List<ClaimMembers__c>{cm1, cm2};

            
        List<ClaimMembers__Share> shareList = [SELECT Id FROM ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APEXSHARINGREASON];
        System.assertEquals(2, shareList.size(), 'Both Claimmember should have been shared with the EligibleSalesLead');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        //Scenario 3 Delete ClaimMember
        delete cm2;
        shareList = [SELECT Id FROM ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APEXSHARINGREASON];
        System.assertEquals(1, shareList.size(), 'Only 1 claimMember left.');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        //Scenario 4 Undelete ClaimMember
        undelete cm2;
        shareList = [SELECT Id FROM ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APEXSHARINGREASON];
        System.assertEquals(2, shareList.size(), 'Both Claimmember should have been shared with the EligibleSalesLead.');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        //Scenario 5 Delete Account
        delete acc;
        shareList = [SELECT Id FROM ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APEXSHARINGREASON];
        System.assertEquals(1, shareList.size(), 'Only 1 claimmember has an eligblesaleslead. No account for the other claimmember.');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        Test.startTest();
        //Scenario 6 undelete Account
        undelete acc;
        shareList = [SELECT Id FROM ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APEXSHARINGREASON];
        System.assertEquals(2, shareList.size(), 'Both Claimmember should have been shared with only 1 EligibleSalesLeads');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        
        //Scenario 2.1: Update EligbleSalesLead ClaimMember
        cm2.EligibleSalesLead__c = testUser3.Id;
        update cm2;
        shareList = [SELECT Id FROM ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APEXSHARINGREASON];
        System.assertEquals(4, shareList.size(), 'Both Claimmember should have been shared with both EligibleSalesLeads');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        //Scenario 2.2: Update Account ClaimMember
        cm2.Account__c = acc2.Id;
        update cm2;
        shareList = [SELECT Id FROM ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APEXSHARINGREASON];
        System.assertEquals(2, shareList.size(), 'Both Claimmember should have been shared with only 1 EligibleSalesLeads');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        //Scenario 2.3: Update AssignedApproverId__c ClaimMember
        cm2.AssignedApproverId__c = testUser1.Id;
        update cm2;
        shareList = [SELECT Id FROM ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APEXSHARINGREASON];
        System.assertEquals(3, shareList.size(), 'Total of 3 shares expected');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        
        //Scenario 7: Send for approval
        
        System.debug('******************* ApprovalProcess Test START **************************');
        ClaimMemberSharingUtil.testProcessInstanceJson = 
            '[ {' +
            '  "attributes" : {' +
            '    "type" : "ProcessInstance",' +
            '    "url" : "/services/data/v54.0/sobjects/ProcessInstance/04g3W000000w0RrQAI"' +
            '  },' +
            '  "Id" : "' + cm2.Id + '",' +
            '  "TargetObjectId" : "' + cm2.Id + '",' +
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
            '      "ActorId" : "' + testUser1.Id + '"' +
            '    }]' +
            '  }' +
            '}]';
        
        cm2.AssignedApproverId__c = null;
        update cm2;
        shareList = [SELECT Id FROM ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APPROVER_APEXSHARINGREASON];
        System.debug(Json.serializePretty(shareList));
        System.assertEquals(1, shareList.size(), 'Total of 1 shares expected');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        System.debug('******************* ApprovalProcess Test 1 END **************************');
        
        cm2.Account__c = acc.Id;
        update cm2;
        shareList = [SELECT Id FROM ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APPROVER_APEXSHARINGREASON];
        System.debug(Json.serializePretty(shareList));
        System.assertEquals(2, shareList.size(), 'Total of 2 shares expected');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        System.debug('******************* ApprovalProcess Test 2 END **************************');
        
        Test.stopTest();
        
        
    }
    
}