@isTest
public class ShareOfWalletHelperTest {

    @isTest
    private static void testSoWShareLogic(){
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
        AccountPlan__c ap2 = TestUtil.CreateAccountPlan('testPlan2', acc2.Id, true);
        ap2.Amount_of_Share_of_Wallet__c = 1;
        update ap2;
        ShareOfWallet__c sow = new ShareOfWallet__c(AccountPlan__c = ap.Id);
        
        //Scenario 1: Insert Sow
        insert sow;
        List<ShareOfWallet__Share> sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(3, sowShares.size(), 'Three share records expected');
        Map<Id, ShareOfWallet__Share> userToShareMap =  new Map<Id, ShareOfWallet__Share>();
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
        System.assertEquals(true, userToShareMap.containsKey(readUserId), 'read user not found');
        System.assertEquals('Read', userToShareMap.get(readUserId).AccessLevel, 'read user does not have read rights.');
        
        
        //Scenario 2: change accountplan Lookup
        sow.AccountPlan__c = ap2.Id;
        update sow;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'two share record expected');
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
        
        
        //Scenario 3: Undelete Sow
        delete sow;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(0, sowShares.size(), 'No share record expected');
        undelete sow;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'two share record expected');
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
    }
    
    
}