/*
* @Name SObjectRecordTypeInvocableTest
* @Author BRITE
* @Group Test Class
* @Description Test class for the SObjectRecordTypeInvocableTest
*/ 
@isTest
private class SObjectRecordTypeInvocableTest {

    @testSetup
    private static void testSetup() {
        User agent = ServicesTestUtil.createUser('Basic Service', 'ServiceGenericUser', false);
        agent.LastName = 'NoRecordTypesAssigned';
        
        User agent2 = ServicesTestUtil.createUser('Basic Service', 'ServiceGenericUser', false);
        agent2.LastName = 'ServiceCaseAssigned';
            
        insert new List<sObject>{agent, agent2};
        List<sObject> permissions = new List<sObject>();        
        permissions.addAll(ServicesTestUtil.assignPermissionsToUser (
                new List<User>{agent2},
                new Set<String> {},
                new Set<String> {'BasicServiceSupport'}, //BasicServiceSupport only has the Support RecordType assigned
                false));
        insert permissions;
    }
    
    
    @isTest
    private static void getRecordTypesNoneAssigned() {
        System.runAs([SELECT Id FROM User WHERE LastName = 'NoRecordTypesAssigned' LIMIT 1][0]) {
        	List<RecordType> recordTypes = SObjectRecordTypeInvocable.getRecordTypes('Case');
            System.assertEquals(0, recordTypes.size(), 'Expected the agent to not have access to record types, did the profile \'ServiceGenericUser\'change?');
        }
    }
    
    @isTest
    private static void getRecordTypesOneAssigned() {
        System.runAs([SELECT Id FROM User WHERE LastName = 'ServiceCaseAssigned' LIMIT 1][0]) {
        	List<RecordType> recordTypes = SObjectRecordTypeInvocable.getRecordTypes('Case');
            System.assertEquals(2, recordTypes.size(), 'Expected the agent to only have access to two record type, did the permissionset \'BasicServiceSupport\'change?');
        }
    }
    
    @isTest
    private static void getRecordTypesNoneAssignedInvoke() {
        System.runAs([SELECT Id FROM User WHERE LastName = 'NoRecordTypesAssigned' LIMIT 1][0]) {
            String sObjName = 'Case';
            SObjectRecordTypeInvocable.SObjectInput sobjInput = new SObjectRecordTypeInvocable.SObjectInput();
            sobjInput.sObjectName = sObjName;
            List<SObjectRecordTypeInvocable.RecordTypesOutput> rtOutput = SObjectRecordTypeInvocable.invokeRecordTypes(new List<SObjectRecordTypeInvocable.SObjectInput>{sobjInput});
            System.assertEquals(1, rtOutput.size(), 'Expected one element in outputlist.');
            System.assertEquals(0, rtOutput[0].recordTypes.size(), 'Expected no recordtypes to be assigned, did the profile \'ServiceGenericUser\'change?');
        }
    }
    
    @isTest
    private static void getRecordTypesInvokeBatch() {
        System.runAs([SELECT Id FROM User WHERE LastName = 'NoRecordTypesAssigned' LIMIT 1][0]) {
            String sObjName = 'Case';
            SObjectRecordTypeInvocable.SObjectInput sobjInput = new SObjectRecordTypeInvocable.SObjectInput();
            sobjInput.sObjectName = sObjName;
            List<SObjectRecordTypeInvocable.RecordTypesOutput> rtOutput = SObjectRecordTypeInvocable.invokeRecordTypes(new List<SObjectRecordTypeInvocable.SObjectInput>{sobjInput, sobjInput});
            System.assertEquals(2, rtOutput.size(), 'Expected two elements in outputlist.');
        }
    }
    
}