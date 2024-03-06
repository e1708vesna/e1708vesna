/*
 * @name CaseRedactionSearchInvocable
 * @author Service
 * @group Invocable Apex
 * @description This class contains the invocable method to search a case and it's related emails for a searchterm. Optionally you can redact the records found.
 */ 
public class CaseRedactionSearchInvocable {
    
    private static Set<Schema.sObjectField> caseFields = new Set<Schema.sObjectField>();
    private static Set<Schema.sObjectField> emailFields = new Set<Schema.sObjectField>();
    @testVisible private static final String REDACT_STRING = '[REDACTED]';
    private static final String EMAIL_DRAFT_STATUS = '5';
    //private static final Integer MAX_CHARACTERS_EMAIL_BODY = 31970;
    private static final String DUPLICATE_CONTENTDOCUMENTLINK_ERROR = 'is already linked with the entity';
    //If you add (text) fields here (and add them to the query) they will also be redacted.
    static {
        caseFields.add(Case.Description);
        caseFields.add(Case.Subject);
        emailFields.add(EmailMessage.Subject);
        emailFields.add(EmailMessage.HTMLBody);
        emailFields.add(EmailMessage.TextBody);
    }    
    
    public class NonBulkifiedMethodException extends Exception {}
    
    public class SearchInput {
        @InvocableVariable(label='Case Id' description='Id of the case you would search through' required=true)
        public Id caseId;
        @InvocableVariable(label='Search Term' description='String to search for' required=true)
        public String searchTerm;
        @InvocableVariable(label='Redact' description='Set to true to search and redact the case. Set to false to perform search only.' required=true)
        public Boolean redact;
    }
    
    public class SearchOutput {
        @InvocableVariable(label='Case hit' description='True indicates the search term has been found on the Case' required=true)
        public boolean hitOnCase;
        @InvocableVariable(label='Search Term' description='The amount of Emails the search term was found on' required=true)
        public integer amountOfEmailHits;

        SearchOutput(){
            hitOnCase = false;
            amountOfEmailHits = 0;
        }
    }
    
    /**
     * description: Wrapper class to relate attachments to a non-inserted redacted email.
     **/
    private class EmailAttachmentWrapper{
		EmailMessage redactedEmail;
        List<ContentDocumentLink> attachments;
        
        EmailAttachmentWrapper(EmailMessage email, List<ContentDocumentLink> attachmentList){
            redactedEmail = email;
            attachments = attachmentList;
        }
    }
    
