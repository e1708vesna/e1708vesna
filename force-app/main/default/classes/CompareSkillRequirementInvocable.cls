public class CompareSkillRequirementInvocable {
    
    public class Wrapper {
        @InvocableVariable(label='New Skill Requirements' description='New Skill Requirements' required=true)
        public List<SkillRequirement> newSkillRequirements;
        @InvocableVariable(label='Old Skill Requirements' description='Old Skill Requirements' required=true)
        public List<SkillRequirement> oldSkillRequirements;
        @InvocableVariable(label='Case Id' required=true)
        public Id caseId;
    }
    
    //Does not account for changes in isAdditionalSkill fields.
    @InvocableMethod(label='Did requirements change?' description='Compares new skill requirements to existing, returns whether the requirements has changed.')
    public static List<boolean> compareSkillRequirements(List<Wrapper> input){
        Set<Id> caseIds = new Set<Id>();
        List<Boolean> returnList = new List<Boolean>();
        Map<Id, Set<Id>> oldSkillRequirementByCaseId = new Map<Id, Set<Id>>();
        //And Query all current SkillRequirements related the the PendingService Routing records
        for ( Wrapper c : input){
            caseIds.add(c.caseId);
            for (SkillRequirement sr : c.oldSkillRequirements){
                Set<Id> skillRequirementSet = oldSkillRequirementByCaseId.get(c.caseId);
                if (skillRequirementSet == null){
                    skillRequirementSet = new Set<Id>();
                    oldSkillRequirementByCaseId.put(c.caseId, new Set<Id>());
                }
                oldSkillRequirementByCaseId.get(c.caseId).add(sr.SkillId);
            }
        }
        //Go over every case that was passed as input and check if the requirements have changed.
        for ( Wrapper c : input){
            Boolean equal = true;
            Integer srCount = 0;
            for (SkillRequirement sr : c.newSkillRequirements){
                srCount++;
                if (!oldSkillRequirementByCaseId.get(c.caseId).contains(sr.SkillId)){
                    equal = false;
                    break;
                }
            }
            //Size check 
            // If there are exactly the same amount of skill requirements in the old situation as the new one. 
            // And the old situation contains all new skill requirements: The requirements have not changed
            if (!equal || srCount != oldSkillRequirementByCaseId.get(c.caseId)?.size()) {
                returnList.add(true);
            }
            else {
                returnList.add(false);
            }
        }
        return returnList;
    }
}