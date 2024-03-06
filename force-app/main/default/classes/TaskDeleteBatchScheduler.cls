/**
 * @description Scheduler Class for the TaskDeleteBatch.
 * @author Brite
 */
global class TaskDeleteBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      TaskDeleteBatch b = new TaskDeleteBatch(); 
      database.executebatch(b);
   }
}