/**
 * @author (s)    : BRITE
 * @description   : Trigger on the Account. Business logic in the AccountHelper
 */
trigger AccountTrig on Account (after update) {

    if (trigger.isAfter) {
        if (trigger.isUpdate) {
            AccountHelper.createAccountSharing(trigger.new, trigger.oldMap);
        }
    }

}