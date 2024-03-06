@isTest
public class ShareOfWalletSharingUtilsTest {

     /*Scenarios:
    //Sow:
        New SoW										Current SoW-> After insert trigger
        Changed AccountPlan lookup  				Current SoW-> After update trigger -> Existing shares get deleted in the function already
        undelete SoW								Current SoW-> After undelete trigger
        
        AccountPlan:
        new AccountPlan								Current SoW-> After insert trigger
        Changed lookup to Account					Current SoW-> After update trigger -> Existing shares get deleted in the function already
        delete AccountPlan							Current SoW -> After delete trigger
        undelete AccountPlan						Current SoW -> After undelete trigger
        
        AccountTeamMember:
        new AccountTeamMember						Current SoW -> After insert trigger
        Changed Account (should not be possible)	Current SoW-> After update trigger; Capture the old SoW by checking the the account of the Trigger.Old and also call the function for that SOW
        delete AccountTeamMember					Current SoW -> After delete trigger
        undelete AccountTeamMember					Current SoW -> After undelete trigger
        Changed Account access						Current SoW-> After update trigger

*/
    
    @isTest
    private static void getNewOldShares (){
        
        User testUser = TestUtil.createUser();
        Id writeUserId = UserInfo.getUserId();
        Id readUserId = testUser.Id;
        Account acc = TestUtil.createAccount('TestAcc1', true, true);
        AccountTeamMember actWrite = TestUtil.createAccountTeamMember(acc.Id, writeUserId, true, true);
        AccountTeamMember actRead = TestUtil.createAccountTeamMember(acc.Id, readUserId, false, true);
        
        
        AccountPlan__c ap = TestUtil.CreateAccountPlan('testPlan', acc.Id, true);
        ap.Amount_of_Share_of_Wallet__c = 1;
        update ap;
        ShareOfWallet__c sow = new ShareOfWallet__c(AccountPlan__c = ap.Id);
        insert sow;
        
        Map<Id, Map<Id, ShareOfWallet__Share>> newShareMap = ShareOfWalletSharingUtils.getNewShares(new Set<Id>{sow.Id});
        Map<Id, Map<Id, ShareOfWallet__Share>> oldShareMap = ShareOfWalletSharingUtils.getCurrentShares(new Set<Id>{sow.Id});

		
        System.assertEquals(true, newShareMap.containsKey(sow.Id), 'Sow not found in new result map');
        Map<Id, ShareOfWallet__Share> userToShareMap = newShareMap.get(sow.Id);
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
        System.assertEquals(true, userToShareMap.containsKey(readUserId), 'read user not found');
        System.assertEquals('Read', userToShareMap.get(readUserId).AccessLevel, 'read user does not have read rights.');
        
        
        System.assertEquals(true, oldShareMap.containsKey(sow.Id), 'Sow not found in old result map');
        userToShareMap = oldShareMap.get(sow.Id);
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have edit rights.');
        System.assertEquals(true, userToShareMap.containsKey(readUserId), 'read user not found');
        System.assertEquals('Read', userToShareMap.get(readUserId).AccessLevel, 'read user does not have read rights.');
    }
    
    @isTest
    private static void cleanseShares (){
        
        Id userId1 = '000000000000000001';
        Id userId2 = '000000000000000002';
        Id userId3 = '000000000000000003';
        Id userId4 = '000000000000000004';
        Id sowId   = '000000000000000005';
        Map<Id, Map<Id, ShareOfWallet__Share>> existingShares= new Map<Id, Map<Id, ShareOfWallet__Share>>();
        Map<Id, Map<Id, ShareOfWallet__Share>> newShares= new Map<Id, Map<Id, ShareOfWallet__Share>>();
        List<ShareOfWallet__Share> upsertList = new List<ShareOfWallet__Share>();
        List<ShareOfWallet__Share> deleteList = new List<ShareOfWallet__Share>();
        
        
        ShareOfWalletSharingUtils.cleanseShares(existingShares, newShares, upsertList, deleteList);
        System.assertEquals(0, upsertList.size(), 'Upsert List should be empty');
        System.assertEquals(0, deleteList.size(), 'delete List should be empty');
        
        
        
        //one in existing that is not in new
        //one in new that is not in existing
        //one in existing and new
        //one in existing and new that have different access rights
        Map<Id, ShareOfWallet__Share> existingShareMap = new Map<Id, ShareOfWallet__Share>();
        ShareOfWallet__Share existingShareRecord1 = new ShareOfWallet__Share(AccessLevel = 'Read', ParentId = sowId, RowCause = ShareOfWalletSharingUtils.APEXSHARINGREASON, UserOrGroupId = userId1);
        existingShareMap.put(userId1, existingShareRecord1);
        ShareOfWallet__Share existingShareRecord3 = new ShareOfWallet__Share(AccessLevel = 'Read', ParentId = sowId, RowCause = ShareOfWalletSharingUtils.APEXSHARINGREASON, UserOrGroupId = userId3);
        existingShareMap.put(userId3, existingShareRecord3);
        ShareOfWallet__Share existingShareRecord4 = new ShareOfWallet__Share(AccessLevel = 'Read', ParentId = sowId, RowCause = ShareOfWalletSharingUtils.APEXSHARINGREASON, UserOrGroupId = userId4);
        existingShareMap.put(userId4, existingShareRecord4);
        existingShares.put(sowId, existingShareMap);
            
        Map<Id, ShareOfWallet__Share> newShareMap = new Map<Id, ShareOfWallet__Share>();
        ShareOfWallet__Share shareRecord2 = new ShareOfWallet__Share(AccessLevel = 'Read', ParentId = sowId, RowCause = ShareOfWalletSharingUtils.APEXSHARINGREASON, UserOrGroupId = userId2);
        newShareMap.put(userId2, shareRecord2);
        ShareOfWallet__Share shareRecord3 = new ShareOfWallet__Share(AccessLevel = 'Read', ParentId = sowId, RowCause = ShareOfWalletSharingUtils.APEXSHARINGREASON, UserOrGroupId = userId3);
        newShareMap.put(userId3, shareRecord3);
        ShareOfWallet__Share shareRecord4 = new ShareOfWallet__Share(AccessLevel = 'Edit', ParentId = sowId, RowCause = ShareOfWalletSharingUtils.APEXSHARINGREASON, UserOrGroupId = userId4);
        newShareMap.put(userId4, shareRecord4);
        newShares.put(sowId, newShareMap);
        
        ShareOfWalletSharingUtils.cleanseShares(existingShares, newShares, upsertList, deleteList);
        System.assertEquals(2, upsertList.size(), 'Upsert List should have one entry');
        System.assertEquals(1, deleteList.size(), 'delete List should have two entries');
    }
}