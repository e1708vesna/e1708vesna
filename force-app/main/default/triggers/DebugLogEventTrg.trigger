/**
* @author Sales
* @group Trigger
* @description Handles Debug Log platform events
*/
trigger DebugLogEventTrg on DebugLogEvent__e (after insert) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            DebugLogEventTrgHandler.createDebugLogs(Trigger.new);
        }
    }
}