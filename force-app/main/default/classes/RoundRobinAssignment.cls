public class RoundRobinAssignment {
    @InvocableMethod (label='Assign Leads Round Robin' description='Assigns the owner of the lead through Round Robin')
    public static void assignLeads(List<Id> leadIds){
        System.debug('In assignLeads Invocable Method: ' + leadIds.size());
        Map<Id, RoundRobinAssignee__c> assigneeToUpdate = new Map<Id, RoundRobinAssignee__c>();
        Map<Id, Lead> leadToUpdate = new Map<Id, Lead>();
		List<Lead> leadList = getLeads(leadIds);
        Map<String, List<Lead>> rrToLeadList = new Map<String, List<Lead>>();
        
        //Populate RoundRobin To Lead map.
        for (Lead ld : leadList){
            if (String.isNotBlank(ld.RoundRobinName__c)){
                if (!rrToLeadList.containsKey(ld.RoundRobinName__c)){
                    List<Lead> tempList = new List<Lead>();
                    tempList.add(ld);
                    rrToLeadList.put(ld.RoundRobinName__c, tempList);
                }
                else {
                    List<Lead> tempList = rrToLeadList.get(ld.RoundRobinName__c);
                    tempList.add(ld);
                }
            }
        }
        
        //Construct RoundRobin To Assignee map.
        Map<String, List<RoundRobinAssignee__c>> rrToAssigneesMap = getRRMap(rrToLeadList.keySet());        
        
        DateTime now = DateTime.now();
        Long timeNow = now.getTime();
        
        //Loop through found Round Robin 
        for (String rrName : rrToAssigneesMap.keySet()){
            integer i = 0;
            List<RoundRobinAssignee__c> assigneeList = rrToAssigneesMap.get(rrName);
            List<Lead> rrLeadList = rrToLeadList.get(rrName);
            for (Lead ld : rrLeadList){
                RoundRobinAssignee__c assignee = assigneeList[math.mod(i, assigneeList.size())];
                ld.OwnerId = assignee.User__c;
                assignee.LastAssigned__c = DateTime.newInstance(timeNow - rrLeadList.size() + i);
                assigneeToUpdate.put(assignee.Id, assignee);
                leadToUpdate.put(ld.Id, ld);
                i++;
            }
        }
        update leadToUpdate.values();
        update assigneeToUpdate.values();
    }
    
    
    //Constructs a map for RoundRobin to Assignees based on the input set
    private static Map<String, List<RoundRobinAssignee__c>> getRRMap(Set<String> roundRobinSet){
        Map<String, List<RoundRobinAssignee__c>> rrToAssigneeMap = new Map<String, List<RoundRobinAssignee__c>>();
        List<RoundRobinAssignee__c> rrAssigneeList = getAsigneeByRoundRobinName(roundRobinSet);
        for (RoundRobinAssignee__c assignee : rrAssigneeList){
            if (!rrToAssigneeMap.containsKey(assignee.RoundRobin__r.Name)){
                    List<RoundRobinAssignee__c> tempList = new List<RoundRobinAssignee__c>();
                    tempList.add(assignee);
                    rrToAssigneeMap.put(assignee.RoundRobin__r.Name, tempList);
                }
                else {
                    List<RoundRobinAssignee__c> tempList = rrToAssigneeMap.get(assignee.RoundRobin__r.Name);
                    tempList.add(assignee);
                }
        }
        return rrToAssigneeMap;
    }
    
    //Queries the lead with Round Robin Information
    private static List<Lead> getLeads(List<Id> leadIds){
        return [SELECT Id, RoundRobinName__c, OwnerId From Lead WHERE Id in: leadIds];
    }
    
    
    
    //Queries the Round Robin Assignees base on round robin name
    private static List<RoundRobinAssignee__c> getAsigneeByRoundRobinName(Set<String> roundRobinSet){
        return [SELECT Id, LastAssigned__c, User__c, RoundRobin__r.Name FROM RoundRobinAssignee__c 
                WHERE IsActive__c = true 
                AND ActiveUser__c = true 
                AND RoundRobin__r.IsActive__c = true 
                AND RoundRobin__r.Name in: roundRobinSet 
                ORDER BY LastAssigned__c ASC];
    }
    
}