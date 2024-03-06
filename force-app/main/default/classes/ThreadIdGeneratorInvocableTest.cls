/*
 * @name ThreadIdGeneratorInvocableTest
 * @author Service
 * @group Invocable Apex Tests
 * @description Unit test class for ThreadIdGeneratorInvocable. This test ensures the proper generation of Thread IDs for Case records.
 */
@isTest
public class ThreadIdGeneratorInvocableTest {

    /*
     * Test the generateThreadId invocable method with valid Case IDs. This ensures that for every given Case ID, a Thread ID is generated.
     */
    @isTest static void testGenerateThreadId() {
        //Create a sample Case record for testing
        Case testCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, null, null, false);
        testCase.Subject = 'Test Case for Thread ID';
        insert testCase;

        // Prepare the input for the invocable method
        ThreadIdGeneratorInvocable.CaseInput caseInput = new ThreadIdGeneratorInvocable.CaseInput();
        caseInput.caseId = testCase.Id;

        // Call the invocable method
        Test.startTest();
        List<ThreadIdGeneratorInvocable.StringOutput> outputs = ThreadIdGeneratorInvocable.generateThreadId(new List<ThreadIdGeneratorInvocable.CaseInput>{ caseInput });
        Test.stopTest();

        

        // Asserts
        Assert.isTrue(outputs != null, 'Output list should not be null');
        Assert.isTrue(outputs.size() == 1, 'Output list should have one entry');
        Assert.isTrue(outputs[0].threadingMessageId != null, 'Thread ID should be generated for valid Case ID');
    }
}