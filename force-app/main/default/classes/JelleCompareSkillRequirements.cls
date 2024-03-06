public class JelleCompareSkillRequirements {
    
    public class Wrapper {
        @InvocableVariable(label='New Skill Requirements' description='New Skill Requirements' required=true)
        public List<SkillRequirement> newSkillRequirements;
        @InvocableVariable(label='Case Id' required=true)
        public Id caseId;
        
        
    }
    
    //Does not account for changes in isAdditionalSkill fields. 
    @InvocableMethod(label='Did requirements change?' description='Compares new skill requirements to existing')
    public static List<boolean> compareSkillRequirements(List<Wrapper> comparable){
        Set<Id> caseIds = new Set<Id>();
        for ( Wrapper c : comparable){
            caseIds.add(c.caseId);
        }
        
        List<Boolean> returnList = new List<Boolean>();
        Map<Id, Map<Id, SkillRequirement>> oldSkillRequirementByCaseId = new Map<Id, Map<Id, SkillRequirement>>();
        Map<Id, PendingServiceRouting> psrByCase = new Map<Id, PendingServiceRouting>();
        Map<Id, PendingServiceRouting> psrMap = new Map<Id, PendingServiceRouting>();
        for (PendingServiceRouting psr : [Select Id, WorkItemId From PendingServiceRouting WHERE WorkItemId in :caseIds]){
            psrByCase.put(psr.WorkItemId, psr);
            psrMap.put(psr.Id, psr);
        }
        
        
        
        For (SkillRequirement sr : [SELECT Id, 
                                    SkillId, 
                                    Skill.DeveloperName, 
                                    SkillLevel, 
                                    IsAdditionalSkill, 
                                    SkillPriority,
                                    RelatedRecordId
                                    FROM SkillRequirement  
                                    WHERE RelatedRecordId in: psrMap.keySet()]){
                                        PendingServiceRouting psr = psrMap.get(sr.RelatedRecordId);
                                        
                                        Map<Id, SkillRequirement> skillRequirementMap = oldSkillRequirementByCaseId.get(psr.WorkItemId);
                                        if (skillRequirementMap == null){
                                            skillRequirementMap = new Map<Id, SkillRequirement>();
                                            oldSkillRequirementByCaseId.put(psr.WorkItemId, new Map<Id, SkillRequirement>());
                                        }
                                        oldSkillRequirementByCaseId.get(psr.WorkItemId).put(sr.SkillId, sr);
                                        
                                        
                                    }
        
        
        for ( Wrapper c : comparable){
            Boolean equal = true;
            Integer srCount = 0;
            for (SkillRequirement sr : c.newSkillRequirements){
                srCount++;
                if (!oldSkillRequirementByCaseId.get(c.caseId).containsKey(sr.SkillId)){
                    equal = false;
                    break;
                }
            }
            //Size check 
            //As the size is the same: it is enough to check only if 1 list is completely in the other. So Size check is sufficient necause we checkd if the old skill requirement still contained the old one..
            System.debug(equal);
            System.debug(srCount);
            System.debug(c.caseId);
            System.debug(oldSkillRequirementByCaseId.get(c.caseId)?.size());
            if (!equal || srCount != oldSkillRequirementByCaseId.get(c.caseId)?.size()) {
                returnList.add(true);
                system.debug(true);
            }
            else {
                
                system.debug(false);
                returnList.add(false);
            }
        }
        return returnList;
    }
}