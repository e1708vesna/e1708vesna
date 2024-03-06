public with sharing class DownloadRelatedFilesLghtCtrl {
    
    
    //Use @AuraEnabled to enable client- and server-side access to the method
    @AuraEnabled
    public static List<ContentDocument> getContentVersions(String recordId) {
        
        //Query EmailMessages
        List<Id> relatedIds = new List<Id>();
        List<EmailMessage> emailMessages = [Select id, ContentDocumentIds from EmailMessage WHERE ParentId =: recordId];
        for (EmailMessage em: emailMessages){
            relatedIds.add(em.Id);
        }
        
        relatedIds.add(recordId);
        List<ContentDocument> documentList = new List<ContentDocument>();
        List<ContentDocumentLink> links = [SELECT Id, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.FileType, ContentDocument.ContentSize FROM ContentDocumentLink WHERE LinkedEntityId in: relatedIds];
        Set<Id> processedDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : links){
            if (processedDocumentIds.contains(link.ContentDocument.Id)){
                continue;
            }
            processedDocumentIds.add(link.ContentDocument.Id);
            documentList.add(link.ContentDocument);
        }
        return documentList;
    }
}