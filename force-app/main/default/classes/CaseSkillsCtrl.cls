/*
 * @name CaseSkillsCtrl
 * @author Service
 * @group Lightning Controller
 * @description This class contains a method retreiving the skills for a case which is in a state of being routed by omni channel or accepted by an agnt.
 */ 
public class CaseSkillsCtrl {

    /**
     * @description Retrieve list of skills needed to solve the case. If the case is not yet assigned to an agent, or the agent didn't yet accept
     *              the case, retrieve the requested mandatory and optional skill. If the case is being worked on by an agent, retrieve the skills
     *              on which the case has been assigned to the agent.
     * 
     * @param caseId Id of the case for which skills need to be retrieved
     * @return List of requested cq accepted skills
     */
    @AuraEnabled(cacheable=true)
    public static List<sObject> getSkills(String caseId) {

        // if there is a pending service routing record, the case is not assigned to an agent or the agent didn't accept it yet
        List<PendingServiceRouting> psrList = [
            SELECT Id
                                               FROM PendingServiceRouting 
                                               WHERE WorkItemId = :caseId 
            ORDER BY CreatedDate DESC
            ]; 
        
        if (!psrList.isEmpty()) {
            // if there is, retrieve the expected skills for the case 
            Id psrId = psrList[0].Id;
            return [SELECT Id, 
                           SkillId, 
                           Skill.MasterLabel, 
                           SkillLevel, 
                           IsAdditionalSkill, 
                           SkillPriority
                   FROM SkillRequirement  
                   WHERE RelatedRecordId =: psrId];
        } else {
            // retrieve skills based on which the agent received the case
            return [SELECT Id, 
                           SkillId, 
                           Skill.MasterLabel, 
                           SkillLevel, 
                           IsAdditionalSkill, 
                           SkillPriority
                    FROM AgentWorkSkill  
                    WHERE AgentWorkId IN (SELECT Id FROM AgentWork WHERE WorkItemId =: caseId AND Status = 'Opened')];
        }
    }  
}