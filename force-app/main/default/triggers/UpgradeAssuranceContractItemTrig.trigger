/**
 * @description   : Trigger on the UpgradeAssuranceContractItem__c. Business logic in the UpgradeAssuranceContractItemHelper
 * @author (s)    : Brite
 */
trigger UpgradeAssuranceContractItemTrig on UpgradeAssuranceContractItem__c (after insert, after update, after delete) {
    if (!SkipTrigger.UpgradeAssuranceContractItemSkip) {    
        if (trigger.isAfter) {
            if (trigger.isInsert) {
                UpgradeAssuranceContractItemHelper.updatePrices(trigger.new);
            }
            if (trigger.isUpdate) {
                UpgradeAssuranceContractItemHelper.updatePrices(trigger.new);
            }
            if (trigger.isDelete) {
                UpgradeAssuranceContractItemHelper.updatePrices(trigger.old);
            }
        }    
    }
}