/**
 * @description   : MsDynNedapLicenseHeader test class
 * @author (s)    : BRITE
 */
@isTest
private class NavisionLicenseItemBtchSchdTest {
    
    @testSetup
    public static void setup() {
        Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName('ChannelPartner', Account.getSObjectType());
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());

        List<Account> accountList = new List<Account>();
        accountList.add(new Account (Name = 'ChannelPartner', CustomerCode__c = '00000001', RecordTypeId = recIdChannelPartner));
        accountList.add(new Account (Name = 'EndUser', CustomerCode__c = '90000001', RecordTypeId = recIdEndCustomer));
        insert accountList;
        String artNo = 'art1077';
        String licNbr = 'lic000001';
        String licItemNbr = '9999';
        Decimal orgMsrpPrice = 45.67;

        MSRP__c msrp1 = TestUtil.createMSRP(artNo, 'EUR', orgMsrpPrice, 0, Date.today().addDays(-15), Date.today().addDays(5), true);
        MSRP__c msrp2 = TestUtil.createMSRP('item001', 'EUR', orgMsrpPrice, 0, Date.today().addDays(-15), Date.today().addDays(5), true);
        License__c lic = TestUtil.createLicense (licNbr, accountList[1].Id, true);
        LicenseItem__c licItem = new LicenseItem__c(
                                        Name = licItemNbr,
                                        ArtNo__c = artNo,
                                        InitialQuantity__c = 2.0,
                                        LineNumber__c = 'line1',
                                        LicenseTypeVersion__c = 'v1.0', 
                                        NavisionExternalId__c = licNbr + '_' + licItemNbr,
                                        PriceDate__c = Date.today(),
                                        Quantity__c = 10,
                                        VersionCode__c = 'VC1-0',
                                        License__c = lic.Id,
                                        Item__c = msrp1.Id);
        insert licItem;
    }
    
    @isTest
    public static void testBatch() {
        // This causes a fake response to be generated
        //Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.READMULTIPLE));
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.READMULTIPLE));
        
        List<Account> accountTmpList = [select Id from Account];
        system.assertEquals(2, accountTmpList.Size(), '2 Accounts should exist!');
        
        Test.startTest();
        new NavisionLicenseItemBtchSchd().execute(null);
        Test.stopTest();
        
        List<LicenseItem__c> licenseItemList = [SELECT l.VersionCode__c, l.UnitPrice__c, l.TotalPrice__c, l.SQLTimeStamp__c, l.Quantity__c, l.PriceDate__c, 
                                                        l.NavisionExternalId__c, l.Name, l.LineNumber__c, l.License__c, l.LicenseTypeVersion__c, 
                                                        l.ItemDescription__c, l.InitialQuantity__c, l.Id, l.Currency__c, l.ArticleNumber__c, l.Item__c 
                                                FROM LicenseItem__c l];
        system.debug('licenseItemList: ' + licenseItemList.size());
        system.debug('licenseItem0: ' + licenseItemList[0]);
        system.debug('licenseItem1: ' + licenseItemList[1]);


        System.assertEquals(2, licenseItemList.size(), 'Case1: should match!');

        List<Msrp__c> msrpList = [SELECT Id FROM MSRP__C];
        system.assertNotEquals(null, licenseItemList[0].Item__c, 'Case 2: Should have MSRP for more then 2 items');
        system.assertNotEquals(null, licenseItemList[1].Item__c, 'Case 2: Should have MSRP for more then 2 items');
    }

    @isTest
    public static void deleteNullQuantityBatch() {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.NULLQUANTITY));
        
        List<Account> accountTmpList = [select Id from Account];
        system.assertEquals(2, accountTmpList.Size(), '2 Accounts should exist!');

        List<LicenseItem__c> licenseItemList = [Select l.VersionCode__c, l.UnitPrice__c, l.TotalPrice__c, l.SQLTimeStamp__c, l.Quantity__c, l.PriceDate__c, l.NavisionExternalId__c, l.Name, l.LineNumber__c, l.License__c, l.LicenseTypeVersion__c, l.ItemDescription__c, l.InitialQuantity__c, l.Id, l.Currency__c, l.ArticleNumber__c From LicenseItem__c l];
        System.assertEquals(1, licenseItemList.size(), 'Case1: should match!');

        Test.startTest();
        new NavisionLicenseItemBtchSchd().execute(null);
        Test.stopTest();
        
        licenseItemList = [Select l.VersionCode__c, l.UnitPrice__c, l.TotalPrice__c, l.SQLTimeStamp__c, l.Quantity__c, l.PriceDate__c, l.NavisionExternalId__c, l.Name, l.LineNumber__c, l.License__c, l.LicenseTypeVersion__c, l.ItemDescription__c, l.InitialQuantity__c, l.Id, l.Currency__c, l.ArticleNumber__c From LicenseItem__c l];
        system.debug('licenseItemList: ' + licenseItemList.size());
        System.assertEquals(0, licenseItemList.size(), 'Case1: should match!');
    }

    @isTest
    public static void deleteVersionNotSupportedBatch() {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.VERSIONNOTSUPPORTED));
        
        List<Account> accountTmpList = [select Id from Account];
        system.assertEquals(2, accountTmpList.Size(), '2 Accounts should exist!');

        List<LicenseItem__c> licenseItemList = [Select l.VersionCode__c, l.UnitPrice__c, l.TotalPrice__c, l.SQLTimeStamp__c, l.Quantity__c, l.PriceDate__c, l.NavisionExternalId__c, l.Name, l.LineNumber__c, l.License__c, l.LicenseTypeVersion__c, l.ItemDescription__c, l.InitialQuantity__c, l.Id, l.Currency__c, l.ArticleNumber__c From LicenseItem__c l];
        System.assertEquals(1, licenseItemList.size(), 'Case1: should match!');

        Test.startTest();
        new NavisionLicenseItemBtchSchd().execute(null);
        Test.stopTest();
        
        licenseItemList = [Select l.VersionCode__c, l.UnitPrice__c, l.TotalPrice__c, l.SQLTimeStamp__c, l.Quantity__c, l.PriceDate__c, l.NavisionExternalId__c, l.Name, l.LineNumber__c, l.License__c, l.LicenseTypeVersion__c, l.ItemDescription__c, l.InitialQuantity__c, l.Id, l.Currency__c, l.ArticleNumber__c From LicenseItem__c l];
        system.debug('licenseItemList: ' + licenseItemList.size());
        System.assertEquals(0, licenseItemList.size(), 'Case1: should match!');
    }
}