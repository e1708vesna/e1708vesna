/**
* 9 August - Updated by Matthew for testing
* Removed V1 in Url, was causing an error because it was missing from the referralId int
* Updated constructWhereClauseOpportunityQuery to check null value in statuses
* Set response content-type to 'application/json;charset=UTF-8' so it can be parsed, was defaulting to octet-stream
**/
@RestResource(urlMapping='/PartnerPortal/*/ReferralRecords')
global with sharing class PartnerPortalRest {
    private static Final Integer MAX_NUMBER_RECORDS_RETURNED = 1000;
    private static Final ID OPPORTUNITY_RECORD_TYPE_ID = Constants.RT_ID_OPP_SALES;
    private static Final Map<String, Map<String, String>> ORDER_BY_FIELDS = instantiateOrderByFieldMap();
    
    @HttpGet
    global static void getRequest() {
        String referralId = RestContext.request.requestURI.substringBetween('PartnerPortal/', '/ReferralRecords');
        Set<String> statuses = parseCommaSeperatedList(RestContext.request.params.get('statuses'));
        String createdDateFrom = RestContext.request.params.get('createdDateFrom');
        String createdDateTill = RestContext.request.params.get('createdDateTill');
        String numberOfRecords = RestContext.request.params.get('numberOfRecords');
        String offset = RestContext.request.params.get('offset');
        String sortField = RestContext.request.params.get('sortField');
        String sortOrder = RestContext.request.params.get('sortOrder');
        processRequest(referralId, statuses, createdDateFrom, createdDateTill, numberOfRecords, offset, sortField, sortOrder);
    }
    
    /**
* Queries Lead and Opportunity records related to the ReferralAccount and consolidates them into one array. The resulting list is sorted
* @param referralId Partner Account Id of which to return the related records.
* @param statusses List of statusses to filter the records on.
* @param createdDateFrom Only return records of which the createdDate is after or equal to this parameter.
* @param createdDateTill Only return records of which the createdDate is before or equal to this parameter.
* @param numberOfRecords Max records to return
* @param offset Number of records to skip
*/
    global static void processRequest(String referralId, Set<String> statuses, String createdDateFromString, String createdDateTillString, String numberOfRecordsString, String offsetString, String sortField, String sortOrder) {
        Set<String> validStatusses = parseCommaSeperatedList(Label.PartnerPortalStatuses);
        referralId = referralId != null ? String.escapeSingleQuotes(referralId) : null;
        if (statuses != null) {
            for (String status : statuses){
                status = String.escapeSingleQuotes(status);
            }
        }
        createdDateFromString = createdDateFromString != null ? String.escapeSingleQuotes(createdDateFromString) : null;
        createdDateTillString = createdDateTillString != null ? String.escapeSingleQuotes(createdDateTillString) : null;
        numberOfRecordsString = numberOfRecordsString != null ? String.escapeSingleQuotes(numberOfRecordsString) : null;
        offsetString = offsetString != null ? offsetString = String.escapeSingleQuotes(offsetString) : null;
        List<ExceptionResponse> exceptionList = new List<ExceptionResponse>();
        
        
        RestResponse res = RestContext.response;
        Date createdDateFrom = parseDate(createdDateFromString, 'createdDateFrom', exceptionList);
        Date createdDateTill = parseDate(createdDateTillString, 'createdDateTill', exceptionList);
        Integer numberOfRecords = parseInteger(numberOfRecordsString, 'numberOfRecords', exceptionList);
        Integer offset = parseInteger(offsetString, 'offset', exceptionList);
        
        //Validate input 
        if (createdDateTill != null) {
            createdDateTill = createdDateTill.addDays(1); //This is needed because a query on CreatedDate does not return the day itself due to the time portion of the CreatedDate field
        }
        if (numberOfRecords == null){
            numberOfRecords = 200;
        }
        else if (numberOfRecords > MAX_NUMBER_RECORDS_RETURNED || numberOfRecords < 1){
            addException(exceptionList, 'INVALID_INPUT', 'Exception : Invalid value for field "numberOfRecords". Value should be between "1" and "' + MAX_NUMBER_RECORDS_RETURNED + '"');
        }
        if (offset == null){
            offset = 0;
        }
        else if (offset < 0){
            addException(exceptionList, 'INVALID_INPUT', 'Exception : Invalid value for field "offset". Value should be larger than "0"');
        }
        if (!String.isBlank(sortField) && !ORDER_BY_FIELDS.containsKey(sortField)){
            addException(exceptionList, 'INVALID_INPUT', 'Exception : Invalid value "' + sortField + '" for field sortField. Valid values are ' + Json.serialize(ORDER_BY_FIELDS.keySet()));
        }
        
        
        if (!String.isBlank(sortOrder) && sortOrder != 'ASC' && sortOrder != 'DESC'){
            addException(exceptionList, 'INVALID_INPUT', 'Exception : Invalid value "' + sortOrder + '" for field sortOrder. Valid values are \"ASC\" or \"DESC\"');
        }
        /*//Check for required fields
List<String> missingFields = new List<String>();
if (String.isBlank(referralId)){
missingFields.add('referralId');
}
//Return an error or continue?
if (missingFields.size() > 0) { //Missing Fields
addException(exceptionList, 'MISSING_FIELDS', 'Exception : Required field missing ' + Json.serialize(missingFields) );
*/
        
        if (statuses != null && statuses.size() > 0){
            for (String status : statuses){
                if (!validStatusses.contains(status)){
                    addException(exceptionList, 'INVALID_INPUT', 'Exception : Invalid value "' + status + '" in Statuses. Valid values are ' + Json.serialize(validStatusses));
                }
            }
        }
        
        //Check for required fields
        if (referralId != null && (referralId.length() != 18 || !referralId.startsWith('001'))){
            addException(exceptionList, 'INVALID_INPUT', 'Exception : Invalid value "' + referralId + '" for referralId.');
        }
        
        if (exceptionList != null && exceptionList.size() > 0) {
            res.addHeader('Content-Type','application/json;charset=UTF-8');
            res.statusCode = 400;
            res.responseBody = blob.valueOf(JSON.serialize(exceptionList, true));
            return;
        }
        List<Lead> leadList = new List<Lead>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<ReturnRecord> returnListFull = new List<ReturnRecord>();
        
        Integer totalNumberOfLeads = getTotalNumberOfLeads(referralId, statuses, createdDateTill, createdDateFrom);
        Integer totalNumberOfOpportunities = getTotalNumberOfOpportunities(referralId, statuses, createdDateTill, createdDateFrom);
        
        if (totalNumberOfLeads > 0) {
            leadList = queryLeads(referralId, statuses, createdDateTill, createdDateFrom, numberOfRecords, offset, sortField, sortOrder);
        }
        if (totalNumberOfOpportunities > 0) {
            opportunityList = queryOpportunities(referralId, statuses, createdDateTill, createdDateFrom, numberOfRecords, offset, sortField, sortOrder);
        }
        List<ReturnRecord> returnList = sortReturnList(leadList, opportunityList, sortField, sortOrder, numberOfRecords, offset);
        
        
        /*returnListFull.sort();
List<ReturnRecord> returnList = new List<ReturnRecord>();

while(!returnListFull.isEmpty() && returnList.size() < numberOfRecords) { 
returnList.add(returnListFull.remove(0)); 
}*/
        res.addHeader('Content-Type','application/json;charset=UTF-8');
        res.statusCode = 200;
        //res.responseBody = Blob.valueOf(JSON.serialize(new ReturnWrapper(returnList, totalNumberOfLeads + totalNumberOfOpportunities), True));
        res.responseBody = Blob.valueOf(new ReturnWrapper(returnList, totalNumberOfLeads + totalNumberOfOpportunities).toJson());
    }
    
    /**
* Sorts a (sorted) List of Leads with a (sorted) list of Opportunities
* @param leadList sorted list of Leads
* @param opportunityList sorted list of Opportunities
* @param sortField field on which to sort
* @param sortOrder order on which to sort (ASC or DESC)
* @param numberOfRecords max number of records to return
* @return List<ReturnRecord> List of records to return
*/
    private static List<ReturnRecord> sortReturnList(List<Lead> leadList, List<Opportunity> opportunityList, String sortField, String sortOrder, Integer numberOfRecords, Integer offset){
        List<ReturnRecord> returnList = new List<ReturnRecord>();
        
        String sortFieldLead = ORDER_BY_FIELDS.get(sortField)?.get('Lead');
        String sortFieldOpportunity = ORDER_BY_FIELDS.get(sortField)?.get('Opportunity');
        //Set Default ordering
        if (String.isBlank(sortFieldLead) || String.isBlank(sortFieldOpportunity)){
            sortFieldLead = 'LastModifiedDate';
            sortFieldOpportunity = 'LastModifiedDate';
        }
        if (String.isBlank(sortOrder) || (sortOrder != 'ASC' && sortOrder != 'DESC')){
            sortOrder = 'DESC';
        }
        Integer leadIndex = 0;
        Integer opportunityIndex = 0;
        Integer currentOffset = 0;
        
        While (returnList.size() < numberOfRecords && (leadIndex < leadList.size() || opportunityIndex < opportunityList.size())){
            if (leadIndex >= leadList.size()){
                if (currentOffset == offset) {
                    returnList.add(new ReturnRecord(opportunityList[opportunityIndex]));
                }
                else {
                    currentOffset++;
                }
                opportunityIndex++;
                continue;
            }
            else if (opportunityIndex >= opportunityList.size()){
                if (currentOffset == offset) {
                    returnList.add(new ReturnRecord(leadList[leadIndex]));
                }
                else {
                    currentOffset++;
                }
                leadIndex++;
                continue;
            }
            List<String> relationPath = sortFieldLead.split('\\.');
            sObject currentSObject = leadList[leadIndex];
            for (Integer i = 0; i < relationPath.size() - 1; i++){
                if (currentSObject != null) {
                    currentSObject = currentSObject.getSObject(relationPath[i]);
                }
            }
            Object valueLead = currentSObject == null ? null : currentSObject.get(relationPath[relationPath.size() - 1]);
            
            relationPath = sortFieldOpportunity.split('\\.');
            currentSObject = opportunityList[opportunityIndex];
            for (Integer i = 0; i < relationPath.size() - 1; i++){
                if (currentSObject != null) {
                	currentSObject = currentSObject.getSObject(relationPath[i]);
                }
            }
            Object valueOpportunity = currentSObject == null ? null : currentSObject.get(relationPath[relationPath.size() - 1]);
            
            if (compareObject(valueLead, valueOpportunity, sortOrder == 'ASC')){
                if (currentOffset == offset) {
                    returnList.add(new ReturnRecord(leadList[leadIndex]));
                }
                else {
                    currentOffset++;
                }
                leadIndex++;
            }
            else {
                if (currentOffset == offset) {
                    returnList.add(new ReturnRecord(opportunityList[opportunityIndex]));
                    
                }
                else {
                    currentOffset++;
                }
                opportunityIndex++;
            }
            
            
        }
        return returnList;
    }
    
    
    private static boolean compareObject(Object leadValue, Object opportunityValue, boolean orderBy){
        if (leadValue == null){
            return true;
        }
        if (opportunityValue == null){
            return false;
        }
        
        if (leadValue instanceof Decimal){
            return orderBy ? (Decimal) leadValue < (Decimal)opportunityValue : (Decimal) leadValue > (Decimal)opportunityValue;
        }
        if (leadValue instanceof Long){
            return orderBy ? (Long) leadValue < (Long)opportunityValue : (Long) leadValue > (Long)opportunityValue;
        }
        if (leadValue instanceof Integer){
            return orderBy ? (Integer) leadValue < (Integer)opportunityValue : (Integer) leadValue > (Integer)opportunityValue;
        }
        if (leadValue instanceof String){
            return orderBy ? (String) leadValue < (String)opportunityValue : (String) leadValue > (String)opportunityValue;
        }
        if (leadValue instanceof Date){  
            return orderBy ? (Date) leadValue < (Date)opportunityValue : (Date) leadValue > (Date)opportunityValue;     
        }
        if (leadValue instanceof DateTime){
            return orderBy ? (DateTime) leadValue < (DateTime)opportunityValue : (DateTime) leadValue > (DateTime)opportunityValue;
        }
        return false;
        
    }
    /**
* Constructs the ORDER BY clause
* @param sortField field on which to sort
* @param sortOrder order on which to sort
* @param objectname sObject name for which the ORDER BY Clause is constructed.
* @return String ORDER BY clause to be used in the query
*/
    private static String constructOrderByClause(String sortField, String sortOrder, String sObjectName){
        sortField = ORDER_BY_FIELDS.get(sortField)?.get(sObjectName);
        
        //Set Default ordering
        if (String.isBlank(sortField)){
            sortField = 'LastModifiedDate';
        }
        if (String.isBlank(sortOrder) || (sortOrder != 'ASC' && sortOrder != 'DESC')){
            sortOrder = 'DESC';
        }
        String orderByClause = 'ORDER BY ' + sortField + ' ' + sortOrder + ' ';
        return orderByClause;
    }
    
    /**
* Queries Lead records related to the ReferralAccount
* @param referralId Partner Account Id of which to return the related records.
* @param statusses List of statusses to filter the records on.
* @param createdDateFrom Only return records of which the createdDate is after or equal to this parameter.
* @param createdDateTill Only return records of which the createdDate is before or equal to this parameter.
* @param numberOfRecords Max records to return
* @param offset Number of records to skip
* @return List of Leads
*/
    private static List<Lead> queryLeads(String referralId, Set<String> statuses, Date createdDateTill, Date createdDateFrom, Integer numberOfRecords, Integer offset, String sortField, String sortOrder){
        integer limitRecords = numberOfRecords + offset;
        String query = 'Select CreatedDate, Company, Company_Segment__c, ReachOutToPartnerFirst__c, CountryCode, Email, FirstName, Id, LastModifiedDate, LastName, LeadDescription__c, PartnerContact__c, Partner_Portal_Referral_Status__c, Phone, ReferralAddedDate__c, SalesChannelSingle__c, Title, Website' + 
            ' From Lead ' + 
            constructWhereClauseLeadQuery(statuses, createdDateTill, createdDateFrom) +
            constructOrderByClause(sortField, sortOrder, 'Lead') + 
            ' LIMIT :limitRecords';
        
        return Database.query(query);
    }
    
    /**
* Gets the count of total Lead records related to the ReferralAccount
* @param referralId Partner Account Id of which to count the related records.
* @param statusses List of statusses to filter the records on.
* @param createdDateFrom Only count records of which the createdDate is after or equal to this parameter.
* @param createdDateTill Only count records of which the createdDate is before or equal to this parameter
* @return Integer
*/
    private static Integer getTotalNumberOfLeads(String referralId, Set<String> statuses, Date createdDateTill, Date createdDateFrom){
        String query = 'Select Count(Id) From Lead ' + constructWhereClauseLeadQuery(statuses, createdDateTill, createdDateFrom);
        List<AggregateResult> countLeads = Database.query(query);
        return (Integer) countLeads[0].get('expr0');
    }
    
    
    
    /**
* Constructs the where clause for querying Leads
* @param statusses List of statusses to filter the records on.
* @param createdDateFrom Only return records of which the createdDate is after or equal to this parameter.
* @param createdDateTill Only return records of which the createdDate is before or equal to this parameter.
* @return String Where clause to be used in the query
*/
    private static String constructWhereClauseLeadQuery(Set<String> statuses, Date createdDateTill, Date createdDateFrom){
        String whereClause = 'Where Partner_Referral__c = :referralId ' +
            'AND Type__c = \'Merchant\' ' +
            'AND isConverted = False ' +
            (statuses != null && statuses.size() > 0 ? 'AND Partner_Portal_Referral_Status__c in :statuses ' : '') +
            (createdDateTill != null ? 'AND CreatedDate <= :createdDateTill ' : '') +
            (createdDateFrom != null ? 'AND CreatedDate >= :createdDateFrom ' : '');
        return whereClause;
    }
    
    /**
* Queries Opportunity records related to the ReferralAccount
* @param referralId Partner Account Id of which to return the related records.
* @param statusses List of statusses to filter the records on.
* @param createdDateFrom Only return records of which the createdDate is after or equal to this parameter.
* @param createdDateTill Only return records of which the createdDate is before or equal to this parameter.
* @param numberOfRecords Max records to return
* @param offset Number of records to skip
* @return List of Opportunities
*/
    private static List<Opportunity> queryOpportunities(String referralId, Set<String> statuses, Date createdDateTill, Date createdDateFrom, Integer numberOfRecords, Integer offset, String sortField, String sortOrder){
        integer limitRecords = numberOfRecords + offset;
        String query = 'Select CreatedDate, Account.Name, Account_Company_Segment__c, CountryMerchant__c, ' + 
            'Opportunity_Primary_Contact__r.Email, Opportunity_Primary_Contact__r.FirstName, Id, LastModifiedDate, Opportunity_Primary_Contact__r.LastName, ConvertedLeadDescription__c, Description,' + 
            //' PartnerContact__c, 
            ' Partner_Portal_Referral_Status__c, ReferralAddedDate__c, ' + 
            'Opportunity_Primary_Contact__r.Phone, Sales_channel__c, Opportunity_Primary_Contact__r.Title, Account.Website' + 
            ' From Opportunity ' + 
            constructWhereClauseOpportunityQuery(statuses, createdDateTill, createdDateFrom) +
            constructOrderByClause(sortField, sortOrder, 'Opportunity') + 
            ' LIMIT :limitRecords';
        return Database.query(query);
    }
    
    /**
* Gets the count of total Opportunity records related to the ReferralAccount
* @param referralId Partner Account Id of which to count the related records.
* @param statusses List of statusses to filter the records on.
* @param createdDateFrom Only count records of which the createdDate is after or equal to this parameter.
* @param createdDateTill Only count records of which the createdDate is before or equal to this parameter
* @return Integer
*/
    private static Integer getTotalNumberOfOpportunities(String referralId, Set<String> statuses, Date createdDateTill, Date createdDateFrom){
        Id recordTypeId = Constants.RT_ID_OPP_SALES;
        String query = 'Select Count(Id) From Opportunity ' + constructWhereClauseOpportunityQuery(statuses, createdDateTill, createdDateFrom);
        List<AggregateResult> countRecords = Database.query(query);
        return (Integer) countRecords[0].get('expr0');
    }
    
    /**
* Constructs the where clause for querying Opportunities
* @param statusses List of statusses to filter the records on.
* @param createdDateFrom Only return records of which the createdDate is after or equal to this parameter.
* @param createdDateTill Only return records of which the createdDate is before or equal to this parameter.
* @return String Where clause to be used in the query
*/
    private static String constructWhereClauseOpportunityQuery(Set<String> statuses, Date createdDateTill, Date createdDateFrom){
        String whereClause = 'Where Referral_by_account__c = :referralId ' +
            'AND RecordTypeId = :OPPORTUNITY_RECORD_TYPE_ID ' +
            (statuses != null ? 'AND Partner_Portal_Referral_Status__c in :statuses ' : '') + 
            (createdDateTill != null ? 'AND CreatedDate <= :createdDateTill ' : '') +
            (createdDateFrom != null ? 'AND CreatedDate >= :createdDateFrom ' : '');
        return whereClause;
    }
    
    
    /**
* Adds an exception to the input list.
* @param exceptionList List to add the exception to.
* @param errorCode Error code of the exception
* @param message Error message
*/
    private static void addException(List<ExceptionResponse> exceptionList, String errorCode, String message){
        exceptionList.add(new ExceptionResponse(errorCode, message));
    }   
    
    /**
* Parses a String to a Date. If it is not possible, adds an exception to the Exception list
* @param strValue String value to parse to a Date
* @param fieldName When parsing fails, this fieldName is used in the error message
* @param exceptionList When parsing fails, add an exception to this list.
* @return Date value of String
*/
    private static Date parseDate(String strValue, String fieldName, List<ExceptionResponse> exceptionList){
        Try {
            return String.isBlank(strValue) ? null : Date.parse(strValue);
        }
        Catch (Exception e){
            addException(exceptionList, 'INVALID_INPUT', 'Exception : Cannot Parse Date "' + strValue + '" for field "' + fieldName +'". Valid syntax is: dd/mm/YYYY');
            return null;
        }
    }
    
    /**
* Parses a String to an Integer. If it is not possible, adds an exception to the Exception list
* @param strValue String value to parse to an integer
* @param fieldName When parsing fails, this fieldName is used in the error message
* @param exceptionList When parsing fails, add an exception to this list.
* @return Integer value of String
*/
    private static Integer parseInteger(String strValue, String fieldName, List<ExceptionResponse> exceptionList){
        Try {
            return String.isBlank(strValue) ? null : Integer.valueOf(strValue);
        }
        Catch (Exception e){
            addException(exceptionList, 'INVALID_INPUT', 'Exception : Cannot Parse Integer "' + strValue + '" for field "' + fieldName +'"');
            return null;
        }
    }
    
    /**
* Parses a Comma Seperated String to a Set of Strings. Returns null for a blank string. Trims string values
* @param str String value to parse to a list.
* @return Set<String> List of string
*/
    Private static Set<String> parseCommaSeperatedList(String str){
        if (String.isBlank(str)){
            return null;
        }
        else {
            Set<String> setToReturn = new Set<String>();
            for (String strValue : str.split(',')){
                setToReturn.add(strValue.trim());
            }
            return setToReturn;
        }
    }
    
    /**
* Class to return when a custom error is thrown.
*/
    global class ExceptionResponse {
        global String errorCode;
        global String message;
        
        /**
* Constructor.
* @param errorCode Type of error: e.g. CUSTOM_ERROR.
* @param message Fault string.
*/
        ExceptionResponse(String errorCode, String message){
            this.errorCode = errorCode;
            this.message = message;
        }
    }
    
    
    /**
* Class to return when call is succesfull.
*/
    global class ReturnWrapper {
        global integer totalSize;
        global integer totalRecords;
        List<ReturnRecord> records;
        
        
        /**
* Constructor.
* @param records List of records to be returned.
* @param totalRecords Total amount of records matching the query (ignores Limit and Offset)
*/
        ReturnWrapper(List<ReturnRecord> records, Integer totalRecords){
            this.totalSize = records.size();
            this.totalRecords = totalRecords;
            this.records = records;
            
        }
        
        private String toJson(){
            String str = '{' +
                '"totalSize":' + this.totalSize +
                ',"totalRecords":' + this.totalRecords +
                ',"records":[';
            
            for (ReturnRecord r : this.records){
                str += r.toJson() + ',';
            }
            str = str.removeEnd(',');
            str += ']}';
            return str;
            
        }
        
    }
    
    /**
* Class to consolidate Lead and Opportuny records
* Implements Comparable so we can use the List.Sort() functionality
* TODO: Check if we can write our own Sort function. Might be able to do this more efficiently since both lists are already sorted.
*/
    global class ReturnRecord implements Comparable{
        global DateTime CreatedDate;
        global String Company;
        global String CompanySegment;
        global String CountryCode;
        global String Email;
        global String FirstName;
        global String Id;
        global DateTime LastModifiedDate;
        global String LastName;
        global String LeadDescription;
        global String PartnerContact;
        global String PartnerPortalReferralStatus;
        global String Phone;
        global Date ReferralAddedDate;
        global String SalesChannelSingle;
        global String Title;
        global String sObjectType;
        global String Website;
        global String ReachOutToPartnerFirst;
        
        /**
* Constructor for a lead record.
* @param ld lead to process
*/
        ReturnRecord(lead ld){
            this.CreatedDate = ld.CreatedDate;
            this.Company = ld.Company;
            this.CompanySegment = ld.Company_Segment__c;
            this.CountryCode = ld.CountryCode;
            this.Email = ld.Email;
            this.FirstName = ld.FirstName;
            this.Id = ld.Id;
            this.LastModifiedDate = ld.LastModifiedDate;
            this.LastName = ld.lastName;
            this.LeadDescription = ld.LeadDescription__c;
            this.PartnerContact = ld.PartnerContact__c;
            this.PartnerPortalReferralStatus = ld.Partner_Portal_Referral_Status__c;
            this.ReferralAddedDate = ld.ReferralAddedDate__c;
            this.Phone = ld.Phone;
            this.SalesChannelSingle = ld.SalesChannelSingle__c;
            this.Title = ld.Title;
            this.sObjectType = 'Lead';
            this.Website = ld.Website;
            this.ReachOutToPartnerFirst = ld.ReachOutToPartnerFirst__c;
        }
        
        
        /**
* Constructor for a lead record.
* @param opp Opportunity to process
*/
        ReturnRecord(Opportunity opp){
            this.CreatedDate = opp.CreatedDate;
            this.Company = opp.Account.Name;
            this.CompanySegment = opp.Account_Company_Segment__c;
            this.CountryCode = opp.CountryMerchant__c;
            this.Email = opp.Opportunity_Primary_Contact__r.Email;
            this.FirstName = opp.Opportunity_Primary_Contact__r.FirstName;
            this.Id = opp.Id;
            this.LastModifiedDate = opp.LastModifiedDate;
            this.LastName = opp.Opportunity_Primary_Contact__r.LastName;
            this.LeadDescription = String.isBlank(opp.Description) ? opp.ConvertedLeadDescription__c : opp.Description;
            //this.PartnerContact = opp.PartnerContact__c;
            this.PartnerPortalReferralStatus = opp.Partner_Portal_Referral_Status__c;
            this.Phone = opp.Opportunity_Primary_Contact__r.Phone;
            this.ReferralAddedDate = opp.ReferralAddedDate__c;
            this.SalesChannelSingle = opp.Sales_Channel__c;
            this.Title = opp.Opportunity_Primary_Contact__r.Title;
            this.sObjectType = 'Opportunity';
            this.Website = opp.Account.Website;
            
            //this.ReachOutToPartnerFirst = ld.ReachOutToPartnerFirst__c;
        }
        
        
        
        /**
* CompareTo function for the Comparable Interface
* @param compareTo record to compare to.
*/
        global Integer compareTo(Object compareTo) {
            // Cast argument to ReturnRecord type
            ReturnRecord compareToRecord = (ReturnRecord)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (LastModifiedDate > compareToRecord.LastModifiedDate) {
                // Set return value to a positive value.
                returnValue = -1;
            } else if (LastModifiedDate < compareToRecord.LastModifiedDate) {
                // Set return value to a negative value.
                returnValue = 1;
            } else if ((LastModifiedDate == null) && (compareToRecord.LastModifiedDate != null)){
                // nulls-first implementation
                returnValue = 1;
            } else if ((LastModifiedDate != null) && (compareToRecord.LastModifiedDate == null)){
                // nulls-first implementation
                returnValue = -1;
            }        
            return returnValue;       
        }
        
        private String toJson(){
            String str = '{' +
                fieldToJson('CreatedDate', CreatedDate) +
                fieldToJson('Company', Company) +
                fieldToJson('Company_Segment__c', CompanySegment) +
                fieldToJson('CountryCode', CountryCode) +
                fieldToJson('Email', Email) +
                fieldToJson('FirstName', FirstName) +
                fieldToJson('Id', Id) +
                fieldToJson('LastModifiedDate', LastModifiedDate) +
                fieldToJson('LastName', LastName) +
                fieldToJson('LeadDescription__c', LeadDescription) +
                fieldToJson('PartnerContact__c', PartnerContact) +
                fieldToJson('Partner_Portal_Referral_Status__c', PartnerPortalReferralStatus) +
                fieldToJson('ReferralAddedDate__c', ReferralAddedDate) +
                fieldToJson('Phone', Phone) +
                fieldToJson('SalesChannelSingle__c', SalesChannelSingle) +
                fieldToJson('Title', Title) +
                fieldToJson('sObjectType', sObjectType) +
                fieldToJson('Website', Website) +
                fieldToJson('ReachOutToPartnerFirst__c', ReachOutToPartnerFirst);
            str = str.removeEnd(',') + '}';
            return str;
        }
        
    }
    
    private static String fieldToJson(String fieldName, String value){
        return (String.isBlank(value) ? '' : '"' + fieldName + '":"' + value.escapeJava() + '",');
    }
    
    private static String fieldToJson(String fieldName, Integer value){
        return (value == null ? '' : '"' + fieldName + '":' + value + ',');
    }
    
    private static String fieldToJson(String fieldName, DateTime value){
        return (value == null ? '' : '"' + fieldName + '":"' + value.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + '",');
    }
    
    
    
    private static String fieldToJson(String fieldName, Date value){
        
        return (value == null ? '' : '"' + fieldName + '":"' + intToString(value.year(), 4) + '-' + intToString(value.month(), 2) + '-' + intToString(value.Day(),2) + '",');
    }
    
    private static String intToString(Integer i, Integer totalCharacters){
        String str = String.valueOf(i);
        while (str.length() < totalCharacters){
            str = '0' + str;
        }
        return str;
    }
    
    private static Map<String, Map<String, String>> instantiateOrderByFieldMap(){
        Map<String, Map<String, String>> orderByMap = new Map<String, MAP<String, String>>();
        orderByMap.put('CreatedDate', new Map<String, String>{'Lead' => 'CreatedDate', 'Opportunity' => 'CreatedDate', 'ReturnRecord' => 'CreatedDate'});
        orderByMap.put('LastModifiedDate', new Map<String, String>{'Lead' => 'LastModifiedDate', 'Opportunity' => 'LastModifiedDate', 'ReturnRecord' => 'LastModifiedDate'});
        orderByMap.put('ReferralAddedDate__c', new Map<String, String>{'Lead' => 'ReferralAddedDate__c', 'Opportunity' => 'ReferralAddedDate__c', 'ReturnRecord' => 'ReferralAddedDate'});
        orderByMap.put('Company', new Map<String, String>{'Lead' => 'Company', 'Opportunity' => 'Account.Name', 'ReturnRecord' => 'Company'});
        return orderByMap;
    }
}