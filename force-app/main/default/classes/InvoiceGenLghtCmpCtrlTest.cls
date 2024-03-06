/**
 * @description   : Test functionality of InvoiceGenLghtCmpCtrl class
 * @author (s)    : Brite
 */
@isTest
private class InvoiceGenLghtCmpCtrlTest {
    
    @isTest
    public static void testCreateUpgradeAssuranceContractItem() {
        List<UpgradeAssuranceContractItem__c> resultList;
        // case 3: known contract, but without contract items
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.today(), null, true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        UpgradeAssuranceContractItem__c uacItem = TestUtil.createUpgradeAssuranceContractItem('contract item', uac.Id, licItem.Id, true);

        List<Invoice__c> invoiceList = new List<Invoice__c>();
        invoiceList.add (new Invoice__c (Status__c = 'New'));
        insert invoiceList;

        //uac.Invoice__c = invoiceList[0].Id;
        uac.YourOrder__c = 'Test12345';
        uac.Currency__c = 'EUR';
        update uac;

        uac.Invoice__c = invoiceList[0].Id;
        update uac;

        InvoiceGenLghtCmpCtrl.CsvWrapper csvw = InvoiceGenLghtCmpCtrl.createInvoiceFileApex(invoiceList[0].Id);
        system.assertEquals(9, csvw.title.length(), 'CSV title wrapper is not set');
        system.assert(csvw.csv.contains('Test12345'), 'CSV content YourOrder__c wrapper is not set');

        //Check lock
		List<UpgradeAssuranceContract__c> uacList = [SELECT u.lock__c, u.RequestUnlock__c, Email__c FROM UpgradeAssuranceContract__c u WHERE u.Invoice__c =: invoiceList[0].Id];

        system.assertEquals(true, uacList[0].lock__c, 'Record should be locked');
        //system.assertEquals(false, uacList[0].RequestUnlock__c, 'Request Unlock should be reset');

        try {
            uacList[0].Email__c = 'test@test.nl';
            update uacList[0];
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains('Record is locked!'), 'Record should be locked');
        }

        uacList = [SELECT u.lock__c, u.RequestUnlock__c, Email__c FROM UpgradeAssuranceContract__c u WHERE u.Invoice__c =: invoiceList[0].Id];
        system.assertNotEquals('test@test.nl', uacList[0].Email__c, 'Email should not be changed');

        uacList[0].Email__c = 'test@test.nl';
        uacList[0].RequestUnlock__c = !uacList[0].RequestUnlock__c;
        update uacList[0];

        uacList = [SELECT u.lock__c, u.RequestUnlock__c, Email__c FROM UpgradeAssuranceContract__c u WHERE u.Invoice__c =: invoiceList[0].Id];

        system.assertEquals(true, uacList[0].lock__c, 'Record should be locked');
        system.assertEquals('test@test.nl', uacList[0].Email__c, 'Email should be changed');

    }
}