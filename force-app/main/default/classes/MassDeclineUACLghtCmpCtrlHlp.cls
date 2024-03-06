public without sharing class MassDeclineUACLghtCmpCtrlHlp {
    
    /**
     * decline UAC Bulk
     **/
    public static String declineUACBulk (List<UpgradeAssuranceContract__c> upgradeAssuranceContractList, Boolean decline){
        String returnValue = '';

        upgradeAssuranceContractList = [SELECT Id, RequestUnlock__c, RecordTypeId FROM UpgradeAssuranceContract__c WHERE Id IN :upgradeAssuranceContractList];
        Id pendingContractRt = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType()); //Cloned_Contract
        for (UpgradeAssuranceContract__c upgradeAssuranceContract : upgradeAssuranceContractList) {     
            if (upgradeAssuranceContract.RecordTypeId == pendingContractRt) {
                upgradeAssuranceContract.Declined__c = decline; 
                //Set to request temporary unlock. Wil never be saved as set in the data base! Used by automation
                upgradeAssuranceContract.RequestUnlock__c = !upgradeAssuranceContract.RequestUnlock__c;
            }
        }
        try {
            update upgradeAssuranceContractList;
        } catch (Exception ex) {
            returnValue = ex.getMessage();
        }       
        
        return returnValue;
    }
}