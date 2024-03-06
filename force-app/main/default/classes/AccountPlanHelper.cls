public class AccountPlanHelper {    
    
    public static Set<Id> relatedSOWIdSet = new Set<Id>();
    public static Set<Id> relatedCiIdSet = new Set<Id>();
    
    public static void afterInsertHandler(List<AccountPlan__c> newList){        
        Set<Id> changedConfidentialInformationIdSet = new Set<Id>();
        for (AccountPlan__c ap : newList){
            if (ap.APConfidentialInformation__c != null) {
                changedConfidentialInformationIdSet.add(ap.APConfidentialInformation__c);
            }
        }
        APConfidentialInformationSharingUtils.insertUpdateDeleteCiShare(changedConfidentialInformationIdSet);
    }
    
    public static void afterUpdateHandler(List<AccountPlan__c> newList, Map<Id, AccountPlan__c> oldMap){
        //List<ShareOfWallet__c> sowList = [Select Id From ShareOfWallet__c Where AccountPlan__c in: newList];
        //Set<Id> newSowIds = (new Map<Id,SObject>(newList)).keySet();
        Set<Id> changedAccountPlanIdSet = new Set<Id>();
        Set<Id> changedConfidentialInformationIdSet = new Set<Id>();
        for (AccountPlan__c ap : newList){
            if (ap.Account__c != oldMap.get(ap.Id).Account__c){
                changedAccountPlanIdSet.add(ap.Id);
                changedConfidentialInformationIdSet.add(ap.APConfidentialInformation__c);
            } 
            if (ap.APConfidentialInformation__c != oldMap.get(ap.Id).APConfidentialInformation__c) {
                if (ap.APConfidentialInformation__c != null) {
                    changedConfidentialInformationIdSet.add(ap.APConfidentialInformation__c);
                }
                if (oldMap.get(ap.Id).APConfidentialInformation__c != null) {
                    changedConfidentialInformationIdSet.add(oldMap.get(ap.Id).APConfidentialInformation__c);
                }
            }
        }
        List<ShareOfWallet__c> sowList = [Select Id From ShareOfWallet__c Where AccountPlan__c IN: changedAccountPlanIdSet];
        Set<Id> sowIds = (new Map<Id,SObject>(sowList)).keySet();   
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(sowIds);
        APConfidentialInformationSharingUtils.insertUpdateDeleteCiShare(changedConfidentialInformationIdSet);
    }
    
    public static void beforeDeleteHandler(List<AccountPlan__c> oldList){
        Set<Id> accountPlanIdSet = (new Map<Id,SObject>(oldList)).keySet();
        for (AccountPlan__c ap : oldList){
            if (ap.APConfidentialInformation__c != null) {
                relatedCiIdSet.add(ap.APConfidentialInformation__c);
            }
        }
        
        
        List<ShareOfWallet__c> sowList = [Select Id From ShareOfWallet__c Where AccountPlan__c IN: accountPlanIdSet];
        Set<Id> sowIdList = ((new Map<Id,SObject>(sowList)).keySet());
        relatedSOWIdSet.addAll(sowIdList);
    }
    
    public static void afterDeleteHandler(){
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(relatedSOWIdSet);
        APConfidentialInformationSharingUtils.insertUpdateDeleteCiShare(relatedCiIdSet);
    }
    
    public static void afterUndeleteHandler(List<AccountPlan__c> newList){
        Set<Id> accountPlanIdSet = (new Map<Id,SObject>(newList)).keySet();
        Set<Id> changedConfidentialInformationIdSet = new Set<Id>();
        for (AccountPlan__c ap : newList){
            if (ap.APConfidentialInformation__c != null) {
                changedConfidentialInformationIdSet.add(ap.APConfidentialInformation__c);
            }
        }
        List<ShareOfWallet__c> sowList = [Select Id From ShareOfWallet__c Where AccountPlan__c IN: accountPlanIdSet];
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare((new Map<Id,SObject>(sowList)).keySet());
        APConfidentialInformationSharingUtils.insertUpdateDeleteCiShare(changedConfidentialInformationIdSet);
    }
}