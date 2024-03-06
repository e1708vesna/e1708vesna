@isTest
public class AmClaimSharingSchedulerTest {
    @isTest
    private static void testschedule() {
        
        Test.StartTest();
        AmClaimSharingScheduler sh1 = new AmClaimSharingScheduler();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test AmClaimSharingScheduler', sch, sh1); 
        Test.stopTest(); 
    }
}