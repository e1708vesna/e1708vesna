/**
 * @description   : Controller Class helper for the lightning TermsConditions page to ignore the record lock
 * @author (s)    : Brite
 */
global without sharing class DeclineUACLghtCmpCtrlHlp {
    /**
     * decline UAC
     **/
    public static void declineUAC (UpgradeAssuranceContract__c upgradeAssuranceContract, boolean decline) {
        Id clonedContractRt = RecordTypeUtil.getRecordTypeIdByDevName('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());

        if (upgradeAssuranceContract.RecordTypeId == clonedContractRt) {
            upgradeAssuranceContract.Declined__c = decline; 
            upgradeAssuranceContract.RequestUnlock__c = !upgradeAssuranceContract.RequestUnlock__c;
            update upgradeAssuranceContract;
        }
    }  
    
}