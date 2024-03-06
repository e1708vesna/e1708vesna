/**
 * @description   : AccountContactRelationHelper test class
 * @author (s)    : Brite
 */
@isTest
private class AccountContactRelationHelperTest {

    @isTest
    private static void testCreateAccountSharing() {
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());

    	List<Account> accounts = new List<Account>(); 
    	accounts.add(new Account(Name = 'channelpartner1', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'channelpartner2', RecordTypeId = recIdChannelPartner)); // no license linked
		accounts.add(new Account(Name = 'channelpartner3', RecordTypeId = recIdChannelPartner)); // license linked
		accounts.add(new Account(Name = 'channelpartner4', RecordTypeId = recIdChannelPartner)); // no license linked
		accounts.add(new Account(Name = 'channelpartner5', RecordTypeId = recIdChannelPartner)); // license linked
		accounts.add(new Account(Name = 'endCustomer3', RecordTypeId = recIdEndCustomer)); 
		accounts.add(new Account(Name = 'endCustomer5', RecordTypeId = recIdEndCustomer)); 
		insert accounts;
		
		List<License__c> licenses = new List<License__c> ();
		// create license between end customer 3 and channel partner 3
		licenses.add(TestUtil.createLicense('lic1001', accounts[5].Id, false));
		licenses[0].ChannelPartner__c = accounts[2].Id;
		// create license between end customer 5 and channel partner 5
		licenses.add(TestUtil.createLicense('lic1002', accounts[6].Id, false));
		licenses[1].ChannelPartner__c = accounts[4].Id;
        insert licenses;

		// channel partner is directly connected to channelPartner1 account
        Contact channelPartner = TestUtil.createContact('Fred', 'Flatter', 'f.f@somecomp.fake', accounts[0].Id, true);
        
        // case 1: no community user + link to a channel partner without a license
		TestUtil.createIndirectAccountContactRelation(accounts[1].Id, channelPartner.Id, true);
        
        List<AccountShare> accountShareList = [SELECT Id FROM AccountShare WHERE RowCause = 'Manual'];
		System.assertEquals(0, accountShareList.size(), 'Case 1: No manual account shares should be created.');

        // case 2: no community user + link to a channel partner with a license
		TestUtil.createIndirectAccountContactRelation(accounts[2].Id, channelPartner.Id, true);

        accountShareList = [SELECT Id FROM AccountShare WHERE RowCause = 'Manual'];
		System.assertEquals(0, accountShareList.size(), 'Case 2: No manual account shares should be created.');
        
