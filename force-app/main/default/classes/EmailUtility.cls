/**
* @author Sales
* @group Invocable Actions
* @description Reusable Email Sending utility through which
* flows can send bulk email based on mappings in a custom metadata
* name updating.
*/
public with sharing class EmailUtility {
    /* @Description Called by flows to send emails based on EmailMapping__mdt
     * @Param emailsToBeSent Wrapper objects which indicate the email mapping DeveloperName and Record Id for merge fields
     * @Return None
     */
    @InvocableMethod(label='Send Email' description='Sends email based on custom metadata EmailMapping__mdt' category='General Actions')
    public static void sendEmail(List<List<EmailWrapper>> emailsToBeSent) {
        system.debug(emailsToBeSent[0]);
        List<EmailWrapper> inputEmails = emailsToBeSent[0];
        Id recordId = inputEmails[0].recordId;
        Map<Id, EmailMappings__mdt> emailMappings = fetchEmailMappings(inputEmails); //fetch EmailMappings__mdt in context
        if(emailMappings != null) {
            Map<String, EmailTemplateWrapper> templateMap = createEmailTemplateMapping(emailMappings.values(), recordId);
            Map<String, List<Id>> recipientsMap = createRecipientsMapping(emailMappings.values());
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(EmailMappings__mdt mapping : emailMappings.values()) {
                String subject = templateMap.get(mapping.EmailTemplate__c).emailSubject;
                String body = templateMap.get(mapping.EmailTemplate__c).emailBody;
                List<Id> recipientIds = recipientsMap.get(mapping.EmailTemplate__c);
                for(Id recipientId : recipientIds) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTargetObjectId(recipientId);
                    email.setSubject(subject);
                    email.setHtmlBody(body);
                    email.saveAsActivity = false;
                    emails.add(email);
                }
            }
            if(emails.isEmpty() == false) {
                List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emails);
                System.debug(sendResults);
            }
        }
    }

    /* @Description fetches EmailMappings__mdt passed as params through wrapper objects
     * @Param handoverEmails - Wrapper objects passed to apex as input from flow
     * @Return Map<Id, EmailMappings__mdt> / null
     */
    public static Map<Id, EmailMappings__mdt> fetchEmailMappings(List<EmailWrapper> handoverEmails) {
        List<String> emailMappingNames = extractEmailMappingNames(handoverEmails);
        if(emailMappingNames.isEmpty() == false) {
            Map<Id, EmailMappings__mdt> emailMappings = new Map<Id, EmailMappings__mdt>([SELECT Id, DeveloperName, EmailTemplate__c, GroupsName__c, GroupType__c
            FROM EmailMappings__mdt
            WHERE DeveloperName IN :emailMappingNames]);
            return emailMappings;
        }
        else {
            return null;
        }

    }

    /* @Description creates a list of EmailMappings__mdt api names
     * @Param handoverEmails - Wrapper objects passed to apex as input from flow
     * @Return List<EmailMappings__mdt api names>
     */
    public static List<String> extractEmailMappingNames(List<EmailWrapper> handoverEmails) {
        List<String> emailMappingNames = new List<String>();
        for(EmailWrapper handoverEmail : handoverEmails) {
            emailMappingNames.add(handoverEmail.mappingName);
        }
        return emailMappingNames;
    }

    /* @Description creates a mapping of email templates
     * @Param emailMappings email mappings in context
     * @Param recordId record Id to be used to populate merge fields on templates
     * @Return mapping of email template api name to wrapper objects
     * which hold email subject and body with merge fields populated based on record Id
     */
    public static Map<String, EmailTemplateWrapper> createEmailTemplateMapping(List<EmailMappings__mdt> emailMappings, Id recordId) {
        Map<String, EmailTemplateWrapper> emailTemplateMap = new Map<String, EmailTemplateWrapper>();
        List<String> emailTemplateNames = new List<String>();
        for(EmailMappings__mdt mapping : emailMappings) {
            emailTemplateNames.add(mapping.EmailTemplate__c);
        }
        for(EmailTemplate emailTemplate : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :emailTemplateNames]) {
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, recordId); //this helps to populate the merge fields in email template based on record id
            EmailTemplateWrapper emailTemplateWrap = new EmailTemplateWrapper();
            emailTemplateWrap.emailSubject = mail.getSubject();
            emailTemplateWrap.emailBody = mail.getHTMLBody();
            emailTemplateMap.put(emailTemplate.DeveloperName, emailTemplateWrap);
        }
        return emailTemplateMap;
    }

    /* @Description created a mapping of email recipients
     * @Param emailMappings email mappings in context
     * @Return mapping of email template api name to user ids
     */
    public static Map<String, List<Id>> createRecipientsMapping(List<EmailMappings__mdt> emailMappings) {
        Map<String, List<Id>> recipientsMap = new Map<String, List<Id>>();
        List<String> publicGroupNames = new List<String>();
        List<String> queueNames = new List<String>();
        List<String> roleNames = new List<String>();
        for(EmailMappings__mdt mapping : emailMappings) {
            List<String> recipientGroups = mapping.GroupsName__c.split(',');
            List<Id> recipientIds = queryRecipientsIds(recipientGroups, mapping.GroupType__c);
            if(recipientIds.isEmpty() == false) {
                recipientsMap.put(mapping.EmailTemplate__c, recipientIds);
            }
        }
        return recipientsMap;
    }

    /* @Description queries recipient ids (internal users) based on group type
     * @Param groupNames api names of the group(s)
     * @Param groupType can be Public Group / Queue / Role
     * @Return user ids which belong to the group
     */
    public static List<Id> queryRecipientsIds(List<String> groupNames, String groupType) {
        List<Id> recipientIds = new List<Id>();
        for(String groupName : groupNames) {
            if(groupType == 'Role') {
                for(User user : [SELECT Id FROM User WHERE UserRole.DeveloperName = :groupName]) {
                    recipientIds.add(user.Id);
                }
            }
            else if(groupType == 'Queue' || groupType == 'Public Group') {
                String groupTypeFilter = groupType == 'Queue' ? 'Queue' : 'Regular';
                for(User user : [SELECT Id FROM User WHERE Id IN (SELECT
                        UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :groupName and Group.Type = :groupTypeFilter)]) {
                    recipientIds.add(user.Id);
                }
            }
        }
        return recipientIds;
    }

    /* @Description wrapper class to hold
     * email subject and body populated with
     * merge fields based on record id
     */
    public class EmailTemplateWrapper {
        public String emailSubject;
        public String emailBody;
    }
}