public inherited sharing class SObjectRecordTypeInvocableJelle {
    /*
* @name SObjectRecordTypeInvocable
* @author BRITE
* @group Invocable Apex
* @description This class contains the invocable method to retreive a list of record types that the running user can create for a SObject
*/ 
    public static List<RecordType> getRecordTypes(String objTypeStr) {
        
        List<RecordTypeInfo> infos = Schema.getGlobalDescribe().get(objTypeStr).getDescribe().getRecordTypeInfos();
        List<String> recTypeDevNameList = new List<String> ();
        List<RecordType> recordTypeList = new List<RecordType> ();
        
        if (infos.size() > 1) {
            for (RecordTypeInfo i : infos) {
                if (i.isAvailable())
                    recordTypeList.add(createRecordType(i));
            }
        } 
        else {
            recordTypeList.add(createRecordType(infos[0]));
        }
        return recordTypeList;
        
    }
    
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
    
    private static RecordType createRecordType(RecordTypeInfo i){
        return new RecordType(Id = i.getRecordTypeId(), Name = i.getName(), DeveloperName = i.getDeveloperName(), isActive = i.isActive());
    }
}


// JTAL: Instead of using sObjectList[0] try doing this in a for loop for each item in the list.
// Consider the invocable method that fires on 2 cases. This invocable method return an owner based on the topic field. If you use inputList[0] you will only perform the invocable method for the first case.
// It is also important that the return list is just as big as the input list. For each member of the inputlist you need to have a return value.