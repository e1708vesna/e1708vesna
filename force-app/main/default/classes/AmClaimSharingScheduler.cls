global class AmClaimSharingScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      AmClaimSharingBatch b = new AmClaimSharingBatch(); 
      database.executebatch(b);
   }
}