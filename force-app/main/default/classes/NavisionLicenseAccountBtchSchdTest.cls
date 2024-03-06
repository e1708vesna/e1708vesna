/**
 * @description   : NavisionLicenseAccountBtchSchd test class
 * @author (s)    : BRITE
 */
@isTest
private class NavisionLicenseAccountBtchSchdTest {
    
    @isTest 
    public static void testBatch() {      
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.READMULTIPLE));
        
        Test.startTest();
        new NavisionLicenseAccountBtchSchd().execute(null);
        Test.stopTest();

        List<Account> accountTmpList = [select Id from Account];
        system.assertEquals(2, accountTmpList.Size(), '2 Accounts should exist!');        
        //System.assertEquals('', accountTmpList[0].Name, 'Case1: should match!');
    }    
}