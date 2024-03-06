@isTest
public class ClaimSharingUtilsTest {
    
    //Scenarios to test:
    // 1 New claim
    // 2 Update Claim: Update of Account__c
    // 3 Delete Claim
    // 4 Undelete Claim
    // 5 new ClaimMember
    // 6 Update ClaimMember
    // 		6.1 Account__c
    // 		6.2 EligibleSalesLead__c
    // 		6.3 AssignedApproverId__c
    // 7 delete claimMember
    // 8 undelete ClaimMember
    // 9 Delete of account
    // 10 Undelete of Account
    
    
    
    //All scenarios need to have their own test method
    /*@isTest
    private static void createClaimMember (){
        User testUser1 = TestUtil.createUser();
        User testUser2 = TestUtil.createUser();
        User testUser3 = TestUtil.createUser();
        User eligbleSalesUser = TestUtil.createUser();
        User assignedApproverUser = TestUtil.createUser();
        Id currentUserId = UserInfo.getUserId();
        Account acc = TestUtil.createAccount('TestAcc1', true, false);
        Account acc2 = TestUtil.createAccount('TestAcc1', true, false);
        List<Account> accList = new List<Account>();
        accList.add(acc);
        accList.add(acc2);
        insert accList;
        
        ClaimMembers__c cm1 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser1.Id, EligibleSalesLead__c = currentUserId);
        ClaimMembers__c cm2 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser2.Id);
        insert new List<ClaimMembers__c>{cm1, cm2};
            
        //Scenario 1: New Claim
		Claim__c claim1 = new Claim__c(Account__c = acc.Id);
		Claim__c claim2 = new Claim__c(Account__c = acc.Id);
        insert new List<Claim__c>{claim1, claim2};
		List<Claim__Share> shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(2, shareList.size(), 'Scenario 1: Claims Should have been shared with the EligibleSalesLead');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        System.debug('************************* Before Scenario 3 ********************');
        //Scenario 3: delete Claim
        delete claim1;
        shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(1, shareList.size(), 'Scenario 3: Only one claim remains to be shared with anyone');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        System.debug('************************* Before Scenario 4 ********************');
        //Scenario 4: undelete claim
        undelete claim1;
        shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(2, shareList.size(), 'Scenario 4: Claims Should have been shared with the EligibleSalesLead');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        System.debug('************************* Before Scenario 5 ********************');
        //Scenario 5: New ClaimMember
        ClaimMembers__c cm3 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser3.Id, EligibleSalesLead__c = eligbleSalesUser.Id);
        insert cm3;
        shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(4, shareList.size(), 'Scenario 5: Both claims should have been shared with 2 people');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        
        
        System.debug('************************* Before Scenario 6.1 ********************');
        //Scenario 6.1: Update ClaimMember: Account__c
        cm3.Account__c = acc2.Id;
        update cm3;
        shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(2, shareList.size(), 'Scenario 6.1: Only one eligble sales lead');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        Test.startTest();
        delete cm3; //Get rid of this ClaimMember for simplicity in the Test Classess
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        System.debug('************************* Before Scenario 6.2 ********************');
        
        //Scenario 6.2: Update ClaimMember: Eligble SalesLead
        cm2.EligibleSalesLead__c = eligbleSalesUser.Id;
        update cm2;
        shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(4, shareList.size(), 'Scenario 6.2: Both claims should be shared with 2 users.');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        //Scenario 6.3: Update ClaimMember: Eligble SalesLead
        cm2.AssignedApproverId__c = assignedApproverUser.Id;
        update cm2;
        shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(6, shareList.size(), 'Scenario 6.2: Both claims should be shared with 3 users.');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        
        
        cm2.AssignedApproverId__c = null;
        update cm2;
        
        System.debug('************************* Before Scenario 7 ********************');
        //Scenario 7: Delete ClaimMember
        delete cm2;
        shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(2, shareList.size(), 'Scenario 7: Only one eligble sales lead');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        System.debug('************************* Before Scenario 8 ********************');
        //Scenario 8: Undelete ClaimMember
        undelete cm2;
        shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
       	System.assertEquals(4, shareList.size(), 'Scenario 8: Both claims should be shared with 2 users.');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        Test.stopTest();
        
        
    }
*/

