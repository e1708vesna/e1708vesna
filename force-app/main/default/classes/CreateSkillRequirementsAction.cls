/**
 * @author Service
 * @group Invocable action
 * @description Action to convert records from Taxonomy-Skill Mapping object to Skill Requirement records.
 */
public class CreateSkillRequirementsAction {
    
    /**
     * @description Convert list of TaxonomySkillMapping__c records into SkillRequirement records. It will set
     *      the level, mandatory/optional and priority of a skill.
     * 
     * @param taxonomySkillMappingLists List of a list of TaxonomySkillMapping__c records to convert
     * @return List of a list of converted SkillRequirement records
     */
    @InvocableMethod(label='Create SkillRequirement from Mapping' description='Convert Taxonomy Skill Mapping to Skill Requirement')
    public static List<List<SkillRequirement>> createSkillRequirementFromMapping(List<List<TaxonomySkillMapping__c>> taxonomySkillMappingLists) {
        List<List<SkillRequirement>> output = new List<List<SkillRequirement>>();
        Set<String> SkillDeveloperNames = new Set<String>();
        Map<String, Id> SkillByDeveloperName = new Map<String, Id>();

        // collect developer names of the needed skills
        for (List<TaxonomySkillMapping__c> taxonomySkillMappingList : taxonomySkillMappingLists) {
            for (TaxonomySkillMapping__c mappingRecord : taxonomySkillMappingList) {
                SkillDeveloperNames.add(mappingRecord.SkillDeveloperName__c);
            }
        }

        // retrieve skill ids
        for (Skill s : [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName IN: SkillDeveloperNames]) {
            SkillByDeveloperName.put(s.DeveloperName, s.Id);
        }

        // convert taxonomy-skill mapping records into Skill Requirement records
        for (List<TaxonomySkillMapping__c> taxonomySkillMappingList : taxonomySkillMappingLists) {
            List<SkillRequirement> skillRequirements = new List<SkillRequirement>();
            output.add(skillRequirements);
            for (TaxonomySkillMapping__c mappingRecord : taxonomySkillMappingList) {
                if (SkillByDeveloperName.containsKey(mappingRecord.SkillDeveloperName__c)) {
                    SkillRequirement sr = new SkillRequirement();
                    sr.SkillId = SkillByDeveloperName.get(mappingRecord.SkillDeveloperName__c);
                    sr.SkillLevel = mappingRecord.SkillLevel__c != null ? mappingRecord.SkillLevel__c : 0;
                    sr.IsAdditionalSkill = mappingRecord.IsAdditionalSkill__c;
                    if (sr.IsAdditionalSkill){
                        sr.SkillPriority = mappingRecord.SkillPriority__c != null ? Integer.valueOf(mappingRecord.SkillPriority__c) : 0;
                    }
                    skillRequirements.add(sr);
                }
            }
        }

        return output;
    }
}