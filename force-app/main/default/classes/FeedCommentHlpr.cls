/*
 * @name FeedCommentHlpr
 * @author Service
 * @group Trigger Handler
 * @description This class implements the logic for the FeedComment Trigger.
**/
public class FeedCommentHlpr {
    
    /* @Description Handles the logic to update related Case records on case comment.
    * @Param newFeedComments List of FeedComments to process
    */
    public static void handleCommentOnCase(List<FeedComment> newFeedComments) {
        //Only trigger this logic if the logged in user is a portal user, or has the custom permission called ServiceIntegrationStatusUpdate
        if (!'CspLitePortal'.equals(UserInfo.getUserType()) && !FeatureManagement.checkPermission('ServiceIntegrationStatusUpdate')){
            return;
        }
        Map<Id, List<FeedComment>> commentsByCaseId = new Map<Id, List<FeedComment>>(); //Use a map to retrieve the sObject record to be able to add a validation error if needed.
        List<Case> casesToUpdate = new List<Case>();
        for (FeedComment comment : newFeedComments) {
            //Filter non-case comments
            if (Schema.Case.SObjectType == comment.ParentId.getSobjectType()) {
                if (!commentsByCaseId.containsKey(comment.ParentId)){
                    commentsByCaseId.put(comment.ParentId, new List<FeedComment>());
                }
            	commentsByCaseId.get(comment.ParentId).add(comment);
            }
        }
        //Do not process this for Cases that are Blocked, or shopper cases.
        for (Case c : [SELECT Id, 
                       AllowPortalUserToUpdateStatus__c, 
                       IsClosed, 
                       TimeToReopen__c, 
                       TimeReopened__c, 
                       Status, 
                       WaitingOnMerchantDateTime__c, 
                       OwnerId 
                       FROM Case 
                       WHERE 
                       Id in: commentsByCaseId.keySet() 
                       AND AutoCloseReason__c != 'Blocked Email' 
                       AND (IsShopperCase__c = FALSE 
                            OR ShopperCaseAllowed__c = TRUE)
                       AND (RecordType.DeveloperName = 'ServiceCase' 
                            OR RecordType.DeveloperName = 'InternalCase' 
                            OR RecordType.DeveloperName = 'Support')
                      ]){
            
            if (c.IsClosed) {
                if (String.IsBlank(c.TimeToReopen__c)) {
                    for (FeedComment comment : commentsByCaseId.get(c.Id)){
                        comment.addError(System.Label.FeedCommentCaseCannotBeReopened);
                    }
                }
                else {
                    c.Status = 'In Progress';
                    c.TimeReopened__c = DateTime.now();
                    c.Reopened__c = true;
                    c.AllowPortalUserToUpdateStatus__c = !c.AllowPortalUserToUpdateStatus__c;
                    casesToUpdate.add(c);
                }
            }
            else if ('Waiting for Merchant'.equals(c.Status) || 
                     ('Handover'.equals(c.Status) && Schema.User.SObjectType == c.OwnerId.getSobjectType())) {
                c.Status = 'In Progress';
                c.WaitingOnMerchantDateTime__c = null;
                c.AllowPortalUserToUpdateStatus__c = !c.AllowPortalUserToUpdateStatus__c;
                casesToUpdate.add(c);
            }
        }
        update casesToUpdate;
    }
}