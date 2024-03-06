public with sharing class ApConfidentialInformationCtrl {

    @AuraEnabled(Cacheable=true)
    public static List<UserRecordAccess> getUserRecordAccess(List<Id> sow, String apci) {
        Set<Id> recordIds = new Set<Id>(sow);
        if(String.isNotBlank(apci)) recordIds.add((Id) apci);

        return [SELECT RecordId,
            HasReadAccess
            FROM UserRecordAccess
            WHERE UserId = :UserInfo.getUserId()
            AND RecordId IN :recordIds];
    }

    @AuraEnabled(Cacheable=true)
    public static List<AggregateResult> getShareOfWalletSummary(Id accountPlanId) {
        return [SELECT SUM(CurrentAdyenMarginMonth__c) currentMargin,
            SUM(VolumeMonthOnAdyen__c) volumeMonthAdyen,
            SUM(VolumeMonth__c) volumeMonth
            FROM ShareOfWallet__c
            WHERE AccountPlan__c = :accountPlanId];
    }
}