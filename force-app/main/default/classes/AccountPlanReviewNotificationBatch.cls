/**
* @author Sales
* @group Batch
* @description Batch which runs daily to send notifications to managers
* of users who own an Account Plan which has not been
* reviewed since the past 365 days. Also, re-sends notification
* every 14 days if the Account Plan does not get reviewed
*/
public class AccountPlanReviewNotificationBatch implements Database.Batchable<sObject> {

    public static List<AccountPlan__c> remindersToBeUpdated = new List<AccountPlan__c>();
    public static List<ApexDebugLog.Error> errorLogs = new List<ApexDebugLog.Error>();

    public Database.QueryLocator start(Database.BatchableContext context) {
        Set<String> accountStatuses = new Set<String>{
                'Live', 'Transacting', 'Churning'
        };
        String query = 'SELECT Id, Name, OwnerId, Owner.LastName, Account__r.Account_Status__c, Account__r.Owner.FirstName, ReviewReminderDate__c, DaysNotReviewed__c FROM AccountPlan__c WHERE DaysNotReviewed__c >= 365 AND Account__r.Account_Status__c IN :accountStatuses AND Owner.IsActive = true AND Account__r.Owner.FirstName != \'AM Pool\' AND Account__r.Owner.FirstName != \'AM Pod\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<AccountPlan__c> scope) {
        system.debug(scope);
        Map<String, List<AccountPlan__c>> notificationMapping = createNotificationMappings(scope);
        sendNotifications(notificationMapping);
        updateReminderDates();
    }

    /* @Description creates a mapping of managers and the account plans for which
     * notifications have to be sent. We are sending one notification per account plan
     * @Param accountPlans Account Plans fetched by the Batch
     * @Return Map<String, List<AccountPlan__c>> Mapping of ManagerId to Account Plans
     */
    public static Map<String, List<AccountPlan__c>> createNotificationMappings(List<AccountPlan__c> accountPlans) {
        Map<String, List<AccountPlan__c>> notificationMapping = new Map<String, List<AccountPlan__c>>();
        Map<String, String> ownerToManager = fetchManagerMapping(accountPlans);
        for (AccountPlan__c accountPlan : accountPlans) {
            if (accountPlan.Owner.LastName != 'Unmanaged') {
                if (ownerToManager.containsKey(accountPlan.OwnerId)) {
                    String managerId = ownerToManager.get(accountPlan.ownerId);
                    if(accountPlan.DaysNotReviewed__c == 365 || accountPlan.ReviewReminderDate__c == Date.Today() || accountPlan.ReviewReminderDate__c == null) {
                        if (notificationMapping.containsKey(managerId)) {
                            notificationMapping.get(managerId).add(accountPlan);
                        } else {
                            notificationMapping.put(managerId, new List<AccountPlan__c>{
                                    accountPlan
                            });
                        }
                        remindersToBeUpdated.add(accountPlan);
                    }
                }
            }
        }
        return notificationMapping;
    }

    /* @Description creates a mapping of unreviewed Account
     * Plan Owner and their assigned Manager
     * @Param accountPlans Account Plans fetched by the Batch
     * @Return Map<String, String> Mapping of OwnerId to ManagerId
     */
    public static Map<String, String> fetchManagerMapping(List<AccountPlan__c> accountPlans) {
        Set<Id> accountPlanOwners = new Set<Id>();
        Map<String, String> ownerToManager = new Map<String, String>();
        for (AccountPlan__c accountPlan : accountPlans) {
            accountPlanOwners.add(accountPlan.OwnerId);
        }
        for (User user : [SELECT Id, ManagerId FROM User WHERE Id IN :accountPlanOwners AND IsActive = true]) { //put a check for inactive manager
            ownerToManager.put(user.Id, user.ManagerId);
        }
        return ownerToManager;
    }

    /* @Description sends notifications to the managers
     * we send one notification per unreviewed account plan
     * @Param notificationMapping Mapping of ManagerId to Unreviewed Account Plans
     * @Return none
     */
    public static void sendNotifications(Map<String, List<AccountPlan__c>> notificationMapping) {
        Id notificationId = fetchNotificationId();
        for (String recipientId : notificationMapping.keySet()) {
            List<AccountPlan__c> accountPlans = notificationMapping.get(recipientId);
            for (AccountPlan__c accountPlan : accountPlans) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle(System.Label.AccountPlanUnreviewedTitle);
                notification.setBody(replaceAccountPlanName(accountPlan.Name));
                notification.setNotificationTypeId(notificationId);
                notification.setTargetId(accountPlan.Id);
                try {
                    notification.send(new Set<String>{
                            recipientId
                    });
                } catch (Exception e) {
                    ApexDebugLog.Error errorLog = new ApexDebugLog.Error(
                            'AccountPlanReviewNotificationBatch',
                            'sendNotifications',
                            '',
                            e
                    );
                    errorLogs.add(errorLog);
                }
            }
        }
    }

    /* @Description replaces Account Plan Name dynamically in the notification message
    * @Param accountPlanName name of Account Plan to be used
    * @Return String modified message with Account Plan Name
    */
    public static String replaceAccountPlanName(String accountPlanName) {
        String message = System.Label.AccountPlanUnreviewedNotificationMessage.replace('<AccountPlanName>', accountPlanName);
        return message;
    }

    public static Id fetchNotificationId() {
        CustomNotificationType notificationType = [
                SELECT Id, DeveloperName
                FROM CustomNotificationType
                WHERE DeveloperName = 'DesktopAndMobile'
        ];
        return notificationType.Id;
    }

    /* @Description updates next reminder date to 14 days from now
    * @Param none
    * @Return none
    */
    public static void updateReminderDates() {
        for (AccountPlan__c accountPlan : remindersToBeUpdated) {
            accountPlan.ReviewReminderDate__c = Date.today().addDays(14);
        }
        try {
            update remindersToBeUpdated;
        } catch (Exception e) {
            ApexDebugLog.Error errorLog = new ApexDebugLog.Error(
                    'AccountPlanReviewNotificationBatch',
                    'updateReminderDates',
                    '',
                    e
            );
            errorLogs.add(errorLog);
        }
    }

    public void finish(Database.BatchableContext BC) {
        if(!errorLogs.isEmpty()) {
            ApexDebugLog.createLog(errorLogs);
        }
    }
}