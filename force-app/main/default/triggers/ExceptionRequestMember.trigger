/**
* @author        : Brite
* @description   :
*/

trigger ExceptionRequestMember on ExceptionRequestMember__c (after insert, after update, after delete, after undelete) {
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ExceptionRequestMemberHelper.handleAfterInsertTriggerSharing(Trigger.new);
        }
        if (Trigger.isUpdate) {
            ExceptionRequestMemberHelper.handleAfterUpdateTriggerSharing(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            ExceptionRequestMemberHelper.handleAfterDeleteTriggerSharing(Trigger.old);
        }
        if (Trigger.isUnDelete) {
            ExceptionRequestMemberHelper.handleAfterUndeleteTriggerSharing(Trigger.new);
        }
    }
}