/**
 * @description General FeedComment trigger handler that triggers the filtering on record types and populates the old and new case lists and maps.
 */
public class FeedCommentTrgHndl extends TriggerHandler {
    
    public override void afterInsert() {
        FeedCommentHlpr.handleCommentOnCase((List<FeedComment>) Trigger.new);
    }
    
    
}