public class AgentWorkHlpr {

    /**
     * @description This method sets the Case Ownership back to the queue after an agent Declined, Timed-out, is unavailable in omnichannel
     * @param newAgentWork Trigger.New context
     **/
    public static void handleDecline(List<AgentWork> newAgentWork){
        Map<Id,Id> AgentByCaseId = new Map<Id,Id>();
        Set<String> cancelledStatusses = new Set<String>{'Declined','DeclinedOnPushTimeout', 'Unavailable'};
            for (AgentWork aw : newAgentWork){
                if (cancelledStatusses.contains(aw.Status)){
                    AgentByCaseId.put(aw.WorkItemId, aw.UserId);
                    
                }
            }
        List<Case> caseList = new List<Case>();
        for (Case c : [Select Id, OwnerId, PreviousQueueID__c From Case Where Id in: AgentByCaseId.keySet()]){
            if (c.PreviousQueueID__c != null && AgentByCaseId.get(c.Id) == c.OwnerId){ // Check if the owner is the same, otherwise it has already been routed by Omni Channel
                c.OwnerId = c.PreviousQueueID__c;
                caseList.add(c);
            }
        }
        update caseList;
    }
}