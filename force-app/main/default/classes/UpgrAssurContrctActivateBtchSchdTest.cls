/**
 * @description   : Class for testing functionality of Ugrade Assurance Contract Activation batch
 * @author (s)    : BRITE
 */
@isTest
private class UpgrAssurContrctActivateBtchSchdTest {
    
    @testSetup
    public static void setup() {
        // create MSRP data
        List<MSRP__c> msrpList = new List<MSRP__c> ();
        msrpList.add(TestUtil.createMSRP('art1002', 'EUR', 25, 0, Date.today().addMonths(-1), Date.today().addMonths(1), false));
        msrpList.add(TestUtil.createMSRP('art1002', 'EUR', 24, 5, Date.today().addMonths(-1), Date.today().addMonths(1), false));
        msrpList.add(TestUtil.createMSRP('art1002', 'EUR', 23, 0, Date.today().addMonths(3), Date.today().addMonths(5), false));
        msrpList.add(TestUtil.createMSRP('art1003', 'EUR', 15, 0, Date.today().addDays(-20), Date.today().addDays(-5), false));
        msrpList.add(TestUtil.createMSRP('art1003', 'EUR', 20, 0, Date.today().addDays(-2), null, false));
        msrpList.add(TestUtil.createMSRP('art1003', 'GBP', 21, 0, Date.today().addDays(-2), null, false));
        
        insert msrpList;
    }
    
    @isTest
    public static void testActivate () {
    	Integer thisYear = Date.today().Year();
    	
        // case 1: Create UpgradeAssuranceContract
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        //Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        
        //primary test data
        License__c lic = TestUtil.createLicense('lic1002', acc.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear,1,1), Date.newInstance(thisYear,12,31), true);
        MSRP__c msrp2 = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear+1,1,1), Date.newInstance(thisYear+1,12,31), true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(rtIdClonedContract, lic.Id, false);
        uac.AdditionalConditions__c = false;
        uac.StartDate__c = Date.newInstance(uac.StartDate__c.year(), uac.StartDate__c.month(), 1);

        insert uac;
        List<UpgradeAssuranceContract__c> uacNewList = [SELECT Id, RecordTypeId, Stage__c, StartDateLine__c FROM UpgradeAssuranceContract__c];
        system.assertEquals(1, uacNewList.size(), 'Case 1: a new Upgrade Assurance Contract should have been created');
        system.assertEquals('New', uacNewList[0].Stage__c, 'Case 2: Stage should be New');
        system.assertEquals(rtIdClonedContract, uacNewList[0].RecordTypeId, 'Case 2: RecordTypeId should be Pending Contract');
    	system.debug('StartDateLine__c: ' + uacNewList[0].StartDateLine__c);    	

        uacNewList = [SELECT u.Status__c, u.StartDate__c, u.StartDateLine__c, u.Stage__c, u.SignedDate__c, u.SignedBy__c, 
        		u.RecordTypeId, u.Name, u.LineAmount__c, u.LicenseeName__c, u.License__c, u.Invoice__c, u.Id, u.Exception__c, 
        		u.EndDate__c, u.EndDateLine__c, u.EndCustomer__c, u.Email__c, u.ContractDuration__c, u.ChannelPartner__c, 
        		u.Approved__c, u.AdditionalConditions__c, u.AdditionalConditionsReason__c, u.Active__c, 
        		u.AcceptTermsAndConditions__c FROM UpgradeAssuranceContract__c u WHERE RecordTypeId =:rtIdClonedContract AND AdditionalConditions__c = false AND StartDateLine__c = THIS_YEAR];
         
        system.assertEquals(1, uacNewList.size(), 'Case 2: 1 Upgrade Assurance Contract should exist for the where clause');
    	    	
		//Case 2: Activate Upgrade Assurance Contract with the Batch    	    	
    	Test.startTest();
        new UpgrAssurContrctActivateBtchSchd().execute (null);
    	Test.stopTest();
    	
    	Id rtIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
        uacNewList = [SELECT Id, RecordTypeId, Stage__c FROM UpgradeAssuranceContract__c];
        system.assertEquals(1, uacNewList.size(), 'Case 2: 1 Upgrade Assurance Contract should exist');
        system.assertEquals('Order', uacNewList[0].Stage__c, 'Case 2: Stage should have been changed to Order');
        system.assertEquals(rtIdActivatedContract, uacNewList[0].RecordTypeId, 'Case 2: RecordTypeId should be changed to Activated Contract');
	}
}