public without sharing class AgentWorkTrgHndlr extends AgentWorkTrgHndl{

    public AgentWorkTrgHndlr() {
        filterAgentWorkRecords();
    }

    public override void afterUpdate() {
        AgentWorkHlpr.handleDecline(newAgentWork);
    }

}