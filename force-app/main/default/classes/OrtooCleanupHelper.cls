/**
 * @author    stvb
 * @copyright {@link https://sidekickit.nl Sidekick-IT}
 */

global with sharing class OrtooCleanupHelper
{
    /**
     * Cleans up all uploads from the ortoo_e2a__EmailMessage__c object if added before today - retentionInDays variable.
     */
    global static List<ContentDocument> cleanupEmailMessageContentDocuments(Integer retentionInDays)
    {
        // Set the delete date to today - retentionInDays
        Datetime deleteDate = Datetime.now().addDays(-retentionInDays);

        System.debug('Looking for messages/uploads modified before ' + deleteDate.formatLong());

        // Add two where statements; One for the upload, and one for the selecting object.
        List<ortoo_e2a__EmailMessage__c> emailMessages = [
                SELECT Id, Name, (SELECT Id, ContentDocument.Id, ContentDocument.Title FROM ContentDocumentLinks WHERE SystemModstamp < :deleteDate)
                FROM ortoo_e2a__EmailMessage__c
                WHERE LastModifiedDate < :deleteDate
        ];

        List<ContentDocument> toBeDeleted = new List<ContentDocument>();
        for (ortoo_e2a__EmailMessage__c emailMessage : emailMessages) {
            for (ContentDocumentLink contentDocumentLink : emailMessage.ContentDocumentLinks) {
                toBeDeleted.add(contentDocumentLink.ContentDocument);

                System.debug(emailMessage.Name + ' - Marking `' + contentDocumentLink.ContentDocument.Title + '` for deletion.');
            }
        }

        if (toBeDeleted.size() > 0) {
            delete toBeDeleted;

            System.debug('Deleted ' + toBeDeleted.size() + ' uploads.');
        } else {
            System.debug('No uploads marked for deletion, aborting.');
        }

        return toBeDeleted;
    }
}