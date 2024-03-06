/**
 * @description   : Code coverage Test class for the TaskDeleteBatchScheduler class
 * 					No business logic to test
 * @author (s)    : Brite
 **/
@isTest
private class TaskDeleteBatchSchedulerTest {

    static testmethod void test() {       
        
        Test.startTest();
        // Schedule the test job
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('TestMarketoTaskDelete',
                                       CRON_EXP, 
                                       new TaskDeleteBatchScheduler());        
        Test.stopTest();
        
    }
}