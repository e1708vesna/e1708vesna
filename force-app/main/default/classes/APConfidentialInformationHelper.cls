public class APConfidentialInformationHelper {

    public static void afterInsertHandler(List<APConfidentialInformation__c> newList){
        Set<Id> sowIds = (new Map<Id,SObject>(newList)).keySet();
        APConfidentialInformationSharingUtils.insertUpdateDeleteCiShare(sowIds);
    }
    
    public static void afterUndeleteHandler(List<APConfidentialInformation__c> newList){
        Set<Id> sowIds = (new Map<Id,SObject>(newList)).keySet();
        APConfidentialInformationSharingUtils.insertUpdateDeleteCiShare(sowIds);
    }
}