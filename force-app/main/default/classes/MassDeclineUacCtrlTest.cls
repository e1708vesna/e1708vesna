@isTest
private  class MassDeclineUacCtrlTest {
    @isTest
    private static void massDeclineConstructorTest(){

        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id rtIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(rtIdPendingContract, lic.Id, false);
        uac.StartDate__c = Date.newInstance(uac.StartDate__c.year(), uac.StartDate__c.month(), 1);
        insert uac;

        /* Set the correct vf page to test */
		PageReference tpageRef = Page.MassDeclineUac;
        Test.setCurrentPage(tpageRef);

        /* initiate the standard Set Controller */
		ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id FROM UpgradeAssuranceContract__c]));
		/* set the selection */  
        setCon.setSelected(new List<UpgradeAssuranceContract__c> {uac});
		/* Initiate the controller class */  
		MassDeclineUacCtrl decuacCtrl = new MassDeclineUacCtrl(setCon);

        /* verify the selectedLeadIds string */
		System.assert(decuacCtrl.selectedIds.contains('{\'sobjectType\': \'UpgradeAssuranceContract__c\',\'Id\': \'' + uac.Id + '\'}'), 'Actual variable selectedIds: ' + decuacCtrl.selectedIds);	
        
        /* check the exception*/
	 	setCon.setSelected(new List<UpgradeAssuranceContract__c> ());
        decuacCtrl = new MassDeclineUacCtrl(setCon);
         
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for (Apexpages.Message msg : msgs) {
            if (msg.getDetail().contains(System.label.NoUacSelected)) {
                b = true;
            }
         }	
        System.assert(b, 'Expected message: No Upgrade Assurance Contract selected.');	
    }
}
