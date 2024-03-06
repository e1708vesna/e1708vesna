/**
* @description Test class for testing functionality of class AccountHelper
* @author BRITE
*/
@isTest
private class AccountHelperTest {
    
    @isTest
    public static void testUpdateCurrencyIsoCode() {
        // create test data
        Account acc = new Account(Name = 'test account');
        
        // case 1: null check
        try {
            AccountHelper.updateCurrencyIsoCode(null);
            AccountHelper.updateCurrencyIsoCode(new List<Account> ());
            AccountHelper.updateCurrencyIsoCode(new List<Account> {acc});
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // case 2: United States
        acc.BillingCountryCode = 'US';
        AccountHelper.updateCurrencyIsoCode(new List<Account> {acc});
        system.assertEquals('USD', acc.CurrencyIsoCode, 'Case 2: CurrencyIsoCode');
        
        // case 3: Canada
        acc.BillingCountryCode = 'CA';
        AccountHelper.updateCurrencyIsoCode(new List<Account> {acc});
        system.assertEquals('CAD', acc.CurrencyIsoCode, 'Case 3: CurrencyIsoCode');
        
        // case 4: United Kingdom
        acc.BillingCountryCode = 'GB';
        AccountHelper.updateCurrencyIsoCode(new List<Account> {acc});
        system.assertEquals('GBP', acc.CurrencyIsoCode, 'Case 4: CurrencyIsoCode');
        
        // case 5: Ireland
        acc.BillingCountryCode = 'IE';
        AccountHelper.updateCurrencyIsoCode(new List<Account> {acc});
        system.assertEquals('GBP', acc.CurrencyIsoCode, 'Case 5: CurrencyIsoCode');
        
        // case 6: Australia
        acc.BillingCountryCode = 'AU';
        AccountHelper.updateCurrencyIsoCode(new List<Account> {acc});
        system.assertEquals('AUD', acc.CurrencyIsoCode, 'Case 6: CurrencyIsoCode');
        
        // case 7: Brazil
        acc.BillingCountryCode = 'BR';
        AccountHelper.updateCurrencyIsoCode(new List<Account> {acc});
        system.assertEquals('BRL', acc.CurrencyIsoCode, 'Case 7: CurrencyIsoCode');
        
        // case 8: Other country
        acc.BillingCountryCode = 'NL';
        acc.CurrencyIsoCode = 'USD';
        AccountHelper.updateCurrencyIsoCode(new List<Account> {acc});
        system.assertEquals('USD', acc.CurrencyIsoCode, 'Case 8: CurrencyIsoCode');
        
        // case 9: set currency iso code via trigger
        acc.BillingCountry = 'United Kingdom';
        acc.BillingCountryCode = 'GB';
        acc.BillingStreet = 'London Lane';
        insert acc;
        
        acc = [SELECT ID, Name, BillingCountry, BillingCountryCode, CurrencyIsoCode FROM Account WHERE Id = :acc.Id];
        system.assertEquals('GB', acc.BillingCountryCode, 'Case 9: BillingCountryCode');
        system.assertEquals('GBP', acc.CurrencyIsoCode, 'Case 9: CurrencyIsoCode');
        
        // case 10: update currency iso code via trigger
        acc.BillingCountry = 'Canada';
        acc.BillingCountryCode = 'CA';
        update acc;
        
        acc = [SELECT ID, Name, BillingCountry, CurrencyIsoCode FROM Account WHERE Id = :acc.Id];
        system.assertEquals('CAD', acc.CurrencyIsoCode, 'Case 10: CurrencyIsoCode');
    }
    
   
    @isTest
    private static void testUpdateRecordType() {
        // case 1: null check
        try {
            AccountHelper.updateAccountType(null);
            AccountHelper.updateAccountType(new List<Account> ());
        } catch (Exception ex) {
            system.assert(false, 'Exception thrown: ' + ex.getMessage());
        }
        
        // case 2: 'Is Partner' set to true
        //Brite 16Oktober2019 replaced all RT_ID_ACC_MERCHANT by RT_ID_ACC_COMPETITOR
        //Account acc = new Account(Name = 'first test case', RecordTypeId = Constants.RT_ID_ACC_MERCHANT, IsPartner__c = true, BillingCountry='Netherlands');
        //Account acc = new Account(Name = 'first test case', RecordTypeId = Constants.RT_ID_ACC_COMPETITOR, IsPartner__c = true, BillingCountry='Netherlands');        
        //insert acc;
        
        //acc = [SELECT Id, RecordTypeId FROM Account WHERE Id = :acc.Id];
        //system.assertEquals(Constants.RT_ID_ACC_PARTNER_V2, acc.RecordTypeId, 'Case 2: recordTypeId');
        
        // case 3: 'Is Partner' set to false
        Account acc = new Account(Name = 'second test account', RecordTypeId = Constants.RT_ID_ACC_COMPETITOR, IsPartner__c = false, BillingCountry='Netherlands');
        insert acc;
        
        acc = [SELECT Id, RecordTypeId FROM Account WHERE Id = :acc.Id];
        system.assertEquals(Constants.RT_ID_ACC_COMPETITOR, acc.RecordTypeId, 'Case 3: recordTypeId');
    }
    
    @isTest
    private static void testSoWShareLogic(){
        User testUser = TestUtil.createUser();
        User writeUser = TestUtil.createUser2();
        Id writeUserId = writeUser.Id;
        Id readUserId = testUser.Id;
        Account acc = TestUtil.createAccount('TestAcc1', true, true);
        List<AccountTeamMember> actList = [Select Id from AccountTeamMember];
        System.assertEquals(1, actList.size(), 'one AccountTeamMembers Expected after first Account Insert');
        //Account acc2 = TestUtil.createAccount('TestAcc2', Constants.RT_ID_ACC_Live, true);
        AccountTeamMember actWrite = TestUtil.createAccountTeamMember(acc.Id, writeUserId, true, true);
        AccountPlan__c ap = TestUtil.CreateAccountPlan('testPlan', acc.Id, true);
        ap.Amount_of_Share_of_Wallet__c = 1;
        update ap;
        ShareOfWallet__c sow = new ShareOfWallet__c(AccountPlan__c = ap.Id);
        insert sow;
        List<ShareOfWallet__Share> sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'Two share record expected');
        Map<Id, ShareOfWallet__Share> userToShareMap =  new Map<Id, ShareOfWallet__Share>();
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'writeUser should be found');
        
