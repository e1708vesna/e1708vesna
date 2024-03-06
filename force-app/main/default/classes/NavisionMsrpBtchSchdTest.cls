/**
 * @description   : NavisionMsrpBtchSchd test class
 * @author (s)    : BRITE
 */
@isTest
private class NavisionMsrpBtchSchdTest {
    
    @isTest
    public static void testBatch() {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new MsDynNedapMsrpMock (MsDynNedapMsrpMock.READMULTIPLE));
        
        Test.startTest();        
        new NavisionMsrpBtchSchd().execute(null);
        Test.stopTest();
        
        List<MSRP__c> msrpList = [Select m.Id From MSRP__c m];
        system.debug('msrpList: ' + msrpList.size());
        System.assertEquals(1, msrpList.size(), 'Case1: should match!');
    }
}