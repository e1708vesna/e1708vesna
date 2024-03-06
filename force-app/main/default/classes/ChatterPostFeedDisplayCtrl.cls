/*
 * @author Sales
 * @group Lightning Web Controller
 * @description Controller for ChatterPostFeedDisplay LWC
 * Responsible for retrieving relevant feed items related to a specific
 * case, and preparing them for display in the community portal
 */
public without sharing class ChatterPostFeedDisplayCtrl {

    @AuraEnabled(cacheable=true)
    public static List<FeedItemWrapper> fetchChatterPosts(String recordId) {
        try {
            List<FeedItemWrapper> chatterPosts = processChatterPosts(Id.valueOf(recordId));
            if(chatterPosts == null) {
                throw new QueryException('No Records Returned');
                //throw error;
            }
            else {
                return chatterPosts;
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* @Description processes chatter posts and it's comments
     * @Param recordId : id of the case in context
     * @Return List<FeedItemWrapper> transformed feed items & comments, if present
     * @Return null, if no FeedItem records are found
     */
    public static List<FeedItemWrapper> processChatterPosts(Id recordId) {
        List<FeedItem> feedItems = fetchFeedItems(recordId);
        if(!feedItems.isEmpty()) {
            Map<Id, Boolean> userToPortalStatus = createUserToPortalStatusMapping(feedItems);
            List<FeedItemWrapper> feedItemWraps = new List<FeedItemWrapper>();
            feedItemWraps.addAll(processFeedItems(feedItems, userToPortalStatus));
            return feedItemWraps;
        }
        else {
            return null;
        }
    }

    /* @Description transforms FeedItem records into FeedItemWrapper
     * @Param feedItems : chatter posts in context
     * @param userToPortalStatus : map of users in context to their portal status
     * @Return List<FeedItemWrapper> transformed FeedItem records
     */
    public static List<FeedItemWrapper> processFeedItems(List<FeedItem> feedItems, Map<Id, Boolean> userToPortalStatus) {
        List<FeedItemWrapper> feedItemWraps = new List<FeedItemWrapper>();
        for(FeedItem item : feedItems) {
            FeedItemWrapper itemWrap = new FeedItemWrapper();
            itemWrap.id = item.Id;
            itemWrap.body = item.Body;
            itemWrap.createdDate = item.CreatedDate;
            //the user name to be displayed depends on who created the post
            //if the creator is an internal user then 'Adyen', otherwise portal user name
            itemWrap.createdByUser = userToPortalStatus.get(item.CreatedById) ? item.createdBy.Name : 'Adyen';
            feedItemWraps.add(itemWrap);
            if(!item.FeedComments.isEmpty()) {
                feedItemWraps.addAll(processFeedItemComments(item.FeedComments, userToPortalStatus));
            }
        }
        return feedItemWraps;
    }

    /* @Description transforms FeedComment records into FeedItemWrapper
     * @Param feedItems : chatter posts in context
     * @param userToPortalStatus : map of users in context to their portal status
     * @Return List<FeedItemWrapper> transformed FeedItem records
     */
    public static List<FeedItemWrapper> processFeedItemComments(List<FeedComment> feedComments, Map<Id, Boolean> userToPortalStatus) {
        List<FeedItemWrapper> feedItemWraps = new List<FeedItemWrapper>();
        for(FeedComment comment : feedComments) {
            FeedItemWrapper itemWrap = new FeedItemWrapper();
            itemWrap.id = comment.Id;
            itemWrap.body = comment.CommentBody;
            itemWrap.createdDate = comment.CreatedDate;
            //the user name to be displayed depends on who created the post
            //if the creator is an internal user then 'Adyen', otherwise portal user name
            itemWrap.createdByUser = userToPortalStatus.get(comment.CreatedById) == true ? comment.createdBy.Name : 'Adyen';
            feedItemWraps.add(itemWrap);
        }
        return feedItemWraps;
    }

    /* @Description queries for FeedItem records based on case in context and type of post
     * @Param recordId : id of the case in context
     * @Return List<FeedItem> queried FeedItem records
     */
    public static List<FeedItem> fetchFeedItems(Id recordId) {
        Set<String> validContentTypes = new Set<String>{'ContentPost', 'TextPost'};
        return [SELECT Id, CreatedById, CreatedBy.Name, CreatedDate, Body, RelatedRecordId,
                (SELECT Id, CreatedById, CommentBody, CreatedDate, CreatedBy.Name FROM FeedComments ORDER BY CreatedDate DESC)
                FROM FeedItem
                WHERE Type IN :validContentTypes AND ParentId = :recordId AND Visibility = 'AllUsers' ORDER BY CreatedDate DESC];
    }

    /* @Description creates a map of all users who created chatter posts
     * to a boolean which signifies whether they are portal users
     * @Param feedItems : FeedItem records in context
     * @Return Map<Id, Boolean> map of user id to their portal status
     */
    public static Map<Id, Boolean> createUserToPortalStatusMapping(List<FeedItem> feedItems) {
        Set<Id> feedItemUserIds = new Set<Id>();
        for(FeedItem item : feedItems) {
            feedItemUserIds.add(item.CreatedById);
            if(!item.FeedComments.isEmpty()) {
                for(FeedComment comment : item.FeedComments) {
                    feedItemUserIds.add(comment.CreatedById);
                }
            }
        }
        Map<Id, Boolean> userToPortalStatus = new Map<Id, Boolean>();
        for(User user : [SELECT Id, ContactId FROM User WHERE Id IN :feedItemUserIds]) {
            Boolean portalStatus = user.ContactId == null ? false : true;
            userToPortalStatus.put(user.Id, portalStatus);
        }
        return userToPortalStatus;
    }

    public class FeedItemWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String body;
        @AuraEnabled
        public DateTime createdDate;
        @AuraEnabled
        public String createdByUser;
    }
}