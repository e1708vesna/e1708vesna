trigger OpportunityLineItem on OpportunityLineItem (after insert, after update, after delete, after undelete) {
	if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CustomHistoryUtility.logHistoryAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {            
            CustomHistoryUtility.logHistoryAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete){
            CustomHistoryUtility.logHistoryAfterDelete(Trigger.old);
            CustomHistoryHelper.deleteRelatedCustomHistory(Trigger.oldMap.keySet());
        }
        if (Trigger.isUndelete) {
            CustomHistoryHelper.undeleteRelatedCustomHistory(Trigger.newMap.keySet());
        }
    }
}