/**
 * @description   : LicenseItemHelper test class
 * @author (s)    : BRITE
 */
@isTest
private class LicenseItemHelperTest {
	
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
    static void unitPriceSetTest() {
    	Date startDate = Date.today().addDays(-1);
    	List<MSRP__c> msrpList = new List<MSRP__c>(); 
    	msrpList.add( new MSRP__c ( ArticleNumber__c = 'art1001',
                                	Currency__c = 'EUR',
                                	MinimumQuantity__c = 0,
                                	Description__c = 'MSRP description art1001',
                                	UnitPrice__c = 23.50,
                                	StartDate__c = startDate ) );
    	msrpList.add( new MSRP__c ( ArticleNumber__c = 'art1001',
                                	Currency__c = 'GBP',
                                	MinimumQuantity__c = 0,
                                	Description__c = 'MSRP description art1001',
                                	UnitPrice__c = 13.50,
                                	StartDate__c = startDate ) );
    	msrpList.add( new MSRP__c ( ArticleNumber__c = 'art1001',
                                	Currency__c = 'EUR',
                                	MinimumQuantity__c = 5,
                                	Description__c = 'MSRP description art1001',
                                	UnitPrice__c = 22.50,
                                	StartDate__c = startDate ) );
                
		insert msrpList;
		
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', recIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        
        //Case 1:
        LicenseItem__c lit = TestUtil.createLicenseItem('12345', 'art1001', lic.Id, msrpList[1].Id, true);
        
        List<LicenseItem__c> licItemList = [SELECT Id, Item__c FROM LicenseItem__c];
         
        system.assertEquals(msrpList[2].Id, licItemList[0].Item__c, 'Case 1: Should have changed to MSRP for more then 5 items');
    	
    }

    @isTest
    public static void testTotalPrice () {
    	Integer thisYear = Date.today().Year();
    	
		Test.startTest();
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
                                        Quantity__c = 100,	//100
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
                                        Quantity__c = 10,	//150
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
                                        Quantity__c = 1,	//333
                                        VersionCode__c = 'VC1-0',
                                        License__c = lic.Id));
        insert licItemList;
		Test.stopTest();

        List<License__c> licList = [SELECT Id, LicenseValue__c, LicenseOrgValue__c FROM License__c];

        system.assertEquals(6333, licList[0].LicenseValue__c, 'Case 1: Price should be Calcualated');
        system.assertEquals(11833, licList[0].LicenseOrgValue__c, 'Case 1: Price should be Calcualated');
    }
}