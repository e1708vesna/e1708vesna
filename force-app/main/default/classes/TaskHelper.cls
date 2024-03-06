/**
 * @description TriggerHelper for the business logic on task database actions
 * @author BRITE
 */
public without sharing class TaskHelper {

    /**
     * @description When a Marketo user creates a task related to a lead or contact, a new Marketing Activity record
     *              should be created.
     *              Runs after insert of tasks
     *
     * @param newList List of created tasks
     */
    public static void convertToMarketingActivity(List<Task> newList) {
        String leadIdPrefix = Lead.SObjectType.getDescribe().getKeyPrefix();
        String contactIdPrefix = Contact.SObjectType.getDescribe().getKeyPrefix();
        List<MarketingActivity__c> marketingActivityList = new List<MarketingActivity__c> ();
        MarketingActivity__c marketingActivity;
        
        Id profileIdRunUser = UserInfo.getProfileId();
        String automatedUser = UserInfo.getName();
        if(automatedUser != 'Automated Process'){
        //Profile p = [SELECT Id, Name FROM Profile WHERE Id = :profileIdRunUser];
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileIdRunUser]?.Name;
        if (profileName != null && profileName.containsIgnoreCase('marketo')) {
            Set<Id> taskIdSet = new Set<Id> ();
            for (Task t : newList) {
                if (t.WhoId != null && t.Id != null) {
                    marketingActivity = new MarketingActivity__c (
                        Subject__c = t.Subject,
                        Comments__c = t.Description,
                        OwnerId = t.OwnerId,
                        ActivityDate__c = t.ActivityDate
                    );
                    if (String.valueOf(t.WhoId).startsWith(leadIdPrefix)) {
                        marketingActivity.Lead__c = t.WhoId;
                    } else if (String.valueOf(t.WhoId).startsWith(contactIdPrefix)) {
                        marketingActivity.Contact__c = t.WhoId;
                        marketingActivity.Account__c = t.AccountId;
                    }
    
                    marketingActivityList.add(marketingActivity);
                }
            }
        }
            if (!marketingActivityList.isEmpty()) {
            // create Marketing Activity records
                insert marketingActivityList;
            }
        }
    }    
}