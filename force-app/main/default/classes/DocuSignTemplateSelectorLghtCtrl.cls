public class DocuSignTemplateSelectorLghtCtrl {
    
    /**
    * Queries DocuSign Envelope records based on some filters
    * @param searchQuery Filter on Name field, when blank, this filter is not used
    * @param region Region to filter on, when blank, this filter is not used
    * @param contractType ContractType to filter on, when blank, this filter is not used
    * @param salesChannel Sales Channel to filter on, when blank, this filter is not used
    * @param queryLimit Max records to return
    * @return List of dsfs__EnvelopeConfiguration__c records that meet the filter criteria
    */
    @AuraEnabled
    public static List<dsfs__EnvelopeConfiguration__c> queryEnvelopeConfigurations(String searchQuery, String region, String contractType, String salesChannel, Integer queryLimit) {
        String query = 'Select Id, Name, ContractCountryCurrency__c, ContractType__c, SalesChannel__c, Description__c  FROM dsfs__EnvelopeConfiguration__c';
        //String whereClause = '';
        String whereClause = ' dsfs__Active__c = True';
        if (!String.isBlank(searchQuery)){
        	searchQuery = String.escapeSingleQuotes(searchQuery);
            whereClause += ' AND Name like \'%' + searchQuery + '%\'';
        }
        if (!String.isBlank(region)){
            whereClause += ' AND ContractCountryCurrency__c = :region';
        }
        if (!String.isBlank(contractType)){
            whereClause += ' AND ContractType__c = :contractType';
        }
        if (!String.isBlank(salesChannel)){
            whereClause += ' AND SalesChannel__c = :salesChannel';
        }
        
        if (!String.isBlank(whereClause)){
            whereClause = whereClause.removeEnd(' AND');
            query += ' WHERE' + whereClause;
        }
        query += ' LIMIT :queryLimit';
        System.debug(query);
        return Database.query(query);
    }
    
    
    /**
    * Describes the picklist fields on DocuSign Envelope Object. Returns map of possible picklist options.
    * @return Map<String, Map<String, String>> Picklist options per field.
    */
    @AuraEnabled 
    public static Map<String, Map<String, String>> getPicklistValues(){
        Map<String, Map<String, String>> options = new Map<String, Map<String, String>>();
        options.put('Region', new Map<String, String>());
        for (Schema.PicklistEntry p: dsfs__EnvelopeConfiguration__c.ContractCountryCurrency__c.getDescribe().getPicklistValues()) {
            options.get('Region').put(p.getValue(), p.getLabel());
        }
        options.put('SalesChannel', new Map<String, String>());
        for (Schema.PicklistEntry p: dsfs__EnvelopeConfiguration__c.SalesChannel__c.getDescribe().getPicklistValues()) {
            options.get('SalesChannel').put(p.getValue(), p.getLabel());
        }
        options.put('ContractType', new Map<String, String>());
        for (Schema.PicklistEntry p: dsfs__EnvelopeConfiguration__c.ContractType__c.getDescribe().getPicklistValues()) {
            options.get('ContractType').put(p.getValue(), p.getLabel());
        }
        return options;
    }
}