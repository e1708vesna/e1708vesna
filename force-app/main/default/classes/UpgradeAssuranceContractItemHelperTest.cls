/**
 * @description   : Test functionality of UpgradeAssuranceContractItemHelper class
 * @author (s)    : Brite
 */
@isTest
private class UpgradeAssuranceContractItemHelperTest {
    
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
    public static void testCreateUpgradeAssuranceContractItem() {
        UpgradeAssuranceContract__c uac = new UpgradeAssuranceContract__c();
        uac.Id = 'a041x0000017IlBAAU';
        uac.StartDateLine__c = Date.today();
        
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItem1', 'art1002', 'a011x000000qngpAAA', 'a031x000001Pe8EAAS', false);
        licItem.Id = 'a021x0000010N4YAAU';
        
        UpgradeAssuranceContractItem__c uacItem = UpgradeAssuranceContractItemHelper.createUpgradeAssuranceContractItem(uac, licItem);
        
        system.assertNotEquals(null, uacItem, 'UpgradeAssuranceContractItem is null');
        system.assertEquals(uac.Id, uacItem.UpgradeAssuranceContract__c, 'UpgradeAssuranceContract__c');
        system.assertEquals(uac.StartDateLine__c, uacItem.PriceDate__c, 'PriceDate__c');
        system.assertEquals(licItem.Id, uacItem.LicenseItem__c, 'LicenseItem__c');
        system.assertEquals(licItem.ArtNo__c, uacItem.ArticleNumber__c, 'ArticleNumber__c');
        system.assertEquals(licItem.Currency__c, uacItem.Currency__c, 'Currency__c');
        system.assertEquals(licItem.InitialQuantity__c, uacItem.InitialQuantity__c, 'InitialQuantity__c');
        system.assertEquals(licItem.ItemDescription__c, uacItem.ItemDescription__c, 'ItemDescription__c');
        system.assertEquals(licItem.LineNumber__c, uacItem.LineNumber__c, 'LineNumber__c');
        system.assertEquals(licItem.NavisionExternalId__c, uacItem.NavisionExternalId__c, 'NavisionExternalId__c');
        system.assertEquals(licItem.Quantity__c, uacItem.Quantity__c, 'Quantity__c');
        system.assertEquals(licItem.LicenseTypeVersion__c, uacItem.UpgradeAssuranceContractTypeVersion__c, 'UpgradeAssuranceContractTypeVersion__c');
        system.assertEquals(licItem.VersionCode__c, uacItem.VersionCode__c, 'VersionCode__c');
    }
    
    @isTest
    public static void testCloneLicenseItems() {
        List<UpgradeAssuranceContractItem__c> resultList;
        
        // case 1: empty list check
        try {
            UpgradeAssuranceContractItemHelper.cloneLicenseItems(new List<UpgradeAssuranceContract__c> ());
            
            resultList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
            system.assertEquals(true, resultList.isEmpty(), 'Case 1: result list is not empty');
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // case 2: UpgradeAssuranceContract without items attached to related License record
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
        resultList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
        system.assertEquals(true, resultList.isEmpty(), 'Case 2: result list is not empty');
        
        Test.startTest();

        // case 3: UpgradeAssuranceContract with items attached to related License record AND price known in MSRP
        lic = TestUtil.createLicense('lic1002', acc.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1002', 'EUR', 23.45, 0, Date.today().addMonths(-4), Date.today().addMonths(-3), true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr2', 'art1002', lic.Id, msrp.Id, false);
        licItem.ArtNo__c = 'art1002';
        insert licItem;
        uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, false);
        uac.StartDateLine__c = Date.today();
        
        insert uac;
        
        resultList = [SELECT Id, ArticleNumber__c, PriceDate__c, UnitPrice__c FROM UpgradeAssuranceContractItem__c WHERE UpgradeAssuranceContract__c = :uac.Id];
        
        system.assertEquals(false, resultList.isEmpty(), 'Case 3: result list is empty');
        system.assertEquals(1, resultList.size(), 'Case 3: size resultList');
        
        UpgradeAssuranceContractItem__c uacItem = resultList[0];
        system.assertEquals('art1002', uacItem.ArticleNumber__c, 'Case 3: ArticleNumber__c');
        
        // @TODO    system.assertEquals(uac.StartDateLine__c.Year(), uacItem.PriceDate__c.Year(), 'Case 3: PriceDate__c');
        system.assertEquals(24, uacItem.UnitPrice__c, 'Case 3: UnitPrice__c');
        
        // case 4: UpgradeAssuranceContract with items attached to related License record; no price found in MSRP
        lic = TestUtil.createLicense('lic1004', acc.Id, true);
        msrp = TestUtil.createMSRP('art1004', 'EUR', 23.45, 0, Date.today().addMonths(-12), Date.today().addMonths(-11), true);
        licItem = TestUtil.createLicenseItem('licItemNbr4', 'art1002', lic.Id, msrp.Id, false);
        licItem.ArtNo__c = 'art1004';
        insert licItem;
        uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, false);
        uac.StartDateLine__c = Date.today();
        
