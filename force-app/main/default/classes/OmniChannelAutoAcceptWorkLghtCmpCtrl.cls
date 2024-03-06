/**
 * @description Controller class for OmniChannelAutoAcceptWork Lightning component.
 * @author Service
 **/
public class OmniChannelAutoAcceptWorkLghtCmpCtrl {
    
	@AuraEnabled
    public static AgentWork getAgentWorkDetails(String agentWorkId) {
    	List<AgentWork> agentWorkList = [SELECT Id, IsStatusChangeInitiated, IsOwnerChangeInitiated FROM AgentWork WHERE Id =: agentWorkId];
        if (agentWorkList != null && agentWorkList.size() > 0){
            return agentWorkList[0];
        }
        return null;
    }
}