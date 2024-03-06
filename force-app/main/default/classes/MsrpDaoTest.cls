/**
 * @description   : MSRP DAO Test class for retrieving MSRP data from the database.
 * @author (s)    : BRITE
 */
@isTest
private class MsrpDaoTest {
    
    @testSetup
    public static void setup() {
        Date startDate = Date.today().addDays(-2);
        Date endDate = Date.today().addDays(2);

        Date startDateOld = Date.today().addDays(-20);
        Date endDateOld = Date.today().addDays(-10);
    
        List<MSRP__c> msrpList = new List<MSRP__c>();
        msrpList.add(new MSRP__c(UnitPrice__c = 1.25, StartDate__c = null, SQLTimeStamp__c = 1, 
                NavisionMsrpNumber__c = '1001', MinimumQuantity__c = 1, EndDate__c = endDate,  
                Description__c = 'Acces port type 1',   Description2__c = 'No specials', Currency__c = 'EUR', 
                ArticleNumber__c = '801001'));
        msrpList.add(new MSRP__c(UnitPrice__c = 2.25, StartDate__c = startDate, SQLTimeStamp__c = 2, 
                NavisionMsrpNumber__c = '1002', MinimumQuantity__c = 1, EndDate__c = endDate,  
                Description__c = 'Acces port type 2',   Description2__c = 'No specials', Currency__c = 'EUR', 
                ArticleNumber__c = '801002'));
        msrpList.add(new MSRP__c(UnitPrice__c = 1.25, StartDate__c = startDateOld, SQLTimeStamp__c = 3, 
                NavisionMsrpNumber__c = '1003', MinimumQuantity__c = 1, EndDate__c = endDateOld,  
                Description__c = 'Acces port type 1',   Description2__c = 'No specials', Currency__c = 'EUR', 
                ArticleNumber__c = '801001'));
        insert msrpList;
    }

    @isTest
    static void generalTest() {
    	List<MSRP__c> msrpList = [SELECT Id, ArticleNumber__c FROM MSRP__c];
    	Set<String> artNumSet = new Set<String>();
    	for (MSRP__c msrp : msrpList) {
    		artNumSet.add(msrp.ArticleNumber__c);
    	}
    	
    	//Case1: Get all Msrp by article number set for de date today 
		List<MSRP__c> msrpResultList = MsrpDao.getByArticleNumber(artNumSet);
		system.assertEquals(3, msrpResultList.size(), 'Case1: All msrp records should return');
			
     	//Case2: Get all Msrp by article number set for de date today 
		msrpResultList = MsrpDao.getByArticleNumberToday(artNumSet);
		system.assertEquals(1, msrpResultList.size(), 'Case2: Only 1 valid msrp record should return');
        
    	Set<Id> idSet = new Set<Id>();
		idSet.add(msrpList[0].Id);
		
    	msrpResultList = MsrpDao.getByIdSet(idSet);
		system.assertEquals(1, msrpResultList.size(), 'Case3: Only 1 valid msrp record should return');
        
    }
    
    @isTest
    public static void testGetByArticleNumberAndMinStartDate() {
        Date startDate = Date.today();

        List<MSRP__c> resultList;
        // case 1: empty set check
        resultList = MsrpDao.getByArticleNumberAndMinStartDate(new Set<String> (), startDate);
        system.assertNotEquals(null, resultList, 'Case 1: result list is null');
        system.assertEquals(0, resultList.size(), 'Case 1: size resultList');
                
        // case 2: article number not known
        resultList = MsrpDao.getByArticleNumberAndMinStartDate(new Set<String> {'801005'}, startDate);
        system.assertNotEquals(null, resultList, 'Case 2: result list is null');
        system.assertEquals(0, resultList.size(), 'Case 2: size resultList');
        
        // case 3: article number known, but outside defined date
        resultList = MsrpDao.getByArticleNumberAndMinStartDate(new Set<String> {'801002'}, startDate.addDays(-52));
        system.assertNotEquals(null, resultList, 'Case 3: result list is null');
        system.assertEquals(0, resultList.size(), 'Case 3: size resultList');
        
        // case 4: article number known and inside defined min date
        resultList = MsrpDao.getByArticleNumberAndMinStartDate(new Set<String> {'801002'}, startDate);
        system.assertNotEquals(null, resultList, 'Case 4: result list is null');
        system.assertEquals(1, resultList.size(), 'Case 4: size resultList');
    }
    
}