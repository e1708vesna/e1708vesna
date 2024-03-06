public class RelationshipMergeUtility {

      
    /**
    * Checks if the deleted records are part of a merge operation. If so, it calls the logic to consolidate the related relationships
    * @param deletedRecords List of sObject record (should be a list of Leads or Accounts).
    */
    public static void afterDeleteMerge(List<sObject> deletedRecords){
        Set<Id> masterIds = new Set<Id>();
        for (sObject record : deletedRecords){
            if (record.get('MasterRecordId') != null){
                masterIds.add((Id) record.get('MasterRecordId'));
            }
        }
        For (Id masterId : masterIds){
            consolidateRelationships(masterId);
        }
    }
    
    /**
    * Prepares the data to consolidate Relationships after a merge operation happened and calls the logic that handles the consolidation logic
    * @param masterId Id of the masterId record (should belong to a Lead or Account).
    */
    public static void consolidateRelationships(Id masterId){
        List<Relationship__c> masterRelationships;
        if (String.valueOf(masterId.getSobjectType()) == 'Account') {
            masterRelationships = [SELECT Id,
                                   Lead__c,
                                   Account__c,
                                   Opportunity__c,
                                   PartnerType__c,
                                   UniqueIdentifier__c
                                   FROM Relationship__c Where Account__c =: masterId];
        }
        else {
            masterRelationships= [SELECT Id,
                                                  Lead__c,
                                                  Account__c,
													Opportunity__c,
                                                  PartnerType__c,
                                                  UniqueIdentifier__c
                                                  FROM Relationship__c Where Lead__c =: masterId];
        }
        RelationshipTuple tuple = new RelationshipTuple();
        tuple.masterRelationshipsByExternalId = new Map<String, Relationship__c>();
        tuple.slaveRelationships = new List<Relationship__c>();
        for (Relationship__c rShip : masterRelationships){
			//The merge has already happened. All relationships have been reparented to the masterrecord. Automations are not ran on reparented child records. 
            //Thus the UniqueIdentifier has not been updated. We can use this to identify the slave child records. If the first part of the unique identifier is not equal to the masterRecordId it is part of the merge.
            if (rShip.UniqueIdentifier__c.substring(0,18).equals(rShip.Account__c) || rShip.UniqueIdentifier__c.substring(0,18).equals(rShip.Lead__c)){
                tuple.masterRelationshipsByExternalId.put(rShip.UniqueIdentifier__c, rShip);
            }
            else {
                tuple.slaveRelationships.add(rShip);
            }
        }
        consolidateRelationships(masterId, tuple);
    }
    
    //Wrapper class to create a tuple: Relationships related to the masterRecord, Relationships related to the Slave records.
    private class RelationshipTuple {
        Map<String, Relationship__c> masterRelationshipsByExternalId;
        List<Relationship__c> slaveRelationships;
    }
    
    
    /**
    * Identify duplicate Relationships records and consolidates them. Also consolidates related relationship records.
    * @param masterId Id of the masterId record (should belong to a Lead or Account).
    * @param tuple RelationshipsTuple containing the Relationships records of the master and the slave(s).
    */
    public static void consolidateRelationships(Id masterId, RelationshipTuple tuple){
        List<Relationship__c> relationshipToDelete = new List<Relationship__c>();
        List<Relationship__c> relationshipToUpsert = new List<Relationship__c>();
        for (Relationship__c rShip : tuple.slaveRelationships){
            String externalId = masterId + '-' + rShip.PartnerType__c + (rShip.Opportunity__c == null ? '' :  '-' + rShip.Opportunity__c); //Recalculate because merging does not recalculate this.
            if (tuple.masterRelationshipsByExternalId.containsKey(externalId)){ //merge/delete the relationships if they already exist.
                relationshipToDelete.add(rShip);
                //Merge related relationships.
            }
            else { //Add it to the master
                rShip.UniqueIdentifier__c = externalId;
                if (String.valueOf(masterId.getSobjectType()) == 'Lead') {
                	rShip.Lead__c = masterId;
                }
                else {
                	rShip.Account__c = masterId;
                }
                tuple.masterRelationshipsByExternalId.put(externalId, rShip);
                relationshipToUpsert.add(rShip);
                //No need to update relationships
            }
            
        }
        delete relationshipToDelete;
        upsert relationshipToUpsert;
    }
    
}