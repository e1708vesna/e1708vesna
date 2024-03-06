global class ClaimMemberSharingScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      ClaimMemberSharingBatch b = new ClaimMemberSharingBatch(); 
      database.executebatch(b);
   }
}