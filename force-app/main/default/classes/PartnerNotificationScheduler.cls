/**
* @author Sales
* @group Async - Schedulable
* @description Schedules the batch PartnerNotificationBatch
*/
global class PartnerNotificationScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
        PartnerNotificationBatch batch = new PartnerNotificationBatch();
        Database.executeBatch(batch, 100);
    }
}