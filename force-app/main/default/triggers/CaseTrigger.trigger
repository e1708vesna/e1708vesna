/**
 * @description This is the main Case handler. Its purpose is to redirect to sales and service case management.
 */
trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete) {

    if (!FeatureManagement.checkPermission('BypassCaseTriggerValidationMigration')){
        if (Trigger.isBefore && Trigger.isInsert) {
            CaseHelper.setUserOnCase(Trigger.new);
        }
        
        new CaseServiceTrgHndl().run();
        new CaseSalesTrgHndl().run();
    }

}