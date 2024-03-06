public class ExceptionRequestHelper {

    public static void handleAfterInsertTriggerSharing(ExceptionRequest__c[] newRequests){
        ExceptionRequestSharingUtil shareHelper = ExceptionRequestSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ExceptionRequest__c cm : newRequests){
            recordIds.add(cm.Id);
            if (cm.Account__c != null){
                accountIds.add(cm.Account__c);
            }
        }
        recordIds.addAll((new Map<Id,ExceptionRequest__c>([SELECT Id FROM ExceptionRequest__c WHERE Account__c in: accountIds])).keySet());
        if (recordIds.size() > 0 ) {
            shareHelper.storeRecords(recordIds);
            shareHelper.commitRecords();
        }
    }
    
    public static void handleAfterUpdateTriggerSharing(ExceptionRequest__c[] newRequests, Map<Id, ExceptionRequest__c> oldClaimsMap){
        ExceptionRequestSharingUtil shareHelper = ExceptionRequestSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ExceptionRequest__c cm : newRequests){
            
            Id oldAccountId = cm.Account__c;
            id newAccountId = oldClaimsMap.get(cm.Id).Account__c;
            if (newAccountId != oldAccountId){
                if (newAccountId != null){
                    accountIds.add(newAccountId);
                }
                if (oldAccountId != null){
                    accountIds.add(oldAccountId);
                }
                recordIds.add(cm.Id);
            }
            //ActualApproverChanged
            if (cm.ActualApproverId__c != oldClaimsMap.get(cm.Id).ActualApproverId__c) {
                System.debug('ActualApprovedId has changed');
                accountIds.add(newAccountId);
                recordIds.add(cm.Id);
            }
            //AssignedApproverChanged
            if (cm.AssignedApproverId__c != oldClaimsMap.get(cm.Id).AssignedApproverId__c) {
                accountIds.add(newAccountId);
                recordIds.add(cm.Id);
            }
        }
        recordIds.addAll((new Map<Id,ExceptionRequest__c>([SELECT Id FROM ExceptionRequest__c WHERE Account__c in: accountIds])).keySet());
        if (recordIds.size() > 0 ) {
            shareHelper.storeRecords(recordIds);
            shareHelper.commitRecords();
        }
    }
    
    public static void handleAfterDeleteTriggerSharing(ExceptionRequest__c[] oldClaims){
        ExceptionRequestSharingUtil shareHelper = ExceptionRequestSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ExceptionRequest__c cm : oldClaims){
            if (cm.Account__c != null){
                accountIds.add(cm.Account__c);
            }
        }
        recordIds.addAll((new Map<Id,ExceptionRequest__c>([SELECT Id FROM ExceptionRequest__c WHERE Account__c in: accountIds])).keySet());
        if (recordIds.size() > 0 ) {
            shareHelper.storeRecords(recordIds);
            shareHelper.commitRecords();
        }
    }
    
    public static void handleAfterUndeleteTriggerSharing(ExceptionRequest__c[] newRequests){
        ExceptionRequestSharingUtil shareHelper = ExceptionRequestSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ExceptionRequest__c cm : newRequests){
            if (cm.Account__c != null){
                accountIds.add(cm.Account__c);
            }
            recordIds.add(cm.Id);
        }
        recordIds.addAll((new Map<Id,ExceptionRequest__c>([SELECT Id FROM ExceptionRequest__c WHERE Account__c in: accountIds])).keySet());
        if (recordIds.size() > 0 ) {
            shareHelper.storeRecords(recordIds);
            shareHelper.commitRecords();
        }
    }
}