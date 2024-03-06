/**
 * @description   : Class to test the generic Batchscheduler BtchSchd 
 * @author (s)    : Brite
 */
@isTest
private  class BtchSchdTest {
    @isTest
    private static void directTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
    	BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

        bs.scheduleWakeup(true);
    	Test.stopTest();
    }
	
    @isTest
	private static void moreHitsInErrorTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

		ss.MoreHitsAvailableIndicator__c = true;
		update ss;
		bs.inError = true;
        bs.scheduleWakeup(false);
    	Test.stopTest();
    }

    @isTest
	private static void fixedMonthTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

		ss.MoreHitsAvailableIndicator__c = false;
		ss.AutoReschedule__c = true;
		ss.FixedMonth__c = true;
		update ss;
        bs.scheduleWakeup(false);
    	Test.stopTest();
    }

    @isTest
	private static void fixedDayTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

		ss.MoreHitsAvailableIndicator__c = false;
		ss.AutoReschedule__c = true;
		ss.FixedMonth__c = false;
		ss.FixedDay__c = true;
		update ss;
        bs.scheduleWakeup(false);
    	Test.stopTest();
    }

    @isTest
	private static void fixedTimeTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

		ss.MoreHitsAvailableIndicator__c = false;
		ss.AutoReschedule__c = true;
		ss.FixedMonth__c = false;
		ss.FixedDay__c = false;
		ss.FixedTime__c = true;
		update ss;
        bs.scheduleWakeup(false);
    	Test.stopTest();
    }

    @isTest
	private static void offsetTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

		ss.MoreHitsAvailableIndicator__c = false;
		ss.AutoReschedule__c = true;
		ss.FixedMonth__c = false;
		ss.FixedDay__c = false;
		ss.FixedTime__c = false;
		update ss;
        bs.scheduleWakeup(false);
    	Test.stopTest();
    }

    @isTest
	private static void offsetErrorTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

		ss.MoreHitsAvailableIndicator__c = false;
		ss.AutoReschedule__c = true;
		ss.FixedMonth__c = false;
		ss.FixedDay__c = false;
		ss.FixedTime__c = false;
		ss.RescheduleDelayHours__c = -5;
		update ss;
        bs.scheduleWakeup(false);
    	Test.stopTest();
    }

    @isTest
	private static void constructorExecuteTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

		bs.execute(null, userList);
		system.assertEquals('BtchSchd', bs.JOB_NAME_PREFIX); 
		system.assert(!bs.solo); 
    	Test.stopTest();
    }

    @isTest
	private static void scheduleByClassNameTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

    	bs.scheduleWakeup (bs.JOB_NAME_PREFIX, true);
    	Test.stopTest();
    }

    @isTest
	private static void scheduleByClassNameErrorTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

    	bs.scheduleWakeup ('JamTestJamTestJam', true);
    	Test.stopTest();
    }

    @isTest
	private static void finishTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

		ss.MoreHitsAvailableIndicator__c = false;
		update ss;
    	bs.solo = false;
		bs.finish(null);
    	Test.stopTest();
    }

    @isTest
	private static void stopSoloTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

    	bs.scheduleStop();
    	bs.scheduleSolo();
    	Test.stopTest();
    }

    @isTest
	private static void forseStopTest() {
    	Test.startTest();
		List<User> userList = [SELECT Id FROM User];
		BtchSchd bs = new BtchSchd ();
		SchedulerSettings__c ss = bs.getSchedulerSettings();

		ss.MoreHitsAvailableIndicator__c = false;
		ss.AutoReschedule__c = true;
		ss.FixedMonth__c = false;
		ss.FixedDay__c = false;
		ss.FixedTime__c = false;
		update ss;
        bs.scheduleWakeup(false);
    	bs.scheduleStop();
    	Test.stopTest();
    }
}