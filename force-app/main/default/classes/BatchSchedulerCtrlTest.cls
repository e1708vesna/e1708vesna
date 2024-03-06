/**
 * @description   : Code coverage Test class for the BatchSchedulerCtrl class
 * 					No business logic to test
 * @author (s)    : Brite
 **/
@isTest
private class BatchSchedulerCtrlTest {
	final static String JOB_NAME_PREFIX = 'EchoServiceBtchSchd';

	@isTest
    static void pageFunctionalityTest () {
        SchedulerSettings__c ss = TestUtil.createSchedulerSettings('JOB_NAME_PREFIX', true);
        
    	Test.startTest();
    	BatchSchedulerCtrl bs = new BatchSchedulerCtrl ();
    	bs.init();
    	
    	List<BatchSchedulerCtrl.schedbatjob> sbjList = bs.getSbj ();
    	system.assertEquals(1, sbjList.size(), 'Only one Batch was setup');
    	
    	bs.inputValue = JOB_NAME_PREFIX;
    	bs.scheduleWakeup ();
    	bs.scheduleStop ();
    	bs.scheduleSolo ();
    	bs.getStatus();
    	
    	Test.stopTest();
    	bs.getStatus();
    	
    }
}