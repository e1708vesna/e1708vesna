/**
 * @description General case trigger handler that triggers the filtering on record types and populates the old and new case lists and maps.
 */
public class EmailMessageTrgHndl extends TriggerHandler {
    
    public override void beforeInsert() {
        EmailMessageHlpr.cloneClosedCaseBeforeInsert((List<EmailMessage>) Trigger.new);
    }
    
    
}