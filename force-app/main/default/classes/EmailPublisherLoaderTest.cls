/**
 * @Name EmailPublisherLoaderTest
 * @Author Service
 * @Group Test Class
 * @Description Test class to verify the logic in the class EmailPublisherLoader.
 */ 
@isTest
public class EmailPublisherLoaderTest {
    
    
    //Test if the inbound email address is changed to the main email.
    @isTest
    private static void testInboundEmailOnly(){
        //Prepare Test Data
        Account acc = ServicesTestUtil.createAccount('test account 1', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId(), true);
        Contact con = ServicesTestUtil.createContact(acc.Id, 'TestContact', 'test@example.com', false);
        con.InboundEmail__c = 'inbound@example.com';
        insert con;
        Case relatedCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, con.Id, false);
        insert relatedCase;               
        EmailMessage defaultEmailMessage = new EmailMessage();
        Set<String> toAddresses = new Set<string>();
        toAddresses.add(con.InboundEmail__c);
        Set<String> ccAddresses = new Set<string>();
        ccAddresses.add(con.InboundEmail__c);
        Set<String> bccAddresses = new Set<string>();
        bccAddresses.add(con.InboundEmail__c);        
        defaultEmailMessage.ToAddress = String.join(toAddresses, '; ');
        defaultEmailMessage.CcAddress = String.join(ccAddresses, '; ');
        defaultEmailMessage.BccAddress = String.join(bccAddresses, '; ');
        List<QuickAction.SendEmailQuickActionDefaults> actionDefaults = createContext(relatedCase.Id, defaultEmailMessage);
        
        Test.startTest();
        EmailPublisherLoader publisher = new EmailPublisherLoader();
        publisher.onInitDefaults(actionDefaults);        
        Test.stopTest();
        
