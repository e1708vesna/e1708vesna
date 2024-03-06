@isTest
public class AccountPlanHelperTest {

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
        ShareOfWallet__c sow = new ShareOfWallet__c(AccountPlan__c = ap.Id);
        
        //Scenario 1: Change AccountLookup on AccountPlan
        insert sow;
        ap.Account__c = acc2.Id;
        update ap;
        
        List<ShareOfWallet__Share> sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'Two share record expected');
        Map<Id, ShareOfWallet__Share> userToShareMap =  new Map<Id, ShareOfWallet__Share>();
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
        
        //Scenario 2: delete AccountPlan
        delete ap;
        
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(0, sowShares.size(), 'No share record expected');
        
        //Scenario 3: undelete AccountPlan
        undelete ap;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'Two share record expected');
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
    }
    
    @isTest
    private static void testCiShareLogic(){
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
        
        
        //Scenario 1: Change AccountLookup on AccountPlan
        
        ap.Account__c = acc2.Id;
        update ap;
        
        List<APConfidentialInformation__Share> sowShares = [Select Id, UserOrGroupId, AccessLevel FROM APConfidentialInformation__Share Where RowCause =: APConfidentialInformationSharingUtils.APEXSHARINGREASON];
        
        System.assertEquals(2, sowShares.size(), 'Two share record expected');
        Map<Id, APConfidentialInformation__Share> userToShareMap =  new Map<Id, APConfidentialInformation__Share>();
        for (APConfidentialInformation__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
        
        //Scenario 2: delete AccountPlan
        delete ap;
        
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM APConfidentialInformation__Share Where RowCause =: APConfidentialInformationSharingUtils.APEXSHARINGREASON];
        System.assertEquals(0, sowShares.size(), 'No share record expected');
        
        //Scenario 3: undelete AccountPlan
        undelete ap;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM APConfidentialInformation__Share Where RowCause =: APConfidentialInformationSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'Two share record expected'); //For some reason the Owner is not reinstated as teammember
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
    }
    
    
}