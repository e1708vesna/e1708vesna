/**
* @author Sales - Amy
* @group Reusable Utility
* @description This class houses common methods which can be reused across the codebase
*/
public class Utils {


    /* @Description finds out name of the sObject from Id
     * @Param record : record from which the id needs to be extracted
     * @Param idFieldName : name of the field which holds the id in question
     * @Return String : name of the sObject
     */
    public static String getSObjectNameFromId(sObject record, String idFieldName) {
        Id sObjectId = (Id)record.get(idFieldName);
        return sObjectId.getSObjectType().getDescribe().getName();
    }

    /* @Description uses regex to match a string
     * @Param regexPattern : pattern to be checked
     * @Param input : string to be checked for the pattern
     * @Return Boolean : true if pattern is found, false otherwise
     */
    public static Boolean matchRegexExpression(String regexPattern, String input) {
        Pattern pattern = Pattern.compile(regexPattern);
        Matcher matcher = pattern.matcher(input);
        return matcher.find();
    }

    /* @Description creates information logs to measure running-time of apex features
     * @Param starTime : code execution beginning timestamp
     * @Param endTime : code execution ending timestamp
     * @Param apexClass : apex class for which runtime is getting mesaured
     * @Param method : running method(s)
     * @Param message : message to be included, if any !
     * @Return void
     */
    public static void createRuntimeLog(Time startTime, Time endTime, String apexClass, String method, String message) {
        Integer timeDifferenceInSeconds = endTime.second() - startTime.second();
        ApexDebugLog.Information infoLog = new ApexDebugLog.Information(
                apexClass,
                method,
                String.valueOf(timeDifferenceInSeconds),
                message
        );
        ApexDebugLog.createLog(new List<ApexDebugLog.Information>{ infoLog });
    }

    /* @Description utility method to create error logs from LWC
     * @Param logJSON : logs to be created in JSON format
     * @Return Map<Id, UserRecordAccess> : UserRecordAccess mapping
     */
    @AuraEnabled
    public static void createLogs(String logJSON) {
        try {
            List<ApexDebugLog.LightningComponentError> errorLogs = (List<ApexDebugLog.LightningComponentError>)JSON.deserialize(logJSON, ApexDebugLog.LightningComponentError.class);
            ApexDebugLog.createLog(errorLogs);
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* TEST UTILS */

    public static boolean checkSharingReason(List<sObject> shares) {
        Map<String, String> sharingReasonMapping = new Map<String, String>{
                'APEXSHARINGREASONSOW' => 'AMPoolSOW__c',
                'APEXSHARINGREASONAPC' => 'AMPoolAPC__c'
        };
        Boolean result = true;
        String objectName = Utils.getSObjectNameFromId(shares[0], 'ParentId');
        String sharingReason = objectName == 'ShareOfWallet__c' ? sharingReasonMapping.get('APEXSHARINGREASONSOW') : sharingReasonMapping.get('APEXSHARINGREASONAPC');
        for(sObject share : shares) {
            if(share.get('RowCause') != sharingReason) {
                result = false;
                break;
            }
        }
        return result;
    }

    public static boolean checkAccessLevel(List<sObject> shares, String accessLevel) {
        Boolean result = true;
        for(sObject share : shares) {
            if(share.get('AccessLevel') != accessLevel) {
                result = false;
                break;
            }
        }
        return result;
    }

    /* @Description fetches UserRecordAccess mapping for the passed in records
     * @Param records : list of records to be checked
     * @Param userId : user id for which the access needs to be checked
     * @Param recordIdFieldName : field on the record which holds the id of the record in question
     * @Return Map<Id, UserRecordAccess> : UserRecordAccess mapping
     */
    public static Map<Id, UserRecordAccess> fetchRecordAccessMapping(List<sObject> records, Id userId, String recordIdFieldName) {
        Set<Id> recordIds = new Set<Id>();
        for(sObject record : records) {
            recordIds.add((Id)record.get(recordIdFieldName));
        }
        Map<Id, UserRecordAccess> recordAccessMapping = new Map<Id, UserRecordAccess>([
                SELECT RecordId
                FROM UserRecordAccess
                WHERE UserId = :userId AND HasEditAccess = true AND RecordId IN :recordIds
        ]);
        return recordAccessMapping;
    }

    /* TEST UTILS */
}