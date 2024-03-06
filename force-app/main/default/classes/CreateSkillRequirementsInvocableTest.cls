/**
 * @author Service
 * @group Invocable action
 * @description Class to test business logic of class CreateSkillRequirementsInvocable
 */
@isTest
private class CreateSkillRequirementsInvocableTest {

    @testSetup
    static void makeData() {
        // make sure that the current user has the correct permission to create TaxonomuSkillMapping__c records
        ServicesTestUtil.assignPermissionsToUser(
            new List<User> {new User(Id = UserInfo.getUserId())}, 
            null, 
            new Set<String> {'ServiceManageTaxonomySkillMapping'}, 
            true);
    }

    @isTest
    private static void createSkillRequirementFromMappingEmptyList() {
        List<List<SkillRequirement>> skillRequirementList = 
            CreateSkillRequirementsInvocable.createSkillRequirementFromMapping(new List<List<TaxonomySkillMapping__c>> ());
        Assert.areNotEqual(null, skillRequirementList, 'Case 1: result list should be an empty list');
        Assert.areEqual(0, skillRequirementList.size(), 'Case 1: result list should be an empty list');
        
        skillRequirementList = 
            CreateSkillRequirementsInvocable.createSkillRequirementFromMapping(new List<List<TaxonomySkillMapping__c>> {new List<TaxonomySkillMapping__c> ()});
        Assert.areNotEqual(null, skillRequirementList, 'Case 2: result list should be an empty list in a list');
        Assert.areEqual(1, skillRequirementList.size(), 'Case 2: result list should be an empty list in a list');
    }

    @isTest
    private static void createSkillRequirementFromMappingSingleList() {
        TaxonomySkillMapping__c tsm = new taxonomySkillMapping__c (
            SkillDeveloperName__c = 'Vip',
            SkillLevel__c = 5,
            IsAdditionalSkill__c = true,
            SkillPriority__c = 2
        );

        Skill expectedSkill = [SELECT Id FROM Skill WHERE DeveloperName = :tsm.SkillDeveloperName__c];

        // case 1: single list with single record in it
        List<List<SkillRequirement>> skillRequirementList = 
            CreateSkillRequirementsInvocable.createSkillRequirementFromMapping(new List<List<TaxonomySkillMapping__c>> {new List<TaxonomySkillMapping__c> {tsm}});
        Assert.areNotEqual(null, skillRequirementList, 'Case 1: result list should not be an empty list');
        Assert.areEqual(1, skillRequirementList.size(), 'Case 1: result list should contain one list');
        Assert.areNotEqual(null, skillRequirementList[0], 'Case 1: result list should not be an empty list in a list');
        Assert.areNotEqual(null, skillRequirementList[0].size(), 'Case 1: result list should have one item');

        SkillRequirement sr = skillRequirementList[0][0];
        Assert.areEqual(expectedSkill.Id, sr.SkillId, 'Case 1: Skill ID');
        Assert.areEqual(tsm.SkillLevel__c, sr.SkillLevel, 'Case 1: Skill Level');
        Assert.areEqual(tsm.isAdditionalSkill__c, sr.isAdditionalSkill, 'Case 1: Is Additional Skill');
        Assert.areEqual(tsm.SkillPriority__c, sr.SkillPriority, 'Case 1: Skill Priority');

        // case 2: single list with multiple records in it
        skillRequirementList = 
            CreateSkillRequirementsInvocable.createSkillRequirementFromMapping(new List<List<TaxonomySkillMapping__c>> {new List<TaxonomySkillMapping__c> {tsm, tsm, tsm}});
        Assert.areEqual(3, skillRequirementList[0].size(), 'Case 2: result list should have 3 items');
    }

    @isTest
    private static void createSkillRequirementFromMappingMultipleLists() {
        TaxonomySkillMapping__c tsm = new taxonomySkillMapping__c (
            SkillDeveloperName__c = 'Vip',
            SkillLevel__c = 5,
            IsAdditionalSkill__c = true,
            SkillPriority__c = 2
        );

        List<List<SkillRequirement>> skillRequirementList = 
            CreateSkillRequirementsInvocable.createSkillRequirementFromMapping(new List<List<TaxonomySkillMapping__c>> {
                new List<TaxonomySkillMapping__c> {tsm, tsm},
                new List<TaxonomySkillMapping__c> {tsm, tsm},
                new List<TaxonomySkillMapping__c> {tsm, tsm}});
        Assert.areNotEqual(null, skillRequirementList, 'result list should not be an empty list');
        Assert.areEqual(3, skillRequirementList.size(), 'result list should contain three lists');
        Assert.areNotEqual(null, skillRequirementList[0], 'result list should not be an empty list in a list');
        Assert.areEqual(2, skillRequirementList[0].size(), 'result list should contain two items');
    }
}