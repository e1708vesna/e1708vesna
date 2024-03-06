/**
 * @description   : Account DAO test class
 * @author (s)    : BRITE
 */
@isTest
private class AccountDaoTest {

	@isTest
	private static void testGetByIdWithLicenses() {
		List<Account> resultList;

    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName('ChannelPartner', Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
    	
    	Account channelPartnerAcc = new Account(Name = 'channelpartner', RecordTypeId = recIdChannelPartner);
    	Account endCustomerAcc = new Account(Name = 'endCustomer', RecordTypeId = recIdEndCustomer);
		insert new List<Account> {channelPartnerAcc, endCustomerAcc};

		// case 1: empty set 
		try {
			resultList = AccountDao.getByIdWithLicenses(new Set<Id> {});

			system.assertNotEquals(null, resultList, 'Case 1: result is null');
			system.assertEquals(0, resultList.size(), 'Case 1: number of results');
		} catch (Exception ex) {
			system.assert(false, 'Case 1: empty set paramater failes: ' + ex.getMessage());
		}

		// case 2: without licenses
		resultList = AccountDao.getByIdWithLicenses(new Set<Id> {endCustomerAcc.Id});
		
		system.assertNotEquals(null, resultList, 'Case 2: result is null');
		system.assertEquals(1, resultList.size(), 'Case 2: number of results');
		system.assertEquals(0, resultList[0].LicensesCustomer__r.size(), 'Case 2: number of licenses');

		// case 3 with related license
		License__c lic = TestUtil.createLicense('lic1001', endCustomerAcc.Id, false);
        lic.ChannelPartner__c = channelPartnerAcc.Id;
        insert lic;

		resultList = AccountDao.getByIdWithLicenses(new Set<Id> {endCustomerAcc.Id});
		
		system.assertNotEquals(null, resultList, 'Case 3: result is null');
		system.assertEquals(1, resultList.size(), 'Case 3: number of results');
		system.assertEquals(1, resultList[0].LicensesCustomer__r.size(), 'Case 3: number of licenses');
	}

	/*
    static testMethod void deploymentTest() {
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName('ChannelPartner', Account.getSObjectType());
    	Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
    	
    	Account channelPartnerAcc = new Account(Name = 'channelpartner', RecordTypeId = recIdChannelPartner);
    	insert channelPartnerAcc;
    	
    	Account endCustomerAcc = new Account(Name = 'endCustomer', RecordTypeId = recIdEndCustomer, ChannelPartner__c = channelPartnerAcc.Id);
		insert endCustomerAcc;

		List<Account> accList = [select Id, Name, ChannelPartner__c from Account];
        System.assertEquals(2,accList.size(), '2 Accounts should be created' );
		
    	Set<Id> chnPrtAccIdSet = new Set<Id>();
    	chnPrtAccIdSet.add(channelPartnerAcc.Id);
    	
        List<Account> accountList = AccountDao.getByChannelPartner(chnPrtAccIdSet);
        System.assertEquals(1,accountList.size(), 'One Account Share should be found' );
    }
	*/
}