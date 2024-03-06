/**
 * @description   : Class to test the generic Batchscheduler BtchSchdQueryLocator 
 * @author (s)    : Brite
 */
@isTest
private  class BtchSchdQueryLocatorTest {
    @isTest
    private static void directTest() {
        Test.startTest();
        List<User> userList = [SELECT Id FROM User];
        BtchSchdQueryLocator bs = new BtchSchdQueryLocator ();
        SchedulerSettings__c ss = bs.getSchedulerSettings();
        System.assertEquals('BtchSchdQueryLocator', bs.JOB_NAME_PREFIX, 'Job Name should be the Class Name');
        bs.scheduleWakeup(true);
        Test.stopTest();
    }
/*
    @isTest
    private static void directNoMoreHitsTest() {
        Test.startTest();
        List<User> userList = [SELECT Id FROM User];
        BtchSchdQueryLocator bs = new BtchSchdQueryLocator ();
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
        BtchSchdQueryLocator bs = new BtchSchdQueryLocator ();
        SchedulerSettings__c ss = bs.getSchedulerSettings();
        bs.query = 'FOUT';
        bs.start(null);
        Test.stopTest();
    }
}