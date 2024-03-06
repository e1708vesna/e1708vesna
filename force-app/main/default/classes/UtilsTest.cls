/**
* @author sales
* @group Apex Test
* @description Test class for UtilsTest
*/
@isTest
public with sharing class UtilsTest {

    @TestSetup
    public static void createData() {
       TestDataFactory.createSObject('Account', new Map<String, Object>{
                'BillingCountry' => 'Netherlands',
                'RecordTypeId' => Constants.RT_ID_ACC_BUSINESS
        });
    }

    @IsTest
    public static void getSObjectNameFromId() {
        sObject account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        String sObjectName = Utils.getSObjectNameFromId(account, 'Id');
        Test.stopTest();
        Assert.areEqual('Account', sObjectName, 'Object Name received is as expected');
    }

    @IsTest
    public static void fetchRecordAccessMapping() {
        sObject account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Map<Id, UserRecordAccess> accessMapping = Utils.fetchRecordAccessMapping(new List<sObject>{account}, UserInfo.getUserId(), 'Id');
        Test.stopTest();
        Assert.isNotNull(accessMapping, 'Access Mapping is not null as expected');
    }

    @IsTest
    public static void createRuntimeLog() {
        Time startTime = DateTime.now().time();
        Time endTime = Datetime.now().addMinutes(5).time();
        String message = 'Testing creation of runtime logs';
        Test.startTest();
        Utils.createRuntimeLog(startTime, endTime, 'UtilsTest', 'createRuntimeLog', message);
        Test.stopTest();
        DebugLog__c generatedLog = [SELECT Id, ApexClass__c, MethodName__c, Type__c, Message__c, RecordIdOrData__c
                                    FROM DebugLog__c
                                   ];
        Assert.isNotNull(generatedLog, 'Runtime log generated as expected');
        Assert.areEqual('Information', generatedLog.Type__c, 'Runtime log if of Information type as expected');
        Assert.areEqual('UtilsTest', generatedLog.ApexClass__c, 'Apex Class Name populated as expected');
        Assert.areEqual('createRuntimeLog', generatedLog.MethodName__c, 'Method Name populated as expected');
        Assert.areEqual(message, generatedLog.Message__c, 'Message populated as expected');
        Assert.areEqual(endTime.second() - startTime.second(), Integer.valueOf(generatedLog.RecordIdOrData__c));
    }

}