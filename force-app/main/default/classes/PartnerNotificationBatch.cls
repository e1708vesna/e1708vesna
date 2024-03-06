/**
* @author Sales - Amy
* @group Batch
* @description Sends Email Notification to Partner(s) & Partner Manager(s) when
* A referral lead is rejected
* A referral opportunity is Transacting (Won) OR Closed Lost
*/
public class PartnerNotificationBatch implements Database.Batchable<sObject>, Database.Stateful {

    public static Map<String, Id> emailToPartnerManagerMapping = new Map<String, Id>();

    //queries for referral opportunities & leads
    public List<sObject> start(Database.BatchableContext bc) {
        Map<String, Set<String>> stageMap = new Map<String, Set<String>> {
                'Lead' => new Set<String>{'Rejected'},
                'Opportunity' => new Set<String>{'Closed Lost', 'Transacting'}
        };
        List<sObject> scope = new List<sObject>();
        scope.addAll(OpportunityDao.getReferralOpportunitiesByStage(stageMap.get('Opportunity')));
        scope.addAll(LeadDao.getReferralLeadsByStatus(stageMap.get('Lead')));
        return scope;
    }

    //sends emails to partner(s) & partner manager(s)
    public void execute(Database.BatchableContext context, List<sObject> scope) {
        List<Messaging.SingleEmailMessage> emails = processEmails(scope);
        if(!Test.isRunningTest()) {
            if(!emails.isEmpty()) {
                try {
                    List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emails);
                    performPostNotificationSteps(sendResults, scope);
                }
                catch(Exception e) {
                    ApexDebugLog.Error log = new ApexDebugLog.Error(
                            'PartnerNotificationBatch',
                            'execute',
                            '',
                            e
                    );
                    ApexDebugLog.createLog(new List<ApexDebugLog.Error>{ log });
                }
            }
        }
    }



    /**
     * @Description creates a list of single email messages to be sent
     * @Param scope : records in context. This is a combination of lead and opportunity records
     * @Return List<Messaging.SingleEmailMessage> : emails to be sent
    */
    public static List<Messaging.SingleEmailMessage> processEmails(List<sObject> scope) {
        generatePartnerManagerMapping(scope);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<String, EmailTemplate> templateMapping = prepareEmailTemplates();
        for(sObject record : scope) {
            Id recordId = (Id)record.get('Id');
            Id templateId = templateMapping.get(formTemplateKey(record)).Id;
            List<String> toAddresses = new List<String>{
                    (String)record.get('PartnerContactEmail__c')
            };
            String partnerManagerEmail = (String)record.get('PartnerManagerEmail__c');
            system.debug('partner manager email -- ' + partnerManagerEmail);
            system.debug(toaddresses);
            Id partnerManagerId = emailToPartnerManagerMapping.get(partnerManagerEmail);
            Messaging.SingleEmailMessage mergeMail = populateMergeFields(recordId, templateId);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(partnerManagerId);
            email.setToAddresses(toAddresses);
            email.setSubject(mergeMail.getSubject());
            email.setHtmlBody(mergeMail.getHTMLBody());
            email.saveAsActivity = false;
            emails.add(email);
        }
        return emails;
    }

    /**
     * @Description generates a mapping of partner manager email to user id
     * this mapping is used to : set target object id for email and
     * filter records related to failed emails
     * @Param scope : records in context. This is a combination of lead and opportunity records
     * @Return void
    */
    public static void generatePartnerManagerMapping(List<sObject> scope) {
        Set<String> managerEmails = extractManagerEmails(scope);
        for(User user : [SELECT Id, Email FROM User WHERE Email IN :managerEmails]) {
            emailToPartnerManagerMapping.put(user.Email, user.Id);
        }
    }

    /**
     * @Description creates a mapping of Opportunity / Lead Stage to Email Template
     * @Param None
     * @Return Map<String, EmailTemplate> template mapping
     */
    public static Map<String, EmailTemplate> prepareEmailTemplates() {
        Map<String, EmailTemplate> templateMapping = new Map<String, EmailTemplate>();
        Set<String> emailTemplateNames = new Set<String>{
                'CommercialReferralOpportunityWonPartnerNotification',
                'CommercialReferralOpportunityLostPartnerNotification',
                'CommercialReferralLeadRejectedPartnerNotification'
        };
        for(EmailTemplate emailTemplate : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :emailTemplateNames]) {
            if(emailTemplate.DeveloperName == 'CommercialReferralOpportunityWonPartnerNotification') {
                templateMapping.put('OpportunityTransacting', emailTemplate);
            }
            else if(emailTemplate.DeveloperName == 'CommercialReferralOpportunityLostPartnerNotification') {
                templateMapping.put('OpportunityClosed Lost', emailTemplate);
            }
            else {
                templateMapping.put('LeadRejected', emailTemplate);
            }
        }
        return templateMapping;
    }

    /**
     * @Description dynamically forms mapping key depending upon the type of object
     * the key is a combination of sObject name and it's corresponding stage
     * @Param record : sObject record, can be either an Opportunity / Lead
     * @Return String mapping key
     */
    public static String formTemplateKey(sObject record) {
        String sObjectType = Utils.getSObjectNameFromId(record, 'Id');
        String templateKey = sObjectType == 'Opportunity' ? sObjectType + String.valueOf(record.get('StageName')) : sObjectType + String.valueOf(record.get('Status'));
        return templateKey;
    }

    /**
     * @Description populates merge fields in email template
     * @Param recordId : source record for merge field values
     * @Param emailTemplateId : template in which merge fields can be populated
     * @Return Messaging.SingleEmailMessage populated template
     */
    public static Messaging.SingleEmailMessage populateMergeFields(Id recordId, Id emailTemplateId) {
        return Messaging.renderStoredEmailTemplate(emailTemplateId, null, recordId);
    }

    /* @Description extracts emails of partner managers in scope
     * @Param scope : records in context, which is a combination of lead & opportunity
     * @Return Set<String> : partner manager emails
     */
    public static Set<String> extractManagerEmails(List<sObject> scope) {
        Set<String> managerEmails = new Set<String>();
        for(sObject record : scope) {
            String managerEmail = (String)record.get('PartnerManagerEmail__c');
            if(managerEmail != null) {
                managerEmails.add(managerEmail);
            }
        }
        return managerEmails;
    }

    /**
     * @Description performs actions which need to happen after emails are sent
     * creates warning logs for failed email notifications
     * updates 'Partner Notified?' field on lead and Opportunity to true for successful emails
     * @Param emailResults : result for each email that has been sent out
     * @Param scope : records in context, which is a combination of Lead & Opportunity
     * @Return void
     */
    public void performPostNotificationSteps(List<Messaging.SendEmailResult> emailResults, List<sObject> scope) {
        Set<Id> failedTargetObjects = createLogs(emailResults);
        if(failedTargetObjects.size() != scope.size()) {
            Set<String> successfulEmails = extractSuccessfulEmails(failedTargetObjects);
            updateRecords(successfulEmails, scope);
        }
    }

    /**
     * @Description creates warning logs for failed email notifications
     * @Param emailResults : result for each email that has been sent out
     * @Return Set<Id> : user id(s) related to failed email notifications
     */
    public Set<Id> createLogs(List<Messaging.SendEmailResult> emailResults) {
        Set<Id> failedTargetObjects = new Set<Id>();
        List<ApexDebugLog.Warning> emailWarnings = new List<ApexDebugLog.Warning>();
        for(Messaging.SendEmailResult result : emailResults) {
            if(!result.isSuccess()) {
                for(Messaging.SendEmailError error : result.getErrors()) {
                    ApexDebugLog.Warning log = new ApexDebugLog.Warning(
                            'PartnerNotificationBatch',
                            'execute',
                            error.getMessage(),
                            error.getTargetObjectId() + ' ' + error.getStatusCode() + ' ' + String.join(error.getFields(), ',')
                    );
                    emailWarnings.add(log);
                    failedTargetObjects.add(error.getTargetObjectId());
                }
            }
        }
        if(!emailWarnings.isEmpty()) {
            ApexDebugLog.createLog(emailWarnings);
        }
        return failedTargetObjects;
    }

    /**
     * @Description filters successful email id(s)
     * @Param failedTargetObjects : user id(s) for which email notification failed
     * @Return Set<String> : email id(s) for which emails were successful
     */
    public Set<String> extractSuccessfulEmails(Set<Id> failedTargetObjects) {
        Set<String> successfulEmails = new Set<String>();
        for(String email : emailToPartnerManagerMapping.keySet()) {
            if(!failedTargetObjects.contains(emailToPartnerManagerMapping.get(email))) {
                successfulEmails.add(email);
            }
        }
        return successfulEmails;
    }

    /**
     * @Description if email notification was successful, marks the corresponding
     * lead / opportunity's 'Partner Notified?' field to true
     * @Param successfulEmails : email(s) for which email notification was successful
     * @Param scope : records in context, which is a combination of Lead & Opportunity
     * @Return void
     */
    public void updateRecords(Set<String> successfulEmails, List<sObject> scope) {
        List<sObject> recordsToBeUpdated = new List<sObject>();
        for(sObject record : scope) {
            String partnerManagerEmail = (String)record.get('PartnerManagerEmail__c');
            if(successfulEmails.contains(partnerManagerEmail)) {
                record.put('PartnerNotified__c', true);
                recordsToBeUpdated.add(record);
            }
        }
        try {
            update recordsToBeUpdated;
        }
        catch(Exception e) {
            ApexDebugLog.Error log = new ApexDebugLog.Error(
                    'PartnerNotificationBatch',
                    'updateRecords',
                    '',
                    e
            );
            ApexDebugLog.createLog(new List<ApexDebugLog.Error>{ log });
        }
    }

    public void finish(Database.BatchableContext BC) {

    }
}