/**
* @author Sales
* @group Schedulable
* @description Schedules the batch AccountPlanReviewNotificationScheduler
*/
global with sharing class AccountPlanReviewNotificationScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
        AccountPlanReviewNotificationBatch batch = new AccountPlanReviewNotificationBatch();
        Database.executeBatch(batch, 200);
    }
}