        EmailMessage em = (EmailMessage) actionDefaults[0].getTargetSObject();
        toAddresses = new Set<String>(em.ToAddress.split('; '));
        bccAddresses = new Set<String>(em.BccAddress.split('; '));
        ccAddresses = new Set<String>(em.CcAddress.split('; '));
        Assert.IsTrue(toAddresses.size() == 1, 'Expected only one ToAddress');
        Assert.IsTrue(bccAddresses.size() == 1, 'Expected only one Bccaddress');
        Assert.IsTrue(ccAddresses.size() == 1, 'Expected only one Ccaddress');
        Assert.IsTrue(toAddresses.contains(con.Email), 'Expected the contacts Email to be present');
        Assert.IsTrue(bccAddresses.contains(con.Email), 'Expected the contacts Email to be present');
        Assert.IsTrue(ccAddresses.contains(con.Email), 'Expected the contacts Email to be present');
        Assert.IsFalse(toAddresses.contains(con.InboundEmail__c), 'Expected the contacts Inbound Email to be replace');
        Assert.IsFalse(bccAddresses.contains(con.InboundEmail__c), 'Expected the contacts Inbound Email to be replace');
        Assert.IsFalse(ccAddresses.contains(con.InboundEmail__c), 'Expected the contacts Inbound Email to be replace');
    } 
    
    //Test if the logic works when there are multiple emailaddresses present.
    @isTest
    private static void testMultipleEmails(){
        //prepare Test Data
        Account acc = ServicesTestUtil.createAccount('test account 1', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId(), true);
        Contact con = ServicesTestUtil.createContact(acc.Id, 'TestContact', 'test@example.com', false);
        con.InboundEmail__c = 'inbound@example.com';
        insert con;
        Case relatedCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, con.Id, false);
        insert relatedCase;               
        EmailMessage defaultEmailMessage = new EmailMessage();
        Set<String> toAddresses = new Set<string>();
        toAddresses.add(con.InboundEmail__c);
        toAddresses.add('unrelated@example.com');
        Set<String> ccAddresses = new Set<string>();
        ccAddresses.add(con.InboundEmail__c);
        ccAddresses.add('unrelated@example.com');
        Set<String> bccAddresses = new Set<string>();
        bccAddresses.add(con.InboundEmail__c);
        bccAddresses.add('unrelated@example.com');        
        defaultEmailMessage.ToAddress = String.join(toAddresses, '; ');
        defaultEmailMessage.CcAddress = String.join(ccAddresses, '; ');
        defaultEmailMessage.BccAddress = String.join(bccAddresses, '; ');
        List<QuickAction.SendEmailQuickActionDefaults> actionDefaults = createContext(relatedCase.Id, defaultEmailMessage);
        
        Test.startTest();
        EmailPublisherLoader publisher = new EmailPublisherLoader();
        publisher.onInitDefaults(actionDefaults);    
        Test.stopTest();        
        
        //Assert Outcome
        EmailMessage em = (EmailMessage) actionDefaults[0].getTargetSObject();
        toAddresses = new Set<String>(em.ToAddress.split('; '));
        bccAddresses = new Set<String>(em.BccAddress.split('; '));
        ccAddresses = new Set<String>(em.CcAddress.split('; '));
        
        
        Assert.IsTrue(toAddresses.size() == 2, 'Expected two ToAddress');
        Assert.IsTrue(bccAddresses.size() == 2, 'Expected two one Bccaddress');
        Assert.IsTrue(ccAddresses.size() == 2, 'Expected two one Ccaddress');
        Assert.IsTrue(toAddresses.contains(con.Email), 'Expected the contacts Email to be present');
        Assert.IsTrue(bccAddresses.contains(con.Email), 'Expected the contacts Email to be present');
        Assert.IsTrue(ccAddresses.contains(con.Email), 'Expected the contacts Email to be present');
        Assert.IsFalse(toAddresses.contains(con.InboundEmail__c), 'Expected the contacts Inbound Email to be replace');
        Assert.IsFalse(bccAddresses.contains(con.InboundEmail__c), 'Expected the contacts Inbound Email to be replace');
        Assert.IsFalse(ccAddresses.contains(con.InboundEmail__c), 'Expected the contacts Inbound Email to be replace');
    } 
    
    //Test if the main email is not duplicated if it is already present.
    @isTest
    private static void testBothContactEmails(){
        //Prepare Test Data
        Account acc = ServicesTestUtil.createAccount('test account 1', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId(), true);
        Contact con = ServicesTestUtil.createContact(acc.Id, 'TestContact', 'test@example.com', false);
        con.InboundEmail__c = 'inbound@example.com';
        insert con;
        Case relatedCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, con.Id, false);
        insert relatedCase;               
        EmailMessage defaultEmailMessage = new EmailMessage();
        Set<String> toAddresses = new Set<string>();
        toAddresses.add(con.InboundEmail__c);
        toAddresses.add(con.Email);
        Set<String> ccAddresses = new Set<string>();
        ccAddresses.add(con.InboundEmail__c);
        ccAddresses.add(con.Email);
        Set<String> bccAddresses = new Set<string>();
        bccAddresses.add(con.InboundEmail__c);
        bccAddresses.add(con.Email);        
        defaultEmailMessage.ToAddress = String.join(toAddresses, '; ');
        defaultEmailMessage.CcAddress = String.join(ccAddresses, '; ');
        defaultEmailMessage.BccAddress = String.join(bccAddresses, '; ');
        List<QuickAction.SendEmailQuickActionDefaults> actionDefaults = createContext(relatedCase.Id, defaultEmailMessage);
        
        Test.startTest();
        EmailPublisherLoader publisher = new EmailPublisherLoader();
        publisher.onInitDefaults(actionDefaults);        
        Test.stopTest();
        
        //Assert Outcome
        EmailMessage em = (EmailMessage) actionDefaults[0].getTargetSObject();
        toAddresses = new Set<String>(em.ToAddress.split('; '));
        bccAddresses = new Set<String>(em.BccAddress.split('; '));
        ccAddresses = new Set<String>(em.CcAddress.split('; '));
        
        
        Assert.IsTrue(toAddresses.size() == 1, 'Expected only one ToAddress');
        Assert.IsTrue(bccAddresses.size() == 1, 'Expected only one Bccaddress');
        Assert.IsTrue(ccAddresses.size() == 1, 'Expected only one Ccaddress');
        Assert.IsTrue(toAddresses.contains(con.Email), 'Expected the contacts Email to be present');
        Assert.IsTrue(bccAddresses.contains(con.Email), 'Expected the contacts Email to be present');
        Assert.IsTrue(ccAddresses.contains(con.Email), 'Expected the contacts Email to be present');
        Assert.IsFalse(toAddresses.contains(con.InboundEmail__c), 'Expected the contacts Inbound Email to be replace');
        Assert.IsFalse(bccAddresses.contains(con.InboundEmail__c), 'Expected the contacts Inbound Email to be replace');
        Assert.IsFalse(ccAddresses.contains(con.InboundEmail__c), 'Expected the contacts Inbound Email to be replace');
    } 
    
    
    //Test if the code works when there are no default email addresses set.
    @isTest
    private static void testNoDefaultEmails(){
        //Prepare Test Data
        Account acc = ServicesTestUtil.createAccount('test account 1', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId(), true);
        Contact con = ServicesTestUtil.createContact(acc.Id, 'TestContact', 'test@example.com', false);
        con.InboundEmail__c = 'inbound@example.com';
        insert con;
        Case relatedCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, con.Id, false);
        insert relatedCase;
        EmailMessage defaultEmailMessage = new EmailMessage();
        List<QuickAction.SendEmailQuickActionDefaults> actionDefaults = createContext(relatedCase.Id, defaultEmailMessage);
        
        Test.startTest();
        EmailPublisherLoader publisher = new EmailPublisherLoader();
        publisher.onInitDefaults(actionDefaults);        
        Test.stopTest();
        
        //Assert Outcome
        EmailMessage em = (EmailMessage) actionDefaults[0].getTargetSObject();
        
        
        
        Assert.isTrue(String.isBlank(em.toAddress), 'Expected no ToAddresses');
        Assert.isTrue(String.isBlank(em.bccAddress), 'Expected no BccAddresses');
        Assert.isTrue(String.isBlank(em.ccAddress), 'Expected no CcAddresses');
    } 
    
    
    /* @Description Creates the context for the QuickAction.QuickActionDefaultsHandler interface
    * @Param caseId RecordId to which the contextId should be set.
    * @Param em EmailMessage to be used by the interface, set default values beforehand.
    * @Return List<QuickAction.SendEmailQuickActionDefaults> context to be used in the test
    */
    private static List<QuickAction.SendEmailQuickActionDefaults> createContext(Id caseId, EmailMessage em){
        List<Map<String, Object>> defaultSettingAsUntypedObject = new List<Map<String, Object>>
        {
            new Map<String, Object>
            {
                'targetSObject' => em,
                    'contextId' => caseId,
                    'actionType' => 'Email',
                    'actionName' => 'Case.Email',
                    'fromAddressList' => new List<String> { 'support@example.com' }
            }
        };
            
            return (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsUntypedObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
    }
}