/**
* @author Sales
* @group Test
* @description Test Class for ApexDebugLog
*/
@IsTest
private class ApexDebugLogTest {
    
    /* @Scenario: Create Error Debug Log */
    @IsTest
    public static void createErrorLogTest() {
        Exception caughtException;
        Test.startTest();
        try {
            Contact invalidContact = new Contact(LastName = 'Test');
            insert invalidContact;
        }
        catch(Exception ex) {
            caughtException = ex;
            List<ApexDebugLog.Error> errorLogs = new List<ApexDebugLog.Error>();
            ApexDebugLog.Error errorLog = new ApexDebugLog.Error(
                    'ApexDebugLogTest',
                    'createErrorLogTest',
                    '',
                    ex);
            errorLogs.add(errorLog);
            ApexDebugLog.createLog(errorLogs);
        }
        Test.stopTest();
        DebugLog__c generatedErrorLog = [SELECT Id, Type__c, ApexClass__c, ExceptionType__c, Message__c, MethodName__c, RecordIdOrData__c, StackTrace__c
                               FROM DebugLog__c
                               ];
        Assert.isNotNull(generatedErrorLog, 'Error Log Generated Successfully');
        Assert.areEqual('Error', generatedErrorLog.Type__c, 'Expected Debug Log of type Error');
        Assert.areEqual('ApexDebugLogTest', generatedErrorLog.ApexClass__c, 'Expected value ApexDebugLogTest');
        Assert.areEqual('createErrorLogTest', generatedErrorLog.MethodName__c, 'Expected value createErrorLogTest');
        Assert.isNull(generatedErrorLog.RecordIdOrData__c, 'Expected no value since we did not pass anything');
        Assert.areEqual(caughtException.getStackTraceString(), generatedErrorLog.StackTrace__c, 'Expected stack trace from exception');
        Assert.areEqual(caughtException.getMessage(), generatedErrorLog.Message__c, 'Expected error message from exception');
        Assert.areEqual(caughtException.getTypeName().split('\\.')[1], generatedErrorLog.ExceptionType__c, 'Expected Exception Type from exception');
     }
    
    /* @Scenario: Create Information Debug Log */
    @IsTest
    public static void createInformationLogTest() {
        List<ApexDebugLog.Information> infoLogs = new List<ApexDebugLog.Information>();
        ApexDebugLog.Information infoLog = new ApexDebugLog.Information(
              'ApexDebugLogTest',
               'createInformationLogTest',
               '',
               'Test Information Log');
        infoLogs.add(infoLog);
        Test.startTest();
        ApexDebugLog.createLog(infoLogs);
        Test.stopTest();
        DebugLog__c generatedInfoLog = [SELECT Id, Type__c, ApexClass__c, ExceptionType__c, Message__c, MethodName__c, RecordIdOrData__c, StackTrace__c
                               FROM DebugLog__c
                               ];
        Assert.isNotNull(generatedInfoLog, 'Info Log Generated Successfully');
        Assert.areEqual('Information', generatedInfoLog.Type__c, 'Expected Debug Log of type Information');
        Assert.areEqual('ApexDebugLogTest', generatedInfoLog.ApexClass__c, 'Expected value ApexDebugLogTest');
        Assert.areEqual('createInformationLogTest', generatedInfoLog.MethodName__c, 'Expected value createInformationLogTest');
        Assert.isNull(generatedInfoLog.RecordIdOrData__c, 'Expected no value since we did not pass anything');
        Assert.isNull(generatedInfoLog.StackTrace__c, 'Expected no value since information logs dont contain stack trace');
        Assert.areEqual('Test Information Log', generatedInfoLog.Message__c, 'Expected error message passed in from method');
        Assert.isNull(generatedInfoLog.ExceptionType__c, 'Expected Exception Type of None');
    }

    /* @Scenario: Create Warning Debug Log */
    @IsTest
    public static void createWarningLogTest() {
        List<ApexDebugLog.Warning> warningLogs = new List<ApexDebugLog.Warning>();
        ApexDebugLog.Warning warningLog = new ApexDebugLog.Warning(
                'ApexDebugLogTest',
                'createWarningLogTest',
                '',
                'Test Warning Log');
        warningLogs.add(warningLog);
        Test.startTest();
        ApexDebugLog.createLog(warningLogs);
        Test.stopTest();
        DebugLog__c generatedWarningLog = [SELECT Id, Type__c, ApexClass__c, ExceptionType__c, Message__c, MethodName__c, RecordIdOrData__c, StackTrace__c
        FROM DebugLog__c
        ];
        Assert.isNotNull(generatedWarningLog, 'Warning Log Generated Successfully');
        Assert.areEqual('Warning', generatedWarningLog.Type__c, 'Expected Debug Log of type Warning');
        Assert.areEqual('ApexDebugLogTest', generatedWarningLog.ApexClass__c, 'Expected value ApexDebugLogTest');
        Assert.areEqual('createWarningLogTest', generatedWarningLog.MethodName__c, 'Expected value createWarningLogTest');
        Assert.isNull(generatedWarningLog.RecordIdOrData__c, 'Expected no value since we did not pass anything');
        Assert.isNull(generatedWarningLog.StackTrace__c, 'Expected no value since warning logs dont contain stack trace');
        Assert.areEqual('Test Warning Log', generatedWarningLog.Message__c, 'Expected error message passed in from method');
        Assert.isNull(generatedWarningLog.ExceptionType__c, 'Expected Exception Type to be null');
    }
    
    /* @Scenario: Create Platform Event Error Debug Log */
    @isTest
    public static void handleEventPublishResultsTest() {
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        Database.SaveResult sr = (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"Testing PE failure fallback...","statusCode":"PLATFORM_EVENT_PUBLISHING_UNAVAILABLE"}]}', Database.SaveResult.class);
        results.add(sr);
        Test.startTest();
        ApexDebugLog.handleEventPublishResults(results);
        Test.stopTest();
        DebugLog__c generatedErrorLog = [SELECT Id, Type__c, ApexClass__c, ExceptionType__c, Message__c, MethodName__c, RecordIdOrData__c, StackTrace__c
        FROM DebugLog__c
        ];
        Assert.isNotNull(generatedErrorLog, 'Error Log Generated Successfully');
        Assert.areEqual('Error', generatedErrorLog.Type__c, 'Expected Debug Log of type Error');
        Assert.areEqual('ApexDebugLog', generatedErrorLog.ApexClass__c, 'Expected value ApexDebugLogTest');
        Assert.areEqual('createLogAsync', generatedErrorLog.MethodName__c, 'Expected value createInformationLogTest');
        Assert.isNull(generatedErrorLog.StackTrace__c, 'Expected no value since information logs dont contain stack trace');
        Assert.areEqual('DebugLogEvent__e not published Successfully', generatedErrorLog.Message__c, 'Expected error message passed in from method');
        Assert.areEqual('PlatformEventException', generatedErrorLog.ExceptionType__c, 'Expected Exception Type of None');
    }
}