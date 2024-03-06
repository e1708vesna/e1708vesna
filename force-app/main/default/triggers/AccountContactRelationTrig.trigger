/**
 * @description   : Trigger on the AccountContactRelation. Business logic in the AccountContactRelationHelper
 * @author (s)    : Brite
 */
trigger AccountContactRelationTrig on AccountContactRelation (after insert, after delete) {

    if (trigger.isAfter) {
        if (trigger.isInsert) {
            AccountContactRelationHelper.createAccountSharing(trigger.new);
        }
        if (trigger.isDelete) {
            AccountContactRelationHelper.deleteAccountSharing(trigger.old);
        }
    }

}