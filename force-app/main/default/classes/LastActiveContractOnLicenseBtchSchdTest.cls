/**
 * @description   : LastActiveContractOnLicenseBtchSchd test class
 * @author (s)    : BRITE
 */
@isTest
private class LastActiveContractOnLicenseBtchSchdTest {
    @isTest
    static void schedulerUpdateTest() {
        // temporary stop trigger update
        LicenseHelper.skipUpdateUACSummaryFields = true;

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
        uac2.StartDate__c = Date.today();
        uac2.StartDateLine__c = Date.today();
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

        LicenseHelper.skipUpdateUACSummaryFields = false;

        lic = [SELECT Id, LastActivatedUAC__c FROM License__c WHERE Id = :lic.Id];
		System.assertEquals(null, lic.LastActivatedUAC__c, 'Case 1: UAC 2 should be empty');
         
        Test.startTest();
        new LastActiveContractOnLicenseBtchSchd().execute(null);	
        Test.stopTest();

        lic = [SELECT Id, LastActivatedUAC__c FROM License__c WHERE Id = :lic.Id];
		System.assertEquals(uac2.Id, lic.LastActivatedUAC__c, 'Case 1: UAC 2 should be set');
    }
}