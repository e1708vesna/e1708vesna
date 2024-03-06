public class CustomHistoryHelper {
	
    /**
    * method to delete all related Custom History records related to list of records.
    * @param  parentRecords List of sObjects for which the related customhistory records should be deleted. This can be the Trigger.Old from the after delete trigger.
    */
    public static void deleteRelatedCustomHistory(List<sObject> parentRecords){
        Set<Id> parentIds = new Set<Id>();
        for (sObject record : parentRecords){
            parentIds.add((Id) record.get('Id'));
        }
        deleteRelatedCustomHistory(parentIds);
    }
    
    /**
    * method to delete all related Custom History records related to list of records.
    * @param  parentIds Set of Ids for which the related customhistory records should be deleted. This can be the Trigger.oldMap.keySet() from the after delete trigger.
    */
    public static void deleteRelatedCustomHistory(Set<Id> parentIds){
        delete [SELECT Id FROM History__c WHERE ParentId__c in: parentIds];
    }
    
    /**
    * method to undelete all related Custom History records related to list of records.
    * @param  parentRecords List of sObjects for which the related customhistory records should be restored. This can be the Trigger.new from the after undelete trigger.
    */
    public static void undeleteRelatedCustomHistory(List<sObject> parentRecords){
        Set<Id> parentIds = new Set<Id>();
        for (sObject record : parentRecords){
            parentIds.add((Id) record.get('Id'));
        }
        undeleteRelatedCustomHistory(parentIds);
    }
    
    /**
    * method to undelete all related Custom History records related to list of records.
    * @param  parentIds Set of Ids for which the related customhistory records should be restored. This can be the Trigger.newMap.keySet() from the after undelete trigger.
    */
    public static void undeleteRelatedCustomHistory(Set<Id> parentIds){
        List<History__c> hList = [SELECT Id FROM History__c WHERE ParentId__c in: parentIds AND IsDeleted = true ALL ROWS];
        //undelete hList;
        List<Database.UndeleteResult> undeleteResult = Database.undelete(hList, false);
        for (Database.UndeleteResult result : undeleteResult){
            if (!result.isSuccess()){
                System.debug(JSON.serialize(result.getErrors()));
            }
        }
    }
}