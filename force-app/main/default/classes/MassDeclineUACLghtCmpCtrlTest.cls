@isTest
private class MassDeclineUACLghtCmpCtrlTest {
    
    @isTest
    private static void declineUACBulkTest() {
        
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id rtIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);

        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        License__c lic1 = TestUtil.createLicense('lic1002', acc.Id, true);

        List<License__c> licList = new List<License__c>();
        licList.add(lic);
        licList.add(lic1);

        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(rtIdPendingContract, lic.Id, false);
        UpgradeAssuranceContract__c uac1 = TestUtil.createUpgradeAssuranceContract(rtIdPendingContract, lic1.Id, false);

        List<UpgradeAssuranceContract__c> uacList = new List<UpgradeAssuranceContract__c>();
        uacList.add(uac);
        uacList.add(uac1);

        for(UpgradeAssuranceContract__c item : uacList){
            System.assertEquals(false, item.Declined__c, 'Case 1: Not yet declined');
        }

        Test.startTest();

        MassDeclineUACLghtCmpCtrl.declineUACBulk(uacList);

        Test.stopTest();   

        Set<Id> setId = new Set<Id>(); 
        for(UpgradeAssuranceContract__c i : uacList){
            setId.add(i.Id); 
        }
        
        uacList = [SELECT Id, Declined__c FROM UpgradeAssuranceContract__c WHERE Id IN :setId];  
        for(UpgradeAssuranceContract__c it : uacList){
            System.assertEquals(true, it.Declined__c, 'Case 2: Should be declined');
        }
		
    }

}
