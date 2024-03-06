/**
 * @author (s)    : Brite
 * @description   : Trigger on Lead
 */
trigger Lead on Lead (before insert, before update, after update, after insert, after delete, after undelete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadHelper.handleFieldsOnInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            LeadHelper.handleFieldsBeforeConvertion(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LeadHelper.handleFieldsAfterInsert(Trigger.new);
            CustomHistoryUtility.logHistoryAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            LeadHelper.validatePartnerType(Trigger.newMap); //amy
            LeadHelper.handleAfterUpdateTrigger(Trigger.new, Trigger.oldMap);
            CustomHistoryUtility.logHistoryAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete){
            PartnerTypeMergeUtility.afterDeleteMerge(Trigger.old);
            RelationshipMergeUtility.afterDeleteMerge(Trigger.old);
            CustomHistoryUtility.logHistoryAfterDelete(Trigger.old);
        }
        if (Trigger.isUndelete) {
            CustomHistoryHelper.undeleteRelatedCustomHistory(Trigger.newMap.keySet());
        }
    }
}