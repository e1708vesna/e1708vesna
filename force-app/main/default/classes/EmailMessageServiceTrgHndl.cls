/**
 * @description Class to handle Service cloud cases: filter cases based on record type, and start run the methods
 *              for service cloud cases
 */
public without sharing class EmailMessageServiceTrgHndl extends TriggerHandler {

    public override void beforeInsert() {
        EmailMessageHlpr.closeFirstResponseMilestones(Trigger.new);
    }

    public override void afterInsert() {
    }

}