    /**
     * @description This method checks if the searchterm exists on the Case or the related email records. The records can optionally be redacted.
     * @param searchInput Input of the call, consisting of a Case Id, SearchTerm and a boolean to indicates to redact the records found.
     * @return List<SearchOutput> Summary of hits found, consisting of a boolean to indicate a hit was found on case, and an Integer to indicate on how many Email records the searchterm was found.
     **/
    @InvocableMethod(label='Search Case Content' description='Checks if the searchterm exists on the Case or related EmailMessages. Should only be used in a screenflow.' category='Case')
    public static List<SearchOutput> searchCase(List<SearchInput> searchInput) {
        if (searchInput.size() > 1){
            throw new NonBulkifiedMethodException('This invocable action is not bulkified and should only be used in screenflows');
        }
        
        SearchInput parameters = searchInput[0]; 
        String soslSearchTerm = parameters.searchTerm;

        //prepare output
        List<SearchOutput> outputList = new List<SearchOutput>(); 
        SearchOutput output = new SearchOutput(); 
        outputList.add(output);

        Case caseRecord = [SELECT 
                        Id,
                        Subject,
                        Description,
                        (SELECT 
                            Id
                            FROM EmailMessages)
                    FROM Case
                    WHERE Id = :parameters.caseId];
        //Handle search and redaction of Case record
        if (caseRecord != null){
            output.hitOnCase = redactField(caseRecord, caseFields, parameters.searchTerm, REDACT_STRING, parameters.redact);
            if (output.hitOnCase && parameters.redact){
                update caseRecord;
            }
        }
        //Handle search and redaction Email records
        if (caseRecord?.EmailMessages != null && caseRecord.EmailMessages.size()>0){
            List<EmailMessage> redactedEmails = new List<EmailMessage>();
            List<EmailMessage> originalEmails = new List<EmailMessage>();
            List<ContentDocumentLink> newContentDocumentLinks = new List<ContentDocumentLink>();
            List<Task> originalTasks = new List<Task>();
            List<EmailAttachmentWrapper> attachmentWrappers = new List<EmailAttachmentWrapper>();
            //perform query in for loop to negate some potential heap space issues
            for (EmailMessage email : [SELECT Id, 
                                        ActivityId,
                                        BccAddress, 
                                        CcAddress, 
                                        CreatedById, 
                                        CreatedDate, 
                                        FirstOpenedDate, 
                                        ValidatedFromAddress, 
                                        FromAddress, 
                                        FromName,
                                        HasAttachment,
                                        Headers,
                                        HtmlBody,
                                        IsExternallyVisible,
                                        Incoming,
                                        IsPrivateDraft,
                                        LastModifiedById,
                                        LastModifiedDate,
                                        LastOpenedDate,
                                        MessageDate,
                                        MessageIdentifier,
                                        ParentId,
                                        RelatedToId,
                                        Status,
                                        Subject,
                                        TextBody,
                                        ToAddress,
                                        (SELECT Id, ContentDocumentId, ContentDocument.Title, ShareType, Visibility, LinkedEntityId from ContentDocumentLinks)
                                        FROM EmailMessage WHERE Id in: caseRecord.EmailMessages]){

                if (redactField(email, emailFields, parameters.searchTerm, REDACT_STRING, parameters.redact)){
                    output.amountOfEmailHits++;
                    if (parameters.redact) {
                        originalEmails.add(new EmailMessage(Id = email.Id));
                        //Relate attachments to the case record
                        newContentDocumentLinks.addAll(constructDocumentLinksToParent(email));
                        if (email.ActivityId != null){//Delete related task, since it contains the email body and subject.
                            originalTasks.add(New Task(Id = email.ActivityId)); 
                        }
                        EmailMessage redactedEmail;
                        if (!EMAIL_DRAFT_STATUS.equals(email.status)){ //Cannot insert email in draft status.
                            email.Id = null;
                            email.ValidatedFromAddress = null; // Workaround for now since an error occurs when populated. Invalid value for restricted picklist.
                            attachmentWrappers.add( new EmailAttachmentWrapper (email, email.ContentDocumentLinks));
                            redactedEmails.add(email);
                        }
                        
                    }
                }
            }
            if (parameters.redact){
                insert redactedEmails;
                //Create ContentDocumentLink records now that the redacted email records have their Ids populated
                for (EmailAttachmentWrapper wrapper : attachmentWrappers){
                    newContentDocumentLinks.addAll(constructDocumentLinkToEmailCopy(wrapper.attachments, wrapper.redactedEmail.Id));
                }
                List<Database.SaveResult> contentDocumentSaveResults = Database.insert(newContentDocumentLinks, false);
                for (Database.SaveResult sr : contentDocumentSaveResults){
                    if (!sr.isSuccess()){
                        for (Database.Error error : sr.getErrors()){
                            if (!error.getMessage().contains(DUPLICATE_CONTENTDOCUMENTLINK_ERROR)){
                                throw new DmlException(error.getMessage());
                            }
                        }
                    }
                }
                delete originalEmails;
                delete originalTasks;
            }
        }
        return outputList;
    }
    
