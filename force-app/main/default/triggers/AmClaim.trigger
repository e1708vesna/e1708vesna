/**
* @author        : Brite
* @description   :
*/
trigger AmClaim on AmClaim__c (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AmClaimHelper.handleAfterInsertTriggerSharing(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AmClaimHelper.handleAfterUpdateTriggerSharing(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            AmClaimHelper.handleAfterDeleteTriggerSharing(Trigger.old);
        }
        if (Trigger.isUnDelete) {
            AmClaimHelper.handleAfterUndeleteTriggerSharing(Trigger.new);
        }
    }
}