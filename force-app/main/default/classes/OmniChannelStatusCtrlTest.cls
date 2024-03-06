/*
 * @description Test class for OmniChannelStatusCtrl. It focuses on testing the getCaseOmniChannelStatus method.
 */
@isTest
private class OmniChannelStatusCtrlTest {

    /*
     * @description Test to ensure the mock AgentWork data is returned correctly when a test is running.
     */
    @isTest
    static void testGetCaseOmniChannelStatusWithMockData() {
        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, null, null, false);
        c.Subject = 'Test Case';
        insert c;

        List<AgentWork> results = OmniChannelStatusCtrl.getCaseOmniChannelStatus(c.Id);
        
        Assert.IsTrue(results != null, 'Results should not be null.');
        Assert.IsTrue(results.size() == 1, 'Should return one mock AgentWork record.');
        Assert.IsTrue(results[0].Status == 'Declined', 'Mocked AgentWork should have Declined status.');
        Assert.IsTrue(results[0].User.Name == 'Agent 3rd Line', 'Associated user name should be Agent 3rd Line.');
    }

}