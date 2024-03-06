/**
 * @author    stvb
 * @copyright {@link https://sidekickit.nl Sidekick-IT}
 */

global with sharing class OrtooCleanupSchedule implements Schedulable
{
    /**
     * Const. for the amount of days after which uploads should be deleted.
     */
    global static final Integer DEFAULT_DOCUMENT_RETENTION = 14;

    /**
     * Starting point for execution.
     *
     * @param context
     */
    global void execute(SchedulableContext context)
    {
        OrtooCleanupHelper.cleanupEmailMessageContentDocuments(DEFAULT_DOCUMENT_RETENTION);
    }
}