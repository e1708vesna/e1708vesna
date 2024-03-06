/**
 * @description Class to handle AgentWork
 */
public virtual class AgentWorkTrgHndl extends TriggerHandler {

    protected List<AgentWork> newAgentWork;
    protected Map<Id, AgentWork> newAgentWorkMap;
    protected List<AgentWork> oldAgentWork;
    protected Map<Id, AgentWork> oldAgentWorkMap;

    protected void filterAgentWorkRecords() {
        TriggerHandler.FilteredRecordSet filteredRecords = filterRecords();
        this.newAgentWork = (List<AgentWork>) filteredRecords.objectNewList;
        this.newAgentWorkMap = filteredRecords.objectNewMap == null || filteredRecords.objectNewMap.isEmpty() ? new Map<Id, AgentWork> () : new Map<Id, AgentWork> (newAgentWork);
        this.oldAgentWork = (List<AgentWork>) filteredRecords.objectOldList;
        this.oldAgentWorkMap = filteredRecords.objectOldMap == null || filteredRecords.objectOldMap.isEmpty() ? new Map<Id, AgentWork> () : new Map<Id, AgentWork> (oldAgentWork);
    }
}