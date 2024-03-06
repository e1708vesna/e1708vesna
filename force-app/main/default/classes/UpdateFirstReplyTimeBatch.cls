public class UpdateFirstReplyTimeBatch implements Database.Batchable<sObject> {
    private String query;

    // Constructor to set the query
    public UpdateFirstReplyTimeBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope) {
        // List to hold cases to be updated
        List<Case> casesToUpdate = new List<Case>();

        // Process each case in the batch
        for (Case c : scope) {
            DateTime earliestTime = findEarliestCommunication(c.Id);
            if (earliestTime != null) {
                c.FirstReplyTime__c = earliestTime;
                casesToUpdate.add(c);
            }
        }

        // Update the cases
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

private DateTime findEarliestCommunication(Id caseId) {
    // Query for earliest feed item based on CreatedDate
    FeedItem[] feedItems = [SELECT CreatedDate FROM FeedItem 
                            WHERE ParentId = :caseId 
                            AND Type = 'TextPost' 
                            AND Visibility = 'AllUsers'
                            ORDER BY CreatedDate ASC LIMIT 1];
    DateTime earliestFeedItemTime = feedItems.isEmpty() ? null : feedItems[0].CreatedDate;

    // Query for earliest email message based on CreatedDate
    EmailMessage[] emailMessages = [SELECT CreatedDate FROM EmailMessage 
                                    WHERE ParentId = :caseId 
                                    AND Incoming = false
                                    ORDER BY CreatedDate ASC LIMIT 1];
    DateTime earliestEmailTime = emailMessages.isEmpty() ? null : emailMessages[0].CreatedDate;

    // Determine the earliest time
    if (earliestFeedItemTime != null && earliestEmailTime != null) {
        return earliestFeedItemTime < earliestEmailTime ? earliestFeedItemTime : earliestEmailTime;
    } else if (earliestFeedItemTime != null) {
        return earliestFeedItemTime;
    } else {
        return earliestEmailTime;
    }
}


    public void finish(Database.BatchableContext bc) {
        // Implement any finalization logic if required
    }
}