public class ExceptionRequestMemberHelper {

    public static void handleAfterInsertTriggerSharing(ExceptionRequestMember__c[] newRequestsMembers){
        ExceptionRequestSharingUtil shareHelper = ExceptionRequestSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ExceptionRequestMember__c cm : newRequestsMembers){
            if (cm.ExceptionRequest__c != null){
                recordIds.add(cm.ExceptionRequest__c);
            }
        }
        if (recordIds != null && recordIds.size() > 0) {
            for (ExceptionRequest__c er : [Select Account__c FROM ExceptionRequest__c WHERE Id in :recordIds]) {
                if (er.Account__c != null) {
                    accountIds.add(er.Account__c);
                }
            }
        }
        recordIds.addAll((new Map<Id,ExceptionRequest__c>([SELECT Id FROM ExceptionRequest__c WHERE Account__c in: accountIds])).keySet());
        if (recordIds.size() > 0 ) {
            shareHelper.storeRecords(recordIds);
            shareHelper.commitRecords();
        }
    }
    
    public static void handleAfterUpdateTriggerSharing(ExceptionRequestMember__c[] newRequests, Map<Id, ExceptionRequestMember__c> oldClaimsMap){
        /*ExceptionRequestSharingUtil shareHelper = ExceptionRequestSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ExceptionRequestMember__c cm : newRequests){
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
        }*/
    }
    
    public static void handleAfterDeleteTriggerSharing(ExceptionRequestMember__c[] oldClaims){
        ExceptionRequestSharingUtil shareHelper = ExceptionRequestSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for (ExceptionRequestMember__c cm : oldClaims){
            if (cm.ExceptionRequest__c != null){
                recordIds.add(cm.ExceptionRequest__c);
            }
        }
        if (recordIds != null && recordIds.size() > 0) {
            for (ExceptionRequest__c er : [Select Account__c FROM ExceptionRequest__c WHERE Id in :recordIds]) {
                if (er.Account__c != null) {
                    accountIds.add(er.Account__c);
                }
            }
        }
        recordIds.addAll((new Map<Id,ExceptionRequest__c>([SELECT Id FROM ExceptionRequest__c WHERE Account__c in: accountIds])).keySet());
        if (recordIds.size() > 0 ) {
            shareHelper.storeRecords(recordIds);
            shareHelper.commitRecords();
        }
    }
    
    public static void handleAfterUndeleteTriggerSharing(ExceptionRequestMember__c[] newRequests){
        ExceptionRequestSharingUtil shareHelper = ExceptionRequestSharingUtil.getInstance();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ExceptionRequestMember__c cm : newRequests){
            if (cm.ExceptionRequest__c != null){
                recordIds.add(cm.ExceptionRequest__c);
            }
        }
        if (recordIds != null && recordIds.size() > 0) {
            for (ExceptionRequest__c er : [Select Account__c FROM ExceptionRequest__c WHERE Id in :recordIds]) {
                if (er.Account__c != null) {
                    accountIds.add(er.Account__c);
                }
            }
        }
        recordIds.addAll((new Map<Id,ExceptionRequest__c>([SELECT Id FROM ExceptionRequest__c WHERE Account__c in: accountIds])).keySet());
        if (recordIds.size() > 0 ) {
            shareHelper.storeRecords(recordIds);
            shareHelper.commitRecords();
        }
    }
}