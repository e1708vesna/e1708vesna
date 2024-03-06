/**
 * @description   : Trigger on the UpgradeAssuranceContract__c. Business logic in the UpgradeAssuranceContractHelper
 * @author (s)    : Brite
 */
trigger UpgradeAssuranceContractTrig on UpgradeAssuranceContract__c (before insert, before update, before delete, after insert, after update, after delete) {    
    if (!SkipTrigger.UpgradeAssuranceContractSkip) {    
        if (trigger.isBefore) {
            if (trigger.isInsert) {
                UpgradeAssuranceContractHelper.calculateIntermediateYears (trigger.new);
                UpgradeAssuranceContractItemHelper.setOrderNumberName (trigger.new);
            }
            if (trigger.isUpdate) {
                //UpgradeAssuranceContractHelper.calculateIntermediateYears (trigger.new);
                UpgradeAssuranceContractItemHelper.checkRecalculate (trigger.new, trigger.oldMap);
                UpgradeAssuranceContractItemHelper.checkLock (trigger.new, trigger.oldMap);
                UpgradeAssuranceContractItemHelper.setOrderNumberName (trigger.new);
                UpgradeAssuranceContractHelper.updateTotalPrices (trigger.newMap);
            } 
        } else if (trigger.isAfter) {
            if (trigger.isInsert) {
                UpgradeAssuranceContractItemHelper.cloneLicenseItems (trigger.new);
                UpgradeAssuranceContractHelper.updateUACSummaryFieldsOnLicenses(trigger.new, trigger.oldMap);
            }
            if (trigger.isUpdate) {
                UpgradeAssuranceContractItemHelper.recalculateContractItems (trigger.new, trigger.newMap, trigger.oldMap);
                UpgradeAssuranceContractHelper.createIntermediateContracts (trigger.new, trigger.oldMap);
                UpgradeAssuranceContractHelper.updateUACSummaryFieldsOnLicenses(trigger.new, trigger.oldMap);
            }
            if (trigger.isDelete) {
                UpgradeAssuranceContractHelper.updateUACSummaryFieldsOnLicenses(null, trigger.oldMap);
            }
        }
    }
}