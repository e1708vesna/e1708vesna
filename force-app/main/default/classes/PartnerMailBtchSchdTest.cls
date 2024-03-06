/**
 * @description   : PartnerMailBtchSchd test class
 * @author (s)    : BRITE
 */
@isTest
private class PartnerMailBtchSchdTest {
        
    @isTest
    public static void testBatch() {        
        Test.startTest();       
    	new PartnerMailBtchSchd().execute(null);        
        Test.stopTest();
    }   
}