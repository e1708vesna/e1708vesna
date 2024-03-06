/**
 * @description   : AccountHelper test class
 * @author (s)    : BRITE
 */
@isTest
private class AccountHelperTest {

    @isTest
    private static void testCreateAccountSharing() {
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());

    	List<Account> accounts = new List<Account>(); 
    	accounts.add(new Account(Name = 'channelpartner1', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'channelpartner2', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'channelpartner3', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'endCustomer1', RecordTypeId = recIdEndCustomer)); 
		accounts.add(new Account(Name = 'endCustomer2', RecordTypeId = recIdEndCustomer)); 
		insert accounts;
		
		// channel partner 1 is directly connected to channelPartner1 account
        Contact channelPartner1 = TestUtil.createContact('Fred', 'Flatter', 'f.f@somecomp.fake', accounts[0].Id, false);
		// channel partner 2 is directly connected to channelPartner2 account
        Contact channelPartner2 = TestUtil.createContact('Wilma', 'Flatter', 'f.f@somecomp.fake', accounts[1].Id, false);
        insert new List<Contact> {channelPartner1, channelPartner2};
		// channel partner 1 is indirectly connected to channelPartner3 account
		TestUtil.createIndirectAccountContactRelation(accounts[2].Id, channelPartner1.Id, true);

		List<License__c> licenses = new List<License__c> ();
		// create license between end customer 1 and channel partner 1
		licenses.add(TestUtil.createLicense('lic1001', accounts[3].Id, false));
		licenses[0].ChannelPartner__c = accounts[0].Id;
		// create license between end customer 2 and channel partner 2
		licenses.add(TestUtil.createLicense('lic1002', accounts[4].Id, false));
        licenses[1].ChannelPartner__c = accounts[1].Id;
        // create license between end customer 2 and channel partner 3
        licenses.add(TestUtil.createLicense('lic1003', accounts[4].Id, false));
        licenses[2].ChannelPartner__c = accounts[2].Id;
        insert licenses;

		// create community users for channel partners
		Test.startTest();
		User channelPartnerUser1 = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner1.Id, false);
        User channelPartnerUser2 = TestUtil.getCommunityUserForContact('acc2', 'Company', channelPartner2.Id, false);
        insert new List<User> {channelPartnerUser1, channelPartnerUser2};
		Test.stopTest();
        
        // there should be 3 manual sharings
		List<AccountShare> accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' And AccountId = :accounts[3].Id];
        System.assertEquals(1, accountShareList.size(), 'Pre test: Number of manual sharings on end customer account 1');
        accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' And AccountId = :accounts[4].Id];
        System.assertEquals(2, accountShareList.size(), 'Pre test: Number of manual sharings on end customer account 2');

        // retrieve a different user to change the ownership of the accounts to
        Id runningUserId = UserInfo.getUserId();
        User otherUser = [SELECT Id FROM User WHERE IsActive = true AND Id != :runningUserId AND ContactId = null AND Profile.Name = 'Nedap Read Only' LIMIT 1];

        // case 1: make irrelevant update on the accounts => no changes should be made to the sharings
        List<Account> endCustomersAccounts = new List<Account> ();
        endCustomersAccounts.add(new Account(Id = accounts[3].Id, Comment__c = 'Some comment'));
        endCustomersAccounts.add(new Account(Id = accounts[4].Id, Comment__c = 'Some comment'));
        update endCustomersAccounts;

        accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(3, accountShareList.size(), 'Case 1: Number of manual sharings on end customer accounts');

        // case 2: update owner of the end customer account
        endCustomersAccounts = new List<Account> ();
        endCustomersAccounts.add(new Account(Id = accounts[3].Id, OwnerId = otherUser.Id));
        endCustomersAccounts.add(new Account(Id = accounts[4].Id, OwnerId = otherUser.Id));
        update endCustomersAccounts;

        accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(3, accountShareList.size(), 'Case 2: Number of manual sharings on end customer accounts'); 
    }

}