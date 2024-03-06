global class ClaimSharingScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      ClaimSharingBatch b = new ClaimSharingBatch(); 
      database.executebatch(b);
   }
}