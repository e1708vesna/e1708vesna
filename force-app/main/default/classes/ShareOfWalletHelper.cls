public class ShareOfWalletHelper {

    public static void afterInsertHandler(List<ShareOfWallet__c> newList){
		Set<Id> sowIds = (new Map<Id,SObject>(newList)).keySet();
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(sowIds);
    }
    
    public static void afterUpdateHandler(List<ShareOfWallet__c> newList, Map<Id, ShareOfWallet__c> oldMap){
		Set<Id> sowIds = new Set<Id>();
        for (ShareOfWallet__c sow : newList){
            if (sow.AccountPlan__c != oldMap.get(sow.Id).AccountPlan__c){
                sowIds.add(sow.Id);
            } 
        }
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(sowIds);
    }
    
    public static void afterUndeleteHandler(List<ShareOfWallet__c> newList){
		Set<Id> sowIds = (new Map<Id,SObject>(newList)).keySet();
        ShareOfWalletSharingUtils.insertUpdateDeleteSOWShare(sowIds);
    }
}