	//All scenarios need to have their own test method
    @isTest
    private static void createClaimMember2 (){
        
        User testUser1 = TestUtil.createUser();
        User testUser2 = TestUtil.createUser();
        User testUser3 = TestUtil.createUser();
        User eligbleSalesUser = TestUtil.createUser();
        User assignedApproverUser = TestUtil.createUser();
        Id currentUserId = UserInfo.getUserId();
        Account acc = TestUtil.createAccount('TestAcc1', true, false);
        Account acc2 = TestUtil.createAccount('TestAcc1', true, false);
        List<Account> accList = new List<Account>();
        accList.add(acc);
        accList.add(acc2);
        insert accList;
        
        ClaimMembers__c cm1 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser1.Id, EligibleSalesLead__c = currentUserId);
        ClaimMembers__c cm2 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser2.Id);
        insert new List<ClaimMembers__c>{cm1, cm2};
            
		Claim__c claim1 = new Claim__c(Account__c = acc.Id);
		Claim__c claim2 = new Claim__c(Account__c = acc.Id);
        insert new List<Claim__c>{claim1, claim2};
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        //
        System.debug('************************* Before Scenario 9 ********************');
        //Scenario 9: delete Account
        delete acc;
        List<Claim__Share> shareList = [SELECT Id, parentId, UserOrGroupId FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
       	System.assertEquals(0, shareList.size(), 'Scenario 9: Both claims should not have been shared.'); //Claims or not shared by account anymore
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        
        System.debug('************************* Before Scenario 10 ********************');
        //Scenario 10: undelete Account
        undelete acc;
        shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
       	System.assertEquals(2, shareList.size(), 'Scenario 10: Both claims should be shared with the eligble sales lead.');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        System.debug('************************* Before Scenario 2 ********************');
        //Scenario 2: Update Claim: Account__c
        claim1.Account__c = acc2.Id;
        update claim1;
        shareList = [SELECT Id FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(1, shareList.size(), 'Scenario 2: Claims are not shared by Account, only by its own Eligble Sales Lead');
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
    }
	  
    //All scenarios need to have their own test method
    @isTest
    private static void sharingApprover (){
        
        User testUser1 = TestUtil.createUser();
        User testUser2 = TestUtil.createUser();
        User testUser3 = TestUtil.createUser();
        User assignedApproverUser = TestUtil.createUser();
        User reassignedApproverUser = TestUtil.createUser();
        Id currentUserId = UserInfo.getUserId();
        Account acc = TestUtil.createAccount('TestAcc1', true, false);
        Account acc2 = TestUtil.createAccount('TestAcc1', true, false);
        List<Account> accList = new List<Account>();
        accList.add(acc);
        accList.add(acc2);
        insert accList;
        
        ClaimMembers__c cm1 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser1.Id, EligibleSalesLead__c = currentUserId);
        ClaimMembers__c cm2 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser2.Id);
        insert new List<ClaimMembers__c>{cm1, cm2};
            

		Claim__c claim1 = new Claim__c(Account__c = acc.Id);
		Claim__c claim2 = new Claim__c(Account__c = acc.Id);
        insert new List<Claim__c>{claim1, claim2};
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        //
        System.debug('************************* Before Approval ********************');
        //Scenario 9: before approval
        List<Claim__Share> shareList = [SELECT Id, parentId, UserOrGroupId FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APPROVER_APEXSHARINGREASON];
       	System.assertEquals(0, shareList.size(), 'Expected no sharing as no approval process has started yet.'); //Claims or not shared by account anymore
        ClaimSharingUtil.getInstance().claimsToRecalculate.clear();
        
        System.debug('Claimmembers in test: ');
        system.debug([SELECT Id, Account__c, EligibleSalesLead__c, AssignedApproverId__c FROM ClaimMembers__c ])  ;  
        ClaimMemberSharingUtil.getInstance().claimMembersToRecalculate.clear();
        
        System.debug('Claimmembers in test: ');
        system.debug([SELECT Id, Account__c, EligibleSalesLead__c, AssignedApproverId__c FROM ClaimMembers__c ])  ;  
        System.debug('************************* After Approval ********************');
        ClaimSharingUtil.testProcessInstanceJson = 
            '[ {' +
            '  "attributes" : {' +
            '    "type" : "ProcessInstance",' +
            '    "url" : "/services/data/v54.0/sobjects/ProcessInstance/04g3W000000w0RrQAI"' +
            '  },' +
            '  "Id" : "' + cm1.Id + '",' +
            '  "TargetObjectId" : "' + cm1.Id + '",' +
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
            '      "ActorId" : "' + assignedApproverUser.Id + '",' +
            '      "OriginalActorId" : "' + reassignedApproverUser.Id + '"' +
            '    }]' +
            '  }' +
            '}]';    
        ClaimSharingUtil.getInstance().storeClaims(new set<Id>{claim1.Id, claim2.Id});
        ClaimSharingUtil.getInstance().commitClaims();
        shareList = [SELECT Id, parentId, UserOrGroupId FROM Claim__Share WHERE RowCause =: ClaimSharingUtil.APPROVER_APEXSHARINGREASON];
       	System.assertEquals(4, shareList.size(), 'Expected both claims to be shared with AssignedApprover and Reassigned Approver.'); //Claims or not shared by account anymore
    }
}