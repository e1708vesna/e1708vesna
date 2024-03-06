/**
 * @author (s)    : Brite
 * @description   : Trigger on ShareOfWallet__c
 */
trigger AccountPlanTrigger on AccountPlan__c (after insert, after update, after undelete, before delete, after delete) {
    
    
    
	if (Trigger.isBefore) {
        if (Trigger.isDelete){
            AccountPlanHelper.beforeDeleteHandler(Trigger.old);
            
        }
    }
	if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AccountPlanHelper.afterInsertHandler(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AccountPlanHelper.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete){
            	AccountPlanHelper.afterDeleteHandler();
        }
        if (Trigger.isUndelete){
            AccountPlanHelper.afterUndeleteHandler(Trigger.new);
        }
    }
}