/**
 * @description   : NavisionLicenseBtchSchd test class (MsDynNedapLicenseHeader)
 * @author (s)    : BRITE
 */
@isTest
private class NavisionLicenseBtchSchdTest {
    
    @testSetup
    public static void setup() {
        Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName('ChannelPartner', Account.getSObjectType());
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());

        List<Account> accountList = new List<Account>();
        accountList.add(new Account (Name = 'ChannelPartner', CustomerCode__c = '00000001', RecordTypeId = recIdChannelPartner));
        accountList.add(new Account (Name = 'EndUser', CustomerCode__c = '90000001', RecordTypeId = recIdEndCustomer));
        insert accountList;
    }
    
    @isTest
    public static void testBatch() {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.READMULTIPLE));
        
        List<Account> accountTmpList = [select Id from Account];
        system.assertEquals(2, accountTmpList.Size(), '2 Accounts should exist!');
        
        Test.startTest();
        new NavisionLicenseBtchSchd().execute(null);
        Test.stopTest();
        
        List<License__c> licenseList = [Select l.Version__c, l.VersionDescription__c, l.ValidityPeriodDays__c, l.ValidityDateStart__c, l.ValidityDateEnd__c, l.UpgradeAssuranceContract__c, l.SystemkeyProvider__c, l.SystemModstamp, l.Status__c, l.SQLTimeStamp__c, l.RenewalPeriod__c, l.NumberOfTemporaryLicenses__c, l.NavisionExternalId__c, l.Name, l.LicenseeName__c, l.LicenseValue__c, l.LicenseType__c, l.LicenseTypeVersion__c, l.LicenseTypeCode__c, l.LastViewedDate, l.LastReferencedDate, l.LastModifiedDate, l.LastModifiedById, l.LastActivityDate, l.KeyType__c, l.IsDeleted, l.Imported__c, l.Id, l.ExportDateTime__c, l.EndCustomer__c, l.DateCreationKey__c, l.Currency__c, l.CreatedDate, l.CreatedById, l.ChannelPartner__c, l.Additional_Information__c From License__c l];
        system.debug('licenseList: ' + licenseList.size());
        System.assertEquals(1, licenseList.size(), 'Case1: should match!');
        System.assertEquals('AEOS', licenseList[0].VersionDescription__c, 'Case1: should match!');        
    }

    @isTest
    public static void testDeleteBatch() {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.READMULTIPLE));
        
        List<Account> accountTmpList = [select Id from Account WHERE Name = 'EndUser'];
        License__c lic = TestUtil.createLicense('1lic000002', accountTmpList[0].Id, true);

        //Case 1: check existance
        List<License__c> licenseList = [SELECT name, NavisionExternalId__c FROM License__c WHERE Id = :lic.Id];
        System.assertEquals(1, licenseList.size(), 'Case1: should exist!');

        Test.startTest();
        new NavisionLicenseBtchSchd().execute(null);
        Test.stopTest();

        //Case 2: check delete
        licenseList = [SELECT name, NavisionExternalId__c FROM License__c WHERE Id = :lic.Id];
        System.assertEquals(0, licenseList.size(), 'Case2: should be deleted!');

        licenseList = [Select l.Version__c, l.VersionDescription__c, l.ValidityPeriodDays__c, l.ValidityDateStart__c, l.ValidityDateEnd__c, l.UpgradeAssuranceContract__c, l.SystemkeyProvider__c, l.SystemModstamp, l.Status__c, l.SQLTimeStamp__c, l.RenewalPeriod__c, l.NumberOfTemporaryLicenses__c, l.NavisionExternalId__c, l.Name, l.LicenseeName__c, l.LicenseValue__c, l.LicenseType__c, l.LicenseTypeVersion__c, l.LicenseTypeCode__c, l.LastViewedDate, l.LastReferencedDate, l.LastModifiedDate, l.LastModifiedById, l.LastActivityDate, l.KeyType__c, l.IsDeleted, l.Imported__c, l.Id, l.ExportDateTime__c, l.EndCustomer__c, l.DateCreationKey__c, l.Currency__c, l.CreatedDate, l.CreatedById, l.ChannelPartner__c, l.Additional_Information__c From License__c l];
        system.debug('licenseList: ' + licenseList.size());
        System.assertEquals(1, licenseList.size(), 'Case3: should match!');
        System.assertEquals('AEOS', licenseList[0].VersionDescription__c, 'Case1: should match!');        
    }
}