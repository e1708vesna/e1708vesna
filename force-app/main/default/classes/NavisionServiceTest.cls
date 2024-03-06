/**
 * @description   : Class for testing functionality of NavisionService
 * @author (s)    : BRITE
 */
@isTest
private class NavisionServiceTest {
    
    @isTest
    public static void testGetAccountsFromLicenseHeader() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.READMULTIPLE));

        SchedulerSettings__c ss = TestUtil.createSchedulerSettings('NavisionLicenseAccountBtchSchd', true);
        
        Test.startTest();
        List<Account> resultList = (new NavisionService()).getAccountsFromLicenseHeader(ss);
        Test.stopTest();
        
        //system.assertEquals('10000001', ss.LastProcessedId__c, 'SchedulerSettings__c LastProcessedId__c');
        system.assertEquals(2, resultList.size(), '#returned accounts');
        // customer 
        system.assertEquals('Channel Partner', resultList[0].Name, 'Customer - Name');
        system.assertEquals('00000001', resultList[0].CustomerCode__c, 'Customer - CustomerCode__c');
        system.assertEquals(RecordTypeUtil.getRecordTypeIdByDevName('ChannelPartner', Account.getSObjectType()),
                            resultList[0].RecordTypeId, 'Customer - RecordType');
        // end user
        system.assertEquals('EndUser Mock', resultList[1].Name, 'End user - Name');
        system.assertEquals('90000001', resultList[1].CustomerCode__c, 'End user - CustomerCode__c');
        system.assertEquals(RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType()),
                            resultList[1].RecordTypeId, 'End user - RecordType');
    }
    
    @isTest
    public static void testGetLicenseHeader() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.READMULTIPLE));
        
        SchedulerSettings__c ss = TestUtil.createSchedulerSettings('NavisionLicenseBtchSchd', true);
        
        Test.startTest();
        List<License__c> resultList = (new NavisionService()).getLicenseHeader(ss);
        Test.stopTest();
        
        //system.assertEquals('10000001', ss.LastProcessedId__c, 'SchedulerSettings__c LastProcessedId__c');
        system.assertEquals(2, resultList.size(), '#returned licenses');
        
        License__c resultLic = resultList[0];
        system.assertEquals(null, resultLic.EndCustomer__c, 'End customer');
        system.assertNotEquals(null, resultLic.EndCustomer__r, 'End customer');
        system.assertEquals('90000001', resultLic.EndCustomer__r.CustomerCode__c, 'End customer - CustomerCode__c (external ID)');
        system.assertEquals(null, resultLic.ChannelPartner__c, 'Channel partner');
        system.assertNotEquals(null, resultLic.ChannelPartner__r, 'Channel partner');
        system.assertEquals('00000001', resultLic.ChannelPartner__r.CustomerCode__c, 'Channel partner - CustomerCode__c (external ID)');
        system.assertEquals('_blank_', resultLic.Status__c, 'Status__c');
    }

    @isTest
    public static void testNoAeosGetLicenseHeader() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.KEYTYPENOTSUPPORTED));
        
        SchedulerSettings__c ss = TestUtil.createSchedulerSettings('NavisionLicenseBtchSchd', true);
        
        Test.startTest();
        List<License__c> resultList = (new NavisionService()).getLicenseHeader(ss);
        Test.stopTest();
        
        //system.assertEquals('10000001', ss.LastProcessedId__c, 'SchedulerSettings__c LastProcessedId__c');
        system.assertEquals(0, resultList.size(), 'VELOS should not load');
        
    }
    
    @isTest
    public static void testGetLicenseLines() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.READMULTIPLE));
        
        SchedulerSettings__c ss = TestUtil.createSchedulerSettings('NavisionLicenseLineBtchSchd', true);
        
    	Date startDate = Date.today().addDays(-1);
    	List<MSRP__c> msrpList = new List<MSRP__c>(); 
    	msrpList.add( new MSRP__c ( ArticleNumber__c = 'item001',
                                	Currency__c = 'EUR',
                                	MinimumQuantity__c = 0,
                                	Description__c = 'MSRP description item001',
                                	UnitPrice__c = 23.50,
                                	StartDate__c = startDate ) );
    	msrpList.add( new MSRP__c ( ArticleNumber__c = 'item001',
                                	Currency__c = 'GBP',
                                	MinimumQuantity__c = 0,
                                	Description__c = 'MSRP description item001',
                                	UnitPrice__c = 23.50,
                                	StartDate__c = startDate ) );
    	msrpList.add( new MSRP__c ( ArticleNumber__c = 'item001',
                                	Currency__c = 'EUR',
                                	MinimumQuantity__c = 5,
                                	Description__c = 'MSRP description item001',
                                	UnitPrice__c = 23.50,
                                	StartDate__c = startDate ) );
        
		insert msrpList;
        
        Test.startTest();
        List<LicenseItem__c> resultList = (new NavisionService()).getLicenseLines(ss);
        Test.stopTest();
        
        //Case 1:
        //system.assertEquals('10000001', ss.LastProcessedId__c, 'Case 1: SchedulerSettings__c LastProcessedId__c');
        system.assertEquals(1, resultList.size(), 'Case 1: #returned license items');
        
        LicenseItem__c licItem = resultList[0];
        system.assertEquals('lic000001_101', licItem.NavisionExternalId__c, 'Case 1: NavisionExternalId__c');
        system.assertEquals('101', licItem.Name, 'Case 1: Name');
        system.assertEquals(null, licItem.License__c, 'Case 1: License__c');
        system.assertNotEquals(null, licItem.License__r, 'Case 1: License__r');
        system.assertEquals('lic000001', licItem.License__r.Name, 'Case 1: License__r.Name');
        
        //Done in the trigger that does not fire since the method is called directly
        //system.assertEquals(msrpList[0].Id, licItem.Item__c, 'Case 1: Should have MSRP for more then 2 items');
        
    }

    @isTest
    public static void testGetMsrp() {
        Test.setMock(WebServiceMock.class, new MsDynNedapMsrpMock (MsDynNedapMsrpMock.READMULTIPLE));
        
        SchedulerSettings__c ss = TestUtil.createSchedulerSettings('NavisionMsrpBtchSchd', true);
        
        Test.startTest();
        List<MSRP__c> resultList = (new NavisionService()).getMsrp(ss);
        Test.stopTest();
        
        //system.assertEquals('10000001', ss.LastProcessedId__c, 'SchedulerSettings__c LastProcessedId__c');
        system.assertEquals(1, resultList.size(), '#returned MSRP');
        
        MSRP__c resultMsrp = resultList[0];
        system.assertEquals(10.95, resultMsrp.UnitPrice__c, 'Unit price');
    }
    
}