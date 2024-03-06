/*
 * @name SObjectRecordTypeInvocable
 * @author BRITE
 * @group Invocable Apex
 * @description This class contains the invocable method to retrieve a list of record types that the running user can create for a SObject
 */ 
public inherited sharing class SObjectRecordTypeInvocable {

    /**
     * @description Get active AVAILABLE record types for an object. As record types cannot be inactivated when users 
     *      are assigned to it, this method will never return inactive record types.
     *      Available record type means that the user has create access on that record type.
     * 
     * @param objectApiName API name of the SObject.
     * @return Returns a list of record types.
     */
    public static List<RecordType> getRecordTypes(String objectApiName) {       
        List<RecordTypeInfo> infos = Schema.getGlobalDescribe().get(objectApiName).getDescribe().getRecordTypeInfos();
        List<RecordType> recordTypeList = new List<RecordType> ();
        if (infos.size() > 1) {
            // if there are more then one available, the object has custom record types
            for (RecordTypeInfo i : infos) {
                if (i.isAvailable() && !i.isMaster()){
                    recordTypeList.add(createRecordType(i));
                }
            }
        } else {
            // if there is only one available, it will be the master record type; the object has no custom record types
            recordTypeList.add(createRecordType(infos[0]));
        }

        return recordTypeList;        
    }

    /**
     * @description Get active AVAIlABLE record types for an object. This method can be used in flows.
     * 
     * @param sObjectList API name of the sObject for which the available record types should be retrieved.
     * @return Returns a list of record types.
     */
    @InvocableMethod(label='Record Types per User' description='Retrieves a list of all RecordTypes that the running user can create for the SObject')
    public static List<RecordTypesOutput> invokeRecordTypes(List<SObjectInput> sObjectList) {
        List<RecordTypesOutput> resultRTList = new List<RecordTypesOutput> ();
        Map<String, List<RecordType>> recordTypeByObject = new Map<String, List<RecordType>>();
        for (SObjectInput input : sObjectList){
            if (!recordTypeByObject.containsKey(input.sObjectName)){
                recordTypeByObject.put(input.sObjectName, getRecordTypes(input.sObjectName));
            }
            RecordTypesOutput output = new RecordTypesOutput();
            output.recordTypes = recordTypeByObject.get(input.sObjectName);
            resultRTList.add(output);
        }
        return resultRTList;
    }

    public class SObjectInput {
        @InvocableVariable(label='sObject Api Name' description='Available Record Types that the running user can create for the SObject' required=true)
        public String sObjectName;
    }

    public class RecordTypesOutput {
        @InvocableVariable(label='Available Record Types' description='All Record Types that the running user can create' required=true)
        public List<RecordType> recordTypes;
    }

    /**
     * @description Convert a RecordTypeInfo record to a RecordType record.
     */
    private static RecordType createRecordType(RecordTypeInfo rtInfo) {
        return new RecordType (
            Id = rtInfo.getRecordTypeId(), 
            Name = rtInfo.getName(), 
            DeveloperName = rtInfo.getDeveloperName(), 
            isActive = rtInfo.isActive());
    } 

}