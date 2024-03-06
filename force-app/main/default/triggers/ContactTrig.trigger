/**
 * @description   : Trigger on the Contact. Business logic in the ContactHelper
 * @author (s)    : BRITE
 */
trigger ContactTrig on Contact (after update) {
    if (trigger.isAfter) {
        if (trigger.isUpdate) {
            ContactHelper.setAccountSharing(trigger.new, trigger.oldMap);
        }
    }    
}