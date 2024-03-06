/**
* @author        : Brite
* @description   :
*/

trigger ExceptionRequest on ExceptionRequest__c (after insert, after update, after delete, after undelete) {
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ExceptionRequestHelper.handleAfterInsertTriggerSharing(Trigger.new);
        }
        if (Trigger.isUpdate) {
            ExceptionRequestHelper.handleAfterUpdateTriggerSharing(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            ExceptionRequestHelper.handleAfterDeleteTriggerSharing(Trigger.old);
        }
        if (Trigger.isUnDelete) {
            ExceptionRequestHelper.handleAfterUndeleteTriggerSharing(Trigger.new);
        }
    }
}