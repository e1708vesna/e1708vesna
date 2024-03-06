public class JelleDebugCaseSkillsController {
	@AuraEnabled
    public static List<sObject> serverEcho(String caseId) {
        
        List<PendingServiceRouting> psrList = [SELECT Id, CapacityWeight, RoutingType, RoutingPriority, ServiceChannel.DeveloperName, Queue.DeveloperName, IsReadyForRouting FROM PendingServiceRouting Where WorkItemId = :caseId order by CreatedDate desc];
        if (psrList != null && psrList.size() > 0){
           Id psrId = psrList[0].Id;
            return [SELECT Id, 
                SkillId, 
                Skill.DeveloperName, 
                Skill.MasterLabel,
                SkillLevel, 
                IsAdditionalSkill, 
                SkillPriority
                FROM SkillRequirement  
                WHERE RelatedRecordId =: psrId];
        }
        else {
            return [SELECT Id, 
                SkillId, 
                Skill.DeveloperName, 
                Skill.MasterLabel,
                SkillLevel, 
                IsAdditionalSkill, 
                SkillPriority
                FROM AgentWorkSkill  
                WHERE AgentWorkId in (Select Id From AgentWork Where WorkItemId =: caseId AND Status = 'Opened')];
        }
    }
}