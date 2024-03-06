@isTest
private class TaskDaoTest {

    @isTest
    private static void getDetailsTest() {
        // create test data
        Lead ld = TestUtil.createLead('test lead', Constants.RT_ID_LEAD_INBOUND2, true);
        Task tk = TestUtil.createTask('task 1', ld.Id, null, 'Completed', Date.today(), true);

        // case 1: unknown Id
        List<Task> resultList = TaskDao.getDetails(new Set<Id> {ld.Id});
        system.assertNotEquals(null, resultList, 'Case 1: returned value is null');
        system.assertEquals(0, resultList.size(), 'Case 1: number of tasks');

        // case 2: known Id
        resultList = TaskDao.getDetails(new Set<Id> {tk.Id});
        system.assertNotEquals(null, resultList, 'Case 2: returned value is null');
        system.assertEquals(1, resultList.size(), 'Case 2: number of tasks');
    }

}