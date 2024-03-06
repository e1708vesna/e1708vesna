/**
 * @description   : UpgradeAssuranceContractHelper test class
 * @author (s)    : Brite
 */
@isTest
private class UpgradeAssuranceContractHelperTest {
    
    @TestSetup
    static void makeData (){
        List<sObject> efList = Test.loadData(ExportFactor__c.sObjectType, 'ExportFactorTestData');
        System.assert(efList.size() == 24);
        System.assertNotEquals(null, efList[0].Id);

        // create MSRP data
        List<MSRP__c> msrpList = new List<MSRP__c> ();
        msrpList.add(TestUtil.createMSRP('8009600', 'EUR', 100, 0, Date.today().addMonths(-1), Date.today().addMonths(1), false));
        msrpList.add(TestUtil.createMSRP('8012040', 'EUR', 150, 5, Date.today().addMonths(-1), Date.today().addMonths(1), false));
        msrpList.add(TestUtil.createMSRP('8012210', 'EUR', 1000, 0, Date.today().addMonths(-1), Date.today().addMonths(1), false));
        msrpList.add(TestUtil.createMSRP('8112215', 'EUR', 333, 0, Date.today().addMonths(-1), Date.today().addMonths(1), false));
        
        insert msrpList;
    }

    @isTest
    public static void testTotalPrice () {
    	Integer thisYear = Date.today().Year();
    	
        // case 1: Create UpgradeAssuranceContract
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        //Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        
        License__c lic = TestUtil.createLicense('lic1002', acc.Id, true);
        List<LicenseItem__c> licItemList = new List<LicenseItem__c>();
        licItemList.add (new LicenseItem__c(
                                        Name = 'licItemNbr1',
                                        ArtNo__c = '8009600',
                                        InitialQuantity__c = 2.0,
                                        LineNumber__c = 'line1',
                                        LicenseTypeVersion__c = 'v1.0', 
                                        NavisionExternalId__c = 'navId' + Math.random(),
                                        PriceDate__c = Date.today(),
                                        Quantity__c = 100,
                                        VersionCode__c = 'VC1-0',
                                        License__c = lic.Id));

        licItemList.add (new LicenseItem__c(
                                        Name = 'licItemNbr2',
                                        ArtNo__c = '8012040',
                                        InitialQuantity__c = 2.0,
                                        LineNumber__c = 'line2',
                                        LicenseTypeVersion__c = 'v1.0', 
                                        NavisionExternalId__c = 'navId' + Math.random(),
                                        PriceDate__c = Date.today(),
                                        Quantity__c = 10,
                                        VersionCode__c = 'VC1-0',
                                        License__c = lic.Id));

        licItemList.add (new LicenseItem__c(
                                        Name = 'licItemNbr3',
                                        ArtNo__c = '8112215',
                                        InitialQuantity__c = 2.0,
                                        LineNumber__c = 'line3',
                                        LicenseTypeVersion__c = 'v1.0', 
                                        NavisionExternalId__c = 'navId' + Math.random(),
                                        PriceDate__c = Date.today(),
                                        Quantity__c = 1,
                                        VersionCode__c = 'VC1-0',
                                        License__c = lic.Id));
        insert licItemList;

        Test.startTest();
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(rtIdClonedContract, lic.Id, false);
        uac.AdditionalConditions__c = true;
        uac.AdditionalConditionsReason__c = 'Unit Test';
        uac.StartDate__c = Date.newInstance(uac.StartDate__c.year(), uac.StartDate__c.month(), 1);
        insert uac;
        Test.stopTest();

        List<UpgradeAssuranceContractItem__c> uaciList = [SELECT Id, AdjustedUnitPrice__c, AdjustmentReason__c FROM UpgradeAssuranceContractItem__c];
        //one contract disappears after the totals are calculated
        system.assertEquals(2, uaciList.size(), 'Case 1: 2 new Upgrade Assurance Contract items should have been created');

        List<UpgradeAssuranceContract__c> uacNewList = [SELECT Id, RecordTypeId, Stage__c, StartDateLine__c, RecalculatedAdjustedLicenseValue__c, RecalculatedLicenseValue__c FROM UpgradeAssuranceContract__c];
        system.assertEquals(1, uacNewList.size(), 'Case 1: a new Upgrade Assurance Contract should have been created');
        system.assertEquals(6333, uacNewList[0].RecalculatedAdjustedLicenseValue__c, 'Case 1 Price should be Calcualated');
        system.assertEquals(6333, uacNewList[0].RecalculatedLicenseValue__c, 'Case 1: Price should be Calcualated');

        for (UpgradeAssuranceContractItem__c uaci : uaciList) {
            uaci.AdjustedUnitPrice__c = 222;
            uaci.AdjustmentReason__c = 'Unit Test';
        }
        update uaciList;

        uacNewList = [SELECT Id, RecordTypeId, Stage__c, StartDateLine__c, RecalculatedAdjustedLicenseValue__c, RecalculatedLicenseValue__c FROM UpgradeAssuranceContract__c];
        system.assertEquals(1, uacNewList.size(), 'Case 2: a new Upgrade Assurance Contract should have been created');
        system.assertEquals(6222, uacNewList[0].RecalculatedAdjustedLicenseValue__c, 'Case 2: Price should be Calcualated');
        system.assertEquals(6333, uacNewList[0].RecalculatedLicenseValue__c, 'Case 2: Price should be Calcualated');
    }
    
