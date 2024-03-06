/**
 * @author (s)    : BRITE
 * @description   : Trigger on the LicenseItem__c. Business logic in the LicenseItemtHelper
 */
trigger LicenseItemTrig on LicenseItem__c (before insert, before update, before delete, after insert, after update, after delete) {
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            LicenseItemHelper.updateArticlePrice(trigger.new, null);
        }
        if (trigger.isUpdate) {
            LicenseItemHelper.updateArticlePrice(trigger.new, trigger.oldMap);
        }
        if (trigger.isDelete) {
            UpgradeAssuranceContractItemHelper.syncUpgradeAssuranceContractItemsDelete(trigger.oldMap);
        }
    }
    
    if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
            UpgradeAssuranceContractItemHelper.syncUpgradeAssuranceContractItems(trigger.new, trigger.oldMap);
            LicenseItemHelper.updatePrices(trigger.new);
        }
        if (trigger.isDelete) {
            LicenseItemHelper.updatePrices(trigger.old);
        }
    }
}