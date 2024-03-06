trigger UserTrg on User (after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CustomHistoryUtility.logHistoryAfterInsert(Trigger.new);
            UserTrgHandler.handleSOWSharing(Trigger.newMap, Trigger.oldMap);
        }

        if (Trigger.isUpdate) {
            CustomHistoryUtility.logHistoryAfterUpdate(Trigger.new, Trigger.oldMap);
            UserTrgHandler.handleSOWSharing(Trigger.newMap, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            CustomHistoryUtility.logHistoryAfterDelete(Trigger.old);
            UserTrgHandler.deleteSOWShares(Trigger.oldMap, true);
        }
    }
}