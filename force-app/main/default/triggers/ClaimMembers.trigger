/**
 * @author        : Brite
 * @description   :
 */

trigger ClaimMembers on ClaimMembers__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
    //System.debug('*** ClaimMembers Trigger: before=' + Trigger.isBefore + '; insert=' + Trigger.isInsert + '; update=' + Trigger.isUpdate);

    //!! Do Not Stop These With TriggerStopper!!
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            
            ClaimMemberHelper.handleAfterInsertTriggerSharing(Trigger.new);
            ClaimMemberHelper.insertDeleteClaimMemberShare(Trigger.new);
        }
        if (Trigger.isUpdate) {
            ClaimMemberHelper.handleAfterUpdateTriggerSharing(Trigger.new, Trigger.oldMap);
            ClaimMemberHelper.updateClaimMemberShare(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            ClaimMemberHelper.handleAfterDeleteTriggerSharing(Trigger.old);
            ClaimMemberHelper.insertDeleteClaimMemberShare(Trigger.old);
        }
        if (Trigger.isUnDelete) {
            ClaimMemberHelper.handleAfterUndeleteTriggerSharing(Trigger.new);
        }
    }

    if (TriggerStopper.stopClaimMembersTrigger) {
        return;
    }


    if (Trigger.isBefore) {
        if (Trigger.isInsert){
            ClaimMemberHelper.handleBeforeInsertTrigger(Trigger.new);
        }
        if (Trigger.isInsert || Trigger.isUpdate) {
            ClaimMemberHelper.handleBeforeTrigger(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isDelete) {
            ClaimMemberHelper.handleAfterDelete(Trigger.old);
        }
    }
}