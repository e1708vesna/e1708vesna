@isTest
public class ExceptionRequestSharingSchedulerTest {
    @isTest
    private static void testschedule() {
        
        Test.StartTest();
        ExceptionRequestSharingScheduler sh1 = new ExceptionRequestSharingScheduler();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test ExceptionRequestSharingScheduler', sch, sh1); 
        Test.stopTest(); 
    }
}