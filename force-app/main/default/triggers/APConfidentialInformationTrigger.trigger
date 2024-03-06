/**
 * @author (s)    : Brite
 * @description   : Trigger on ShareOfWallet__c
 */
trigger APConfidentialInformationTrigger on APConfidentialInformation__c (after insert, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            APConfidentialInformationHelper.afterInsertHandler(Trigger.new);
        }
        if (Trigger.isUndelete){
            APConfidentialInformationHelper.afterUndeleteHandler(Trigger.new);
        }
    }
}