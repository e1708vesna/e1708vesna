/**
 * @description   : Code coverage Test class for the BatchSchedulerCtrl class
 * 					No business logic to test
 * @author (s)    : Brite
 **/
@isTest
private class BatchSchedulerCtrlTest {
	@isTest
    static void pageFunctionalityTest() {
		BtchSchd bsTmp = new BtchSchd();
		bsTmp.getSchedulerSettings();
        
    	Test.startTest();
    	BatchSchedulerCtrl bs = new BatchSchedulerCtrl();
    	bs.init();
    	
    	List<BatchSchedulerCtrl.schedbatjob> sbjList = bs.getSbj ();
    	system.assertEquals(1, sbjList.size(), 'Only one Batch was setup');
    	
    	bs.inputValue = bsTmp.JOB_NAME_PREFIX;
    	bs.scheduleWakeup();
    	bs.scheduleWakeupDirect();
    	bs.scheduleStop();
    	bs.scheduleSolo();
    	bs.getStatus();
		List<BatchSchedulerCtrl.SchedBatJob> sbj = bs.getSbj();
    	
		sbj[0].getName();
		sbj[0].getState();
		sbj[0].getNextRun();
		sbj[0].getAutoReschedule();
		sbj[0].getMoreHitsAvailableIndicator();
		sbj[0].getLastProcessedDateTime();
		sbj[0].getLastProcessedId();
		sbj[0].getDescription();
		sbj[0].getLinkedScheduler();

    	Test.stopTest();
    	bs.getStatus();
    }
}