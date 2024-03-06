public with sharing class MassDeclineUACLghtCmpCtrl {

    @AuraEnabled
    public static String declineUACBulk (List<UpgradeAssuranceContract__c> upgradeAssuranceContractList) {
        return MassDeclineUACLghtCmpCtrlHlp.declineUACBulk (upgradeAssuranceContractList);
    }
}