    @isTest
    public static void testIntermediateYears () {
    	Integer thisYear = Date.today().Year();
    	
        // case 1: Create UpgradeAssuranceContract
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        //Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        
        License__c lic = TestUtil.createLicense('lic1002', acc.Id, true);
        List<LicenseItem__c> licItemList = new List<LicenseItem__c>();
        licItemList.add (new LicenseItem__c(
                                        Name = 'licItemNbr1',
                                        ArtNo__c = '8009600',
                                        InitialQuantity__c = 2.0,
                                        LineNumber__c = 'line1',
                                        LicenseTypeVersion__c = 'v1.0', 
                                        NavisionExternalId__c = 'navId' + Math.random(),
                                        PriceDate__c = Date.today(),
                                        Quantity__c = 100,
                                        VersionCode__c = 'VC1-0',
                                        License__c = lic.Id));

        licItemList.add (new LicenseItem__c(
                                        Name = 'licItemNbr2',
                                        ArtNo__c = '8012040',
                                        InitialQuantity__c = 2.0,
                                        LineNumber__c = 'line2',
                                        LicenseTypeVersion__c = 'v1.0', 
                                        NavisionExternalId__c = 'navId' + Math.random(),
                                        PriceDate__c = Date.today(),
                                        Quantity__c = 10,
                                        VersionCode__c = 'VC1-0',
                                        License__c = lic.Id));

        licItemList.add (new LicenseItem__c(
                                        Name = 'licItemNbr3',
                                        ArtNo__c = '8112215',
                                        InitialQuantity__c = 2.0,
                                        LineNumber__c = 'line3',
                                        LicenseTypeVersion__c = 'v1.0', 
                                        NavisionExternalId__c = 'navId' + Math.random(),
                                        PriceDate__c = Date.today(),
                                        Quantity__c = 1,
                                        VersionCode__c = 'VC1-0',
                                        License__c = lic.Id));
        insert licItemList;

        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(rtIdClonedContract, lic.Id, false);
        uac.AdditionalConditions__c = true;
        uac.Stage__c = 'Order';
        uac.AdditionalConditionsReason__c = 'Unit Test';
        //uac.StartDate__c = Date.newInstance(Date.today().year() - 2, Date.today().month(), 1);
        //uac.StartDateLine__c = Date.newInstance(Date.today().year() - 2, Date.today().month(), 1);
        uac.StartDate__c = Date.newInstance(Date.today().year() - 2, 1, 1);
        uac.StartDateLine__c = Date.newInstance(Date.today().year() - 2, 1, 1);
        uac.Approved__c = true;
        uac.recordTypeId = RecordTypeUtil.getRecordTypeIdByDevName('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
        insert uac;
        Test.startTest();
        UpgradeAssuranceContract__c uac2 = TestUtil.createUpgradeAssuranceContract(rtIdClonedContract, lic.Id, false);
        uac2.AdditionalConditions__c = true;
        uac2.AdditionalConditionsReason__c = 'Unit Test';
        //uac2.StartDate__c = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        //uac2.StartDateLine__c = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        uac2.StartDate__c = Date.newInstance(Date.today().year(), 1, 1);
        uac2.StartDateLine__c = Date.newInstance(Date.today().year(), 1, 1);
        uac2.recordTypeId = rtIdClonedContract;
        insert uac2;
        uac2.Approved__c = true;
        uac2.Stage__c = 'Calculation';
        update uac2;
        uac2 = [SELECT Id, IntermediateYears__c FROM UpgradeAssuranceContract__c WHERE Id = :uac2.id];
        System.assertEquals(1, uac2.IntermediateYears__c, 'Expected 1 intermediate year to be present');
        List<UpgradeAssuranceContract__c> allUacList = [Select Id FROM UpgradeAssuranceContract__c];
        System.assertEquals(3, allUacList.size(), 'Expected a total of 3 Upgrade Assurance Contracts');

    }

    @isTest
    private static void testUpdateUACSummaryFieldsOnLicenses() {
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());
        Id rtIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName(UpgradeAssuranceContractHelper.RT_DEV_NAME_PENDING_CONTRACT, UpgradeAssuranceContract__c.getSObjectType());
        
        Account endCustomerAcc = TestUtil.createAccount('endCustomer', recIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', endCustomerAcc.Id, true);

        // case 1: new contract created in stage 'New' => fields should be empty
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(rtIdPendingContract, lic.Id, false);
        uac.AdditionalConditions__c = true;
        uac.AdditionalConditionsReason__c = 'Unit Test';
        uac.StartDate__c = Date.newInstance(Date.today().year(), 1, 1);
        uac.StartDateLine__c = uac.StartDate__c;
        uac.CombinedBillingAmount__c = 150;
        insert uac;

        // UAC should not be active (incorrect record type)
        uac = [SELECT Id, Active__c, Stage__c, RecordTypeId, RequestUnlock__c, StartDateLine__c, EndDateLine__c
        FROM UpgradeAssuranceContract__c 
        WHERE Id = :uac.Id];
        System.assertEquals(false, uac.Active__c, 'UAC is already active');
        System.assert(uac.StartDateLine__c < Date.Today(), 'Start Date Line is not one month ago');
        System.assertNotEquals(null, uac.EndDateLine__c, 'End date line is not populated');
        // UAC summary fields on license should still be empty
        lic = [SELECT Id, TotalUACValue__c, NumberActiveUACs__c, NumberUACs__c, NumberOpenUACs__c, LastActivatedUAC__c 
               FROM License__c
               WHERE Id = :lic.Id];
        System.assertEquals(0, lic.TotalUACValue__c, 'TotalUACValue__c before activation');
        System.assertEquals(0, lic.NumberActiveUACs__c, 'NumberActiveUACs__c before activation');
        System.assertEquals(0, lic.NumberUACs__c, 'NumberUACs__c before activation');
        System.assertEquals(1, lic.NumberOpenUACs__c, 'NumberOpenUACs__c before activation');
        System.assertEquals(null, lic.LastActivatedUAC__c, 'LastActivatedUAC__c before activation');

        // case 2: activate contract => fields should be populated; UAC record updated
        Id activatedContractRt = RecordTypeUtil.getRecordTypeIdByDevName(UpgradeAssuranceContractHelper.RT_DEV_NAME_ACTIVATED_CONTRACT, UpgradeAssuranceContract__c.getSObjectType());
        uac.Stage__c = 'Order';
        uac.RecordTypeId = activatedContractRt;
        uac.Approved__c = true;
        uac.RequestUnlock__c = !uac.RequestUnlock__c;
        update uac;

        // UAC should now be active
        uac = [SELECT Id, RecordTypeId, StartDateLine__c, EndDateLine__c, Active__c FROM UpgradeAssuranceContract__c WHERE Id = :uac.Id];
        System.assertEquals(activatedContractRt, uac.RecordTypeId, 'Record type is not set to Activated_Contract');
        System.assert(uac.StartDateLine__c <= Date.Today(), 'Start Date Line is not one month ago: ' + uac.StartDateLine__c);
        System.assert(uac.EndDateLine__c >= Date.Today(), 'End date line not after today: ' + uac.EndDateLine__c);
        System.assert(uac.Active__c, 'UAC is not active');
        // UAC summary fields on license should be populated 
        lic = [SELECT Id, TotalUACValue__c, NumberActiveUACs__c, NumberUACs__c, NumberOpenUACs__c, LastActivatedUAC__c 
               FROM License__c
               WHERE Id = :lic.Id];
        System.assertEquals(150, lic.TotalUACValue__c, 'TotalUACValue__c after activation');
        System.assertEquals(1, lic.NumberActiveUACs__c, 'NumberActiveUACs__c after activation');
        System.assertEquals(1, lic.NumberUACs__c, 'NumberUACs__c after activation');
        System.assertEquals(0, lic.NumberOpenUACs__c, 'NumberOpenUACs__c after activation');
        System.assertEquals(uac.Id, lic.LastActivatedUAC__c, 'LastActivatedUAC__c after activation');

        // case 3: delete active contract
        delete uac;

        // UAC summary fields on license should set to 0 again 
        lic = [SELECT Id, TotalUACValue__c, NumberActiveUACs__c, NumberUACs__c, LastActivatedUAC__c 
               FROM License__c
               WHERE Id = :lic.Id];
        System.assertEquals(0, lic.TotalUACValue__c, 'TotalUACValue__c after activation');
        System.assertEquals(0, lic.NumberActiveUACs__c, 'NumberActiveUACs__c after activation');
        System.assertEquals(0, lic.NumberUACs__c, 'NumberUACs__c after activation');
        System.assertEquals(null, lic.LastActivatedUAC__c, 'LastActivatedUAC__c after activation');

        // NOTE: test case where contract expires/ends (without un update), cannot be done via unit test
    }

}