        //Scenario 1: delete account
        delete acc;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(0, sowShares.size(), 'No share record expected');
        
        //Scenario 2: undelete account
        undelete acc;
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(2, sowShares.size(), 'Two share record expected');
        userToShareMap =  new Map<Id, ShareOfWallet__Share>();
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'Write user not found');
        System.assertEquals('Edit', userToShareMap.get(writeUserId).AccessLevel, 'Write user does not have read rights.');
        
    }
    
    /*@isTest
private static void testSoWMergeShareLogic(){
Id profileId = [Select Id From Profile Where Name = 'Brite Salesforce Administrator' LIMIT 1][0].Id;
User testUser = TestUtil.createUser3Profile(profileId, true);
User writeUser = TestUtil.createUser3Profile(profileId, true);
Id writeUserId = writeUser.Id;
Id readUserId = testUser.Id;
//Live Account v2
Account acc = TestUtil.createAccount('TestAcc1', Constants.RT_ID_ACC_Live, true);
Account acc2 = TestUtil.createAccount('TestAcc2', Constants.RT_ID_ACC_Live, true);


AccountTeamMember actWrite = TestUtil.createAccountTeamMember(acc.Id, writeUserId, true, true);
AccountTeamMember actRead = TestUtil.createAccountTeamMember(acc2.Id, readUserId, false, true);
AccountPlan__c ap = TestUtil.CreateAccountPlan('testPlan', acc.Id, true);
AccountPlan__c ap2 = TestUtil.CreateAccountPlan('testPlan2', acc.Id, true);
insert ap;
insert ap2;
ShareOfWallet__c sow = new ShareOfWallet__c(AccountPlan__c = ap.Id);
ShareOfWallet__c sow2 = new ShareOfWallet__c(AccountPlan__c = ap2.Id);
insert sow;
insert sow2;
List<ShareOfWallet__c> sowList = new List<ShareOfWallet__c>();
sowList.add(sow);
sowList.add(sow2);

List<ShareOfWallet__Share> sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where ParentId IN: sowList AND RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
System.assertEquals(4, sowShares.size(), 'four share record expected');
Map<Id, ShareOfWallet__Share> userToShareMap =  new Map<Id, ShareOfWallet__Share>();
for (ShareOfWallet__Share sowShare : sowShares) {
userToShareMap.put(sowShare.UserOrGroupId, sowShare);
}
System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'writeUser should be found');
System.assertEquals(true, userToShareMap.containsKey(readUserId), 'readUser should be found');
Test.startTest();
merge acc acc2;        
Test.stopTest();
sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where ParentId IN: sowList AND RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
System.assertEquals(6, sowShares.size(), '6 share record expected');
userToShareMap =  new Map<Id, ShareOfWallet__Share>();
for (ShareOfWallet__Share sowShare : sowShares) {
userToShareMap.put(sowShare.UserOrGroupId, sowShare);
}
}*/
    
    
    //SeeAllData=True is needed because of a bug in Salesforce. Without it, when merging accounts, its account teammembers are not merged.
    @isTest(SeeAllData=True)
    private static void testSoWMergeShareLogicSeeAllData(){        
        Id profileId = [Select Id From Profile Where Name = 'Brite Salesforce Administrator' LIMIT 1][0].Id;
        User testUser = TestUtil.createUser3Profile(profileId, true);
        User writeUser = TestUtil.createUser3Profile(profileId, true);
        Id writeUserId = writeUser.Id;
        Id readUserId = testUser.Id;
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString;
        Account acc = TestUtil.createAccount( uniqueName + '1', true, true);
        Account acc2 = TestUtil.createAccount(uniqueName + '2', true, true);
        
        AccountTeamMember actWrite = new AccountTeamMember();
        actWrite.AccountId = acc.Id;
        actWrite.UserId = writeUserId;
        actWrite.AccountAccessLevel = 'Edit';
        insert actWrite;
        
        AccountTeamMember actRead = new AccountTeamMember();
        actRead.AccountId = acc2.Id;
        actRead.UserId = readUserId;
        actRead.AccountAccessLevel = 'read';
        insert actRead;
        
        
        AccountPlan__c ap = TestUtil.CreateAccountPlan('testPlan', acc.Id, true);
        AccountPlan__c ap2 = TestUtil.CreateAccountPlan('testPlan2', acc2.Id, true);
        
        ShareOfWallet__c sow = new ShareOfWallet__c(AccountPlan__c = ap.Id);
        ShareOfWallet__c sow2 = new ShareOfWallet__c(AccountPlan__c = ap2.Id);
        insert sow;
        insert sow2;
        List<ShareOfWallet__c> sowList = new List<ShareOfWallet__c>();
        sowList.add(sow);
        sowList.add(sow2);
        
        List<ShareOfWallet__Share> sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where ParentId IN: sowList AND RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(4, sowShares.size(), 'four share record expected');
        Map<Id, ShareOfWallet__Share> userToShareMap =  new Map<Id, ShareOfWallet__Share>();
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
        System.assertEquals(true, userToShareMap.containsKey(writeUserId), 'writeUser should be found');
        System.assertEquals(true, userToShareMap.containsKey(readUserId), 'readUser should be found');
        Test.startTest();
        merge acc acc2;        
        Test.stopTest();
        sowShares = [Select Id, UserOrGroupId, AccessLevel FROM ShareOfWallet__Share Where ParentId IN: sowList AND RowCause =: ShareOfWalletSharingUtils.APEXSHARINGREASON];
        System.assertEquals(6, sowShares.size(), '6 share record expected');
        userToShareMap =  new Map<Id, ShareOfWallet__Share>();
        for (ShareOfWallet__Share sowShare : sowShares) {
            userToShareMap.put(sowShare.UserOrGroupId, sowShare);
        }
    }
    
    @isTest
    private static void testAccountOwnerChange(){
        Id profileId = TestUtil.getProfile('Adyen v2 Account Manager');
        Id profileIdNoAm = TestUtil.getProfile('Adyen v2 Customer Success');
        User originalOwner = TestUtil.createUser3Profile(profileId, false);
        User newOwner = TestUtil.createUser3Profile(profileId, false);
        User nonAccountManager = TestUtil.createUser3Profile(profileIdNoAm, false);
        List<User> userInsertList = new List<User>{originalOwner, newOwner, nonAccountManager};
            
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert userInsertList;
        }
        Account acc = TestUtil.createAccount('TestAcc1', true, false);
        acc.OwnerId = originalOwner.Id;
        insert acc;
        AccountPlan__c ap = TestUtil.CreateAccountPlan('testPlan', acc.Id, false);
        ap.Amount_of_Share_of_Wallet__c = 1;
        ap.OwnerId = originalOwner.Id;
        insert ap;
        ShareOfWallet__c sow = new ShareOfWallet__c(AccountPlan__c = ap.Id);
        sow.OwnerId = originalOwner.Id;
        insert sow;
        
        acc.OwnerId = newOwner.Id;
        update acc;
        ap = [Select Id, OwnerId From AccountPlan__c Where Id=:ap.Id];
        System.assertEquals(newOwner.Id, ap.OwnerId, 'Owner of Account Plan should have changed.');
        sow = [Select Id, OwnerId From ShareOfWallet__c Where Id=:sow.Id];
        System.assertEquals(newOwner.Id, sow.OwnerId, 'Owner of SoW should have changed.');
        
        acc.OwnerId = nonAccountManager.Id;
        update acc;
        ap = [Select Id, OwnerId From AccountPlan__c Where Id=:ap.Id];
        System.assertEquals(newOwner.Id, ap.OwnerId, 'Owner of Account Plan should not have changed.');
        sow = [Select Id, OwnerId From ShareOfWallet__c Where Id=:sow.Id];
        System.assertEquals(newOwner.Id, sow.OwnerId, 'Owner of SoW should not have changed.');
    }
    
    @isTest
    private static void encodeAccountLiveLink() {
         
      Map<String, Object> businessAccountMap = new Map<String, Object>{
            'RecordTypeId' => Constants.RT_ID_ACC_BUSINESS,
            'BillingCountry' => 'Colombia',
            'Industry' => 'Retail',
            'SubIndustry__c' => 'Other',
            'Company_Segment__c' => '25 - 50 million',
            'MerchantCoreBusinessModel__c' => 'Platforms',
            'SubBusinessModel__c' => 'Marketplaces',
            'Name' => 'PaxJet',
            'Adyen_Platform_Account_Code__c' => 'PaxJet'
    	};
            
	    Account businessAccount = (Account)TestDataFactory.createSObject('Account', businessAccountMap);

        List<Account> accList = new List<Account> ();
        accList.add(businessAccount);
       	AccountHelper.encodeAccountLiveLink(accList);
        
        businessAccount = [SELECT BO_EncodedAccountKey__c FROM Account WHERE Id = :businessAccount.Id];
        system.assertEquals('B1-Q29tcGFueS5QYXhKZXQ', businessAccount.BO_EncodedAccountKey__c );
    }
}