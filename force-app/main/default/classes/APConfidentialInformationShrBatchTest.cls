@isTest
public class APConfidentialInformationShrBatchTest {

    @isTest
    private static void testShareBatch(){
        User testUser = TestUtil.createUser();
        User writeUser = TestUtil.createUser2();
        Id writeUserId = writeUser.Id;
        Id readUserId = testUser.Id;
        Account acc = TestUtil.createAccount('TestAcc1', true, true);
        Account acc2 = TestUtil.createAccount('TestAcc2', true, true);
        AccountTeamMember actWrite = TestUtil.createAccountTeamMember(acc.Id, writeUserId, true, true);
        AccountTeamMember act2Write = TestUtil.createAccountTeamMember(acc2.Id, writeUserId, true, true);
        AccountTeamMember actRead = TestUtil.createAccountTeamMember(acc.Id, readUserId, false, true);
        
        AccountPlan__c ap = TestUtil.CreateAccountPlan('testPlan', acc.Id, true);
        ap.Amount_of_Share_of_Wallet__c = 1;
        update ap;
        
        Id ciId = [SELECT Id, APConfidentialInformation__c FROM AccountPlan__c WHERE Id =: ap.Id ][0].APConfidentialInformation__c; //Auto Created by flow
        
        delete [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        Test.startTest();
        Database.executeBatch(new APConfidentialInformationSharingBatch());
        Test.stopTest();
        
        List<APConfidentialInformation__Share> sowShares = [Select Id, UserOrGroupId, AccessLevel FROM APConfidentialInformation__Share Where RowCause =: APConfidentialInformationSharingUtils.APEXSHARINGREASON];
        
        System.assertEquals(3, sowShares.size(), 'Two share record expected, Running User and both AccountTeamMembers');
        Map<Id, APConfidentialInformation__Share> userToShareMap =  new Map<Id, APConfidentialInformation__Share>();
        for (APConfidentialInformation__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
        System.assertEquals(true, userToShareMap.containsKey(readUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(readUserId).AccessLevel, 'Read user does not have Edit rights.');
    }
    
        
    
    
}