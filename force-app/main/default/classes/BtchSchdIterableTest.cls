/**
 * @description   : Class to test the generic Batchscheduler BtchSchdIterable 
 * @author (s)    : Brite
 */
@isTest
private  class BtchSchdIterableTest {
    @isTest
    private static void directMoreHitsTest() {
        Test.startTest();
        List<User> userList = [SELECT Id FROM User];
        BtchSchdIterable bs = new BtchSchdIterable ();
        System.assertEquals('BtchSchdIterable', bs.JOB_NAME_PREFIX, 'Job Name should be the Class Name');
        SchedulerSettings__c ss = bs.getSchedulerSettings();
        ss.MaxProcessItems__c = 1;
        update ss;

        bs.scheduleWakeup(true);
        Test.stopTest();
    }
/*
    @isTest
    private static void directNoMoreHitsTest() {
        Test.startTest();
        List<User> userList = [SELECT Id FROM User];
        BtchSchdIterable bs = new BtchSchdIterable ();
        SchedulerSettings__c ss = bs.getSchedulerSettings();
        ss.MaxProcessItems__c = 10000;
        update ss;

        bs.scheduleWakeup(true);
        Test.stopTest();
    }
*/
    @isTest
    private static void queryErrorTest() {
        Test.startTest();
        List<User> userList = [SELECT Id FROM User];
        BtchSchdIterable bs = new BtchSchdIterable ();
        SchedulerSettings__c ss = bs.getSchedulerSettings();
        bs.query = 'FOUT';
        bs.start(null);
        Test.stopTest();
    }
}