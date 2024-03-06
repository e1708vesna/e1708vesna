public class ZendeskAttachmentBatchProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT ZendeskCaseId__c, URL__C, Filename__C, Imported__c FROM ZendeskAttachmentUrl__c WHERE Imported__c = false');
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<String> urls = new List<String>();
        List<String> externalIds = new List<String>();
        List<String> fileNames = new List<String>();
        List<ZendeskAttachmentUrl__c> recordsToUpdate = new List<ZendeskAttachmentUrl__c>();

        for (sObject record : scope) {
            ZendeskAttachmentUrl__c attachment = (ZendeskAttachmentUrl__c) record;
            urls.add(attachment.URL__C);
            externalIds.add(String.valueOf(attachment.ZendeskCaseId__c));
            fileNames.add(attachment.Filename__C);
            recordsToUpdate.add(attachment);
        }

        processAttachments(urls, externalIds, fileNames, recordsToUpdate);

        // Update the records
        update recordsToUpdate;
    }

    public void finish(Database.BatchableContext BC) {
        // This is the post processing after all batches are executed
    }

    private void processAttachments(List<String> urls, List<String> externalIds, List<String> fileNames, List<ZendeskAttachmentUrl__c> recordsToUpdate) {
        transient List<Blob> contentBlobs = new List<Blob>();
    
        for (String url : urls) {
            if (Limits.getHeapSize() > 10000000) {
                break; // Exit the loop once the heap size crosses 10MB
            }
    
            contentBlobs.add(performCalloutAndGetAttachmentBody(url));
            System.debug('HeapSize after getBlob: ' + Limits.getHeapSize());
        }
    
        for (Integer i = 0; i < contentBlobs.size(); i++) {
            uploadContentToCase(externalIds[i], contentBlobs[i], fileNames[i], recordsToUpdate[i]);
        }
    }


    private Blob performCalloutAndGetAttachmentBody(String attachmentUrl) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(attachmentUrl);
        req.setMethod('GET');
        Http http = new Http();

        try {
            HttpResponse res = http.send(req);
            System.debug('HeapSize before getBlob: ' + Limits.getHeapSize());
            if (res.getStatusCode() == 200) {
                return res.getBodyAsBlob();
            } else if (res.getStatusCode() == 302) {
                return performCalloutAndGetAttachmentBody(res.getHeader('location'));
            }
        } catch (System.CalloutException e) {
            System.debug('Callout error: ' + e.getMessage());
        }

        return null;
    }

    private void uploadContentToCase(String externalId, Blob contentBlob, String fileName, ZendeskAttachmentUrl__c attachment) {
        try{
            Case caseRecord = [SELECT Id FROM Case WHERE ZendeskId__c = :externalId LIMIT 1];
            if (caseRecord != null && contentBlob != null) {
                ContentVersion cv = new ContentVersion();
                cv.Title = fileName;
                cv.PathOnClient = fileName;
                cv.VersionData = contentBlob;
                cv.FirstPublishLocationId = caseRecord.Id;
                insert cv;
    
                // Mark the attachment as imported after successful upload.
                attachment.Imported__c = true;
            }
        }catch (System.QueryException e){
            System.debug('Query Exception: ' + e.getMessage());
        }
    }
}