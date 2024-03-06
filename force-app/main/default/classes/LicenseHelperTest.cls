/**
 * @description   : LicenseHelper test class
 * @author (s)    : Brite
 */
@isTest
private class LicenseHelperTest {

    @isTest
    private static void testCreateAccountSharing() {
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

        // case 1: no community user related to the channel partner account upon creation of a new license
		List<License__c> licenses = new List<License__c> ();
		// create license between end customer 1 and channel partner 1
		licenses.add(TestUtil.createLicense('lic1001', accounts[2].Id, false));
		licenses[0].ChannelPartner__c = accounts[0].Id;
		// create license between end customer 2 and channel partner 2
		licenses.add(TestUtil.createLicense('lic1002', accounts[3].Id, false));
		licenses[1].ChannelPartner__c = accounts[1].Id;
        insert licenses;
        
		List<AccountShare> accountShareList = [SELECT Id FROM AccountShare WHERE RowCause = 'Manual'];
		System.assertEquals(0, accountShareList.size(), 'Case 1: No manual account shares should created.');

        delete licenses;

		// create community user for channel partner
		Test.startTest();
		User channelPartnerUser = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner.Id, true);
		Test.stopTest();

        // case 2: a community user exist for channel partner account upon creation of a new license
		licenses = new List<License__c> ();
		// create license between end customer 1 and channel partner 1
		licenses.add(TestUtil.createLicense('lic1003', accounts[2].Id, false));
		licenses[0].ChannelPartner__c = accounts[0].Id;
		// create license between end customer 2 and channel partner 2
		licenses.add(TestUtil.createLicense('lic1004', accounts[3].Id, false));
		licenses[1].ChannelPartner__c = accounts[1].Id;
        insert licenses;

		accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' AND UserOrGroupId = :channelPartnerUser.Id];
        System.assertEquals(2, accountShareList.size(), 'Case 2: No manual account shares should created.');
        // license for two different accounts
		System.assertNotEquals(accountShareList[0].AccountId, accountShareList[1].AccountId, 'Case 2: Missing account shares');

        // case 3: second license on the same account (should not create new shares, or run into an error)
		licenses = new List<License__c> ();
		// create license between end customer 1 and channel partner 1
		licenses.add(TestUtil.createLicense('lic1005', accounts[2].Id, false));
		licenses[0].ChannelPartner__c = accounts[0].Id;
		// create license between end customer 2 and channel partner 2
		licenses.add(TestUtil.createLicense('lic1006', accounts[3].Id, false));
		licenses[1].ChannelPartner__c = accounts[1].Id;
        insert licenses;

		accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' AND UserOrGroupId = :channelPartnerUser.Id];
        System.assertEquals(2, accountShareList.size(), 'Case 3: No manual account shares should created.');
        // license for two different accounts
		System.assertNotEquals(accountShareList[0].AccountId, accountShareList[1].AccountId, 'Case 3: Missing account shares');
    }

    @isTest
    private static void testRecalculateAccountSharing() {
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
        Contact channelPartner = TestUtil.createContact('Fred', 'Flatter', 'f.f@somecomp.fake', accounts[0].Id, true);
		// channel partner is indirectly connected to channelPartner2 account
		TestUtil.createIndirectAccountContactRelation(accounts[1].Id, channelPartner.Id, true);

		// create community user for channel partner
		Test.startTest();
		User channelPartnerUser = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner.Id, true);
        Test.stopTest();
        
        License__c lic = TestUtil.createLicense('lic1001', accounts[3].Id, false);
        lic.ChannelPartner__c = accounts[0].Id;
        insert lic;

        // case 1: channel partner on licese changes to indirect channel partner account of the channel partner user
        lic = new License__c(Id = lic.Id, ChannelPartner__c = accounts[1].Id);
        update lic;
        
		List<AccountShare> accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(1, accountShareList.size(), 'Case 1: There should be an accountShare record');
        System.assertEquals(accounts[3].Id, accountShareList[0].AccountId, 'Case 1: AccountId of the AccountShare');

        // case 2: update end customer account on the license
        lic = new License__c(Id = lic.Id, EndCustomer__c = accounts[4].Id);
        update lic;

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(1, accountShareList.size(), 'Case 2: There should be an accountShare record');
        System.assertEquals(accounts[4].Id, accountShareList[0].AccountId, 'Case 2: AccountId of the AccountShare');

        // case 3: irrelevant update on the license; sharing should nog be changed
        lic = new License__c(Id = lic.Id, Additional_Information__c = 'Some information');
        update lic;

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(1, accountShareList.size(), 'Case 3: There should be an accountShare record');
        System.assertEquals(accounts[4].Id, accountShareList[0].AccountId, 'Case 3: AccountId of the AccountShare');

        // case 4: update channel partner account on the license to an account that is not linked to the channel partner user
        lic = new License__c(Id = lic.Id, ChannelPartner__c = accounts[2].Id);
        update lic;

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(0, accountShareList.size(), 'Case 4: There should not be a manual accountShare record');
    }

    @isTest
    private static void testDeleteAccountSharing() {
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

		// create community user for channel partner
		Test.startTest();
		User channelPartnerUser = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner.Id, true);
        Test.stopTest();
        
        List<License__c> licList = new List<License__c> ();
		licList.add(TestUtil.createLicense('lic1001', accounts[2].Id, false));
        licList[0].ChannelPartner__c = accounts[0].Id;
        licList.add(TestUtil.createLicense('lic1002', accounts[2].Id, false));
        licList[1].ChannelPartner__c = accounts[0].Id;
        licList.add(TestUtil.createLicense('lic1003', accounts[3].Id, false));
        licList[2].ChannelPartner__c = accounts[1].Id;
        licList.add(TestUtil.createLicense('lic1004', accounts[3].Id, false));
        licList[3].ChannelPartner__c = accounts[1].Id;
        insert licList;

        List<AccountShare> accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(2, accountShareList.size(), 'Pre-test: There should be an accountShare record for each end customer account');

        // case 1: Delete one license of each end customer account; user is still linked with one license
        delete new List<License__c> {licList[0], licList[2]};

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(2, accountShareList.size(), 'Case 1: There should still be an accountShare record for each end customer account');

        // case 2: Delete the second license from each end customer account
        delete new List<License__c> {licList[1], licList[3]};

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(0, accountShareList.size(), 'Case 2: There should be no more account shares');

        // case 3: mass delete licence on one end customer account
        licList = new List<License__c> ();
		licList.add(TestUtil.createLicense('lic1001', accounts[2].Id, false));
        licList[0].ChannelPartner__c = accounts[0].Id;
        licList.add(TestUtil.createLicense('lic1002', accounts[2].Id, false));
        licList[1].ChannelPartner__c = accounts[0].Id;
        licList.add(TestUtil.createLicense('lic1003', accounts[3].Id, false));
        licList[2].ChannelPartner__c = accounts[1].Id;
        licList.add(TestUtil.createLicense('lic1004', accounts[3].Id, false));
        licList[2].ChannelPartner__c = accounts[1].Id;
        insert licList;

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(2, accountShareList.size(), 'Case 3a: There should be an account share on each end customer account');

        delete licList;

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(0, accountShareList.size(), 'Case 3b: Account shares should be deleted');

        // case 4: delete license from end customer account that doesn't have a manual sharing -> no error should occur, and no change in account shares
        accounts = new List<Account>(); 
    	accounts.add(new Account(Name = 'channelpartner3', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'endCustomer3', RecordTypeId = recIdEndCustomer)); 
        insert accounts;
        
        License__c lic = TestUtil.createLicense('lic1001', accounts[1].Id, false);
        lic.ChannelPartner__c = accounts[0].Id;
        insert lic;

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual' AND AccountId = :accounts[1].Id];
        System.assertEquals(0, accountShareList.size(), 'Case 4a: No manual account share should exist for this new end customer');

        delete lic;

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual' AND AccountId = :accounts[1].Id];
        System.assertEquals(0, accountShareList.size(), 'Case 4b: Still no manual account share should exist for this new end customer');
    }

    @isTest
    private static void testMultipleChannelPartnersSameEndCustomer() {
        // test sharings when multiple channel partners have sold a license to the same end customer
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());

    	List<Account> accounts = new List<Account>(); 
    	accounts.add(new Account(Name = 'channelpartner1', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'channelpartner2', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'endCustomer1', RecordTypeId = recIdEndCustomer)); 
		insert accounts;
		
		// channel partner 1 is directly connected to channelPartner1 account
        Contact channelPartner1 = TestUtil.createContact('Fred', 'Flatter', 'f.f@somecomp.fake', accounts[0].Id, false);
		// channel partner 2 is directly connected to channelPartner2 account
        Contact channelPartner2 = TestUtil.createContact('Wilma', 'Flatter', 'f.f@somecomp.fake', accounts[1].Id, false);
        insert new List<Contact> {channelPartner1, channelPartner2};

		// create community user for channel partner
		Test.startTest();
		User channelPartnerUser1 = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner1.Id, false);
        User channelPartnerUser2 = TestUtil.getCommunityUserForContact('acc2', 'Company', channelPartner2.Id, false);
        insert new List<User> {channelPartnerUser1, channelPartnerUser2};
        Test.stopTest();

        // case 1: create multiple licenses to the same end customer
        List<License__c> licenses = new List<License__c> ();
        licenses.add(TestUtil.createLicense('lic1001', accounts[2].Id, false));
        licenses[0].ChannelPartner__c = accounts[0].Id;
        licenses.add(TestUtil.createLicense('lic1002', accounts[2].Id, false));
        licenses[1].ChannelPartner__c = accounts[1].Id;
        insert licenses;

        List<AccountShare> accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' AND AccountId = :accounts[2].Id];
		System.assertEquals(2, accountShareList.size(), 'Case 1: An account share should be created for each channel partner user');

        // case 2: delete one license
        delete licenses[0];

        accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' AND AccountId = :accounts[2].Id];
		System.assertEquals(1, accountShareList.size(), 'Case 2: One account share should still be there');
		System.assertEquals(channelPartnerUser2.Id, accountShareList[0].UserOrGroupId, 'Case 2: UserOrGroupId');
    }

    @isTest
    private static void testActiveUacLicense() {
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());
        Id uacRecIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());

    	List<Account> accounts = new List<Account>(); 
    	accounts.add(new Account(Name = 'channelpartner1', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'endCustomer1', RecordTypeId = recIdEndCustomer)); 
		insert accounts;
		
		// channel partner 1 is directly connected to channelPartner1 account
        Contact channelPartner1 = TestUtil.createContact('Fred', 'Flatter', 'f.f@somecomp.fake', accounts[0].Id, false);
		// channel partner 2 is directly connected to channelPartner2 account
        Contact channelPartner2 = TestUtil.createContact('Wilma', 'Flatter', 'f.f@somecomp.fake', accounts[1].Id, false);
        insert new List<Contact> {channelPartner1, channelPartner2};

        // create license
        License__c lic = TestUtil.createLicense('lic1001', accounts[1].Id, true);

        UpgradeAssuranceContract__c uac1 = TestUtil.createUpgradeAssuranceContract(uacRecIdActivatedContract, lic.Id, false);
        uac1.AdditionalConditions__c = false;
        uac1.AdditionalConditionsReason__c = '';
        uac1.Stage__c = 'Order';
        uac1.StartDate__c = Date.newInstance(Date.today().year() - 1, 1, 1);
        uac1.StartDateLine__c = Date.newInstance(Date.today().year() - 1, 1, 1);
        //uac1.EndDate__c = ;
        uac1.Approved__c = true;
        insert uac1;

        UpgradeAssuranceContract__c uac2 = TestUtil.createUpgradeAssuranceContract(uacRecIdActivatedContract, lic.Id, false);
        uac2.AdditionalConditions__c = false;
        uac2.AdditionalConditionsReason__c = '';
        uac2.Stage__c = 'Order';
        uac2.StartDate__c = Date.newInstance(Date.today().year(), 1, 1);
        uac2.StartDateLine__c = Date.newInstance(Date.today().year(), 1, 1);
        //uac2.EndDate__c = ;
        uac2.Approved__c = true;
        insert uac2;

        UpgradeAssuranceContract__c uac3 = TestUtil.createUpgradeAssuranceContract(uacRecIdActivatedContract, lic.Id, false);
        uac3.AdditionalConditions__c = false;
        uac3.AdditionalConditionsReason__c = '';
        uac3.Stage__c = 'Order';
        uac3.StartDate__c = Date.newInstance(Date.today().year(), 1, 1);
        uac3.StartDateLine__c = Date.newInstance(Date.today().year() + 1, 1, 1);
        //uac3.EndDate__c = ;
        uac3.Approved__c = true;
        insert uac3;

        lic = [SELECT Id, LastActivatedUAC__c FROM License__c WHERE Id = :lic.Id];
		System.assertEquals(uac2.Id, lic.LastActivatedUAC__c, 'Case 1: UAC 2 should be set');
    }
}