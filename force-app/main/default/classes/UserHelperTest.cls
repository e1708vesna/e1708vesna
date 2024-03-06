/**
 * @description   : UserHelper test class
 * @author (s)    : Brite
 */
@isTest
private class UserHelperTest {
	/**
	 * Test the creation of the AccountShare for the Community User if it has a relation with the parent Account ChannelPartner
	 */
    static testMethod void setAccountSharing_withLic() {
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());
    	
    	List<Account> accounts = new List<Account>(); 
    	accounts.add(new Account(Name = 'channelpartner1', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'channelpartner2', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'endCustomer1', RecordTypeId = recIdEndCustomer)); 
		accounts.add(new Account(Name = 'endCustomer2', RecordTypeId = recIdEndCustomer)); 
		insert accounts;
		
		// channel partner is directly connected to channelPartner1 account
		Contact channelPartner = TestUtil.createContact('Fred', 'Flatter', 'f.f@somecomp.fake', accounts[0].Id, true);
		// channel partner is indirectly connected to channelPartner2 account
		TestUtil.createIndirectAccountContactRelation(accounts[1].Id, channelPartner.Id, true);

		List<License__c> licenses = new List<License__c> ();
		// license 1 is set for end customer 1 and channel partner account 1
		licenses.add(TestUtil.createLicense('lic1001', accounts[2].Id, false));
		licenses[0].ChannelPartner__c = accounts[0].Id;
		// license 2 is set for end customer 2 and channel partner account 2
		licenses.add(TestUtil.createLicense('lic1002', accounts[3].Id, false));
		licenses[1].ChannelPartner__c = accounts[1].Id;
		insert licenses;
		
		Test.startTest();

		// case 1: Create Account Share for the new PowerCustomerSuccess user!
		User usr1 = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner.Id, true);
		Id contactId = usr1.ContactID;
		
		Test.stopTest();
		
    	Set<Id> accountIdSet = new Set<Id> {accounts[2].Id, accounts[3].Id};    	
		List<AccountShare> accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIdSet AND UserOrGroupId = :usr1.Id];
		System.assertEquals(2, accountShareList.size(), 'Account share should be created: ' + accountShareList);
    }

	/**
	 * Test the creation of the AccountShare for the Community User if it has a relation with the parent Account ChannelPartner
	 */
    static testMethod void setAccountSharingTest_withoutLic() {
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());
    	
    	List<Account> accounts = new List<Account>(); 
    	accounts.add(new Account(Name = 'channelpartner1', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'channelpartner2', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'endCustomer1', RecordTypeId = recIdEndCustomer)); 
		accounts.add(new Account(Name = 'endCustomer2', RecordTypeId = recIdEndCustomer)); 
		insert accounts;
		
		// channel partner is directly connected to channelPartner1 account
		Contact channelPartner = TestUtil.createContact('Fred', 'Flatter', 'f.f@somecomp.fake', accounts[0].Id, true);
		// channel partner is indirectly connected to channelPartner2 account
		TestUtil.createIndirectAccountContactRelation(accounts[1].Id, channelPartner.Id, true);

		Test.startTest();

		// case 1: Create Account Share for the new PowerCustomerSuccess user!
		User usr1 = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner.Id, true);
		Id contactId = usr1.ContactID;
		
		Test.stopTest();
		
    	Set<Id> accountIdSet = new Set<Id> {accounts[2].Id, accounts[3].Id};    	
		List<AccountShare> accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIdSet AND UserOrGroupId = :usr1.Id];
		System.assertEquals(0, accountShareList.size(), 'Account share should NOT be created; there are no licenses.');
    }
    
}