/**
 * @description Test class to verify the correctness of batch class TaskDeleteBatch.
 * @author Brite
 */

@isTest
private class TaskDeleteBatchTest {
    
    @isTest
    private static void DeleteMarketingTasksTest() {
        // create data
        Lead ld = TestUtil.createLead('test lead', Constants.RT_ID_LEAD_INBOUND2, true);
        Lead ld2 = TestUtil.createLead('test lead', Constants.RT_ID_LEAD_INBOUND2, true);
        Account acc = TestUtil.createAccount('Test Company & Co.', Constants.RT_ID_ACC_PARTNER_V2, true);
        Contact con = TestUtil.createContact('Jones', 'jones@testcomp.com.fake', acc.Id, true);
        Contact con2 = TestUtil.createContact('Jones2', 'jones@testcomp.com.fake2', acc.Id, true);
        List<User> marketoUsers = [SELECT Id, Profile.Name FROM User WHERE Profile.Name LIKE '%Marketo%' LIMIT 1];
        Date dueDate = Date.today();
        Task task1, task2, task3, task4, task5, task6;
        // case 1: task created by a non-Marketo user, related to a lead -> task should not be deleted
        task1 = TestUtil.createTask('task test case 1', ld.Id, null, 'Completed', dueDate, false);
        // case 2: task created by a non-Marketo user, related to a contact -> task should not be deleted
        task2 = TestUtil.createTask('task test case 2', con.Id, null, 'Completed', dueDate, false);
        insert new List<Task> {task1, task2};
        if (!marketoUsers.isEmpty()) {
            system.runAs(marketoUsers[0]) {
                //Task Should be deleted
                task3 = TestUtil.createTask('[marketo] task test case 3', ld2.Id, null, 'Completed', dueDate.addDays(5), false);        
                //Task Should be deleted
                task4 = TestUtil.createTask('[marketo] task test case 4', con2.Id, null, 'Completed', dueDate.addDays(5), false);
                //Task should not be deleted
                task5 = TestUtil.createTask('[marketo] task test case 5', null, acc.Id, 'Completed', dueDate.addDays(5), false);
                //Task should not be deleted, since createdDate is not more than 5 minutes ago.
                task6 = TestUtil.createTask('[marketo] task test case 6', con2.Id, null, 'Completed', dueDate.addDays(5), false);
                insert new List<Task> {task3, task4, task5, task6};
            }
        }
        
        DateTime sixMinutesAgo = DateTime.now().addMinutes(-6);
        Test.setCreatedDate(task1.id, sixMinutesAgo);
        Test.setCreatedDate(task2.Id, sixMinutesAgo);
        Test.setCreatedDate(task3.Id, sixMinutesAgo);
        Test.setCreatedDate(task4.Id, sixMinutesAgo);
        Test.setCreatedDate(task5.Id, sixMinutesAgo);
        Test.startTest();
        TaskDeleteBatch batch = new TaskDeleteBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        //only 3 Tasks should remain
        System.assertEquals(4, [SELECT Count() FROM TASK]);
        
    }
}