/**
* @author Sales
* @group Utility
* @description Used to define different types of debug logs -
* error & information. Fires DebugLogEvent__e platform events
* with context information to create DebugLog__c records
*/
global class ApexDebugLog {

    /*@Description Defines the structure of a log*/
    public virtual class Log {
        public String type;
        public String apexClass;
        public String lightningComponent;
        public String method;
        public String recordIdOrData;
        public String message;
        public String stackTrace;
        public String exceptionType;
    }

    /*@Description Extends Log and signifies an error log*/
    public virtual class Error extends Log {
        public Error() {

        }
        public Error(String apexClass, String method, String recordIdOrData, Exception ex){
            this.type = 'Error';
            this.apexClass = apexClass;
            this.method = method;
            this.recordIdOrData = recordIdOrData;
            this.message = ex.getMessage();
            this.stackTrace = ex.getStackTraceString();
            this.exceptionType = ex.getTypeName().split('\\.')[1];
        }
    }
    /*@Description Extends Error and signifies an error log from Lightning Web Components*/
    public class LightningComponentError extends Error {
        public LightningComponentError(String componentName, String method, String exceptionType, String message, String stackTrace) {
            this.type = 'Error';
            this.lightningComponent = componentName;
            this.method = method;
            this.message = message;
            this.stackTrace = stackTrace;
            this.recordIdOrData = '';
            this.exceptionType = exceptionType;
        }
    }

    /* @Description Extends Log and signifies an information log*/
    public virtual class Information extends Log {
        public Information() {

        }
        public Information(String apexClass, String method, String recordIdOrData, String message) {
            this.type = 'Information';
            this.apexClass = apexClass;
            this.method = method;
            this.recordIdOrData = recordIdOrData;
            this.message = message;
        }
    }

    /* @Description Extends Log and signifies an warning log*/
    public class Warning extends Log{
        public Warning(String apexClass, String method, String recordIdOrData, String message){
            this.type = 'Warning';
            this.apexClass = apexClass;
            this.method = method;
            this.recordIdOrData = recordIdOrData;
            this.message = message;
        }
    }

    /* @Description creates DebugLogEvent__e records with relevant information
     * @Param logsToGenerate - Log objects passed by the class which wants to log somehting
     * @Return void
     */
    public static void createLog(List<Log> logsToGenerate) {
        List<DebugLogEvent__e> logEvents = new List<DebugLogEvent__e>();
        for(Log log : logsToGenerate) {
            DebugLogEvent__e logEvent = new DebugLogEvent__e();
            logEvent.TypeEvent__c         = log.type;
            logEvent.ApexClassEvent__c   = log.apexClass;
            logEvent.LightningComponentNameEvent__c = log.lightningComponent;
            logEvent.ExceptionTypeEvent__c  = log.method;
            logEvent.RecordIdOrDataEvent__c  = log.recordIdOrData;
            logEvent.MessageEvent__c  = log.message;
            logEvent.MethodNameEvent__c  = log.method;
            logEvent.StackTraceEvent__c = log.stackTrace;
            logEvent.ExceptionTypeEvent__c = log.exceptionType;
            logEvents.add(logEvent);
        }
        publishLogEvent(logEvents);
    }

    /* @Description publishes DebugLogEvent__e events
     * @Param logEvents - List of DebugLogEvent__e events to be published
     * @Return void
     */
    public static void publishLogEvent(List<DebugLogEvent__e> logEvents) {
        List<Database.SaveResult> results = EventBus.publish(logEvents);
        handleEventPublishResults(results);
    }

    /* @Description if there are failures in publishing log events
     * creates DebugLog__c records synchronously for tracking
     * @Param results - Results after publishing platform events
     * @Return void
     */
    public static void handleEventPublishResults(List<Database.SaveResult> results) {
        List<DebugLog__c> eventExceptionLogs = new List<DebugLog__c>();
        for(Database.SaveResult result : results) {
            if(result.isSuccess() == false) {
                DebugLog__c log = new DebugLog__c();
                log.Type__c = 'Error';
                log.ApexClass__c = 'ApexDebugLog';
                log.ExceptionType__c = 'PlatformEventException';
                log.Message__c = 'DebugLogEvent__e not published Successfully';
                log.MethodName__c = 'createLogAsync';
                log.RecordIdOrData__c = String.join(result.getErrors(), ',');
                log.StackTrace__c = null;
                eventExceptionLogs.add(log);
            }
        }
        if(eventExceptionLogs.isEmpty() == false) {
            insert eventExceptionLogs;
        }
    }
}