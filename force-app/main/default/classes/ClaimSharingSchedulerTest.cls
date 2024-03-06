@isTest
public class ClaimSharingSchedulerTest {
    @isTest
    private static void testschedule() {
        
        Test.StartTest();
        ClaimSharingScheduler sh1 = new ClaimSharingScheduler();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test ClaimSharingScheduler', sch, sh1); 
        Test.stopTest(); 
    }
}