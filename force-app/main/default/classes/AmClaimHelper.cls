public class AmClaimHelper {

    public static void handleAfterInsertTriggerSharing(AmClaim__c[] newRequests){
        AmClaimSharingUtil shareHelper = AmClaimSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        for (AmClaim__c cm : newRequests){
            recordIds.add(cm.Id);
        }
        if (recordIds.size() > 0 ) {
            shareHelper.storeRecords(recordIds);
            shareHelper.commitRecords();
        }
    }
    
    public static void handleAfterUpdateTriggerSharing(AmClaim__c[] newRequests, Map<Id, AmClaim__c> oldClaimsMap){
        AmClaimSharingUtil shareHelper = AmClaimSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (AmClaim__c cm : newRequests){
            //ActualApproverChanged
            if (cm.ActualApproverId__c != oldClaimsMap.get(cm.Id).ActualApproverId__c) {
                recordIds.add(cm.Id);
            }
            //AssignedApproverChanged
            if (cm.AssignedApproverId__c != oldClaimsMap.get(cm.Id).AssignedApproverId__c) {
                recordIds.add(cm.Id);
            }
        }
        if (recordIds.size() > 0 ) {
            shareHelper.storeRecords(recordIds);
            shareHelper.commitRecords();
        }
    }
    
    public static void handleAfterDeleteTriggerSharing(AmClaim__c[] oldClaims){
        //Not really necesarry, as the record is gone anyway
    }
    
    public static void handleAfterUndeleteTriggerSharing(AmClaim__c[] newRequests){
        AmClaimSharingUtil shareHelper = AmClaimSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        for (AmClaim__c cm : newRequests){
            recordIds.add(cm.Id);
        }
        if (recordIds.size() > 0 ) {
            shareHelper.storeRecords(recordIds);
            shareHelper.commitRecords();
        }
    }
}