        insert uac;
        
        resultList = [SELECT Id, ArticleNumber__c, PriceDate__c, UnitPrice__c FROM UpgradeAssuranceContractItem__c WHERE UpgradeAssuranceContract__c = :uac.Id];
        
        system.assertEquals(false, resultList.isEmpty(), 'Case 4: result list is empty');
        system.assertEquals(1, resultList.size(), 'Case 4: size resultList');
        
        uacItem = resultList[0];
        system.assertEquals('art1004', uacItem.ArticleNumber__c, 'Case 4: ArticleNumber__c');

        system.assertEquals(uac.StartDateLine__c.Year(), uacItem.PriceDate__c.Year(), 'Case 4: PriceDate__c');
        system.assertEquals(null, uacItem.UnitPrice__c, 'Case 4: UnitPrice__c');
        
        Test.stopTest();
        // case 5: UpgradeAssuranceContract with multiple items attached to related License record
        lic = TestUtil.createLicense('lic1005', acc.Id, true);
        msrp = TestUtil.createMSRP('art1005', 'EUR', 23.45, 0, Date.today().addDays(-15), Date.today().addDays(-5), true);
        licItem = TestUtil.createLicenseItem('licItemNbr5.1', 'art1005', lic.Id, msrp.Id, true);
        licItem = TestUtil.createLicenseItem('licItemNbr5.2', 'art1005', lic.Id, msrp.Id, true);
        uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, false);
        uac.StartDateLine__c = Date.today().addDays(2);
        insert uac;
        
        resultList = [SELECT Id, ArticleNumber__c, PriceDate__c, UnitPrice__c FROM UpgradeAssuranceContractItem__c WHERE UpgradeAssuranceContract__c = :uac.Id];
        
        system.assertEquals(false, resultList.isEmpty(), 'Case 5: result list is empty');
        system.assertEquals(2, resultList.size(), 'Case 5: size resultList');
    }

    @isTest
    public static void testRecalculateContractItems() {
        List<UpgradeAssuranceContractItem__c> resultList;
        
        Date dateToday = Date.today();
        Date startDateThisYear = Date.newInstance(dateToday.year(), 1, 1);
        Date endDateThisYear = Date.newInstance(dateToday.year(), 12, 31);
        Date startDateNextYear = Date.newInstance(dateToday.year()+1, 1, 1);
        Date endDateNextYear = Date.newInstance(dateToday.year()+1, 12, 31);
        
        // case 1: null/empty map check
        try {
            UpgradeAssuranceContractItemHelper.recalculateContractItems(new List<UpgradeAssuranceContract__c> (), new Map<Id, UpgradeAssuranceContract__c> (), null);
            UpgradeAssuranceContractItemHelper.recalculateContractItems(new List<UpgradeAssuranceContract__c> (), new Map<Id, UpgradeAssuranceContract__c> (), new Map<Id, UpgradeAssuranceContract__c> ());
            
            resultList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
            system.assertEquals(true, resultList.isEmpty(), 'Case 1: result list is not empty');
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }

        // create upgrade assurance contract record
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
        // case 2: date changed; upgrade assurance contract doesn't have contract items
        uac.StartDateLine__c = uac.StartDateLine__c.addDays(2);
        update uac;
        
        resultList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
        system.assertEquals(true, resultList.isEmpty(), 'Case 2: result list is not empty');
        
        // case 3: UpgradeAssuranceContract with items attached to related License record AND price known in MSRP
        lic = TestUtil.createLicense('lic1002', acc.Id, true);
        
        MSRP__c msrp1 = TestUtil.createMSRP('art1004', 'EUR', 23.45, 0, startDateThisYear, endDateThisYear, true);
        MSRP__c msrp2 = TestUtil.createMSRP('art1004', 'EUR', 23.45, 0, startDateNextYear, endDateNextYear, true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr2', 'art1004', lic.Id, msrp1.Id, false);
        licItem.ArtNo__c = 'art1004';
        insert licItem;
        uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, false);
        uac.StartDateLine__c = Date.today();
        insert uac;
        
        uac.StartDateLine__c = Date.today().addMonths(4);
        update uac;
        
        Test.startTest();
        resultList = [SELECT Id, ArticleNumber__c, PriceDate__c, UnitPrice__c FROM UpgradeAssuranceContractItem__c WHERE UpgradeAssuranceContract__c = :uac.Id];
        
        system.assertEquals(false, resultList.isEmpty(), 'Case 3: result list is empty');
        system.assertEquals(1, resultList.size(), 'Case 3: size resultList');
        
        UpgradeAssuranceContractItem__c uacItem = resultList[0];
        system.assertEquals('art1004', uacItem.ArticleNumber__c, 'Case 3: ArticleNumber__c');
        system.assertEquals(uac.StartDateLine__c.Year(), uacItem.PriceDate__c.Year(), 'Case 3: PriceDate__c');
        system.assertEquals(23.45, uacItem.UnitPrice__c, 'Case 3: UnitPrice__c');
        
        // case 4: start date has been changed, but the contract is active
        Id uacRecIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
        uac.RecordTypeId = uacRecIdActivatedContract;
        uac.ContractDuration__c = 'Perpetual';
        uac.StartDateLine__c = Date.today();
        update uac;
        
        List<UpgradeAssuranceContract__c> uacList = [SELECT Id, Active__c FROM UpgradeAssuranceContract__c WHERE Id = :uac.Id];
        system.assertEquals(true, uacList[0].Active__c, 'Case 4: contract not active');
        
        //uac.StartDateLine__c = uac.StartDateLine__c.addMonths(-3);
        //update uac;
        
        resultList = [SELECT Id, ArticleNumber__c, PriceDate__c, UnitPrice__c FROM UpgradeAssuranceContractItem__c WHERE UpgradeAssuranceContract__c = :uac.Id];
        Test.stopTest();
        
        system.assertEquals(false, resultList.isEmpty(), 'Case 4: result list is empty');
        system.assertEquals(1, resultList.size(), 'Case 4: size resultList');
        
        uacItem = resultList[0];
        system.assertEquals('art1004', uacItem.ArticleNumber__c, 'Case 4: ArticleNumber__c');
        system.assertNotEquals(uac.StartDateLine__c, uacItem.PriceDate__c, 'Case 4: PriceDate__c');
        system.assertEquals(23.45, uacItem.UnitPrice__c, 'Case 4: UnitPrice__c');
    }  
    
    @isTest
    public static void testSyncUpgradeAssuranceContractItems() {
        // case 1: null check
        try {
            UpgradeAssuranceContractItemHelper.syncUpgradeAssuranceContractItems(new List<LicenseItem__c> (), null);
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception Thrown: ' + ex.getMessage());
        }

        // create test data        
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1002', 'EUR', 23.45, 0, Date.today().addDays(-15), Date.today().addDays(-5), true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
        List<UpgradeAssuranceContractItem__c> uacItemList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
        
        system.assertEquals(0, uacItemList.size(), 'Case 2: number of contract items before insert');
        
        // case 2: new license item created
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr2', 'art1002', lic.Id, msrp.Id, true);
        
        uacItemList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
        
        /*Sync disabled DvtH
        system.assertEquals(1, uacItemList.size(), 'Case 2: number of contract items after insert');
        
        // case 3a: update license item - initial quantity
        licItem.InitialQuantity__c = 3;
        update licItem;
        
        uacItemList = [SELECT Id, InitialQuantity__c FROM UpgradeAssuranceContractItem__c];
        system.assertEquals(licItem.InitialQuantity__c, uacItemList[0].InitialQuantity__c, 'Case 3a: InitialQuantity__c');
        
        // case 3b: update license item - initial quantity
        licItem.LineNumber__c = 'new line';
        update licItem;
        
        uacItemList = [SELECT Id, LineNumber__c FROM UpgradeAssuranceContractItem__c];
        system.assertEquals(licItem.LineNumber__c, uacItemList[0].LineNumber__c, 'Case 3b: LineNumber__c');
        */
        // case 3c: update license item - initial quantity
        /* must have trigger on msrp in order to have this work
        msrp.Description__c = 'new description';
        update msrp;
        
        uacItemList = [SELECT Id, ItemDescription__c FROM UpgradeAssuranceContractItem__c];
        system.assertEquals(msrp.Description__c, uacItemList[0].ItemDescription__c, 'Case 3c: ItemDescription__c');
        */
    }  
    
    /* Disabled synchronisation on request 20190924
    @isTest
    public static void testSyncUpgradeAssuranceContractItemsDelete() {
        // case 1: null check
        try {
            UpgradeAssuranceContractItemHelper.syncUpgradeAssuranceContractItemsDelete(null);
            UpgradeAssuranceContractItemHelper.syncUpgradeAssuranceContractItemsDelete(new Map<Id, LicenseItem__c> ());
        } catch (Exception ex) {
            system.assert(false, 'Case 1: Exception thrown: ' + ex.getMessage());
        }
        
        // create test data        
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1002', 'EUR', 23.45, 0, Date.today().addDays(-15), Date.today().addDays(-5), true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr2', 'art1002', lic.Id, msrp.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
        List<UpgradeAssuranceContractItem__c> uacItemList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
        system.assertEquals(1, uacItemList.size(), 'Case 2: number of contract items before delete');

        List<UpgradeAssuranceContract__c> uacList = [SELECT Id, License__r.Name, StartDateLine__c, Name FROM UpgradeAssuranceContract__c];
        system.assertEquals('CUA-' + uacList[0].License__r.Name + '-' + uacList[0].StartDateLine__c.year(), uacList[0].Name, 'Case 3: CUA Name incorrect');
        
        delete licItem;
        
        uacItemList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
        system.assertEquals(0, uacItemList.size(), 'Case 2.2: item not deleted');
    }

    @isTest
    public static void testSyncActivatedUACItems() {
        // create test data        
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Id uacRecIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1002', 'EUR', 23.45, 0, Date.today().addDays(-15), Date.today().addDays(-5), true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
        List<UpgradeAssuranceContractItem__c> uacItemList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
        
        system.assertEquals(0, uacItemList.size(), 'Case 2: number of contract items before insert');
        
        // case 2: new license item created
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr2', 'art1002', lic.Id, msrp.Id, true);
        
        uacItemList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
        
        system.assertEquals(1, uacItemList.size(), 'Case 2: number of contract items after insert');
        
        uac.recordTypeId = uacRecIdActivatedContract;
        update uac;

        // case 3a: update license item - initial quantity
        licItem.InitialQuantity__c = 3;
        update licItem;
        
        uacItemList = [SELECT Id, InitialQuantity__c FROM UpgradeAssuranceContractItem__c];
        system.assertNotEquals(licItem.InitialQuantity__c, uacItemList[0].InitialQuantity__c, 'Case 3a: InitialQuantity__c');

        // case 3: add new license item
        LicenseItem__c licItem2 = TestUtil.createLicenseItem('licItemNbr3', 'art1002', lic.Id, msrp.Id, true);

        uacItemList = [SELECT Id FROM UpgradeAssuranceContractItem__c];
        system.assertEquals(1, uacItemList.size(), 'Case 3: number of contract items after insert should stay the same for activated contract');

    }  
    */

    @isTest
    public static void testRecalulatePriceUacItems() {
        // create test data        
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Id uacRecIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Decimal orgMsrpPrice = 23.45;
        MSRP__c msrp = TestUtil.createMSRP('art1008', 'EUR', orgMsrpPrice, 0, Date.today().addDays(-400), Date.today().addDays(400), true);
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr2', 'art1008', lic.Id, msrp.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
        List<UpgradeAssuranceContractItem__c> uacItemList = [SELECT Id, UnitPrice__c FROM UpgradeAssuranceContractItem__c];        
        system.assertEquals(1, uacItemList.size(), 'Case 1: number of contract items');
        system.assertEquals(msrp.UnitPrice__c, uacItemList[0].UnitPrice__c, 'Case 1: Initial Price from MSRP');

        // case 2: update MSRP
        msrp.UnitPrice__c = 79.17;
        update msrp;

        uacItemList = [SELECT Id, UnitPrice__c FROM UpgradeAssuranceContractItem__c];        
        system.assertEquals(orgMsrpPrice, uacItemList[0].UnitPrice__c, 'Case 2: No update expected, Initial Price from MSRP');

        // case 3: No Recalculate request, update anything
        uac.Email__c = 'test@test.test';
        update uac;
        
        uacItemList = [SELECT Id, UnitPrice__c FROM UpgradeAssuranceContractItem__c];
        system.assertEquals(orgMsrpPrice, uacItemList[0].UnitPrice__c, 'Case 3: No Recalculated Price from MSRP');

        // case 4: Recalculate request
        uac.Recalculate__c = true;
        update uac;
        
        uacItemList = [SELECT Id, UnitPrice__c FROM UpgradeAssuranceContractItem__c];
        system.assertEquals(msrp.UnitPrice__c, uacItemList[0].UnitPrice__c, 'Case 4: Recalculated Price from MSRP');

        // case 5: test Recalulate field reset
        List<UpgradeAssuranceContract__c> uacList = [SELECT Id, Recalculate__c FROM UpgradeAssuranceContract__c];
        system.assertEquals(false, uacList[0].Recalculate__c, 'Case 5: Recalculate field should be reset to false');

}  
}