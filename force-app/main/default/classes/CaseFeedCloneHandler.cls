public class CaseFeedCloneHandler {
    
    private static final String CLONED_MESSAGE_EMAIL_PLAIN_TEXT = 'This email has been copied from the Parent Case.\nOriginal Date: {0} GMT\n';
    private static final String CLONED_MESSAGE_EMAIL_HTML = '<p><b>This email has been copied from the Parent Case.<br/>Original Date: {0} GMT<br/></b></p>';
    private static final String CLONED_MESSAGE_FEED_HTML = '<p><b>This post has been copied from the Parent Case.<br/>Original Date: {0} GMT<br/></b></p>';
    private static final List<String> FEED_ITEM_TYPES_TO_CLONE = new List<String>{'ContentPost','LinkPost', 'TextPost', 'AttachArticleEvent', 'CallLogPost', 'CaseCommentPost'};
        
        
        
        private Class FeedWrapper {
            private FeedItem item;
            private List<FeedComment> feedComments;
            
            FeedWrapper(FeedItem item, List<FeedComment> feedComments){
                this.item = item;
                this.feedComments = feedComments;
            }
            
            public FeedItem getFeedItemRecord(){
                return item;
            }
            
            public List<FeedComment> populateFeedComments(){
                for (FeedComment fc : feedComments){
                    fc.FeedItemId = this.item.Id;
                }
                return feedComments;
            }
        }
    
    private Class EmailWrapper {
        private EmailMessage email;
        private List<EmailMessageRelation> emailRelations;
        private List<ContentDocumentLink> contentDocumentLinks;
        
        EmailWrapper(EmailMessage email, List<EmailMessageRelation> emailRelations, List<ContentDocumentLink> contentDocumentLinks){
            this.email = email;
            this.emailRelations = emailRelations;
            this.contentDocumentLinks = contentDocumentLinks;
        }
        
        public EmailMessage getEmailRecord(){
            return email;
        }
        
        public List<EmailMessageRelation> populateEmailRelations(){
            for (EmailMessageRelation emr : emailRelations){
                emr.EmailMessageId = email.Id;
            }
            return emailRelations;
        }
        
        public List<ContentDocumentLink> populateContentDocumentLinks(){
            for (ContentDocumentLink cdl : contentDocumentLinks){
                cdl.LinkedEntityId = email.Id;
            }
            return contentDocumentLinks;
        }
    }
    
    
    public static void copyFeedFromParent(List<Case> caseList){
        //List<Case> cases = [Select Id, ParentId From Case Where Id in: caseList];
        Map<Id, Id> caseIdByParent = new Map<Id, Id>();
        for (Case c : caseList){
            if (String.IsNotBlank(c.ParentId)) {
                caseIdByParent.put(c.ParentId, c.Id);
            }
        }
        system.debug(JSON.serializePretty(caseIdByParent));
        if (caseIdByParent.size() > 0){
            List<FeedItem> feedItemList = [
                SELECT Id,
                Body,
                CreatedById,
                IsRichText,
                LastEditById,
                LastEditDate,
                LinkUrl,
                NetworkScope,
                ParentId,
                RelatedRecordId,
                Status,
                Title,
                Type,
                Visibility
                FROM FeedItem
                WHERE Type in: FEED_ITEM_TYPES_TO_CLONE AND ParentId in: caseIdByParent.keySet()
            ];
            List<FeedWrapper> clonedFeedRecords = copyFeedFromParent(caseIdByParent, feedItemList);
            List<FeedItem> clonedFeedItems = new List<FeedItem>();
            for (FeedWrapper wrapper : clonedFeedRecords){
                clonedFeedItems.add(wrapper.getFeedItemRecord());
            }
            insert clonedFeedItems;
            
            List<EmailMessage> EmailMessageList = [
                SELECT 	Id, 
                ActivityId, 
                BccAddress, 
                BccIds, 
                CcAddress, 
                CcIds, 
                ClientThreadIdentifier, 
                ContentDocumentIds, 
                CreatedById,
                CreatedDate,
                EmailTemplateId, 
                FirstOpenedDate, 
                FromAddress, 
                FromName,
                HasAttachment, 
                Headers, 
                HtmlBody, 
                Incoming, 
                IsBounced, 
                IsClientManaged, 
                IsExternallyVisible, 
                IsOpened, 
                IsPrivateDraft, 
                IsTracked, 
                LastOpenedDate, 
                LastModifiedDate,
                LastModifiedById,
                MessageDate, 
                MessageIdentifier, 
                Name, 
                ParentId, 
                RelatedToId, 
                ReplyToEmailMessageId, 
                Status, 
                Subject, 
                TextBody, 
                ThreadIdentifier, 
                ToAddress, 
                ToIds, 
                ValidatedFromAddress,
                (SELECT Id, 
                 EmailMessageId, 
                 RelationAddress, 
                 RelationId, 
                 RelationObjectType, 
                 RelationType
                 FROM EmailMessageRelations),
                (SELECT Id, 
                 ContentDocumentId, 
                 LinkedEntityId, 
                 ShareType, 
                 Visibility
                 FROM ContentDocumentLinks)
                FROM EmailMessage WHERE ParentId in: caseIdByParent.keySet() AND Status != '5'];
            
            List<EmailWrapper> clonedEmailRecords = copyEmailMessagesFromParent(caseIdByParent, EmailMessageList);
            List<EmailMessage> clonedEmailMessages = new List<EmailMessage>();
            List<EmailMessageRelation> clonedEmailMessageRelations = new List<EmailMessageRelation>();
            List<ContentDocumentLink> clonedContentDocumentLinks = new List<ContentDocumentLink>();
            for (EmailWrapper emailWrapper : clonedEmailRecords){
                clonedEmailMessages.add(emailWrapper.getEmailRecord());
            }
            insert clonedEmailMessages;
            for (EmailWrapper emailWrapper : clonedEmailRecords){
                clonedEmailMessageRelations.addAll(emailWrapper.populateEmailRelations());
                clonedContentDocumentLinks.addAll(emailWrapper.populateContentDocumentLinks());
            }
            insert clonedEmailMessageRelations;
            insert clonedContentDocumentLinks;
        }
    }
    
    private static List<FeedWrapper> copyFeedFromParent(Map<Id, Id> caseIdByParent, List<FeedItem> feedItems){
        List<FeedWrapper> clonedRecords = new List<FeedWrapper>();
        for (FeedItem origFeedItem : feedItems){
            FeedItem clone = new FeedItem(
                Body = origFeedItem.Body,
                CreatedById = origFeeditem.CreatedById,
                IsRichText = origFeedItem.IsRichText,
                LastEditById = origFeedItem.LastEditById,
                LastEditDate = origFeedItem.LastEditDate,
                LinkUrl = origFeedItem.LinkUrl,
                NetworkScope = origFeedItem.NetworkScope,
                ParentId = caseIdByParent.get(origFeedItem.ParentId),
                RelatedRecordId = origFeedItem.RelatedRecordId,
                Status = origFeedItem.Status,
                Title = origFeedItem.Title,
                Type = origFeedItem.Type,
                Visibility = origFeedItem.Visibility
            );
            clonedRecords.add(new FeedWrapper(clone, null));
        }
        return clonedRecords;
    }
    
    private static List<EmailWrapper> copyEmailMessagesFromParent(Map<Id, Id> caseIdByParent, List<EmailMessage> emailMessages){
        List<EmailWrapper> clonedRecords = new List<EmailWrapper>();
        for (EmailMessage origEmail : emailMessages){
            List<EmailMessageRelation> clonedEmailMessageRelations = new List<EmailMessageRelation>();
            List<ContentDocumentLink> clonedContentDocumentLinks = new List<ContentDocumentLink>();
            EmailMessage clone = new EmailMessage(
                BccAddress =  origEmail.BccAddress,
                BccIds = origEmail.BccIds,
                CcAddress = origEmail.CcAddress,
                CcIds = origEmail.CcIds,
                ClientThreadIdentifier = origEmail.ClientThreadIdentifier,  
                CreatedById = origEmail.CreatedById,
                CreatedDate = origEmail.CreatedDate,
                EmailTemplateId = origEmail.EmailTemplateId,
                FirstOpenedDate = origEmail.FirstOpenedDate,  
                FromAddress = origEmail.FromAddress,
                FromName = origEmail.FromName,
                Headers = origEmail.Headers,
                HtmlBody =  String.IsNotBlank(origEmail.HtmlBody) ? String.format(CLONED_MESSAGE_EMAIL_HTML, new List<Object>{origEmail.CreatedDate.formatGMT('MM/dd/yyyy HH:mm:ss')}) + origEmail.HtmlBody : null,  
                Incoming = origEmail.Incoming,  
                IsBounced = origEmail.IsBounced,  
                IsClientManaged = origEmail.IsClientManaged,  
                IsExternallyVisible = origEmail.IsExternallyVisible,  
                IsPrivateDraft = origEmail.IsPrivateDraft,  
                IsTracked = origEmail.IsTracked,
                LastOpenedDate = origEmail.LastOpenedDate,  
                LastModifiedById = origEmail.LastModifiedById,
                LastModifiedDate = origEmail.LastModifiedDate,
                MessageDate = origEmail.MessageDate,
                MessageIdentifier = origEmail.MessageIdentifier, 
                ParentId = caseIdByParent.get(origEmail.ParentId),  
                RelatedToId = origEmail.RelatedToId,  
                ReplyToEmailMessageId = origEmail.ReplyToEmailMessageId,  
                Status = origEmail.Status,
                Subject = origEmail.Subject,  
                TextBody =  String.IsNotBlank(origEmail.TextBody) ? String.format(CLONED_MESSAGE_EMAIL_HTML, new List<Object>{origEmail.CreatedDate.formatGMT('MM/dd/yyyy HH:mm:ss')}) + origEmail.TextBody : null,  
                ThreadIdentifier = origEmail.ThreadIdentifier,  
                ToAddress = origEmail.ToAddress,
                ToIds = origEmail.ToIds,
                ValidatedFromAddress = origEmail.ValidatedFromAddress
            );
            for (EmailMessageRelation relation : origEmail.EmailMessageRelations){
                EmailMessageRelation clonedRelation = new EmailMessageRelation(
                    EmailMessage = clone,
                    RelationAddress = relation.RelationAddress,
                    RelationId = relation.RelationId,
                    RelationType = relation.RelationType
                );
                clonedEmailMessageRelations.add(clonedRelation);
            }
            for (ContentDocumentLink origCdl : origEmail.ContentDocumentLinks){
                ContentDocumentLink cdl = new ContentDocumentLink(
                    ContentDocumentId = origCdl.ContentDocumentId,
                    LinkedEntityId = clone.Id,
                    ShareType = origCdl.ShareType,
                    Visibility = origCdl.Visibility
                );
                clonedContentDocumentLinks.add(cdl);
            }
            clonedRecords.add(new EmailWrapper(clone, clonedEmailMessageRelations, clonedContentDocumentLinks));
        }
        return clonedRecords;
    }
}