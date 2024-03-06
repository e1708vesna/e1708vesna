/**
 * @Name EmailMessageHlprTest
 * @Author Service
 * @Group Test Class
 * @Description Test class to verify the logic in the class EmailMessageHlpr class.
 */ 
@isTest
public class EmailMessageHlprTest {

    @isTest
    private static void cloneServiceCase(){
        Account acc = ServicesTestUtil.createAccount('test account 1', null, true);
        Case caseRecord = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, false);
        caseRecord.Status = 'Completed';
        caseRecord.WaitingOnMerchantDateTime__c = DateTime.now().addDays(-72);
        insert caseRecord;
		String threadingToken = EmailMessages.getFormattedThreadingToken(caseRecord.Id);
        
        Test.startTest();
        EmailMessage email = ServicesTestUtil.createEmailMessage(caseRecord.Id, 'subject ' + threadingToken , 'body ' + threadingToken, 'from@example.com', 'to@example.com', true, true);
        Test.stopTest();
        
        //Check if no exceptions have been raised.
        for (DebugLog__c log : [SELECT ID, Message__c FROM DebugLog__c WHERE MethodName__c = 'cloneClosedCaseBeforeInsert']){
        	Assert.fail('Unexpected exception occured during execution: ' + log.Message__c);
        }
		
        
        //Check email fields
        email = [SELECT Id, Subject, TextBody, HtmlBody, ParentId FROM EmailMessage WHERE Id =: email.Id];
        String newThreadingToken = EmailMessages.getFormattedThreadingToken(email.ParentId);
        
        Assert.areNotEqual(caseRecord.Id, email.ParentId, 'Email should have been reparented.');
        Assert.isFalse(email.TextBody.contains(threadingToken), 'Email TextBody should not contain the old Threading Token.');
        Assert.isTrue(email.TextBody.contains(newThreadingToken), 'Email TextBody should contain the new Threading Token.');
        Assert.isFalse(email.HtmlBody.contains(threadingToken), 'Email HtmlBody should not contain the old Threading Token.');
        Assert.isTrue(email.HtmlBody.contains(newThreadingToken), 'Email HtmlBody should contain the old Threading Token.');

