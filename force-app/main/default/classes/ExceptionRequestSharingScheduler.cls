global class ExceptionRequestSharingScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      ExceptionRequestSharingBatch b = new ExceptionRequestSharingBatch(); 
      database.executebatch(b);
   }
}