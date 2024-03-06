/**
 * @description	  : RecordTypeUtil class is a helper class to retrieve all, or a specific, record type from the database.
 * @author (s)    : BRITE
 */
public class RecordTypeUtil {
    
    private static Map<String, Id> recordTypeMap;

    /**
     * @description Get requested record type if exists, otherwise null
     *
     * @param recordTypeDevName Developer name of the record type.
     * @param sobjectType SobjectType of the record type, i.e. Account, Contact, Opportunity.
     * @return Returns the id of the requested record type if found, otherwise null.
     */
    public static Id getRecordTypeIdByDevName(String recordTypeDevName, Schema.SObjectType sobjectType) {
        if (recordTypeMap == null) {
            // retrieve all record types at once from the database, and 'cache' it
            getAllRecordTypes();
        }
        
        return recordTypeMap.get(sobjectType + '___' + recordTypeDevName);
    }    

    
    /* PRIVATE METHODS */


    /**
     * @description Get all record types.
     */
    private static void getAllRecordTypes() {
        List<RecordType> recordTypeList;
        
        if (recordTypeMap == null) {
            recordTypeList = [SELECT Id, DeveloperName, SobjectType FROM RecordType];
                           
            recordTypeMap = new Map<String, Id>();
            for (RecordType r : recordTypeList) {
                recordTypeMap.put(r.SobjectType + '___' + r.DeveloperName, r.Id);
            }
        }
    }

}