        //Check Case fields
        Case clonedCase = [SELECT Id, Subject FROM Case WHERE Id =: email.ParentId];
        Assert.isTrue(clonedCase.Subject.startsWith(EmailMessageHlpr.CLONED_CASE_SUBJECT_PREFIX), 'Case Subject Prefix not found.');
    }
    

    @isTest
    private static void cloneInternalCase(){
        Account acc = ServicesTestUtil.createAccount('test account 1', null, true);
        Case caseRecord = ServicesTestUtil.createCase(Constants.RT_ID_CASE_INTERNALCASE, acc.Id, null, false);
        caseRecord.Status = 'Completed';
        caseRecord.WaitingOnMerchantDateTime__c = DateTime.now().addDays(-72);
        insert caseRecord;
		String threadingToken = EmailMessages.getFormattedThreadingToken(caseRecord.Id);
        
        Test.startTest();
        EmailMessage email = ServicesTestUtil.createEmailMessage(caseRecord.Id, 'subject ' + threadingToken , 'body ' + threadingToken, 'from@example.com', 'to@example.com', true, true);
        Test.stopTest();
        
        //Check if no exceptions have been raised.
        for (DebugLog__c log : [SELECT ID, Message__c FROM DebugLog__c WHERE MethodName__c = 'cloneClosedCaseBeforeInsert']){
        	Assert.fail('Unexpected exception occured during execution: ' + log.Message__c);
        }
        
        //Check email fields
        email = [SELECT Id, Subject, TextBody, HtmlBody, ParentId FROM EmailMessage WHERE Id =: email.Id];
        String newThreadingToken = EmailMessages.getFormattedThreadingToken(email.ParentId);
        
        Assert.areNotEqual(caseRecord.Id, email.ParentId, 'Email should have been reparented.');
        Assert.isFalse(email.TextBody.contains(threadingToken), 'Email TextBody should not contain the old Threading Token.');
        Assert.isTrue(email.TextBody.contains(newThreadingToken), 'Email TextBody should contain the new Threading Token.');
        Assert.isFalse(email.HtmlBody.contains(threadingToken), 'Email HtmlBody should not contain the old Threading Token.');
        Assert.isTrue(email.HtmlBody.contains(newThreadingToken), 'Email HtmlBody should contain the old Threading Token.');

        //Check Case fields
        Case clonedCase = [SELECT Id, Subject FROM Case WHERE Id =: email.ParentId];
        Assert.isTrue(clonedCase.Subject.startsWith(EmailMessageHlpr.CLONED_CASE_SUBJECT_PREFIX), 'Case Subject Prefix not found.');
    }
    
    @isTest
    private static void cloneSupportCase(){
        Account acc = ServicesTestUtil.createAccount('test account 1', null, true);
        Case caseRecord = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SUPPORTCASE, acc.Id, null, false);
        caseRecord.Status = 'Completed';
        caseRecord.WaitingOnMerchantDateTime__c = DateTime.now().addDays(-72);
        insert caseRecord;
		String threadingToken = EmailMessages.getFormattedThreadingToken(caseRecord.Id);
        
        Test.startTest();
        EmailMessage email = ServicesTestUtil.createEmailMessage(caseRecord.Id, 'subject ' + threadingToken , 'body ' + threadingToken, 'from@example.com', 'to@example.com', true, true);
        Test.stopTest();
        
        //Check if no exceptions have been raised.
        for (DebugLog__c log : [SELECT ID, Message__c FROM DebugLog__c WHERE MethodName__c = 'cloneClosedCaseBeforeInsert']){
        	Assert.fail('Unexpected exception occured during execution: ' + log.Message__c);
        }
        
        //Check email fields
        email = [SELECT Id, Subject, TextBody, HtmlBody, ParentId FROM EmailMessage WHERE Id =: email.Id];
        String newThreadingToken = EmailMessages.getFormattedThreadingToken(email.ParentId);
        Assert.areNotEqual(caseRecord.Id, email.ParentId, 'Email should have been reparented.');
        Assert.isFalse(email.TextBody.contains(threadingToken), 'Email TextBody should not contain the old Threading Token.');
        Assert.isTrue(email.TextBody.contains(newThreadingToken), 'Email TextBody should contain the new Threading Token.');
        Assert.isFalse(email.HtmlBody.contains(threadingToken), 'Email HtmlBody should not contain the old Threading Token.');
        Assert.isTrue(email.HtmlBody.contains(newThreadingToken), 'Email HtmlBody should contain the old Threading Token.');

        //Check Case fields
        Case clonedCase = [SELECT Id, Subject FROM Case WHERE Id =: email.ParentId];
        Assert.isTrue(clonedCase.Subject.startsWith(EmailMessageHlpr.CLONED_CASE_SUBJECT_PREFIX), 'Case Subject Prefix not found.');
    }
    
    @isTest
    private static void validateAdyenMail(){
        Account acc = ServicesTestUtil.createAccount('test account 1', null, true);
        Case caseRecord = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, false);
        caseRecord.Status = 'Completed';
        caseRecord.WaitingOnMerchantDateTime__c = DateTime.now().addDays(-72);
        insert caseRecord;
		String threadingToken = EmailMessages.getFormattedThreadingToken(caseRecord.Id);
        
        Test.startTest();
        EmailMessage email = ServicesTestUtil.createEmailMessage(caseRecord.Id, 'subject ' + threadingToken , 'body ' + threadingToken, 'from@adyen.com', 'to@example.com', true, true);
        Test.stopTest();
        
        //Check if no exceptions have been raised.
        for (DebugLog__c log : [SELECT ID, Message__c FROM DebugLog__c WHERE MethodName__c = 'cloneClosedCaseBeforeInsert']){
        	Assert.fail('Unexpected exception occured during execution: ' + log.Message__c);
        }
        
        //Check email fields
        email = [SELECT Id, Subject, TextBody, HtmlBody, ParentId FROM EmailMessage WHERE Id =: email.Id];
        String newThreadingToken = EmailMessages.getFormattedThreadingToken(email.ParentId);
        Assert.areEqual(caseRecord.Id, email.ParentId, 'Email should not have been reparented.');
    }
    
    @isTest
    private static void validateShopperMail(){
        Account acc = ServicesTestUtil.createAccount('test account 1', null, true);
        Case caseRecord = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, false);
        caseRecord.Status = 'Completed';
        caseRecord.WaitingOnMerchantDateTime__c = DateTime.now().addDays(-72);
        caseRecord.IsShopperCase__c = true;
        insert caseRecord;
		String threadingToken = EmailMessages.getFormattedThreadingToken(caseRecord.Id);
        
        Test.startTest();
        EmailMessage email = ServicesTestUtil.createEmailMessage(caseRecord.Id, 'subject ' + threadingToken , 'body ' + threadingToken, 'from@adyen.com', 'to@example.com', true, true);
        Test.stopTest();
        
        //Check if no exceptions have been raised.
        for (DebugLog__c log : [SELECT ID, Message__c FROM DebugLog__c WHERE MethodName__c = 'cloneClosedCaseBeforeInsert']){
        	Assert.fail('Unexpected exception occured during execution: ' + log.Message__c);
        }
        
        //Check email fields
        email = [SELECT Id, Subject, TextBody, HtmlBody, ParentId FROM EmailMessage WHERE Id =: email.Id];
        String newThreadingToken = EmailMessages.getFormattedThreadingToken(email.ParentId);
        Assert.areEqual(caseRecord.Id, email.ParentId, 'Email should not have been reparented.');
    }
    
}