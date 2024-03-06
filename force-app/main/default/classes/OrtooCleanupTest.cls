/**
 * @author    stvb
 * @copyright {@link https://sidekickit.nl Sidekick-IT}
 */

@isTest
private class OrtooCleanupTest
{
    private static ortoo_e2a__EmailMessage__c factoryTestCase()
    {
        // Create new document (version)
        ContentVersion documentVersion = new ContentVersion();
        documentVersion.PathOnClient = 'test.txt';
        documentVersion.Title = 'test.txt';
        documentVersion.VersionData = Blob.valueOf('test data');
        insert documentVersion;

        // Fetch the document id in order to create a link
        Id documentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :documentVersion.Id].ContentDocumentId;

        // Create new email message
        ortoo_e2a__EmailMessage__c emailMessage = new ortoo_e2a__EmailMessage__c(Name='Test Email Message');
        insert emailMessage;

        // Link the document to the email message
        ContentDocumentLink documentLink = new ContentDocumentLink();
        documentLink.ContentDocumentId = documentId;
        documentLink.LinkedEntityId = emailMessage.Id;
        documentLink.ShareType = 'I';
        insert documentLink;

        return emailMessage;
    }

    @isTest
    private static void testCleanupEmailMessageContentDocuments()
    {
        ortoo_e2a__EmailMessage__c emailMessage = factoryTestCase();

        Test.startTest();
        List<ContentDocument> deletedDocuments = OrtooCleanupHelper.cleanupEmailMessageContentDocuments(-1);
        System.assert(deletedDocuments.size() > 0, 'No documents deleted');
        Test.stopTest();
    }

    @isTest
    private static void testCleanupSchedule()
    {
        ortoo_e2a__EmailMessage__c emailMessage = factoryTestCase();

        Test.startTest();
        String jobId = System.schedule('test job', '0 0 0 * * ?', new OrtooCleanupSchedule());
        Test.stopTest();
    }
}