@isTest
public class ClaimMemberSharingBatchTest {
    
    @isTest
    private static void calculateSharing(){
        User testUser1 = TestUtil.createUser();
        User testUser2 = TestUtil.createUser();
        User testUser3 = TestUtil.createUser();
        Id currentUserId = UserInfo.getUserId();
        Account acc = TestUtil.createAccount('TestAcc1', true, false);
        Account acc2 = TestUtil.createAccount('TestAcc1', true, false);
        List<Account> accList = new List<Account>();
        accList.add(acc);
        accList.add(acc2);
        insert accList;
        
        
        //Scenario 1: Insert ClaimMember
        ClaimMembers__c cm1 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser1.Id, EligibleSalesLead__c = currentUserId);
        ClaimMembers__c cm2 = new ClaimMembers__c(Account__c = acc.Id, User__c = testUser2.Id);
        insert new List<ClaimMembers__c>{cm1, cm2};
            
            delete [Select Id From ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APEXSHARINGREASON];
        Test.startTest();
        Database.executeBatch(new ClaimMemberSharingBatch());
        Test.stopTest();
        List<ClaimMembers__Share> shareList = [Select Id From ClaimMembers__Share WHERE RowCause =: ClaimMemberSharingUtil.APEXSHARINGREASON];
        System.assertEquals(2, shareList.size(), 'Expected two shares to be created.');
        
    }
}