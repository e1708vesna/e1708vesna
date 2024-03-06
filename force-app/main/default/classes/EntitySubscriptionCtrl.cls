/*
 * @name EntitySubscriptionCtrl
 * @author Service
 * @group Lightning Controller
 * @description This class provides functionality to retrieve the total count of records followed by the current user across various Salesforce objects. It supports dynamic retrieval of followed records based on object type and allows the user to unfollow these records.
 */
public with sharing class EntitySubscriptionCtrl {

    // Mapping of object fields for JSON configuration
    private static Map<String, List<String>> objectFieldsMap = new Map<String, List<String>> {
        'Case' => new List<String>{'CaseNumber', 'Subject', 'Status', 'Owner.Name', 'Account.Name', 'LastModifiedDate'},
        'Account' => new List<String>{'Name', 'Owner.Name', 'Website', 'Account_Status__c', 'LastModifiedDate'},
        'Contact' => new List<String>{'Name', 'Email', 'ContactStatus__c', 'Account.Name', 'LastModifiedDate'},
        'Lead' => new List<String>{'Name', 'Email', 'Status', 'Company', 'LastModifiedDate'},
        'Opportunity' => new List<String>{'Name', 'Account.Name', 'Total_Gross_Margin_Services_Products__c', 'FullExpectedMonthlyGrossMargin__c', 'StageName', 'LastModifiedDate'},
        'Handover__c' => new List<String>{'Name', 'Account__c', 'Opportunity__c', 'Status__c', 'LastModifiedDate'},
        'ProductRequest__c' => new List<String>{'Name', 'Type__c', 'Category__c', 'Product__c', 'Status__c', 'LastModifiedDate'},
        'Report' => new List<String>{'Name', 'CreatedById', 'LastModifiedDate'},
        'Dashboard' => new List<String>{'Name', 'CreatedById', 'LastModifiedDate'}
    };

    /*
     * Retrieves dinamically constructed list of column configuration based on the specified object type.
     * Relationship fields are handled specifically to include the related object's name field in the column data.
     * @param objectType The API name of the object for which the column configurations are requested.
     * @return A JSON string representing the list of column configurations.
     */
    @AuraEnabled
    public static String getColumnConfigurations(String objectType) {
        List<Map<String, Object>> columns = new List<Map<String, Object>>();
    
        addSpecialColumn(columns, objectType);
        addFieldColumns(columns, objectType);
        addFollowedDateColumn(columns);
        return JSON.serializePretty(columns);
    }

    /*
     * Adds a special column configuration for the fields with a clickable link.
     * @param columns The list of column configurations.
     * @param objectType The API name of the object.
     */
    private static void addSpecialColumn(List<Map<String, Object>> columns, String objectType) {
        Map<String, Object> typeAttributes = new Map<String, Object>{
            'label' => new Map<String, String>{'fieldName' => objectType == 'Case' ? 'CaseNumber' : 'Name'},
            'url' => new Map<String, String>{'fieldName' => objectType == 'Case' ? 'caseNumberLink' : 'nameLink'}
        };
        String typeAttributesJson = JSON.serialize(typeAttributes);
        columns.add(new Map<String, Object>{
            'label' => objectType == 'Case' ? 'Case Number' : 'Name',
            'fieldName' => objectType == 'Case' ? 'caseNumberLink' : 'nameLink',
            'type' => 'url',
            'typeAttributes' => JSON.deserializeUntyped(typeAttributesJson)
        });
    }
    
    /*
     * Adds standard field columns to the column configuration.
     * @param columns The list of column configurations.
     * @param objectType The API name of the object.
     */
    private static void addFieldColumns(List<Map<String, Object>> columns, String objectType) {
        Map<String, Schema.SObjectField> globalFieldsMap = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();
        List<String> fieldNames = objectFieldsMap.get(objectType);
        for (String fieldName : fieldNames) {
            if (shouldSkipField(objectType, fieldName)) {
                continue;
            }
            Map<String, Object> column = createFieldColumn(globalFieldsMap, fieldName);
            if (column != null) {
                columns.add(column);
            }
        }
    }
    
    /*
     * Determines if a field should be skipped when adding to column configurations.
     * @param objectType The API name of the object.
     * @param fieldName The field name to check.
     * @return A boolean indicating if the field should be skipped.
     */
    private static boolean shouldSkipField(String objectType, String fieldName) {
        return (objectType.equals('Case') && fieldName.equals('CaseNumber')) || 
               (!objectType.equals('Case') && fieldName.equals('Name'));
    }
    
    /*
     * Creates a column configuration map for a standard field.
     * @param globalFieldsMap The global description map of fields.
     * @param fieldName The field name for which the column configuration is created.
     * @return A Map representing the column configuration.
     */
    private static Map<String, Object> createFieldColumn(Map<String, Schema.SObjectField> globalFieldsMap, String fieldName) {
        // Check if the field is a relationship field
        if (fieldName.contains('.')) {
            String[] parts = fieldName.split('\\.', 2);
            String relationshipName = parts[0];
            String relatedFieldName = parts[1];
    
            // Check if the relationship field is present in the global fields map
            if (globalFieldsMap.containsKey(relationshipName + 'Id')) {
                Schema.DescribeFieldResult fieldDescribe = globalFieldsMap.get(relationshipName + 'Id').getDescribe();
                String label = fieldDescribe.getRelationshipName();
                String apiName = relationshipName + '.' + relatedFieldName;
    
                // Create a column configuration for the relationship field
                return new Map<String, Object>{
                    'label' => label,
                    'fieldName' => apiName,
                    'type' => 'text',
                    'sortable' => true
                };
            }
            return null; // Return null if the relationship field is not found
        } else {
            // Handle standard fields
            if (globalFieldsMap.containsKey(fieldName)) {
                Schema.DescribeFieldResult fieldDescribe = globalFieldsMap.get(fieldName).getDescribe();
                return new Map<String, Object>{
                    'label' => fieldDescribe.getLabel(),
                    'fieldName' => fieldName,
                    'type' => getFieldType(fieldDescribe.getType()),
                    'sortable' => true
                };
            }
            return null; // Return null if the field is not found
        }
    }
    
    /*
     * Adds a 'Followed Since' column to the column configuration.
     * @param columns The list of column configurations.
     */
    private static void addFollowedDateColumn(List<Map<String, Object>> columns) {
        columns.add(new Map<String, Object>{
            'label' => 'Followed Since',
            'fieldName' => 'FollowedDate',
            'type' => 'datetime',
            'sortable' => true
        });
    }

    // Utility method for converting field types to LWC datatable compatible types
    private static String getFieldType(Schema.DisplayType displayType) {
        switch on displayType {
            when CURRENCY { return 'currency'; }
            when DATE { return 'date'; }
            when DATETIME { return 'datetime'; }
            when EMAIL { return 'email'; }
            when URL { return 'url'; }
            when else { return 'text'; }
        }
    }

    /*
     * Represents a record followed by a user.
     */
    public class FollowedRecord {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String recordType;
        @AuraEnabled public Map<String, Object> fields; // A map to hold field API names and their values
        @AuraEnabled public DateTime followedDate;
        @AuraEnabled public DateTime lastModifiedDate;
        @AuraEnabled public Id subscriptionId { get; set; } // EntitySubscription ID

        /*
         * Constructor for creating a FollowedRecord instance from a given SObject and followed date.
         * @param record The SObject record from which to extract the data.
         * @param followedDate The DateTime when the user started following the record.
         */
        public FollowedRecord(SObject record, DateTime followedDate , Id subscriptionId) {
            this.recordId = record.Id;
            this.recordType = String.valueOf(record.getSObjectType());
            this.followedDate = followedDate;
            this.lastModifiedDate = (DateTime)record.get('LastModifiedDate');
            this.subscriptionId = subscriptionId;
            this.fields = new Map<String, Object>();

            Map<String, Object> updates = new Map<String, Object>(); // A temporary map to hold updates for relationship fields
            List<String> fieldNames = objectFieldsMap.get(this.recordType); // Retrieve field names defined for the object type from a static map
            
            for (String fieldName : fieldNames) {
                // Check if the field name includes a relationship
                if (fieldName.contains('.')) {
                    String relationship = fieldName.split('\\.')[0]; // Extract the relationship name (before the dot)
                    SObject relatedRecord = (SObject)record.getSObject(relationship); // Get the related record using the relationship name
                    // If the related record exists, get the 'Name' field value
                    if (relatedRecord != null) {
                        updates.put(fieldName, relatedRecord.get('Name'));
                    }
                } else {
                    updates.put(fieldName, record.get(fieldName));
                }
            }

            this.fields.putAll(updates); // Apply the collected field values to the fields map after the loop
            this.fields.put('FollowedDate', this.followedDate); // Add the followed date to the fields map
        }
    }

    /*
    * Retrieves a list of records followed by the current user, filtered by the specified object type
    * and an optional search keyword. 
    * @param objectType The API name of the object type to filter the followed records (e.g., 'Case', 'Account', etc).
    * @param searchKeyword A string keyword to further filter the followed records based on record names or other searchable fields.
    * @return A list of FollowedRecord instances representing records currently followed by the user.
    */
    @AuraEnabled
    public static List<FollowedRecord> getFollowedRecords(String objectType, String searchKeyword) {
        List<FollowedRecord> followedRecords = new List<FollowedRecord>(); // Initialize an empty list to hold the FollowedRecord instances
        Integer queryLimit = 1000; // Limit for each query
        Integer offset = 0; // Initialize offset for pagination

        while (true) {
            // Query for a batch of records with pagination
            List<EntitySubscription> subscriptions = [SELECT Id, ParentId, CreatedDate
                                                      FROM EntitySubscription
                                                      WHERE SubscriberId = :UserInfo.getUserId()
                                                      AND Parent.Type = :objectType
                                                      LIMIT :queryLimit OFFSET :offset];
            
            // Process the fetched subscriptions
            followedRecords.addAll(processSubscriptions(subscriptions, objectType, searchKeyword));
    
            // Break the loop if the number of subscriptions is less than the query limit
            if (subscriptions.size() < queryLimit || followedRecords.size() > 2000) {
                break;
            }
    
            offset += queryLimit; // Increment offset for the next batch
        }
        System.debug('queryLimit1: ' + queryLimit);
        return followedRecords;
    }

    /*
    * Processes a list of EntitySubscription records to create a list of FollowedRecord instances.
    * @param subscriptions A list of EntitySubscription records representing the records followed by the user.
    * @param objectType The API name of the object type for which the followed records are being processed.
    * @param searchKeyword A string keyword used for further filtering the followed records based on record names or other searchable fields.
    * @return A list of FollowedRecord instances created from the provided EntitySubscription records.
    */
    private static List<FollowedRecord> processSubscriptions(List<EntitySubscription> subscriptions, String objectType, String searchKeyword) {
        List<FollowedRecord> tempFollowedRecords = new List<FollowedRecord>();
    
        if (subscriptions.isEmpty()) {
            System.debug('No subscriptions found for objectType: ' + objectType);
            return tempFollowedRecords;
        }

        Map<Id, DateTime> followedDates = new Map<Id, DateTime>(); // A map to associate record IDs with the dates they were followed
        Map<Id, Id> parentToSubscription = new Map<Id, Id>(); // maps ParentId to SubscriptionId
        for (EntitySubscription sub : subscriptions) {
            followedDates.put(sub.ParentId, sub.CreatedDate);
            parentToSubscription.put(sub.ParentId, sub.Id);
        }

        String queryString = buildDynamicQuery(objectType, followedDates.keySet(), searchKeyword);

        // If the query string couldn't be built, log the issue
        if (queryString == null) {
            System.debug('Dynamic query string is null.');
            return tempFollowedRecords;
        }

        List<SObject> records = Database.query(queryString);  // Execute the query to retrieve the actual records that are followed      

        for (SObject record : records) {
            DateTime followedDate = followedDates.get(record.Id); // Retrieve the date when the record was followed
            Id subscriptionId = parentToSubscription.get(record.Id); // Retrieve the corresponding subscription ID
            tempFollowedRecords.add(new FollowedRecord(record, followedDate, subscriptionId)); // Create a new FollowedRecord instance and add it to the list
        }
    
        return tempFollowedRecords;
    }

    /*
     * Constructs a dynamic SOQL query string based on the provided object type, a set of record IDs, and an optional search keyword.
     * @param objectType The type of object for which to build the query (e.g., 'Case', 'Account', etc).
     * @param ids A set of record IDs to include in the WHERE clause of the query.
     * @param searchKeyword A string keyword to further filter the results based on record names or other searchable fields.
     * @return A string representing the SOQL query, or null if the object type has no fields defined.
     */
    private static String buildDynamicQuery(String objectType, Set<Id> ids, String searchKeyword) {
        
        // Retrieve the list of fields to query for the given object type from the pre-defined map
        List<String> fieldNames = objectFieldsMap.get(objectType);
        if (fieldNames == null || fieldNames.isEmpty()) {
            return null;
        }

         String fieldsToQuery = String.join(fieldNames, ', ');
         String idList = '(\'' + String.join(ids, '\',\'') + '\')';

        // Construct the query without modifying the original ids collection
        String soql = 'SELECT ' + fieldsToQuery + ' FROM ' + objectType +
        ' WHERE Id IN ' + idList;
        
        // Add search logic if a search keyword is provided
        if (String.isNotBlank(searchKeyword)) {
            // CASE
            if(objectType == 'Case') {
                soql += ' AND (CaseNumber LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
                soql += ' OR Subject LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
                soql += ' OR Owner.Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
                soql += ' OR Account.Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\')';
            }
            // ACCOUNT
            else if (objectType == 'Account') {
                soql += ' AND (Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
                soql += ' OR Owner.Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\')';
            } 
            // CONTACT || OPPORTUNITY
            else if (objectType == 'Contact' || objectType == 'Opportunity') {
                soql += ' AND (Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
                soql += ' OR Account.Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\')';
            }
            // LEAD
            else if (objectType == 'Lead') {
                soql += ' AND (Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
                soql += ' OR Status LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\')';
            }  
            // HANDOVER
            else if (objectType == 'Handover__c') {
                soql += ' AND (Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
                soql += ' OR Account__c LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
                soql += ' OR Opportunity__c LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\')';
            }
            // PRODUCT REQUEST
            else if (objectType == 'ProductRequest__c') {
                soql += ' AND (Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
                soql += ' OR Product__c LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\')';
            }
            // REPORTS || DASHBOARDS
            else if (objectType == 'Report' || objectType == 'Dashboard') {
                soql += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
            }
        }

        return soql;
    }

    /*
    * Retrieves information about the records followed by the current user.
    * @return A Map<String, Object> where each key-value pair represents the count of followed records for each object type
    * and the total count of all followed records. The map contains two keys: 'total' for the total count, and 'byObject' 
    * for a map of object types and their respective counts.
    */
    @AuraEnabled
    public static Map<String, Object> getFollowedRecordsInfo() {

        Map<String, Integer> recordCountsByObject = new Map<String, Integer>();
        Map<String, Object> followedRecordsInfo = new Map<String, Object>();
        Integer queryLimit = 1000; // Limit for each query
        Integer offset = 0;
        Boolean moreRecords = true;

        while (moreRecords) {
            // Query EntitySubscription without GROUP BY clause
            List<EntitySubscription> subscriptions = [SELECT Id, Parent.Type
                                                    FROM EntitySubscription
                                                    WHERE SubscriberId = :UserInfo.getUserId()
                                                    LIMIT :queryLimit OFFSET :offset];   

            for (EntitySubscription sub : subscriptions) {
                String objectType = sub.Parent.Type;

                Integer count = recordCountsByObject.containsKey(objectType) ? recordCountsByObject.get(objectType) : 0;
                recordCountsByObject.put(objectType, count + 1);
            }

            // Check if more records are to be fetched
            if (subscriptions.size() < queryLimit) {
                moreRecords = false;
            } else {
                offset += queryLimit; // Increment offset for the next query
            }
            System.debug('queryLimit: ' + queryLimit);
        }

        // Calculate total count
        Integer totalCount = 0;
        for (Integer count : recordCountsByObject.values()) {
            totalCount += count;
        }

        followedRecordsInfo.put('total', totalCount);
        followedRecordsInfo.put('byObject', recordCountsByObject);
        return followedRecordsInfo;
    }

    /*
    * Provides functionality to unfollow records in bulk. 
    * @param subscriptionIds A List<Id> representing the IDs of EntitySubscription records to be deleted (unfollowed).
    */
    @AuraEnabled
    public static void unfollowRecords(List<Id> subscriptionIds) {
        if (!Schema.sObjectType.EntitySubscription.isDeletable()) {
            System.debug('User does not have delete access to EntitySubscription');
            return;
        }

        try {
            Database.DeleteResult[] results = Database.delete(subscriptionIds, true);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}