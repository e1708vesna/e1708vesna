/**
 * @Name CaseSkillsCtrlTest
 * @Author Service
 * @Group Test Class
 * @Description Test class to verify the correctness of the methods in the controller class CaseSkillsCtrl.
 *          NOTE: AgentWork records cannot be created manually with a user actual being online in omni-channel!
 */ 
@isTest
private class CaseSkillsCtrlTest {
 
    @isTest
    private static void getSkillsCaseOwnedByQueue() {
        Account acc = ServicesTestUtil.createAccount('testAcc', Constants.RT_ID_ACC_BUSINESS, true);
        Case serviceCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, false);
        serviceCase.OwnerId = ServicesTestUtil.caseQueue.QueueId;   // assign to queue
        insert serviceCase;

        // create pending service routing
        PendingServiceRouting psr = new PendingServiceRouting (
            RoutingType = 'SkillsBased',
            RoutingModel = 'LeastActive',
            RoutingPriority = 1,
            CapacityWeight = 5,
            ServiceChannelId = ServicesTestUtil.caseServiceChannel.Id,
            WorkItemId = serviceCase.Id,
            IsReadyForRouting = false
        );
        insert psr;
        // create skill requirements
        List<Skill> skills = [SELECT Id FROM Skill LIMIT 3];
        List<SkillRequirement> expectedSkillRequirements = new List<SkillRequirement> {
            new SkillRequirement(SkillId = skills[0].Id, IsAdditionalSkill = false, RelatedRecordId = psr.Id),
            new SkillRequirement(SkillId = skills[1].Id, IsAdditionalSkill = false, RelatedRecordId = psr.Id),
            new SkillRequirement(SkillId = skills[2].Id, IsAdditionalSkill = false, RelatedRecordId = psr.Id)
        };
        insert expectedSkillRequirements;
        // activate pending service routing
        psr.IsReadyForRouting = true;
        update psr;

        Test.startTest();

        List<sObject> actualSkillRequirements = CaseSkillsCtrl.getSkills(serviceCase.Id);

        Test.stopTest();

        // verify if all skill requirements have been returned
        Assert.areEqual(3, actualSkillRequirements.size(), 'Number of returned skill requirements');
        Assert.isTrue(actualSkillRequirements[0] instanceOf SkillRequirement, 'Returned object type');
        Set<Id> skillIdSet = (new Map<Id, Skill> (skills)).keySet();
        for (SObject sr : actualSkillRequirements) {
            Assert.isTrue(skillIdSet.contains(((SkillRequirement) sr).SkillId), 'Not the correct skill');
        }
    }

    @isTest
    private static void getSkillsCaseOwnedByQueueNoSkills() {
        Account acc = ServicesTestUtil.createAccount('testAcc', Constants.RT_ID_ACC_BUSINESS, true);
        Case serviceCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, false);
        serviceCase.OwnerId = ServicesTestUtil.caseQueue.QueueId;   // assign to queue
        insert serviceCase;

        // create pending service routing
        PendingServiceRouting psr = new PendingServiceRouting (
            RoutingType = 'SkillsBased',
            RoutingModel = 'LeastActive',
            RoutingPriority = 1,
            CapacityWeight = 5,
            ServiceChannelId = ServicesTestUtil.caseServiceChannel.Id,
            WorkItemId = serviceCase.Id,
            IsReadyForRouting = true
        );
        insert psr;

        Test.startTest();

        List<sObject> actualSkillRequirements = CaseSkillsCtrl.getSkills(serviceCase.Id);

        Test.stopTest();

        // verify if all skill requirements have been returned
        Assert.areEqual(0, actualSkillRequirements.size(), 'Number of returned skill requirements');
    }

    @isTest
    private static void getSkillsCaseWithoutRouting() {
        Account acc = ServicesTestUtil.createAccount('testAcc', Constants.RT_ID_ACC_BUSINESS, true);
        Case serviceCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, true); // assign to user

        Test.startTest();

        List<sObject> actualAgentSkills = CaseSkillsCtrl.getSkills(serviceCase.Id);

        Test.stopTest();

        // verify if all skill requirements have been returned
        Assert.areEqual(0, actualAgentSkills.size(), 'Number of returned skill requirements');
    }

}