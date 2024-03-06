@isTest
public class CustomHistoryUtilityTest {
    
    
    //Mock Custom Metadata Types.
    private static HistoryConfiguration__mdt mdtRecordUpdate = (HistoryConfiguration__mdt) JSON.deserialize('{"attributes":{"type":"HistoryConfiguration__mdt","url":"/services/data/v54.0/sobjects/HistoryConfiguration__mdt/m0F1w0000008c9oEAA"},"Id":"m0F1w0000008c9oEAA","DeveloperName":"TestContact","FieldSetDeveloperName__c":"CustomHistoryTestClass","HistoryType__c":"Test","NameFieldApiName__c":"LastName","ParentFieldApiName__c":"Id","RunAsyncronous__c":false,"RunOnCreate__c":true,"RunOnDelete__c":true,"ObjectApiName__c":"Contact"}',HistoryConfiguration__mdt.class);
    private static HistoryConfiguration__mdt mdtRecordAsyncUpdate = (HistoryConfiguration__mdt) JSON.deserialize('{"attributes":{"type":"HistoryConfiguration__mdt","url":"/services/data/v54.0/sobjects/HistoryConfiguration__mdt/m0F1w0000008c9oEAA"},"Id":"m0F1w0000008c9oEAA","DeveloperName":"TestContact","FieldSetDeveloperName__c":"CustomHistoryTestClass","HistoryType__c":"Test","NameFieldApiName__c":"LastName","ParentFieldApiName__c":"Id","RunAsyncronous__c":true,"RunOnCreate__c":true,"RunOnDelete__c":true,"ObjectApiName__c":"Contact"}',HistoryConfiguration__mdt.class);
    private static HistoryConfiguration__mdt mdtRecordCreate = (HistoryConfiguration__mdt) JSON.deserialize('{"attributes":{"type":"HistoryConfiguration__mdt","url":"/services/data/v54.0/sobjects/HistoryConfiguration__mdt/m0F1w0000008c9oEAA"},"Id":"m0F1w0000008c9oEAA","DeveloperName":"TestContact","FieldSetDeveloperName__c":"CustomHistoryTestClass","HistoryType__c":"Test","NameFieldApiName__c":"LastName","ParentFieldApiName__c":"AccountId","RunAsyncronous__c":false,"RunOnCreate__c":true,"RunOnDelete__c":true,"ObjectApiName__c":"Contact"}',HistoryConfiguration__mdt.class);
    private static HistoryConfiguration__mdt mdtRecordAsyncCreate = (HistoryConfiguration__mdt) JSON.deserialize('{"attributes":{"type":"HistoryConfiguration__mdt","url":"/services/data/v54.0/sobjects/HistoryConfiguration__mdt/m0F1w0000008c9oEAA"},"Id":"m0F1w0000008c9oEAA","DeveloperName":"TestContact","FieldSetDeveloperName__c":"CustomHistoryTestClass","HistoryType__c":"Test","NameFieldApiName__c":"LastName","ParentFieldApiName__c":"AccountId","RunAsyncronous__c":true,"RunOnCreate__c":true,"RunOnDelete__c":true,"ObjectApiName__c":"Contact"}',HistoryConfiguration__mdt.class);
    private static HistoryConfiguration__mdt mdtRecordDelete = (HistoryConfiguration__mdt) JSON.deserialize('{"attributes":{"type":"HistoryConfiguration__mdt","url":"/services/data/v54.0/sobjects/HistoryConfiguration__mdt/m0F1w0000008c9oEAA"},"Id":"m0F1w0000008c9oEAA","DeveloperName":"TestContact","FieldSetDeveloperName__c":"CustomHistoryTestClass","HistoryType__c":"Test","NameFieldApiName__c":"LastName","ParentFieldApiName__c":"AccountId","RunAsyncronous__c":false,"RunOnCreate__c":true,"RunOnDelete__c":true,"ObjectApiName__c":"Contact"}',HistoryConfiguration__mdt.class);
    private static HistoryConfiguration__mdt mdtRecordAsyncDelete = (HistoryConfiguration__mdt) JSON.deserialize('{"attributes":{"type":"HistoryConfiguration__mdt","url":"/services/data/v54.0/sobjects/HistoryConfiguration__mdt/m0F1w0000008c9oEAA"},"Id":"m0F1w0000008c9oEAA","DeveloperName":"TestContact","FieldSetDeveloperName__c":"CustomHistoryTestClass","HistoryType__c":"Test","NameFieldApiName__c":"LastName","ParentFieldApiName__c":"AccountId","RunAsyncronous__c":true,"RunOnCreate__c":true,"RunOnDelete__c":true,"ObjectApiName__c":"Contact"}',HistoryConfiguration__mdt.class);
        
    
    @isTest
    private static void logHistoryAfterInsertContact(){
        Account acc = TestUtil.createAccount('Test Account', true, true);
        Contact con = TestUtil.createContact('Test Contact', 'contact@example.com', acc.Id, true);
        delete [Select Id From History__c];
        Test.startTest();
        CustomHistoryUtility.testObjectType = 'Contact';
        CustomHistoryUtility.testExecutionMetadataRecord = mdtRecordCreate;
        CustomHistoryUtility.logHistoryAfterInsert(new List<sObject>{con});
        Test.stopTest();
        History__c h = [Select Id, parentId__c, recordid__c, FieldName__c, OldValue__c, NewValue__c From History__c LIMIT 1];
        System.assertEquals('Created Contact', h.FieldName__c);
        System.assertEquals('Test Contact', h.NewValue__c);        
    }
    
