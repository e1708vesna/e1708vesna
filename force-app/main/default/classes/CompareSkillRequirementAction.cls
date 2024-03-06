/**
 * @author Service
 * @group Invocable action
 * @description Action to compare lists of skill requirements to see if there is a difference.
 */
public class CompareSkillRequirementAction {
    
    /**
     * @description Input wrapper class
     */
    public class Wrapper {
        @InvocableVariable(label='New Skill Requirements' description='New Skill Requirements' required=true)
        public List<SkillRequirement> newSkillRequirements;
        @InvocableVariable(label='Old Skill Requirements' description='Old Skill Requirements' required=true)
        public List<SkillRequirement> oldSkillRequirements;
        @InvocableVariable(label='Case Id' required=true)
        public Id caseId;
    }

    /**
     * @description Compare two lists of skill requirements with each other. 
     *      Comparison is based on the SKILL itself and not on other details of the requirement like level or optional/mandatory.
     * 
     * @param input For each comparison the previous and current skill requirements of a case
     * @return For each comparison it will return true if there is a difference in skills between previous and current requirements.
     */
    @InvocableMethod(label='Did Skill Requirements change?' description='Compares new skill requirements to existing, returns whether the requirements has changed.')
    public static List<Boolean> isChangedSkillRequirements(List<Wrapper> input) {
        List<Boolean> returnList = new List<Boolean> ();
        Set<Id> oldSkillIdSet, newSkillIdSet;

        
        // go over every case that was passed as input and check if the requirements have changed.
        Boolean isEqual;
        for (Wrapper c : input) {
            isEqual = true;

            // convert list of old skill requirements into a map of old skill requirements with case ID as the key
            oldSkillIdSet = extractSkillIds(c.oldSkillRequirements);

            // verify if new skills have been added
            newSkillIdSet = new Set<Id> ();
            for (SkillRequirement sr : c.newSkillRequirements) {
                if (!oldSkillIdSet.contains(sr.SkillId)) {
                    isEqual = false;
                    break;
                }
                newSkillIdSet.add(sr.SkillId);
            }

            //Size check 
            // If there are exactly the same amount of skill requirements in the old situation as the new one. 
            // And the old situation contains all new skill requirements: The requirements have not changed
            if (!isEqual || newSkillIdSet.size() != oldSkillIdSet?.size()) {
                returnList.add(true);
            }
            else {
                returnList.add(false);
            }
        }

        return returnList;
    }

    /**
     * @description Extract skill ID's  from the skill requirements.
     * 
     * @param skillRequirements List of Skill Requirement records
     * @return Set of skill ID's
     */
    private static Set<Id> extractSkillIds(List<SkillRequirement> skillRequirements) {
        Set<Id> skillIdSet = new Set<Id> ();

        for (SkillRequirement sr : skillRequirements) {
            skillIdSet.add(sr.SkillId);
        }

        return skillIdSet;
    }

}