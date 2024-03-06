public class EmailMessageCloneHandler {
    
    public static void copyFeedFromParent(List<Id> caseIdList){
        List<Case> cases = [Select Id, ParentId From Case Where Id in: caseIdList];
        Map<Id, Id> caseIdByParent = new Map<Id, Id>();
        for (Case c : cases){
            caseIdByParent.put(c.ParentId, c.Id);
        }
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
             FROM EmailMessageRelations)
             FROM EmailMessage WHERE ParentId in: caseIdByParent.keySet()];
        List<EmailMessage> clonedEmailMessages = new List<EmailMessage>();
        List<EmailMessageRelation> clonedEmailMessageRelations = new List<EmailMessageRelation>();
        List<ContentDocumentLink> clonedContentDocumentLinks = new List<ContentDocumentLink>();
        
        copyFeedFromParent(caseIdByParent, EmailMessageList, clonedEmailMessages, clonedEmailMessageRelations, clonedContentDocumentLinks);
        
        insert clonedEmailMessages;
        insert clonedEmailMessageRelations;
    }
    
    private static void copyFeedFromParent(Map<Id, Id> caseIdByParent, List<EmailMessage> emailMessages, List<EmailMessage> clonedEmailMessages, List<EmailMessageRelation> clonedEmailMessageRelations, List<ContentDocumentLink> clonedContentDocumentLinks){
        for (EmailMessage origEmail : emailMessages){
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
                                HtmlBody = origEmail.HtmlBody,  
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
                                TextBody = origEmail.TextBody,  
                                ThreadIdentifier = origEmail.ThreadIdentifier,  
                                ToAddress = origEmail.ToAddress,
                                ToIds = origEmail.ToIds,
                                ValidatedFromAddress = origEmail.ValidatedFromAddress
            );
            clonedEmailMessages.add(clone);
            
            for (EmailMessageRelation relation : clone.EmailMessageRelations){
                EmailMessageRelation clonedRelation = new EmailMessageRelation(
                	EmailMessage = clone,
                    RelationAddress = relation.RelationAddress,
                    RelationId = relation.RelationId,
                    RelationType = relation.RelationType
                );
                clonedEmailMessageRelations.add(clonedRelation);
                System.debug('Email Relation added');
            }
        }
    }
}