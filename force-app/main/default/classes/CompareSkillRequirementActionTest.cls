/**
 * @author Service
 * @group Invocable action
 * @description Class to test business logic of class CompareSkillRequirementAction
 */
@isTest
private class CompareSkillRequirementActionTest {

    private static Id ID_SKILL_1 = '0C57E0000000801';
    private static Id ID_SKILL_2 = '0C57E0000000802';
    private static Id ID_SKILL_3 = '0C57E0000000803';

    @isTest
    private static void noSkillsTest() {
        CompareSkillRequirementAction.Wrapper singleInput = new CompareSkillRequirementAction.Wrapper();
        singleInput.caseId = '5007E00000FWiBYQA1';
        singleInput.oldSkillRequirements = new List<SkillRequirement> {};
        singleInput.newSkillRequirements = new List<SkillRequirement> {};

        List<Boolean> skillRequirementList = 
            CompareSkillRequirementAction.isChangedSkillRequirements(new List<CompareSkillRequirementAction.Wrapper> {singleInput});

//        Assert.areNotEqual(null, skillRequirementList, 'Result should be a empty list instead of null');
        Assert.areNotEqual(null, skillRequirementList, 'Result list should not be null');
        Assert.areEqual(1, skillRequirementList.size(), 'Result should be a list with one boolean value');
        Assert.areEqual(false, skillRequirementList[0], 'Result of the lists comparison');
    }

    @isTest
    private static void skillsNotChangedTest() {
        CompareSkillRequirementAction.Wrapper singleInput = new CompareSkillRequirementAction.Wrapper();
        singleInput.caseId = '5007E00000FWiBYQA1';
        singleInput.oldSkillRequirements = new List<SkillRequirement> {
                new SkillRequirement(SkillId = ID_SKILL_1),
                new SkillRequirement(SkillId = ID_SKILL_2),
                new SkillRequirement(SkillId = ID_SKILL_3)
            };
        singleInput.newSkillRequirements = new List<SkillRequirement> {
            new SkillRequirement(SkillId = ID_SKILL_3),
            new SkillRequirement(SkillId = ID_SKILL_1),
            new SkillRequirement(SkillId = ID_SKILL_2)
        };

        List<Boolean> skillRequirementList = 
            CompareSkillRequirementAction.isChangedSkillRequirements(new List<CompareSkillRequirementAction.Wrapper> {singleInput});

        Assert.areNotEqual(null, skillRequirementList, 'Result list should not be null');
        Assert.areEqual(1, skillRequirementList.size(), 'Result should be a list with one boolean value');
        Assert.areEqual(false, skillRequirementList[0], 'Result of the lists comparison');
    }
    
    @isTest
    private static void skillAddedTest() {
        CompareSkillRequirementAction.Wrapper singleInput = new CompareSkillRequirementAction.Wrapper();
        singleInput.caseId = '5007E00000FWiBYQA1';
        singleInput.oldSkillRequirements = new List<SkillRequirement> {
                new SkillRequirement(SkillId = ID_SKILL_1),
                new SkillRequirement(SkillId = ID_SKILL_2)
            };
        singleInput.newSkillRequirements = new List<SkillRequirement> {
            new SkillRequirement(SkillId = ID_SKILL_1),
            new SkillRequirement(SkillId = ID_SKILL_3),
            new SkillRequirement(SkillId = ID_SKILL_2)
        };

        List<Boolean> skillRequirementList = 
            CompareSkillRequirementAction.isChangedSkillRequirements(new List<CompareSkillRequirementAction.Wrapper> {singleInput});

        Assert.areNotEqual(null, skillRequirementList, 'Result list should not be null');
        Assert.areEqual(1, skillRequirementList.size(), 'Result should be a list with one boolean value');
        Assert.areEqual(true, skillRequirementList[0], 'Result of the lists comparison');
    }
    
    @isTest
    private static void skillRemovedTest() {
        CompareSkillRequirementAction.Wrapper singleInput = new CompareSkillRequirementAction.Wrapper();
        singleInput.caseId = '5007E00000FWiBYQA1';
        singleInput.oldSkillRequirements = new List<SkillRequirement> {
                new SkillRequirement(SkillId = ID_SKILL_1),
                new SkillRequirement(SkillId = ID_SKILL_2),
                new SkillRequirement(SkillId = ID_SKILL_3)
            };
        singleInput.newSkillRequirements = new List<SkillRequirement> {
            new SkillRequirement(SkillId = ID_SKILL_1),
            new SkillRequirement(SkillId = ID_SKILL_3)
        };

        List<Boolean> skillRequirementList = 
            CompareSkillRequirementAction.isChangedSkillRequirements(new List<CompareSkillRequirementAction.Wrapper> {singleInput});

        Assert.areNotEqual(null, skillRequirementList, 'Result list should not be null');
        Assert.areEqual(1, skillRequirementList.size(), 'Result should be a list with one boolean value');
        Assert.areEqual(true, skillRequirementList[0], 'Result of the lists comparison');
    }

