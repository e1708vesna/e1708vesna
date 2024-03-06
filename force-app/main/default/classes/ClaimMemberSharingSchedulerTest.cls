@isTest
public class ClaimMemberSharingSchedulerTest {
    @isTest
    private static void testschedule() {
        
        Test.StartTest();
        ClaimMemberSharingScheduler sh1 = new ClaimMemberSharingScheduler();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test ClaimMemberSharingScheduler', sch, sh1); 
        Test.stopTest(); 
    }
}