    /**
     * @description This method checks if a field contains a searchterm and optionally redacts the fields.
     * @param record record to be searched
     * @param fieldSet Set of fields that will be processed
     * @param searchTerm Text to locate within the field values
     * @param redactString Text that replaces the searchterm
     * @param redact indicates to only perform a search (false), or search and redact (true).
     * @return returns true when a hit was found on one of the fields.
     **/
    private static Boolean redactField(sObject record, Set<Schema.sObjectField> fieldSet, String searchTerm, String redactString, Boolean redact){
        boolean hitFoundOnRecord = false;
        for (Schema.sObjectField field : fieldSet){
            boolean hitFoundOnField = false;
            Schema.DescribeFieldResult dfr = field.getDescribe();
            Schema.DisplayType displayType = dfr.getType();
            if (displayType == Schema.DisplayType.STRING || displayType == Schema.DisplayType.TEXTAREA) {
                Integer maxFieldLength = dfr.getLength() - 3;
                String fieldContent = (String) record.get(field);
                if ( !String.isBlank(fieldContent) && 
                    (fieldContent.contains(searchTerm) || (field == EmailMessage.HtmlBody && fieldContent.contains(searchTerm.escapeHtml4())))){
                    if (!redact) { //If we don't redact, knowing that there is a hit on the record is enough information.
                        return true;
                    }
                    else {
                        hitFoundOnRecord = true;
                        hitFoundOnField = true; 
                        if (field == EmailMessage.HtmlBody) {
                            fieldContent = fieldContent.replace(searchTerm, '<b>' + redactString + '</b>');
                            fieldContent = fieldContent.replace(searchTerm.escapeHtml4(), '<b>' + redactString + '</b>');
                            if (!fieldContent.startsWith(constructOriginalEmailInformationHTMLString((EmailMessage) record))){
                                fieldContent = constructOriginalEmailInformationHTMLString((EmailMessage) record) + fieldContent;
                            }
                            //fieldContent = fieldContent.abbreviate(MAX_CHARACTERS_EMAIL_BODY);
                        }
                        else if (field == EmailMessage.TextBody) {
                            fieldContent = fieldContent.replace(searchTerm, redactString);
                            if (!fieldContent.startsWith(constructOriginalEmailInformationTextString((EmailMessage) record))){
                                fieldContent = constructOriginalEmailInformationTextString((EmailMessage) record) + fieldContent;
                            }
                            //fieldContent = fieldContent.abbreviate(MAX_CHARACTERS_EMAIL_BODY);
                        } 
                        else {
                            fieldContent = fieldContent.replace(searchTerm, redactString);
                        }
                        record.put(field, fieldContent.abbreviate(maxFieldLength));
                    }
                }
            }
        }
        return hitFoundOnRecord;
    }
    
    /**
     * @description This method returns the text to be prepended to the redacted HTMLBody field on an email record.
     * @param email record for which the text needs to be constructed.
     * @return Constructed text.
     **/
    private static string constructOriginalEmailInformationHTMLString(EmailMessage email){
        return '<p><b>Redaction has been applied to this email.<br/>Original Date: ' + email.CreatedDate.formatGMT('MM/dd/yyyy HH:mm:ss') + ' GMT<br/></b></p>';
    }
    
    /**
     * @description This method returns the text to be prepended to the redacted TextBody field on an email record.
     * @param email record for which the text needs to be constructed.
     * @return String Constructed text.
     **/
    private static string constructOriginalEmailInformationTextString(EmailMessage email){
        return 'Redaction has been applied to this email.\nOriginal Date: ' + email.CreatedDate.formatGMT('MM/dd/yyyy HH:mm:ss') + ' GMT\n';
    }
    
    /**
     * @description This method constructs DocumentLink records to link Email files to the parent record.
     * @param email record for which the links needs to be constructed.
     * @return List<ContentDocumentLink> List of content document links.
     **/
    private static List<ContentDocumentLink> constructDocumentLinksToParent(EmailMessage email){
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : email.ContentDocumentLinks){
            contentDocumentLinks.add(new ContentDocumentLink(ContentDocumentId = cdl.ContentDocumentId, LinkedEntityId = email.ParentId, ShareType = cdl.ShareType, Visibility = cdl.Visibility));
        }
        return contentDocumentLinks;
    }
    
    /**
     * @description This method constructs DocumentLink records to link Email files to the parent record.
     * @param attachments List of ContentDocuments that need to be copied to a new record.
     * @param newParentId Id of the record the attachments should be linked to.
     * @return List<ContentDocumentLink> List of content document links.
     **/
    private static List<ContentDocumentLink> constructDocumentLinkToEmailCopy(List<ContentDocumentLink> attachments, Id newParentId){
        List<ContentDocumentLink> newContentDocumentLinks = new List<ContentDocumentLink>();
        if (attachments != null){
            for (ContentDocumentLink att : attachments){
                ContentDocumentLink tempContentDocumentLink = att.clone();
                tempContentDocumentLink.Id = null;
                tempContentDocumentLink.LinkedEntityId = newParentId;
                newContentDocumentLinks.add(tempContentDocumentLink);
            }
        }
        return newContentDocumentLinks;
    }
    
}