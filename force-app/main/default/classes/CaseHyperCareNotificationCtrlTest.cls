@isTest
public class CaseHyperCareNotificationCtrlTest {
    
    
    @TestSetup static void testSetup() {
        User agent = ServicesTestUtil.createUser('Basic Service', 'ServiceGenericUser', false);
        agent.LastName = 'skillsAgent';
        insert agent;

        ServicesTestUtil.assignPermissionsToUser(
                new List<User>{agent},
                new Set<String> {ServicesTestUtil.SERVICE_AGENT_PERMISSION_SET_GROUP_NAME},
                new Set<String> (),
                true);
    }
    
    @isTest
    private static void testHasSkillHappy() {
        Id agentId = [SELECT Id FROM User WHERE LastName = 'skillsAgent' LIMIT 1].Id;
        Skill skillToTest = [SELECT Id, DeveloperName FROM Skill LIMIT 1];
        ServiceResource userServiceResource = new ServiceResource(RelatedRecordId = agentId, Name = 'TestUser', IsActive= true);
        insert userServiceResource;
        insert new ServiceResourceSkill(ServiceResourceId = userServiceResource.Id, SkillId = skillToTest.Id, EffectiveStartDate = System.now().addDays(-1));
        System.runAs(new User(Id = agentId)) {
            System.assertEquals(true, CaseHyperCareNotificationCtrl.userHasSkill(skillToTest.DeveloperName), 'Expected user to have skill ' + skillToTest.DeveloperName);
        }
    } 
    
    @isTest
    private static void testHasSkillNoSkill() {
        Id agentId = [SELECT Id FROM User WHERE LastName = 'skillsAgent' LIMIT 1].Id;
        Skill skillToTest = [SELECT Id, DeveloperName FROM Skill LIMIT 1];
        System.runAs(new User(Id = agentId)){
            System.assertEquals(false, CaseHyperCareNotificationCtrl.userHasSkill(skillToTest.DeveloperName), 'Expected user to not have the skill ' + skillToTest.DeveloperName);
        }
    } 
    
    
    @isTest
    private static void testHasSkillNotActiveYet() {
        Id agentId = [SELECT Id FROM User WHERE LastName = 'skillsAgent' LIMIT 1].Id;
        Skill skillToTest = [SELECT Id, DeveloperName FROM Skill LIMIT 1];
        ServiceResource userServiceResource = new ServiceResource(RelatedRecordId = agentId, Name = 'TestUser', IsActive= true);
        insert userServiceResource;
        insert new ServiceResourceSkill(ServiceResourceId = userServiceResource.Id, SkillId = skillToTest.Id, EffectiveStartDate = System.now().addDays(+1));
        System.runAs(new User(Id = agentId)){
            System.assertEquals(false, CaseHyperCareNotificationCtrl.userHasSkill(skillToTest.DeveloperName), 'Expected user to not have the skill ' + skillToTest.DeveloperName);
        }
    } 
    
    @isTest
    private static void testHasSkillInactive() {
        Id agentId = [SELECT Id FROM User WHERE LastName = 'skillsAgent' LIMIT 1].Id;
        Skill skillToTest = [SELECT Id, DeveloperName FROM Skill LIMIT 1];
        ServiceResource userServiceResource = new ServiceResource(RelatedRecordId = agentId, Name = 'TestUser', IsActive= true);
        insert userServiceResource;
        insert new ServiceResourceSkill(ServiceResourceId = userServiceResource.Id, SkillId = skillToTest.Id, EffectiveStartDate = System.now().addDays(-2), EffectiveEndDate = System.now().addDays(-1));
        System.runAs(new User(Id = agentId)){
            System.assertEquals(false, CaseHyperCareNotificationCtrl.userHasSkill(skillToTest.DeveloperName), 'Expected user to not have the skill');
        }
    } 
    
}