public class HistoryRelatedListLghtCtrl {
	
    // wrapper or Inner class with @AuraEnabled {get;set;} properties*    
    public class HistoryRecord{
        @AuraEnabled public DateTime CreatedDate;
        @AuraEnabled public String CreatedDateFormatted;
        @AuraEnabled public String CreatedById;
        @AuraEnabled public String CreatedByName;
        @AuraEnabled public String FieldName;
        @AuraEnabled public String NewValue;
        @AuraEnabled public String OldValue;
        @AuraEnabled public String NewValueLink;
        @AuraEnabled public String OldValueLink;
        @AuraEnabled public String ParentId;
        @AuraEnabled public String RecordId;
        @AuraEnabled public String LinkToRecord;
        
        HistoryRecord(History__c hr){
            this.CreatedDate = hr.CreatedDate;
            this.CreatedById = hr.CreatedById;
            this.CreatedByName = hr.CreatedBy.Name;
            this.CreatedDateFormatted = (String) hr.get('CreatedDateFormatted');
            this.FieldName = hr.FieldName__c;
            this.NewValue = hr.NewValue__c;
            this.OldValue = hr.OldValue__c;
            this.ParentId = hr.ParentId__c;
            this.RecordId = hr.RecordId__c;
            this.LinkToRecord = hr.LinkToRecord__c;
        }
        
        HistoryRecord(Id recordId, sObject standardHistory, String newValueLink, String oldValueLink){
            this.CreatedDate = (DateTime) standardHistory.get('CreatedDate');
            this.CreatedDateFormatted = (String) standardHistory.get('CreatedDateFormatted');
            this.CreatedById = (String) standardHistory.get('CreatedById');
            this.CreatedByName = (String) standardHistory.getSobject('CreatedBy')?.get('Name');
            this.FieldName = (String) standardHistory.get('Field');
            this.NewValue = String.valueOf(standardHistory.get('NewValue')); 
            this.OldValue = String.valueOf(standardHistory.get('OldValue'));
            this.ParentId = recordId;
            this.RecordId = recordId;
            this.LinkToRecord = '/' + recordId;
        }
    }
    
    /*private static boolean recordAccessChecked = false;

    private static void checkRecordAccess(string recordId){
        if (recordAccessChecked){
            return;
        }
        List<UserRecordAccess> accessList = [SELECT RecordId FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND HasReadAccess = true AND RecordId = :recordId];
        if (accessList == null || accessList.size() == 0){
            throw new NoAccessException();
        }
        recordAccessChecked = true;
    }*/
    @AuraEnabled
    public static List<HistoryRecord> getHistory(string parentId, integer maxItems, String historyType, Boolean includeStandardHistory){
        Set<String> historyTypes = splitStringByComma(historyType);
        List<HistoryRecord> standardHistory = includeStandardHistory ? getStandardHistory(parentId, maxItems) : new List<HistoryRecord>();
        List<History__c> customHistory = getCustomHistory(parentId, maxItems, historyTypes);
        List<HistoryRecord> history = new List<HistoryRecord>();
        integer indexStandard = 0;
        integer indexCustom = 0;
        
        While ((indexStandard < standardHistory.size() || indexCustom < customHistory.size() ) && history.size() < maxItems + 1){
            if (indexStandard == standardHistory.size() && indexCustom <  customHistory.size()){
                history.add(new HistoryRecord(customHistory[indexCustom]));
                indexCustom++;
            }
            else if (indexStandard < standardHistory.size() && indexCustom == customHistory.size()){
                history.add(standardHistory[indexStandard]);
                indexStandard++;
            }
            else {
                if (standardHistory[indexStandard].CreatedDate > customHistory[indexCustom].CreatedDate ){
                    history.add(standardHistory[indexStandard]);
                    indexStandard++;
                }
                else {
                    history.add(new HistoryRecord(customHistory[indexCustom]));
                    indexCustom++;
                }
            }
        }
        return history;
    }
    
    private static List<HistoryRecord> getStandardHistory(string parentId, integer maxItems){
        List<HistoryRecord> returnList = new List<HistoryRecord>();
        Schema.SObjectType sobjectType = ((ID)parentId).getSObjectType();
        String ObjectName = sobjectType.getDescribe().getName();
        integer queryLimit = maxItems + 1;
        Set<String> fieldNames = new Set<String>();
        
        
        String query = 'SELECT Id, (SELECT DataType, Format(CreatedDate) CreatedDateFormatted, CreatedDate, CreatedById, CreatedBy.Name, toLabel(Field), OldValue, NewValue FROM Histories WHERE DataType != \'EntityId\' ORDER BY CreatedDate DESC) FROM ' + ObjectName + ' WHERE Id = :parentId LIMIT :queryLimit';
        
        List<sObject> record = Database.query(query);
        if (record.size() > 0){
            
            List<sObject> historyList = (List<sObject>) record[0].getSObjects('Histories');
            if (historyList != null) {
                for (integer i = 0; i < historyList.size(); i++){
                    returnList.add(new HistoryRecord(
                        record[0].Id, 
                        historyList[i], 
                        null, 
                        null
                    ));
                    
                }//End Loop
            }
        }
        return returnList;
    }
                        
                        
                        
                        
    private static List<History__c> getCustomHistory(string parentId, integer maxItems, Set<String> historyTypes){
        integer queryLimit = maxItems + 1;
        List<History__c> returnList;
        if(historyTypes == null || historyTypes.size() == 0 || historyTypes.contains('All')){
            returnList = [Select format(CreatedDate) CreatedDateFormatted, CreatedDate, CreatedById, CreatedBy.Name, FieldName__c, NewValue__c, OldValue__c, ParentId__c, RecordId__c, LinkToRecord__c From History__c Where ParentId__c = :parentId ORDER BY CreatedDate DESC];
        
        }
        else {
            returnList = [Select format(CreatedDate) CreatedDateFormatted, CreatedDate, CreatedById, CreatedBy.Name, FieldName__c, NewValue__c, OldValue__c, ParentId__c, RecordId__c, LinkToRecord__c From History__c Where ParentId__c = :parentId AND ObjectName__c in: historyTypes ORDER BY CreatedDate DESC];
        }
        return returnList;
    }
    
    
    @AuraEnabled
    public static Map<String, object> getRecordInfoFiltered(string parentId, String historyType, Boolean includeStandardHistory){
        //checkRecordAccess(parentId);
        Map<String, object> returnMap = new Map<String, object>();
        Schema.SObjectType sobjectType = ((ID)parentId).getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        
        SObject record = Database.query('Select Name From ' + sobjectName + ' Where Id = :parentId');
        
        returnMap.put('recordName', record.get('Name'));
        returnMap.put('objectName', sobjectName);
        returnMap.put('records', getHistory(parentId, 9999, historyType, includeStandardHistory));
        return returnMap;
    }
    
    private static Set<String> splitStringByComma(String str){
        Set<String> stringSet = new Set<String>();
        if (!String.isBlank(str)){
            //Get a list of strings
            List<String> stringsUntrimmed = str.split(',');
            for (String stringValue : stringsUntrimmed){
                String stringTrimmed = stringValue.trim();
                if (!String.isBlank(stringTrimmed)){
                    stringSet.add(stringTrimmed);
                }
            }
        }
        return stringSet;
    }
    
}