		// create community user for channel partner
		Test.startTest();
		User channelPartnerUser = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner.Id, true);
		Test.stopTest();

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(1, accountShareList.size(), 'After User Creation: One manual account share should be created.');
        System.assertEquals(accounts[5].Id, accountShareList[0].AccountId, 'After User Creation: Linked account');

        // case 3: community user + link to a channel partner without a license
        TestUtil.createIndirectAccountContactRelation(accounts[3].Id, channelPartner.Id, true);

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(1, accountShareList.size(), 'Case 3: No new manual account share should be created.');
        System.assertEquals(accounts[5].Id, accountShareList[0].AccountId, 'Case 3: Linked account');

        // case 4: community user + link to a channel partner with a license
        TestUtil.createIndirectAccountContactRelation(accounts[4].Id, channelPartner.Id, true);

        accountShareList = [SELECT Id FROM AccountShare WHERE RowCause = 'Manual' AND AccountId = :accounts[6].Id];
        System.assertEquals(1, accountShareList.size(), 'Case 4: One new account share should be created.');
    }

    @isTest
    private static void testDeleteAccountSharing() {
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());

    	List<Account> accounts = new List<Account>(); 
    	accounts.add(new Account(Name = 'channelpartner1', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'channelpartner2', RecordTypeId = recIdChannelPartner)); // no license linked
		accounts.add(new Account(Name = 'channelpartner3', RecordTypeId = recIdChannelPartner)); // license linked
		accounts.add(new Account(Name = 'channelpartner4', RecordTypeId = recIdChannelPartner)); // no license linked
		accounts.add(new Account(Name = 'channelpartner5', RecordTypeId = recIdChannelPartner)); // license linked
		accounts.add(new Account(Name = 'endCustomer3', RecordTypeId = recIdEndCustomer)); 
		accounts.add(new Account(Name = 'endCustomer5', RecordTypeId = recIdEndCustomer)); 
		insert accounts;
		
		List<License__c> licenses = new List<License__c> ();
		// create license between end customer 3 and channel partner 3
		licenses.add(TestUtil.createLicense('lic1001', accounts[5].Id, false));
		licenses[0].ChannelPartner__c = accounts[2].Id;
		// create license between end customer 5 and channel partner 5
		licenses.add(TestUtil.createLicense('lic1002', accounts[6].Id, false));
		licenses[1].ChannelPartner__c = accounts[4].Id;
        insert licenses;

		// channel partner is directly connected to channelPartner1 account
        Contact channelPartner = TestUtil.createContact('Fred', 'Flatter', 'f.f@somecomp.fake', accounts[0].Id, true);
        
        // create indirect account relations
        List<AccountContactRelation> relations = new List<AccountContactRelation> ();
        relations.add(TestUtil.createIndirectAccountContactRelation(accounts[1].Id, channelPartner.Id, false));
        relations.add(TestUtil.createIndirectAccountContactRelation(accounts[2].Id, channelPartner.Id, false));
        relations.add(TestUtil.createIndirectAccountContactRelation(accounts[3].Id, channelPartner.Id, false));
        relations.add(TestUtil.createIndirectAccountContactRelation(accounts[4].Id, channelPartner.Id, false));
        insert relations;

        List<AccountShare> accountShareList = [SELECT Id FROM AccountShare WHERE RowCause = 'Manual'];
		System.assertEquals(0, accountShareList.size(), 'Pre test: No manual account shares should be created.');

        // case 1: no community user; delete relationship with a channel partner that doesn't have a license connected
        delete relations[0];

        // case 2: no community user; delete relationship with a channel partner that does have a license connected
        delete relations[1];

		// create community user for channel partner
		Test.startTest();
		User channelPartnerUser = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner.Id, true);
		Test.stopTest();

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(1, accountShareList.size(), 'After User Creation: One manual account share should be created.');
        System.assertEquals(accounts[6].Id, accountShareList[0].AccountId, 'After User Creation: Linked account');

        // case 3: community user; delete relationship with a channel partner that doesn't have a license connected
        delete relations[2];

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(1, accountShareList.size(), 'Case 3: Account share should still be there.');

        // case 4: community user; delete relationship with a channel partner that does have license connected
        delete relations[3];

        accountShareList = [SELECT Id, AccountId FROM AccountShare WHERE RowCause = 'Manual'];
        System.assertEquals(0, accountShareList.size(), 'Case 4: No manual account share should exist.');
    }

    @isTest
    private static void testMultipleChannelPartnersSameEndCustomer() {
        // test sharings when multiple channel partners have sold a license to the same end customer, 
        // but channel partner user is connected to both channel partner accounts
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());

    	List<Account> accounts = new List<Account>(); 
    	accounts.add(new Account(Name = 'channelpartner1', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'channelpartner2', RecordTypeId = recIdChannelPartner)); 
		accounts.add(new Account(Name = 'endCustomer1', RecordTypeId = recIdEndCustomer)); 
		insert accounts;
		
		// channel partner is directly connected to channelPartner1 account
        Contact channelPartner = TestUtil.createContact('Fred', 'Flatter', 'f.f@somecomp.fake', accounts[0].Id, true);
        // channel partner user is indirectly connect to channelPartner2 account
        AccountContactRelation relation = TestUtil.createIndirectAccountContactRelation(accounts[1].Id, channelPartner.Id, true);

		// create community user for channel partner
		Test.startTest();
		User channelPartnerUser = TestUtil.getCommunityUserForContact('acc1', 'Company', channelPartner.Id, true);
        Test.stopTest();

        List<License__c> licenses = new List<License__c> ();
        licenses.add(TestUtil.createLicense('lic1001', accounts[2].Id, false));
        licenses[0].ChannelPartner__c = accounts[0].Id;
        licenses.add(TestUtil.createLicense('lic1002', accounts[2].Id, false));
        licenses[1].ChannelPartner__c = accounts[1].Id;
        insert licenses;

        System.assertEquals(2, [SELECT Id FROM License__c].size(), 'Number of licenses');

        List<AccountShare> accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' AND AccountId = :accounts[2].Id];
		System.assertEquals(1, accountShareList.size(), 'Pre test: An account share should be created on the end customer account');

        // case 1: delete license with the channel partner account that is directly linked to the channel partner user
        delete licenses[0];

        accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' AND AccountId = :accounts[2].Id];
        System.assertEquals(1, accountShareList.size(), 'Case 1: One account share should still be there');
        
        undelete licenses[0];
        
        // case 2: delete license with the chanenl partner account that is indirectly linked to the channel partner user
        delete licenses[1];

        accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' AND AccountId = :accounts[2].Id];
        System.assertEquals(1, accountShareList.size(), 'Case 2: One account share should still be there');

        undelete licenses[1];

        // case 3: delete indirect relationship; account share should still be there
        delete relation;

        accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' AND AccountId = :accounts[2].Id];
        System.assertEquals(1, accountShareList.size(), 'Case 3: One account share should still be there');
    }    

}