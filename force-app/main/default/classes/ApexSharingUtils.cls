public class ApexSharingUtils {
    
    //It is better to construct this Set using a describe call. Filtering fields that do not end with AccessLevel.
    private static final Set<String> fieldNameSet = new Set<String>{'AccessLevel', 'AccountAccessLevel', 'CaseAccessLevel', 'ContactAccessLevel', 'LeadAccessLevel'};
                    
                    
    /* Compares existing shares with new shares
* This method compares two maps containing share records. It creates an upsert and a delete list.
* @param existingShares a map within a map. Inner map: Share records by userId. Outer map: Share map by record Id.
* @param newShares a map within a map. Inner map: Share records by userId. Outer map: Share map by record Id.
* @param upsertList This list will be filled with share records that should be upserted. Parameter should not be null.
* @param deleteList This list will be filled with share records that should be deleted. Parameter should not be null.
* */
    public static void cleanseShares(Map<Id, Map<Id, sObject>> existingShares, Map<Id, Map<Id,sObject>> newShares, List<sObject> upsertList, List<sObject> deleteList){
        
        //Check existing shares if they are still in the new situation, if not delete them.
        for (Id existingSowId : existingShares.keySet()){
            Map<Id, sObject> existingSharesMap = existingShares.get(existingSowId);
            Map<Id, sObject> newSharesMap = newShares.get(existingSowId);
            for (Id userId : existingSharesMap.keySet()){
                if (newSharesMap == null || !newSharesMap.containsKey(userId)){
                    deleteList.add(existingSharesMap.get(userId));
                }
            }
        }
        
        //Check new shares if they are already in the existing situation, if so update, if not insert them.
        for (Id newSowId : newShares.keySet()){
            Map<Id, sObject> existingSharesMap = existingShares.get(newSowId);
            Map<Id, sObject> newSharesMap = newShares.get(newSowId);
            for (Id userId : newSharesMap.keySet()){
                //if it is not already there, insert
                if (existingSharesMap == null || !existingSharesMap.containsKey(userId)){
                    upsertList.add(newSharesMap.get(userId));
                }
                //else if access is different: update
                else {
                    sObject newShare = newSharesMap.get(userId);
                    sObject existingShare = existingSharesMap.get(userId);
                    boolean upsertRecord = false;
                        for (String fieldName : fieldNameSet) {
                            if (compareFieldsAndUpdate(existingShare, newShare, fieldName)){
                                upsertRecord = true;
                            }
                        }
                    if (upsertRecord){
                        upsertList.add(existingShare);
                    }
                }
            }
            
        }
    }
    
    private static boolean compareFieldsAndUpdate(sObject existingRecord, sObject newRecord, String fieldName){
        //use a try catch to in order to be able to use all accessLevel fields in an sObject. It is better to use a describe call instead.
        try {
            if (newRecord.get(fieldName) != existingRecord.get(fieldName)){
                existingRecord.put(fieldName, newRecord.get(fieldName)); //update the existing share record in order to preserve the id;
                return true;
            }
        }
        catch (System.SObjectException e){
            return false;
        }
        return false;
    }
}