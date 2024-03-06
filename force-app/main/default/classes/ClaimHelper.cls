public class ClaimHelper {

    public static void handleAfterInsertTriggerSharing(Claim__c[] newClaims){
        ClaimSharingUtil shareHelper = ClaimSharingUtil.getInstance();
        Set<Id> claimIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Claim__c cm : newClaims){
            claimIds.add(cm.Id);
            if (cm.Account__c != null){
                accountIds.add(cm.Account__c);
            }
        }
        claimIds.addAll((new Map<Id,Claim__c>([SELECT Id FROM Claim__c WHERE Account__c in: accountIds])).keySet());
        if (claimIds.size() > 0 ) {
            shareHelper.storeClaims(claimIds);
            shareHelper.commitClaims();
        }
    }
    
    public static void handleAfterUpdateTriggerSharing(Claim__c[] newClaims, Map<Id, Claim__c> oldClaimsMap){
        ClaimSharingUtil shareHelper = ClaimSharingUtil.getInstance();
        Set<Id> claimIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Claim__c cm : newClaims){
            
            Id oldAccountId = cm.Account__c;
            id newAccountId = oldClaimsMap.get(cm.Id).Account__c;
            if (newAccountId != oldAccountId){
                if (newAccountId != null){
                    accountIds.add(newAccountId);
                }
                if (oldAccountId != null){
                    accountIds.add(oldAccountId);
                }
                claimIds.add(cm.Id);
            }
        }
        claimIds.addAll((new Map<Id,Claim__c>([SELECT Id FROM Claim__c WHERE Account__c in: accountIds])).keySet());
        if (claimIds.size() > 0 ) {
            shareHelper.storeClaims(claimIds);
            shareHelper.commitClaims();
        }
    }
    
    public static void handleAfterDeleteTriggerSharing(Claim__c[] oldClaims){
        ClaimSharingUtil shareHelper = ClaimSharingUtil.getInstance();
        Set<Id> claimIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Claim__c cm : oldClaims){
            if (cm.Account__c != null){
                accountIds.add(cm.Account__c);
            }
        }
        claimIds.addAll((new Map<Id,Claim__c>([SELECT Id FROM Claim__c WHERE Account__c in: accountIds])).keySet());
        if (claimIds.size() > 0 ) {
            shareHelper.storeClaims(claimIds);
            shareHelper.commitClaims();
        }
    }
    
    public static void handleAfterUndeleteTriggerSharing(Claim__c[] newClaims){
        ClaimSharingUtil shareHelper = ClaimSharingUtil.getInstance();
        Set<Id> claimIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Claim__c cm : newClaims){
            if (cm.Account__c != null){
                accountIds.add(cm.Account__c);
            }
            claimIds.add(cm.Id);
        }
        claimIds.addAll((new Map<Id,Claim__c>([SELECT Id FROM Claim__c WHERE Account__c in: accountIds])).keySet());
        if (claimIds.size() > 0 ) {
            shareHelper.storeClaims(claimIds);
            shareHelper.commitClaims();
        }
    }
}