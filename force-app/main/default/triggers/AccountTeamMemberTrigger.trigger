/**
 * @author (s)    : Brite
 * @description   : Trigger on ShareOfWallet__c
 */
trigger AccountTeamMemberTrigger on AccountTeamMember (after insert, after update, after undelete, before delete, after delete) {
    
    
    
    if (Trigger.isBefore) {
        if (Trigger.isDelete){
            AccountTeamMemberTrgHelper.beforeDeleteHandler(Trigger.old);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AccountTeamMemberTrgHelper.afterInsertHandler(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AccountTeamMemberTrgHelper.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete){
            AccountTeamMemberTrgHelper.afterDeleteHandler();
        }
    }
}