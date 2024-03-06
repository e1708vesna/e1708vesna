/*
 * @name CaseHyperCareNotificationCtrl
 * @author Service
 * @group Lightning Controller
 * @description This class contains the  method to check if the running user has a specific Service Resource Skill
 */ 
public with sharing class CaseHyperCareNotificationCtrl {
    
    /**
     * Checks if the running user has a specific Service Resource Skill
     * @param skillName Service Resource Skill Name to check against
     * @return returns True or False depending on if the current user has the Service Resource Skill assigned
     **/
    @AuraEnabled(cacheable=true)
    public static boolean userHasSkill(String skillName) {
        return [
            SELECT Id 
            FROM ServiceResourceSkill 
            WHERE EffectiveStartDate < :System.now() 
                AND (EffectiveEndDate = null OR EffectiveEndDate > :System.now()) 
                AND ServiceResource.RelatedRecordId = :UserInfo.getUserID() 
                AND Skill.DeveloperName =: skillName].size() > 0;
    }
}