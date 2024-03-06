/**
 * @description   : LicenseItemUpdateBtchSchd test class
 * @author (s)    : BRITE
 */
@isTest
private class LicenseItemUpdateBtchSchdTest {
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
                                	UnitPrice__c = 23.50,
                                	StartDate__c = startDate ) );
    	msrpList.add( new MSRP__c ( ArticleNumber__c = 'art1001',
                                	Currency__c = 'EUR',
                                	MinimumQuantity__c = 5,
                                	Description__c = 'MSRP description art1001',
                                	UnitPrice__c = 23.50,
                                	StartDate__c = startDate ) );
        
		insert msrpList;
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', recIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        
        //Case 1:
        LicenseItem__c lit = TestUtil.createLicenseItem('12345', 'art1001', lic.Id, msrpList[1].Id, true);
        
        List<LicenseItem__c> licItemList = [SELECT Id, Item__c FROM LicenseItem__c];
         
        system.assertEquals(msrpList[2].Id, licItemList[0].Item__c, 'Case 1: Should have changed to MSRP for more then 5 items');
        
        //Case 2:
    	MSRP__c msrpNew = new MSRP__c ( ArticleNumber__c = 'art1001',
                                	Currency__c = 'EUR',
                                	MinimumQuantity__c = 9,
                                	Description__c = 'MSRP description art1001',
                                	UnitPrice__c = 22.50,
                                	StartDate__c = startDate );
        
		insert msrpNew;
        Test.startTest();
        new LicenseItemUpdateBtchSchd().execute(null);	
        Test.stopTest();

        licItemList = [SELECT Id, Item__c FROM LicenseItem__c];
         
        system.assertEquals(msrpNew.Id, licItemList[0].Item__c, 'Case 2: Should have changed to MSRP for more then 9 items');        
    }
}