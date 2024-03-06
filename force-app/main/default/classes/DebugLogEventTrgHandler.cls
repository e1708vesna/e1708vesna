/**
* @author Sales
* @group Trigger Handler
* @description Handler class for DebugLogEventTrg
*/
public class DebugLogEventTrgHandler {
	
    public static void createDebugLogs(List<DebugLogEvent__e> debugLogEventsNew) {
        List<DebugLog__c> debugLogs = new List<DebugLog__c>();
        for(DebugLogEvent__e logEvent : debugLogEventsNew) {
            DebugLog__c log = new DebugLog__c();
            log.ApexClass__c = logEvent.ApexClassEvent__c;
            log.LightningComponentName__c = logEvent.lightningComponentNameEvent__c;
            log.MethodName__c = logEvent.MethodNameEvent__c;
            log.ExceptionType__c = logEvent.ExceptionTypeEvent__c;
            log.MessageLong__c = logEvent.MessageEvent__c;
            log.RecordIdOrData__c = logEvent.RecordIdOrDataEvent__c;
            log.StackTrace__c = logEvent.StackTraceEvent__c;
            log.Type__c = logEvent.TypeEvent__c;
            debugLogs.add(log);
        }
        if(debugLogs.isEmpty() == false) {
            try {
                insert debugLogs;
            }
            catch(Exception ex) {
                List<ApexDebugLog.Error> errorLogs = new List<ApexDebugLog.Error>();
                ApexDebugLog.Error errorLog = new ApexDebugLog.Error(
                    	'DebugLogEventTrgHandler',
                        'debugLogEventsNew',
                        String.join(debugLogs, ','),
                        ex);
                errorLogs.add(errorLog);
                ApexDebugLog.createLog(errorLogs);
            }
        }
    }

}