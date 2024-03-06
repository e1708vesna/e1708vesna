/**
 * @description   : ContactHelper test class
 * @author (s)    : BRITE
 */
@isTest
private class ContactHelperTest {

	/**
	 * Test the creation of the AccountShare for the Community User if it has a relation with the parent Account ChannelPartner
	 */
    static testMethod void accountShareTest() {
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());

    	List<Account> accounts = new List<Account>(); 
    	accounts.add(new Account(Name = 'channelpartner1', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'channelpartner2', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'channelpartner3', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'endCustomer1', RecordTypeId = recIdEndCustomer)); 
		accounts.add(new Account(Name = 'endCustomer2', RecordTypeId = recIdEndCustomer)); 
		insert accounts;
		
		// channel partner is directly connected to channelPartner1 account
		Contact channelPartner = TestUtil.createContact('Fred', 'Flatter', 'f.f@somecomp.fake', accounts[0].Id, false);
		// contact of end customer
		Contact endCustomerContact = TestUtil.createContact('Ton', 'EndCustomer', 'ton.endcustomer@someothercomp.fake', accounts[3].Id, false);
		insert new List<Contact> {channelPartner, endCustomerContact};

		List<License__c> licenses = new List<License__c> ();
		// create license between end customer 1 and channel partner 2
		licenses.add(TestUtil.createLicense('lic1001', accounts[3].Id, false));
		licenses[0].ChannelPartner__c = accounts[1].Id;
		// create license between end customer 2 and channel partner 3
		licenses.add(TestUtil.createLicense('lic1002', accounts[4].Id, false));
		licenses[1].ChannelPartner__c = accounts[2].Id;
		insert licenses;

		// create community user for channel partner
		Test.startTest();
		User channelPartnerUser = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner.Id, true);
		Test.stopTest();

		// case 1: update account of end customer contact
		update new Contact(Id = endCustomerContact.Id, AccountId = accounts[4].Id);

		List<AccountShare> accountShareList = [SELECT Id FROM AccountShare WHERE RowCause = 'Manual'];
		System.assertEquals(0, accountShareList.size(), 'Case 1: No manual account share should created.');

		// case 2: update account of channel partner to account 2
		update new Contact(Id = channelPartner.Id, AccountId = accounts[1].Id);

		accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual'];
		System.assertEquals(1, accountShareList.size(), 'Case 2: account share should created for end customer account 1.');
		System.assertEquals(accounts[3].Id, accountShareList[0].AccountId, 'Case 2: should be shared on end customer account 1');

		// case 3: irrelevant update on channel partner contact record => no changes should be made to sharings
		update new Contact(Id = channelPartner.Id, Title = 'Vice President') ;

		accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual'];
		System.assertEquals(1, accountShareList.size(), 'Case 3: account share should created for end customer account 1.');
		System.assertEquals(accounts[3].Id, accountShareList[0].AccountId, 'Case 3: should be shared on end customer account 1');

		// case 4: update account of channel partner to account 3 => account 2 will become indirectly related
		update new Contact(Id = channelPartner.Id, AccountId = accounts[2].Id);

		accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE UserOrGroupId = :channelPartnerUser.Id];
		System.assertEquals(2, accountShareList.size(), 'Case 3: account share should created for both end customer accounts');
	}

}