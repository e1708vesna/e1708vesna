/**
 * @author (s)    : Brite
 * @description   : Trigger on the User. Business logic in the UserHelper
 */
trigger UserTrig on User (after insert) {
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            UserHelper.setAccountSharing(trigger.new);
        }
    }    
}