    @isTest
    private static void duplicateSkillsInListTest() {
        // case 1: duplicate skill contained in old list
        CompareSkillRequirementAction.Wrapper singleInput = new CompareSkillRequirementAction.Wrapper();
        singleInput.caseId = '5007E00000FWiBYQA1';
        singleInput.oldSkillRequirements = new List<SkillRequirement> {
                new SkillRequirement(SkillId = ID_SKILL_1),
                new SkillRequirement(SkillId = ID_SKILL_2),
                new SkillRequirement(SkillId = ID_SKILL_1)
            };
        singleInput.newSkillRequirements = new List<SkillRequirement> {
            new SkillRequirement(SkillId = ID_SKILL_1),
            new SkillRequirement(SkillId = ID_SKILL_2)
        };

        List<Boolean> skillRequirementList = 
            CompareSkillRequirementAction.isChangedSkillRequirements(new List<CompareSkillRequirementAction.Wrapper> {singleInput});

        Assert.areNotEqual(null, skillRequirementList, 'Case 1: Result list should not be null');
        Assert.areEqual(1, skillRequirementList.size(), 'Case 1: Result should be a list with one boolean value');
        Assert.areEqual(false, skillRequirementList[0], 'Case 1: Result of the lists comparison');

        // case 2: duplicate skill contained in new list
        singleInput.oldSkillRequirements = new List<SkillRequirement> {
            new SkillRequirement(SkillId = ID_SKILL_1),
            new SkillRequirement(SkillId = ID_SKILL_2)
        };
        singleInput.newSkillRequirements = new List<SkillRequirement> {
            new SkillRequirement(SkillId = ID_SKILL_1),
            new SkillRequirement(SkillId = ID_SKILL_2),
            new SkillRequirement(SkillId = ID_SKILL_1)
        };

        skillRequirementList = CompareSkillRequirementAction.isChangedSkillRequirements(new List<CompareSkillRequirementAction.Wrapper> {singleInput});

        Assert.areNotEqual(null, skillRequirementList, 'Case 2: Result list should not be null');
        Assert.areEqual(1, skillRequirementList.size(), 'Case 2: Result should be a list with one boolean value');
        Assert.areEqual(false, skillRequirementList[0], 'Case 2: Result of the lists comparison');
    }

    @isTest
    private static void compareForMultipleCasesTest() {
        CompareSkillRequirementAction.Wrapper singleInput1 = new CompareSkillRequirementAction.Wrapper();
        singleInput1.caseId = '5007E00000FWiBYQA1';
        singleInput1.oldSkillRequirements = new List<SkillRequirement> {
                new SkillRequirement(SkillId = ID_SKILL_1),
                new SkillRequirement(SkillId = ID_SKILL_3)
            };
        singleInput1.newSkillRequirements = new List<SkillRequirement> {
            new SkillRequirement(SkillId = ID_SKILL_1),
            new SkillRequirement(SkillId = ID_SKILL_2),
            new SkillRequirement(SkillId = ID_SKILL_3)
        };

        CompareSkillRequirementAction.Wrapper singleInput2 = new CompareSkillRequirementAction.Wrapper();
        singleInput2.caseId = '5007E00000FWiBYQA2';
        singleInput2.oldSkillRequirements = new List<SkillRequirement> {
                new SkillRequirement(SkillId = ID_SKILL_1),
                new SkillRequirement(SkillId = ID_SKILL_2)
            };
        singleInput2.newSkillRequirements = new List<SkillRequirement> {
            new SkillRequirement(SkillId = ID_SKILL_2),
            new SkillRequirement(SkillId = ID_SKILL_1)
        };

        List<Boolean> skillRequirementList = 
            CompareSkillRequirementAction.isChangedSkillRequirements(new List<CompareSkillRequirementAction.Wrapper> {singleInput1, singleInput2});

        Assert.areNotEqual(null, skillRequirementList, 'Result list should not be null');
        Assert.areEqual(2, skillRequirementList.size(), 'Size of the result list');
        // order of the results should be equal to the order of the input
        Assert.areEqual(true, skillRequirementList[0], 'Result of the lists comparison for case 1');
        Assert.areEqual(false, skillRequirementList[1], 'Result of the lists comparison for case 2');
    }

}