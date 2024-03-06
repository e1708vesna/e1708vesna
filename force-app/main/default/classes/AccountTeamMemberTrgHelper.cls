public class AccountTeamMemberTrgHelper {
    
    public static Set<Id> relatedSOWIdSet = new Set<Id>();
    public static Set<Id> relatedCiIdSet = new Set<Id>();
    
    public static void afterInsertHandler(List<AccountTeamMember> newList){
        Set<Id> changedAccountIdSet = new Set<Id>();
        Set<Id> ciIdSet = new Set<Id>();
        for (AccountTeamMember act : newList){
                changedAccountIdSet.add(act.AccountId);
        }
        List<AccountPlan__c> apList = [Select Id, ApConfidentialInformation__c From AccountPlan__c Where Account__c in : changedAccountIdSet];
        for (AccountPlan__c ap : apList){
            if (ap.ApConfidentialInformation__c != null){
                ciIdSet.add(ap.ApConfidentialInformation__c);
            }
        }
        ApConfidentialInformationSharingUtils.insertUpdateDeleteCiShare(ciIdSet);
        List<ShareOfWallet__c> sowList = [Select Id FROM ShareOfWallet__c Where AccountPlan__c in: apList];
        Set<Id> sowIds = (new Map<Id,SObject>(sowList)).keySet();
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(sowIds);
        
    }
    
    public static void afterUpdateHandler(List<AccountTeamMember> newList, Map<Id, AccountTeamMember> oldMap){
        //List<ShareOfWallet__c> sowList = [Select Id From ShareOfWallet__c Where AccountPlan__c in: newList];
        //Set<Id> newSowIds = (new Map<Id,SObject>(newList)).keySet();
        Set<Id> changedAccountIdSet = new Set<Id>();
        Set<Id> ciIdSet = new Set<Id>();
        for (AccountTeamMember act : newList){
            if (act.AccountAccessLevel != oldMap.get(act.Id).AccountAccessLevel || act.AccountId != oldMap.get(act.Id).AccountId){
                changedAccountIdSet.add(act.AccountId);
            } 
        }
        //Should be in DAO
        List<AccountPlan__c> apList = [Select Id, ApConfidentialInformation__c From AccountPlan__c Where Account__c in : changedAccountIdSet];
        for (AccountPlan__c ap : apList){
            if (ap.ApConfidentialInformation__c != null){
                ciIdSet.add(ap.ApConfidentialInformation__c);
            }
        }
        ApConfidentialInformationSharingUtils.insertUpdateDeleteCiShare(ciIdSet);
        List<ShareOfWallet__c> sowList = [Select Id FROM ShareOfWallet__c Where AccountPlan__c in: apList];
        Set<Id> sowIds = (new Map<Id,SObject>(sowList)).keySet();   
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(sowIds);
    }
    
    public static void beforeDeleteHandler(List<AccountTeamMember> oldList){
        Set<Id> changedAccountIdSet = new Set<Id>();
        for (AccountTeamMember act : oldList){
                changedAccountIdSet.add(act.AccountId);
        }
        List<AccountPlan__c> apList = [Select Id, ApConfidentialInformation__c From AccountPlan__c Where Account__c in : changedAccountIdSet];
        for (AccountPlan__c ap : apList){
            if (ap.ApConfidentialInformation__c != null){
                relatedCiIdSet.add(ap.ApConfidentialInformation__c);
            }
        }
        List<ShareOfWallet__c> sowList = [Select Id FROM ShareOfWallet__c Where AccountPlan__c in: apList];
        Set<Id> sowIds = (new Map<Id,SObject>(sowList)).keySet();
        relatedSOWIdSet.addAll(sowIds);
    }
    
    public static void afterDeleteHandler(){
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(relatedSOWIdSet);
        ApConfidentialInformationSharingUtils.insertUpdateDeleteCiShare(relatedCiIdSet);
    }
}