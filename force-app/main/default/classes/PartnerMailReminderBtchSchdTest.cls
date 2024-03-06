/**
 * @description   : PartnerMailReminderBtchSchdTest test class
 * @author (s)    : BRITE
 */
@isTest
private class PartnerMailReminderBtchSchdTest {
        
    @isTest
    public static void testBatch() {        
        Test.startTest();        
        new PartnerMailReminderBtchSchd().execute(null);        
        Test.stopTest();        
    }   
}