    @isTest
    private static void logHistoryAfterUpdateContact(){
        Account acc = TestUtil.createAccount('Test Account', true, true);
        Account acc2 = TestUtil.createAccount('Test Account2', true, true);
        Contact con = TestUtil.createContact('Test Contact', 'contact@example.com', acc.Id, true);
        Contact conOld = con.clone(true);
        con.AccountId = acc2.Id;
        update con;
        delete [Select Id From History__c];
        Test.startTest();
        Contact conNew = [SELECT Id, LastName, AccountId From Contact];
        CustomHistoryUtility.testObjectType = 'Contact';
        CustomHistoryUtility.testExecutionMetadataRecord = mdtRecordUpdate;
        CustomHistoryUtility.logHistoryAfterUpdate(new List<sObject>{conNew}, new Map<Id, sObject> {conOld.Id => conOld});
        Test.stopTest();
        History__c h = [Select Id, FieldName__c, OldValue__c, NewValue__c From History__c LIMIT 1];
        System.assertEquals('Test Account', h.OldValue__c);
        System.assertEquals('Test Account2', h.NewValue__c);
    }
    
    @isTest
    private static void logHistoryAfterDeleteContact(){
        Account acc = TestUtil.createAccount('Test Account', true, true);
        Contact con = TestUtil.createContact('Test Contact', 'contact@example.com', acc.Id, true);
        //delete con;
        delete [Select Id From History__c];
        Test.startTest();
        CustomHistoryUtility.testObjectType = 'Contact';
        CustomHistoryUtility.testExecutionMetadataRecord = mdtRecordDelete;
        CustomHistoryUtility.logHistoryAfterDelete(new List<sObject>{con});
        Test.stopTest();
        History__c h = [Select Id, FieldName__c, OldValue__c, NewValue__c From History__c LIMIT 1];
        System.assertEquals('Deleted Contact', h.FieldName__c);
        System.assertEquals('Test Contact', h.OldValue__c);
    }
    
    @isTest
    private static void logHistoryAfterInsertContactAsync(){
        Account acc = TestUtil.createAccount('Test Account', true, true);
        Contact con = TestUtil.createContact('Test Contact', 'contact@example.com', acc.Id, true);
        delete [Select Id From History__c];
        Test.startTest();
        CustomHistoryUtility.testObjectType = 'Contact';
        CustomHistoryUtility.testExecutionMetadataRecord = mdtRecordAsyncCreate;
        CustomHistoryUtility.logHistoryAfterInsert(new List<sObject>{con});
        Test.stopTest();
        History__c h = [Select Id, parentId__c, recordid__c, FieldName__c, OldValue__c, NewValue__c From History__c LIMIT 1];
        System.assertEquals('Created Contact', h.FieldName__c);
        System.assertEquals('Test Contact', h.NewValue__c);        
    }
    
    @isTest
    private static void logHistoryAfterUpdateContactAsync(){
        Account acc = TestUtil.createAccount('Test Account', true, true);
        Account acc2 = TestUtil.createAccount('Test Account2', true, true);
        Contact con = TestUtil.createContact('Test Contact', 'contact@example.com', acc.Id, true);
        Contact conOld = con.clone(true);
        con.AccountId = acc2.Id;
        update con;
        delete [Select Id From History__c];
        Test.startTest();
        Contact conNew = [SELECT Id, LastName, AccountId From Contact];
        CustomHistoryUtility.testObjectType = 'Contact';
        CustomHistoryUtility.testExecutionMetadataRecord = mdtRecordAsyncUpdate;
        CustomHistoryUtility.logHistoryAfterUpdate(new List<sObject>{conNew}, new Map<Id, sObject> {conOld.Id => conOld});
        Test.stopTest();
        History__c h = [Select Id, FieldName__c, OldValue__c, NewValue__c From History__c LIMIT 1];
        System.assertEquals('Test Account', h.OldValue__c);
        System.assertEquals('Test Account2', h.NewValue__c);
    }
    
