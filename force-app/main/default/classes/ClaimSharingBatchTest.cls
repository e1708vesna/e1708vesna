@isTest
public class ClaimSharingBatchTest {
    
    @isTest
    private static void calculateSharing(){
        
        User testUser1 = TestUtil.createUser();
        User testUser2 = TestUtil.createUser();
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
            delete [Select Id From Claim__Share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        Test.startTest();
        Database.executeBatch(new ClaimSharingBatch());
        Test.stopTest();
        List<Claim__Share> shareList = [Select Id From Claim__share WHERE RowCause =: ClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(2, shareList.size(), 'Expected two shares to be created.');
        
    }
}