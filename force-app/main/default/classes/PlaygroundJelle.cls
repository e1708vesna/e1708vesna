public class PlaygroundJelle {

    
    public static void getEmailFromFeedItem(Id feedItemId){
        
        
        /*List<FeedItem> feedItemList = [
            SELECT Id, Type, CreatedBy.Name, CreatedDate,
            (SELECT FeedItemId, CommentBody, CommentType, RelatedRecordId, CreatedDate, CreatedBy.Name FROM FeedComments ORDER BY CreatedDate DESC)
            FROM FeedItem 
            WHERE Id = :feedItemId 
            AND Type = 'EmailMessageEvent'
            ORDER BY LastModifiedDate DESC
        ];*/
        List<String> feedItemIdList = new List<String>();
            feedItemIdList.add(feedItemId);
        
        //Get ConnectApi data
        Map<Id, ConnectApi.FeedElement> feedElementMap = new Map<Id, ConnectApi.FeedElement>();
        List<ConnectApi.BatchResult> batchResultList = ConnectApi.ChatterFeeds.getFeedElementBatch(Network.getNetworkId(), feedItemIdList);
        
        for(ConnectApi.BatchResult batchResult : batchResultList) {
            if(batchResult.isSuccess()) {
                if(batchResult.getResult() instanceof ConnectApi.FeedElement) {
                    ConnectApi.FeedElement feedElement = (ConnectApi.FeedElement) batchResult.getResult();
                    feedElementMap.put(feedElement.Id, feedElement); //Will have the same Id as the FeedItem record query
                    
                    System.debug(Json.serializePretty(feedElement.capabilities));
                }
            } else {
                System.debug(batchResult.getErrorMessage());
            }
        }
        //System.debug(Json.serializePretty(feedElementMap));
        //System.debug(feedElementMap);
    }
    /*
    public static void postFeedElement(){
        // Define the FeedItemInput object to pass to postFeedElement
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.subjectId = '5007E00000DkA5tQAF';
        
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = 'Would you please review these docs?';
        
        // The MessageBodyInput object holds the text in the post
        //ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        //messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        //messageBodyInput.messageSegments.add(textSegmentInput);
        //feedItemInput.body = messageBodyInput;
        
        // The FeedElementCapabilitiesInput object holds the capabilities of the feed item.
        // For this feed item, we define a files capability to hold the file(s).
        
        //List<String> fileIds = new List<String>();
        //fileIds.add('069xx00000000QO');
        //fileIds.add('069xx00000000QT');
        //fileIds.add('069xx00000000Qn');
        //fileIds.add('069xx00000000Qi');
        //fileIds.add('069xx00000000Qd');
        ConnectApi.EmailMessageInput filesInput = new ConnectApi.FilesCapabilityInput();
        filesInput.items = new List<ConnectApi.FileIdInput>();
        
        for (String fileId : fileIds) {
            ConnectApi.FileIdInput idInput = new ConnectApi.FileIdInput();
            idInput.id = fileId;
            filesInput.items.add(idInput);
        }
        
        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        feedElementCapabilitiesInput.files = filesInput;
        
        feedItemInput.capabilities = feedElementCapabilitiesInput;
        
        // Post the feed item. 
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        
    }*/

    public static void replaceContentVersion(Id contentDocument){
        ContentDocument cd = [SELECT Id, (SELECT Id From ContentVersions) FROM ContentDocument WHERE Id =: contentDocument];
        ContentVersion contentVersion = new ContentVersion(
            ContentDocumentId = cd.Id,
            Title = 'Redacted File',
            PathOnClient = 'Redacted File.txt',
            ReasonForChange = 'Redacted PII',
            VersionData = Blob.valueOf('This file has been redacted.'),
            IsMajorVersion = true
        );

        insert contentVersion;
        //for (ContentVersion cv : cd.ContentVersions){
        //    delete cv;
        //}
        
    }
    
    public static void replaceContentDocument(Id contentDocument){
        ContentDocument cd = [SELECT Id, LatestPublishedVersion.FirstPublishLocationId, (SELECT Id, LinkedEntityId, ShareType, Visibility From ContentDocumentLinks) FROM ContentDocument WHERE Id =: contentDocument];
        
        ContentVersion contentVersion = new ContentVersion(
            //ContentDocumentId = cd.Id,
            FirstPublishLocationId = cd.LatestPublishedVersion.FirstPublishLocationId,
            ContentLocation = 'S',
            Title = 'Redacted File',
            PathOnClient = 'Redacted File.txt',
            ReasonForChange = 'Redacted PII',
            VersionData = Blob.valueOf('This file has been redacted.'),
            IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        for (ContentDocumentLink origLink : cd.ContentDocumentLinks){
            if (origLink.LinkedEntityId != cd.LatestPublishedVersion.FirstPublishLocationId){
                linkList.add(new ContentDocumentLink(LinkedEntityId = origLink.LinkedEntityId,
                                                    ShareType = origLink.ShareType,
                                                    Visibility =origLink.Visibility)
                            );
            }
        }
        insert linkList;
        //delete cd;
        //for (ContentVersion cv : cd.ContentVersions){
        //    delete cv;
        //}
        
    }
    
}