    @isTest
    private static void logHistoryAfterDeleteContactAsync(){
        Account acc = TestUtil.createAccount('Test Account', true, true);
        Contact con = TestUtil.createContact('Test Contact', 'contact@example.com', acc.Id, true);
        //delete con;
        delete [Select Id From History__c];
        Test.startTest();
        CustomHistoryUtility.testObjectType = 'Contact';
        CustomHistoryUtility.testExecutionMetadataRecord = mdtRecordAsyncDelete;
        CustomHistoryUtility.logHistoryAfterDelete(new List<sObject>{con});
        Test.stopTest();
        History__c h = [Select Id, FieldName__c, OldValue__c, NewValue__c From History__c LIMIT 1];
        System.assertEquals('Deleted Contact', h.FieldName__c);
        System.assertEquals('Test Contact', h.OldValue__c);
    }
    
    private static boolean validateField(Map<String, Schema.DescribeSObjectResult> ObjectDescribeMap, String sObjectType, String fieldName){
        if (String.isEmpty(fieldName)){ //field is not mandatory
            return true;
        }
        else {
            Schema.DescribeSObjectResult sObjectDescribe;
            if (!ObjectDescribeMap.containsKey(sObjectType)){
                    sObjectDescribe = Schema.describeSObjects(new List<String>{sObjectType})[0];
                    ObjectDescribeMap.put(sObjectType, sObjectDescribe);
            }
            else {
                sObjectDescribe = ObjectDescribeMap.get(sObjectType);
            }
            return sObjectDescribe.fields.getMap().containsKey(fieldName);
        }
    }
    
    private static boolean validateSObjectType(Map<String, Schema.DescribeSObjectResult> ObjectDescribeMap, String sObjectType){
        if (String.isEmpty(sObjectType)){ //sObjectType is mandatory
            return False;
        }
        else {
            Schema.DescribeSObjectResult sObjectDescribe;
            if (!ObjectDescribeMap.containsKey(sObjectType)){
                try { //Check if sObjectType exists
                    sObjectDescribe = Schema.describeSObjects(new List<String>{sObjectType})[0];
                    ObjectDescribeMap.put(sObjectType, sObjectDescribe);
                    return true;
                }
                Catch (Exception e){
                    return false;
                }
            }
            else { //Already validated this sObjectType
                return true;
            }
        }
    }
    
    private static boolean validateFieldSet(Map<String, Schema.DescribeSObjectResult> ObjectDescribeMap, String fieldSet, String sObjectType){
        if (string.isEmpty(fieldSet)){
            return true;
        }
        else {
            Schema.DescribeSObjectResult sObjectDescribe;
            if (!ObjectDescribeMap.containsKey(sObjectType)){
                sObjectDescribe = Schema.describeSObjects(new List<String>{sObjectType})[0];
                ObjectDescribeMap.put(sObjectType, sObjectDescribe);
            }
            else {
                sObjectDescribe = ObjectDescribeMap.get(sObjectType);
            }
            return sObjectDescribe.FieldSets.getMap().containsKey(fieldSet);
        }
        
    }
    
    @isTest
    private static void validateCustomMetadataTypes(){
        Map<String, Schema.DescribeSObjectResult> ObjectDescribeMap = new Map<String, Schema.DescribeSObjectResult>();
        For (HistoryConfiguration__mdt mdt : [SELECT Id, DeveloperName,  FieldSetDeveloperName__c, HistoryType__c, NameFieldApiName__c, ObjectApiName__c, ParentFieldApiName__c, RunAsyncronous__c, RunOnCreate__c, RunOnDelete__c FROM HistoryConfiguration__mdt]){
            System.assertEquals(True, validateSObjectType(ObjectDescribeMap, mdt.ObjectApiName__c), 'Fieldset does not exist for ' + mdt.DeveloperName);
            System.assertEquals(True, validateFieldSet(ObjectDescribeMap, mdt.FieldSetDeveloperName__c, mdt.ObjectApiName__c), 'Fieldset does not exist for ' + mdt.DeveloperName);
            System.assertEquals(True, validateField(ObjectDescribeMap, mdt.ObjectApiName__c, mdt.NameFieldApiName__c), 'Name field does not exist for ' + mdt.DeveloperName);
            System.assertEquals(True, validateField(ObjectDescribeMap, mdt.ObjectApiName__c, mdt.ParentFieldApiName__c), 'ParentFieldApiName field does not exist for ' + mdt.DeveloperName);
        }
    }
}