@isTest
public class AmClaimSharingBatchTest {
	@isTest
    private static void runBatch(){
        User testUser1 = TestUtil.createUser('t1', false);
        User approver1 = TestUtil.createUser('t3', false);
        User approver2 = TestUtil.createUser('t4', false);
        List<User> testUsers = new List<User>();
        testUsers.add(testUser1);
        testUsers.add(approver1);
        testUsers.add(approver2);
        insert testUsers;
        
        List<AMClaim__c> claimList = new List<AMClaim__c>();
        for (Integer i = 0; i < 200; i ++){
            AMClaim__c claim = new AMClaim__c();
            claim.AssignedApproverId__c = approver1.Id;
            claim.ActualApproverId__c = approver2.Id;
            claimList.add(claim);
        }
        insert claimList;
        delete [Select Id From AMClaim__Share WHERE RowCause =: AmClaimSharingUtil.APEXSHARINGREASON];
        
        Test.startTest();
        Database.executeBatch(new AmClaimSharingBatch());
        Test.stopTest();
        List<AmClaim__Share> shareList = [Select Id From AmClaim__share WHERE RowCause =: AmClaimSharingUtil.APEXSHARINGREASON];
        System.assertEquals(400, shareList.size(), 'Error 404: shares not found. Expected 400 share records to be present');
        
    }
}