/*
* @Name CaseRedactionSearchInvocableTest
* @Author Service
* @Group Test Class
* @Description Test class for the CaseRedactionSearchInvocableTest
*/ 
@isTest
public class CaseRedactionSearchInvocableTest {
    private static final String TEXT_TO_PREPEND = 'Prepended Text before ';
    private static final String TEXT_TO_REDACT = 'Creditcard Number';
    private static final String TEXT_TO_APPEND = 'Appended Text after';
    private static final String HTML_BODY_START = '<html><head><title></title></head><body>';
    private static final String HTML_BODY_END = '</body></html>';
    
    @testSetup
    private static void testSetup() {
        Account acc = ServicesTestUtil.createAccount('testAcc', null, true);

        Case bulkEmailCase = ServicesTestUtil.createCase(null, acc.Id, null, false);
        bulkEmailCase.Subject = 'Bulk Email ' + TEXT_TO_PREPEND + TEXT_TO_REDACT + TEXT_TO_APPEND;
        bulkEmailCase.Description = TEXT_TO_PREPEND + TEXT_TO_REDACT + TEXT_TO_APPEND;
        insert new List<Case> {bulkEmailCase};

        List<EmailMessage> emailMessages = new List<EmailMessage>();
        EmailMessage tempEmail;
        for (integer i = 0; i < 195; i++) {
            tempEmail = new EmailMessage();
            tempEmail.FromAddress = 'example@example.com';
            tempEmail.ToAddress = 'example@example.com';
            tempEmail.Incoming = false;
            tempEmail.Subject = TEXT_TO_PREPEND + TEXT_TO_REDACT + TEXT_TO_APPEND;
            tempEmail.TextBody = TEXT_TO_PREPEND + TEXT_TO_REDACT + TEXT_TO_APPEND;
            tempEmail.HtmlBody = HTML_BODY_START + TEXT_TO_PREPEND + TEXT_TO_REDACT + TEXT_TO_APPEND + HTML_BODY_END;
            tempEmail.ParentId = bulkEmailCase.Id;
            emailMessages.add(tempEmail);
        }
        for (integer i = 0; i < 5; i++) {
            tempEmail = new EmailMessage();
            tempEmail.FromAddress = 'example@example.com';
            tempEmail.ToAddress = 'example@example.com';
            tempEmail.Incoming = false;
            tempEmail.Subject = 'NoHit'+ TEXT_TO_PREPEND + TEXT_TO_APPEND;
            tempEmail.TextBody = TEXT_TO_PREPEND + TEXT_TO_APPEND;
            tempEmail.HtmlBody = HTML_BODY_START + TEXT_TO_PREPEND + TEXT_TO_APPEND + HTML_BODY_END;
            tempEmail.ParentId = bulkEmailCase.Id;
            emailMessages.add(tempEmail);
        }
        insert emailMessages;
        insert new ContentVersion(FirstPublishLocationId = emailMessages[0].Id, Title = 'Test Document', PathOnClient = 'test.txt', VersionData = Blob.valueOf('Test document content'));
    }
    
    @isTest
    private static void redactCaseEmail() {
        List<CaseRedactionSearchInvocable.SearchInput> inputParameterList = new List<CaseRedactionSearchInvocable.SearchInput>();
        CaseRedactionSearchInvocable.SearchInput inputParameters = new CaseRedactionSearchInvocable.SearchInput();
        inputParameterList.add(inputParameters);
        
        Case bulkEmailCase = [SELECT Id FROM Case Where Subject like 'Bulk Email%' LIMIT 1];
        inputParameters.caseId = bulkEmailCase.Id;
        inputParameters.redact = true;
        inputParameters.searchTerm = TEXT_TO_REDACT;

        Test.startTest();
        CaseRedactionSearchInvocable.SearchOutput output = CaseRedactionSearchInvocable.searchCase(inputParameterList)[0];
        Test.stopTest();

        Case bulkEmailCaseAfterRedact = [
            SELECT Id, Subject, Description, 
                (SELECT Id, Subject //, HtmlBody, TextBody 
                 FROM EmailMessages) 
            FROM Case 
            WHERE Subject LIKE 'Bulk Email%' LIMIT 1];
        
        Assert.areEqual(true, output.hitOnCase, 'Expected a hit on the case record');
        Assert.areEqual('Bulk Email ' + TEXT_TO_PREPEND + CaseRedactionSearchInvocable.REDACT_STRING + TEXT_TO_APPEND, bulkEmailCaseAfterRedact.Subject, 'Expected Subject to be redacted');
        Assert.areEqual(TEXT_TO_PREPEND + CaseRedactionSearchInvocable.REDACT_STRING + TEXT_TO_APPEND, bulkEmailCaseAfterRedact.Description, 'Expected Description to be redacted');
        Assert.areEqual(195, output.amountOfEmailHits, 'Expected 195 hits on email');
        Assert.areEqual(200, bulkEmailCaseAfterRedact.EmailMessages.size(), 'Expected 200 email messages to persist after redaction');
        for (EmailMessage email : bulkEmailCaseAfterRedact.EmailMessages) {
            if (email.Subject.startsWith('NoHit')){
                System.assertEquals('NoHit' + TEXT_TO_PREPEND +  TEXT_TO_APPEND, email.Subject);
            }
            else {
                System.assertEquals(TEXT_TO_PREPEND + CaseRedactionSearchInvocable.REDACT_STRING + TEXT_TO_APPEND, email.Subject);
            }
        }
        List<ContentDocument> contentDocuments = [Select Id, Title, (SELECT Id, LinkedEntityId FROM ContentDocumentLinks) FROM ContentDocument WHERE Title = 'Test Document'];
        Assert.areEqual(1, contentDocuments.size());
        Assert.areEqual(3, contentDocuments[0].ContentDocumentLinks?.size()); //Owner, Email, Case
    }
    
    @isTest
    private static void testBulkError() {
        List<CaseRedactionSearchInvocable.SearchInput> inputParameterList = new List<CaseRedactionSearchInvocable.SearchInput>();
        inputParameterList.add(new CaseRedactionSearchInvocable.SearchInput());
        inputParameterList.add(new CaseRedactionSearchInvocable.SearchInput());
        boolean errorThrown = false;
        try {
            CaseRedactionSearchInvocable.searchCase(inputParameterList);
        }
        Catch (CaseRedactionSearchInvocable.NonBulkifiedMethodException e){
            errorThrown = true;
        }
        
        Assert.isTrue(errorThrown);
    }
}