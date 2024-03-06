public class PartnerTypeMergeUtility {

    private static final String EMPTY_ID = '000000000000000000';
        
    /**
    * Checks if the deleted records are part of a merge operation. If so, it calls the logic to consolidate the related Partner Types
    * @param deletedRecords List of sObject record (should be a list of Leads or Accounts).
    */
    public static void afterDeleteMerge(List<sObject> deletedRecords){
        Set<Id> masterIds = new Set<Id>();
        for (sObject record : deletedRecords){
            if (record.get('MasterRecordId') != null){ //When records are merged. The deleted records will have their masterRecordId populated. Use this to query the master record.
                masterIds.add((Id) record.get('MasterRecordId'));
            }
        }
        For (Id masterId : masterIds){
            consolidatePartnerTypes(masterId); //Note: This is not bulkified since Merge operations can not be done in bulk.
        }
    }
    
    
    /**
    * Prepares the data to consolidate PartnerTypes after a merge operation happened and calls the logic that handles the consolidation logic
    * @param masterId Id of the masterId record (should belong to a Lead or Account).
    */   
    public static void consolidatePartnerTypes(Id masterId){
        List<PartnerType__c> masterPartnerType;
        if (String.valueOf(masterId.getSobjectType()) == 'Account') {
        	masterPartnerType = [SELECT Id,
                                                  Account__c,
												  Lead__c,
                                                  Type__c,
                                                  SubType__c,
                                                  UniqueIdentifier__c,
                                                  (SELECT Id,
                                                   Account__c,
                                                   Lead__c,
                                                   Opportunity__c
                                                   FROM Relationships__r)
                                                  FROM PartnerType__c Where Account__c =: masterId];
        }
        else {
            masterPartnerType = [SELECT Id,
                                 Account__c,
								 Lead__c,
                                 Type__c,
                                 SubType__c,
                                 UniqueIdentifier__c,
                                 (SELECT Id,
                                  Account__c,
                                  Lead__c,
                                  Opportunity__c
                                  FROM Relationships__r)
                                 FROM PartnerType__c Where Lead__c =: masterId];
        }
        PartnerTypeTuple tuple = new PartnerTypeTuple();
        tuple.masterPartnerTypesByExternalId = new Map<String, PartnerType__c>();
        tuple.slavesPartnerTypes = new List<PartnerType__c>();
        for (PartnerType__c pt : masterPartnerType){
            //The merge has already happened. All relationships have been reparented to the masterrecord. Automations are not ran on reparented child records. 
            //Thus the UniqueIdentifier has not been updated. We can use this to identify the slave child records. If the first part of the unique identifier is not equal to the masterRecordId it is part of the merge.
            if (pt.UniqueIdentifier__c.substring(0,18).equals(pt.Account__c) || pt.UniqueIdentifier__c.substring(0,18).equals(pt.Lead__c)){
                tuple.masterPartnerTypesByExternalId.put(pt.UniqueIdentifier__c, pt);
            }
            else {
                tuple.slavesPartnerTypes.add(pt);
            }
        }
        consolidatePartnerTypes(masterId, tuple);
    }
        
    //Wrapper class to create a tuple: Partner Types related to the masterRecord, Partner Types related to the Slave records.
    private class PartnerTypeTuple {
        Map<String, PartnerType__c> masterPartnerTypesByExternalId;
        List<PartnerType__c> slavesPartnerTypes;
    }
    
    /**
    * Identify duplicate PartnerType records and consolidates them. Also consolidates related relationship records.
    * @param masterId Id of the masterId record (should belong to a Lead or Account).
    * @param tuple PartnerTypeTuple containing the PartnerType records of the master and the slave(s).
    */   
    public static void consolidatePartnerTypes(Id masterId, PartnerTypeTuple tuple){
        List<PartnerType__c> partnerTypeToDelete = new List<PartnerType__c>();
        List<PartnerType__c> partnerTypeToUpsert = new List<PartnerType__c>();
        List<Relationship__c> relationshipToDelete = new List<Relationship__c>();
        List<Relationship__c> relationshipToUpsert = new List<Relationship__c>();
        for (PartnerType__c pt : tuple.slavesPartnerTypes){
            String externalId = masterId + ' - ' + pt.Type__c + ' - ' + pt.SubType__c; //Recalculate because merging does not recalculate this.
            if (tuple.masterPartnerTypesByExternalId.containsKey(externalId)){ //merge the partner types
                partnerTypeToDelete.add(pt);
                if (pt.Relationships__r != null && pt.Relationships__r.size() > 0) { //Also reparent the child relationships and consolidate
                    List<Relationship__c> rShipToDelete = new List<Relationship__c>();
                    List<Relationship__c> rShipToUpsert = new List<Relationship__c>();
                    consolidateRelationships(tuple.masterPartnerTypesByExternalId.get(externalId).Id, tuple.masterPartnerTypesByExternalId.get(externalId).Relationships__r, pt.Relationships__r, rShipToUpsert, rShipToDelete);
                    if (rShipToUpsert != null && rShipToUpsert.size() > 0) {
                        relationshipToUpsert.addAll(rShipToUpsert);
                    }
                    if (relationshipToDelete != null && relationshipToDelete.size() > 0) {
                        relationshipToDelete.addAll(rShipToDelete);
                    }
                }
                //Merge related relationships.
                
            }
            else { //Add it to the master
                pt.UniqueIdentifier__c = externalId;
                if (String.valueOf(masterId.getSobjectType()) == 'Lead') {
                    pt.Lead__c = masterId;
                }
                else {
                	pt.Account__c = masterId;
                }
                tuple.masterPartnerTypesByExternalId.put(externalId, pt);
                partnerTypeToUpsert.add(pt);
                //No need to update relationships
            }
            
        }
        
        delete relationshipToDelete;
        upsert relationshipToUpsert;
        delete partnerTypeToDelete;
        upsert partnerTypeToUpsert;
    }
    
    
    
    /**
    * Identify duplicate Relationship records and consolidates them.
    * @param masterPartnerTypeId Id of the masterPartnerType
    * @param masterRelationshipList list of relationship records belonging to the masterPartnerType.
    * @param slaveRelationshipList list of relationship records belonging to the slavePartnerType.
    * @param relationshipsToUpsert Relationship list. Should be empty. Relationship records that will need to be upserted will be added to this list.
    * @param relationshipsToDelete Relationship list. Should be empty. Relationship records that will need to be deleted will be added to this list.
    */  
    public static void consolidateRelationships(Id masterPartnerTypeId, List<Relationship__c> masterRelationshipList, List<Relationship__c> slaveRelationshipList, List<Relationship__c> relationshipsToUpsert, List<Relationship__c> relationshipsToDelete){
        
        Map<String, Relationship__c> masterRelationshipByExternalId = new Map<String, Relationship__c>();
        for (Relationship__c rShip : masterRelationshipList){
            masterRelationshipByExternalId.put(constructRelationshipExternalId(rShip), rShip);
        }
        for (Relationship__c rShip : slaveRelationshipList){
            String externalId = constructRelationshipExternalId(rShip);
            if (masterRelationshipByExternalId.containsKey(externalId)){ //merge the relationships
                System.debug('Deleting: ' + externalId);
                relationshipsToDelete.add(rShip);
                //Merge logic?
            }
            else { //Add it to the master PartnerType
                rShip.PartnerType__c = masterPartnerTypeId;
                masterRelationshipByExternalId.put(externalId, rShip);
                relationshipsToUpsert.add(rShip);
            }
        }
    }
    
    
    /**
    * Constructs a uniqueIdentifier for a relationship record to be used to identify duplicate relationship records. Note that this is a different externalId than the Relationship__r.UniqueIdentifier__c field.
    * @param rShip Relationship__c record for which to construct the uniqueIdentifier.
    * @return String constructed UniqueIdentifier
    */  
    private static String constructRelationshipExternalId(Relationship__c rShip){
        String externalId;
        if (rShip.Lead__c != null){
            externalId = rShip.Lead__c;
        }
        else if (rShip.Opportunity__c != null) {
            externalId = '' + rShip.Account__c + rShip.Opportunity__c;
        }
        else {
            externalId = '' + rShip.Account__c + EMPTY_ID;
        }
        return externalId;
    }
}