/**
 * @description This is the main Task handler. Its purpose is to filter the tasks and redirect them to a helper class.
 * @author BRITE
 */
trigger TaskTrg on Task (after insert) {

    if (trigger.isAfter) {
        if (trigger.isInsert) {
            TaskHelper.convertToMarketingActivity(trigger.new);
        }
    }

}