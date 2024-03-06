/**
 * @description   : Trigger on the License. Business logic in the LicenseHelper
 * @author (s)    : Brite
 */
trigger LicenseTrig on License__c (before update, after insert, after update, after delete) {
    if (!SkipTrigger.LicenseSkip) {  
        try {
            if (trigger.isBefore) {
                if (trigger.isUpdate) {
                    LicenseHelper.updateTotalPrices(trigger.newMap);
                }
            }
            if (trigger.isAfter) {
                if (trigger.isInsert) {
                    LicenseHelper.createAccountSharing(trigger.new);
                }
                if (trigger.isUpdate) {
                    LicenseHelper.recalculateAccountSharing(trigger.new, trigger.oldMap);
                    LicenseHelper.updateFieldsLicenseItem(trigger.new, trigger.oldMap);
                }
                if (trigger.isDelete) {
                    LicenseHelper.deleteAccountSharing(trigger.old);
                }
            } 
        } finally {
            CustomLog.commitLog();
        }
    }
}