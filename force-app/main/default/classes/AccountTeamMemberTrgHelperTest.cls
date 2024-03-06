@isTest
public class AccountTeamMemberTrgHelperTest {

    @isTest
    private static void testSoWShareLogic(){
        User testUser = TestUtil.createUser();
        User writeUser = TestUtil.createUser2();
        Id writeUserId = writeUser.Id;
        Id readUserId = testUser.Id;
        Account acc = TestUtil.createAccount('TestAcc1', true, true);
        AccountTeamMember actWrite = TestUtil.createAccountTeamMember(acc.Id, writeUserId, true, false);
        AccountPlan__c ap = TestUtil.CreateAccountPlan('testPlan', acc.Id, true);
        ap.Amount_of_Share_of_Wallet__c = 1;
        update ap;
        ShareOfWallet__c sow = new ShareOfWallet__c(AccountPlan__c = ap.Id);
        
        
        insert sow;
        List<ShareOfWallet__Share> sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(1, sowShares.size(), 'One share record expected');
        Map<Id, ShareOfWallet__Share> userToShareMap =  new Map<Id, ShareOfWallet__Share>();
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(false, userToShareMap.containsKey(writeUserId), 'writeUser should not be found');
        System.assertEquals(false, userToShareMap.containsKey(readUserId), 'readUser should not be found');
        
        //Scenario 1: insert new AccountTeamMember
        insert actWrite;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'two share record expected');
        userToShareMap =  new Map<Id, ShareOfWallet__Share>();
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
        
        
        //Scenario 2: change accountAccessLevel
        actWrite.AccountAccessLevel = 'Read';
        update actWrite;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'two share record expected');
        userToShareMap =  new Map<Id, ShareOfWallet__Share>();
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Read', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have read rights.');
        
        //Scenario 3: Delete AccountTeamMember
        delete actWrite;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(1, sowShares.size(), 'one share record expected');
        
        //Scenario 4: Undelete AccountTeamMember is not possible.
    }
    
    @isTest
    private static void testCiShareLogic(){
        User testUser = TestUtil.createUser();
        User writeUser = TestUtil.createUser2();
        Id writeUserId = writeUser.Id;
        Id readUserId = testUser.Id;
        Account acc = TestUtil.createAccount('TestAcc1', true, true);
        AccountTeamMember actWrite = TestUtil.createAccountTeamMember(acc.Id, writeUserId, true, false);
        AccountPlan__c ap = TestUtil.CreateAccountPlan('testPlan', acc.Id, true);
        ap.Amount_of_Share_of_Wallet__c = 1;
        update ap;
        
        Id ciId = [SELECT Id, APConfidentialInformation__c FROM AccountPlan__c WHERE Id =: ap.Id ][0].APConfidentialInformation__c; //Auto Created by flow
        
        List<APConfidentialInformation__Share> sowShares = [Select Id, UserOrGroupId, AccessLevel FROM APConfidentialInformation__Share Where RowCause =: APConfidentialInformationSharingUtils.APEXSHARINGREASON];
        System.assertEquals(1, sowShares.size(), 'One share record expected');
        Map<Id, APConfidentialInformation__Share> userToShareMap =  new Map<Id, APConfidentialInformation__Share>();
        for (APConfidentialInformation__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(false, userToShareMap.containsKey(writeUserId), 'writeUser should not be found');
        System.assertEquals(false, userToShareMap.containsKey(readUserId), 'readUser should not be found');
        
        //Scenario 1: insert new AccountTeamMember
        insert actWrite;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM APConfidentialInformation__Share Where RowCause =: APConfidentialInformationSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'two share record expected');
        userToShareMap =  new Map<Id, APConfidentialInformation__Share>();
        for (APConfidentialInformation__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
        
        
        //Scenario 2: change accountAccessLevel
        actWrite.AccountAccessLevel = 'Read';
        update actWrite;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM APConfidentialInformation__Share Where RowCause =: APConfidentialInformationSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'two share record expected');
        userToShareMap =  new Map<Id, APConfidentialInformation__Share>();
        for (APConfidentialInformation__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have read rights.');
        
        //Scenario 3: Delete AccountTeamMember
        delete actWrite;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM APConfidentialInformation__Share Where RowCause =: APConfidentialInformationSharingUtils.APEXSHARINGREASON];
        System.assertEquals(1, sowShares.size(), 'one share record expected');
        
        //Scenario 4: Undelete AccountTeamMember is not possible.
    }
    
    
}