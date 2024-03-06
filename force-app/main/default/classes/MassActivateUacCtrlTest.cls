/**
 * @description   : Test class for MassActivateUacCtrl
 */
@isTest
public class MassActivateUacCtrlTest {
	
	@isTest
	public static void testActivateUac() {
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
		
		List<Id> selectedList = new List<Id> {uac.Id};
		
		test.startTest();
		
		/* Set the correct vf page to test */
		PageReference tpageRef = Page.MassActivateUac;
	  	Test.setCurrentPage(tpageRef);
		/* initiate the standard Set Controller */
		ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id FROM UpgradeAssuranceContract__c]));
		/* set the selection */  
		setCon.setSelected([SELECT Id FROM UpgradeAssuranceContract__c]); // this method gives selected records
		/* Initiate the controller class */  
		MassActivateUacCtrl aauacCtrl = new MassActivateUacCtrl(setCon);
		
		/* verify the selectedLeadIds string */
		system.assert(aauacCtrl.selectedIds.contains('{\'sobjectType\': \'UpgradeAssuranceContract__c\',\'Id\': \'' + uac.Id + '\'}'), 'Actual variable selectedIds: ' + aauacCtrl.selectedIds);	 	
		//system.assert(aauacCtrl.selectedIds.contains('{\'sobjectType\': \'UpgradeAssuranceContract__c\',\'Id\': \'' + uac2.Id + '\'}'), 'Actual variable selectedIds: ' + aauacCtrl.selectedIds);	 	
	 	
	 	/* check the exception*/
	 	setCon.setSelected(new List<UpgradeAssuranceContract__c> ());
		aauacCtrl = new MassActivateUacCtrl(setCon);
		
		List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;
		for (Apexpages.Message msg : msgs) {
	    	if (msg.getDetail().contains(System.label.NoUacSelected)) {
	    		b = true;
	    	}
		}	
	 	System.assert(b, 'Expected message: No Upgrade Assurance Contract selected.');		
		
		test.stopTest();
	}   
}