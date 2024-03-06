/**
 * @description   : SyncWithNavisionLghtCtrl test class
 * @author (s)    : BRITE
 */
@isTest
public with sharing class SyncWithNavisionLghtCtrlTest {
    @isTest
    public static void testFunctions() {
        new NavisionLicenseAccountBtchSchd().getSchedulerSettings();
        new NavisionLicenseBtchSchd().getSchedulerSettings();
        new NavisionLicenseItemBtchSchd().getSchedulerSettings();

        SyncWithNavisionLghtCtrl.syncWithNavision();
        List<SyncWithNavisionLghtCtrl.SchedBatJob> SchedBatJobList = SyncWithNavisionLghtCtrl.getStatus();
        System.assert(SchedBatJobList.Size() > 0, 'State of the Schedulers is not returned!');
    }
}