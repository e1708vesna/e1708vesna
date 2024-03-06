public class CustomHistoryUtility {
    private static Map<String, Schema.DescribeSObjectResult> ObjectDescribeMap = new Map<String, Schema.DescribeSObjectResult>();
    public static HistoryConfiguration__mdt testExecutionMetadataRecord; //Can be set in the test class to mock Custom metadata record.
    public static String testObjectType; //Can be set in the test class. The mocked Custom metadata record is only returned during test execution for objects that match this type.
    
    
        /**
* Called internally to log history on After Insert or After delete.
* Contains the logic to log the history.
* @param newList List<sObject> List of object to log history for.
* @param onCreate Boolean Set to true if this function runs in the After Insert Context. Set to False if it runs in the After Delete context.
*/
    private static void logHistoryAfterCreateDelete(List<sObject> newList, Boolean onCreate){
        List<History__c> insertList = new List<History__c>();
        List<HistoryRecordCreation__e> insertListAsync = new List<HistoryRecordCreation__e>();
        Schema.DescribeSObjectResult DOR = newList[0].Id?.getSObjectType().getDescribe();
        String sObjectType = DOR.getName();
        String sObjectLabel = DOR.getLabel();
        ObjectDescribeMap.put(sObjectType, DOR);
        String nameField = [SELECT QualifiedApiName
                            FROM FieldDefinition
                            WHERE EntityDefinition.QualifiedApiName = :sObjectType
                            AND IsNameField = TRUE LIMIT 1]?.QualifiedApiName;
        Map<Id, HistoryConfiguration__mdt> configMap = onCreate ? retrieveConfigurationCreate(sObjectType) : retrieveConfigurationDelete(sObjectType);
        for (sObject record : newList){
            for (HistoryConfiguration__mdt config : configMap.Values()){
                String configNameField = config.NameFieldApiName__c;
                String configParentField = String.isBlank(config.ParentFieldApiName__c) ? 'Id' : config.ParentFieldApiName__c;
                if (config.RunAsyncronous__c){
                    insertListAsync.add(new HistoryRecordCreation__e(
                        FieldName__c = (onCreate ? 'Created ' : 'Deleted ') + sObjectLabel,
                        NewValue__c = (onCreate ? (String.isBlank(configNameField) ? String.valueOf(record.get(nameField)) : String.valueOf(record.get(configNameField))) : null),
                        OldValue__c = (!onCreate ? (String.isBlank(configNameField) ? String.valueOf(record.get(nameField)) : String.valueOf(record.get(configNameField))) : null),
                        ObjectName__c = config.HistoryType__c,
                        RecordId__c = (String) record.get('Id'),
                        ParentId__c = (String) record.get(configParentField)
                    ));
                }
                else {
                    insertList.add(new History__c(
                        FieldName__c = (onCreate ? 'Created ' : 'Deleted ') + sObjectLabel,
                        NewValue__c = (onCreate ? (String.isBlank(configNameField) ? String.valueOf(record.get(nameField)) : String.valueOf(record.get(configNameField))) : null),
                        OldValue__c = (!onCreate ? (String.isBlank(configNameField) ? String.valueOf(record.get(nameField)) : String.valueOf(record.get(configNameField))) : null),
                        ObjectName__c = config.HistoryType__c,
                        RecordId__c = (String) record.get('Id'),
                        ParentId__c = (String) record.get(configParentField)
                    ));
                }
            }
        }
        insert insertList;
        if (insertListAsync.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(insertListAsync);
        }
    }
    
    /**
* Logs history after Update, to be called from the Trigger of the object.
* @param newList List<sObject> List of object to log history for. Should be Trigger.new in the After Update trigger.
* @param oldMap Map<Id, sObject> List of object to log history for. Should be Trigger.oldMap in the After Update trigger.
*/
    public static void logHistoryAfterUpdate(List<sObject> newList, Map<Id, sObject> oldMap){
        List<sObject> relationshipHistory = new List<sObject>();
        List<History__c> insertList = new List<History__c>();
        List<HistoryRecordCreation__e> insertListAsync = new List<HistoryRecordCreation__e>();
        String sObjectType = newList[0].Id?.getSObjectType().getDescribe().getName();
        Map<Id, HistoryConfiguration__mdt> configMap = retrieveConfiguration(sObjectType);
        Map<Schema.FieldSetMember, Set<Id>> configByFieldName = new Map<Schema.FieldSetMember, Set<Id>>();
        for (HistoryConfiguration__mdt config : configMap.values()){
            if (!String.isBlank(config.FieldSetDeveloperName__c)){ //There is a fieldset
                for (Schema.FieldSetMember field : retrieveFieldsFromFieldSet(config.FieldSetDeveloperName__c, sObjectType)){
                    if (!configByFieldName.containsKey(field)){
                        configByFieldName.put(field, new Set<Id>());
                    }
                    configByFieldName.get(field).add(config.Id);
                }
            }
        }
        for (sObject record : newList){
            for (Schema.FieldSetMember fieldSetMember : configByFieldName.keySet()){
                String field = fieldSetMember.getFieldPath();
                if (field.contains('.')){
                    System.debug(LoggingLevel.WARN, 'Invalid field, relationships are not possible');
                    break;
                }
                boolean lookupField = false;
                if (fieldSetMember.getType() == Schema.DisplayType.REFERENCE){
                    lookupField = true;
                }
                String actualField = getFieldNameFromRelationship(field);
                String actualFieldLabel = fieldSetMember.getLabel();
                if (record.get(actualField) != oldMap.get((Id) record.get('Id')).get(actualField)) {
                    String oldValue = String.valueOf(oldMap.get((Id) record.get('Id')).get(actualField));
                    String newValue = String.valueOf(record.get(actualField));
                    oldValue = String.isBlank(oldValue) || oldValue.length() < 255 ? oldValue : oldValue.subString(0,255);
                    newValue = String.isBlank(newValue) || newValue.length() < 255 ? newValue : newValue.subString(0,255);
                    for (Id configId : configByFieldName.get(fieldSetMember)) {
                        if (configMap.get(configId).RunAsyncronous__c){
                            HistoryRecordCreation__e h = new HistoryRecordCreation__e(
                                FieldName__c = actualFieldLabel,
                                NewValue__c = newValue,
                                OldValue__c = oldValue,
                                ObjectName__c = configMap.get(configId).HistoryType__c,
                                RecordId__c = (String) record.get('Id'),
                                ParentId__c = String.isBlank(configMap.get(configId).ParentFieldApiName__c) ? (String) record.get('Id') : (String) record.get(configMap.get(configId).ParentFieldApiName__c)
                            );
                            insertListAsync.add(h);
                            if (lookupField) {
                                relationshipHistory.add(h);
                            }
                            
                        }
                        else {
                            History__c h = new History__c(
                                FieldName__c = actualFieldLabel,
                                NewValue__c = newValue,
                                OldValue__c = oldValue,
                                ObjectName__c = configMap.get(configId).HistoryType__c,
                                RecordId__c = (String) record.get('Id'),
                                ParentId__c = String.isBlank(configMap.get(configId).ParentFieldApiName__c) ? (String) record.get('Id') : (String) record.get(configMap.get(configId).ParentFieldApiName__c)
                            );
                            insertList.add(h);
                            if (lookupField) {
                                relationshipHistory.add(h);
                            }
                        }
                    }
                }
            }
        }
        populateNameFromId(relationshipHistory);
        insert insertList;
        if (insertListAsync.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(insertListAsync);
        }        
    }
        /**
* Logs history after insert, to be called from the Trigger of the object.
* @param newList List<sObject> List of object to log history for. Should be Trigger.new in the After Insert trigger.
*/
    public static void logHistoryAfterInsert(List<sObject> newList){
        logHistoryAfterCreateDelete(newList, true);
    }
    
    /**
* Logs history after delete, to be called from the Trigger of the object.
* @param oldList List<sObject> List of object to log history for. Should be Trigger.Old in the After Delete trigger.
*/
    public static void logHistoryAfterDelete(List<sObject> oldList){
        logHistoryAfterCreateDelete(oldList, false);
    }
    
    
    
    /**
* Retrieves custom history configuration not filtered.
* @param sObjectType String Object Api name for which to retrieve the configuration records.
* @return Map<Id, HistoryConfiguration__mdt> Map of configuration records.
*/
    private static Map<Id, HistoryConfiguration__mdt> retrieveConfiguration(String sObjectType){
        if (Test.isRunningTest()) { //cannot create Custom Metadata in test classes
            if (testObjectType == sObjectType && testExecutionMetadataRecord != null) { //Populated in the testClass
                Map<Id, HistoryConfiguration__mdt> tempMap = new Map<Id, HistoryConfiguration__mdt>();
                tempMap.put(testExecutionMetadataRecord.Id, testExecutionMetadataRecord);
                return tempMap;
            }
            return new Map<Id, HistoryConfiguration__mdt>();
        }
        return new Map<Id, HistoryConfiguration__mdt>([SELECT Id, DeveloperName,  FieldSetDeveloperName__c, HistoryType__c, NameFieldApiName__c, ObjectApiName__c, ParentFieldApiName__c, RunAsyncronous__c, RunOnCreate__c, RunOnDelete__c FROM HistoryConfiguration__mdt WHERE ObjectApiName__c =: sObjectType]);
    }
    
    /**
* Retrieves custom history configuration configured to run on create.
* @param sObjectType String Object Api name for which to retrieve the configuration records.
* @return Map<Id, HistoryConfiguration__mdt> Map of configuration records.
*/
    private static Map<Id, HistoryConfiguration__mdt> retrieveConfigurationCreate(String sObjectType){
        if (Test.isRunningTest()) { //cannot create Custom Metadata in test classes
            if (testObjectType == sObjectType && testExecutionMetadataRecord != null) { //Populated in the testClass
                Map<Id, HistoryConfiguration__mdt> tempMap = new Map<Id, HistoryConfiguration__mdt>();
                tempMap.put(testExecutionMetadataRecord.Id, testExecutionMetadataRecord);
                return tempMap;
            }
            return new Map<Id, HistoryConfiguration__mdt>();
        }
        return new Map<Id, HistoryConfiguration__mdt>([SELECT Id, DeveloperName,  FieldSetDeveloperName__c, HistoryType__c, NameFieldApiName__c, ObjectApiName__c, ParentFieldApiName__c, RunAsyncronous__c, RunOnCreate__c, RunOnDelete__c FROM HistoryConfiguration__mdt WHERE ObjectApiName__c =: sObjectType AND RunOnCreate__c = true]);
    }
    
    /**
* Retrieves custom history configuration configured to run on delete.
* @param sObjectType String Object Api name for which to retrieve the configuration records.
* @return Map<Id, HistoryConfiguration__mdt> Map of configuration records.
*/
    private static Map<Id, HistoryConfiguration__mdt> retrieveConfigurationDelete(String sObjectType){
        if (Test.isRunningTest()) { //cannot create Custom Metadata in test classes
            if (testObjectType == sObjectType && testExecutionMetadataRecord != null) { //Populated in the testClass
                Map<Id, HistoryConfiguration__mdt> tempMap = new Map<Id, HistoryConfiguration__mdt>();
                tempMap.put(testExecutionMetadataRecord.Id, testExecutionMetadataRecord);
                return tempMap;
            }
            return new Map<Id, HistoryConfiguration__mdt>();
        }
        return new Map<Id, HistoryConfiguration__mdt>([SELECT Id, DeveloperName,  FieldSetDeveloperName__c, HistoryType__c, NameFieldApiName__c, ObjectApiName__c, ParentFieldApiName__c, RunAsyncronous__c, RunOnCreate__c, RunOnDelete__c FROM HistoryConfiguration__mdt WHERE ObjectApiName__c =: sObjectType AND RunOnDelete__c = true]);
    }
    
        /**
* Retrieves the fields from a fieldset.
* @param fieldSetName String DeveloperName of the fieldset to be retrieved
* @param sObjectType String Object Api name related to the fieldset.
* @return List<Schema.FieldSetMember> fieldMembers of the fieldset if the fieldset does not exists, returns null
*/
    //https://salesforce.stackexchange.com/questions/1474/how-to-get-fieldset-fields-in-apex-dynamically-fieldset-name-is-not-static
    private static List<Schema.FieldSetMember> retrieveFieldsFromFieldSet(String fieldSetName, String sObjectType)
    {
        Schema.DescribeSObjectResult sObjectDescribe;
        if (!ObjectDescribeMap.containsKey(sObjectType)){
            sObjectDescribe = Schema.describeSObjects(new List<String>{sObjectType})[0];
            ObjectDescribeMap.put(sObjectType, sObjectDescribe);
        }
        else {
            sObjectDescribe = ObjectDescribeMap.get(sObjectType);
        }
        Schema.FieldSet fieldSetObj = sObjectDescribe.FieldSets.getMap().get(fieldSetName);
        if (fieldSetObj == null) {
            return new List<Schema.FieldSetMember>();
        }
        
        return fieldSetObj.getFields();
    } 
    
    
    /**
* Populates the Name of the record in the Old and New value of the History record. This should only be called if OldValue__c or NewValue__c contains an Id.
* It queries what the Name field of the corresponding objects are, then it queries the records and retrieves the Name Value.
* @param hList List<sObject> List of History__c or HistoryRecordCreation__e to be enriched.
*/
    private static void populateNameFromId(List<sObject> hList){
        Map<String, List<sObject>> historyListById = new Map<String, List<sObject>>();
        Map<String, Set<String>> idsByObjectType = new Map<String, Set<String>>();
        Map<String, String> nameFieldByObjectType = new Map<String, String>();
        
        //Collect all ids to query
        for (sObject h : hList){
            if (!String.isBlank((String)h.get('NewValue__c'))) {
                String objectType = String.valueOf(Id.valueOf((String) h.get('NewValue__c') ).getSObjectType());
                if (!idsByObjectType.containsKey(objectType)){
                    idsByObjectType.put(objectType, new Set<String>());
                }
                idsByObjectType.get(objectType).add((String) h.get('NewValue__c')); 
                if (!historyListById.containsKey((String) h.get('NewValue__c'))){
                    historyListById.put((String) h.get('NewValue__c'), new List<sObject>());
                }
                historyListById.get((String) h.get('NewValue__c')).add(h); 
            }
            if (!String.isBlank((String) h.get('OldValue__c'))) {
                String objectType = String.valueOf(Id.valueOf((String) h.get('OldValue__c' )).getSObjectType());
                if (!idsByObjectType.containsKey(objectType)){
                    idsByObjectType.put(objectType, new Set<String>());
                }
                idsByObjectType.get(objectType).add( (String) h.get('OldValue__c')); 
                if (!historyListById.containsKey((String) h.get('OldValue__c'))){
                    historyListById.put( (String) h.get('OldValue__c'), new List<sObject>());
                }
                historyListById.get( (String) h.get('OldValue__c')).add(h);
            }
        }
        //Query Name fields for the object
        for(FieldDefinition fd : [SELECT QualifiedApiName, EntityDefinition.QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName in :idsByObjectType.keySet() AND IsNameField = TRUE]){
            nameFieldByObjectType.put(fd.EntityDefinition.QualifiedApiName, fd.QualifiedApiName);
        }
        //We need to query the names of the references. These can be from different sObject Types. We need to do one query per sObject type. Hence the query in the for loop.
        for (String objectType :  idsByObjectType.keySet()){ 
            Set<String> idSet = idsByObjectType.get(objectType);
            String query = 'SELECT Id, ' + nameFieldByObjectType.get(objectType) + ' FROM ' + objectType + ' WHERE Id in :idSet';
            for (sObject record : Database.query(query)){
                String recordId = (String) record.get('Id');
                String recordName = (String) record.get((String)nameFieldByObjectType.get(objectType));
                for (sObject h : historyListById.get(recordId)){
                    if (recordId.equals((String) h.get('NewValue__c'))){
                        h.put('NewValue__c', recordName);
                    }
                    if (recordId.equals((String) h.get('OldValue__c'))){
                        h.put('OldValue__c', recordName);
                    }
                }
            }
        }
    }
    
    
        /**
* returns the fieldname from a relationship string.
* @param relationshipString String relationship fields which needs to be trimmed.
* @return String the field name extracted from the relationship string
*/
    private static String getFieldNameFromRelationship(String relationshipString){
        if (relationshipString.contains('.')){
            return relationshipString.substring(relationshipString.lastIndexOf('.')+1, relationshipString.length());  
        }
        return relationshipString;
    }
    
    
}