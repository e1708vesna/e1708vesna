/**
 * @author (s)    : Brite
 * @description   : Trigger on ShareOfWallet__c
 */
trigger ShareOfWalletTrigger on ShareOfWallet__c (after insert, after update, after undelete) {
	if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ShareOfWalletHelper.afterInsertHandler(Trigger.new);
        }
        if (Trigger.isUpdate) {
            ShareOfWalletHelper.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isUndelete){
            ShareOfWalletHelper.afterUndeleteHandler(Trigger.new);
        }
    }
}