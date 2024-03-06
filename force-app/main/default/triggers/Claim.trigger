/**
* @author        : Brite
* @description   :
*/

trigger Claim on Claim__c (after insert, after update, after delete, after undelete) {
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ClaimHelper.handleAfterInsertTriggerSharing(Trigger.new);
        }
        if (Trigger.isUpdate) {
            ClaimHelper.handleAfterUpdateTriggerSharing(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            ClaimHelper.handleAfterDeleteTriggerSharing(Trigger.old);
        }
        if (Trigger.isUnDelete) {
            ClaimHelper.handleAfterUndeleteTriggerSharing(Trigger.new);
        }
    }
}