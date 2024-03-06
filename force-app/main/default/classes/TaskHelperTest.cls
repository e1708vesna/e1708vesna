/**
 * @description Test class to verify the correctness of the methods in the class TaskHelper.
 * @author Brite
 */
@isTest
private class TaskHelperTest {

    @isTest
    private static void convertToMarketingActivityTest() {
        // create data
        Lead ld = TestUtil.createLead('test lead', Constants.RT_ID_LEAD_INBOUND2, true);
        Lead ld2 = TestUtil.createLead('test lead', Constants.RT_ID_LEAD_INBOUND2, true);
        Account acc = TestUtil.createAccount('Test Company & Co.', Constants.RT_ID_ACC_PARTNER_V2, true);
        Contact con = TestUtil.createContact('Jones', 'jones@testcomp.com.fake', acc.Id, true);
        Contact con2 = TestUtil.createContact('Jones2', 'jones@testcomp.com.fake2', acc.Id, true);

        List<User> marketoUsers = [SELECT Id, Profile.Name FROM User WHERE Profile.Name LIKE '%Marketo%' LIMIT 1];
        
        Date dueDate = Date.today();
        Task task1, task2, task3, task4, task5;

        Test.startTest();
        // case 1: task created by a non-Marketo user, related to a lead -> task should not be deleted
        task1 = TestUtil.createTask('task test case 1', ld.Id, null, 'Completed', dueDate, false);
        // case 2: task created by a non-Marketo user, related to a contact -> task should not be deleted
        task2 = TestUtil.createTask('task test case 2', con.Id, null, 'Completed', dueDate, false);
        insert new List<Task> {task1, task2};
        //Tasks should not be deleted anymore
        if (!marketoUsers.isEmpty()) {
            system.runAs(marketoUsers[0]) {
                // case 3: task created by a Marketo user, related to a lead, Marketing Activity should be created
                task3 = TestUtil.createTask('[marketo] task test case 3', ld2.Id, null, 'Completed', dueDate.addDays(5), false);
                // case 4: task created by a Marketo user, related to a contact -> Marketing Activity should be created
                task4 = TestUtil.createTask('[marketo] task test case 4', con2.Id, null, 'Completed', dueDate.addDays(5), false);
                // case 5: task created by a Marketo user, related to an account -> Marketing Activity should not be created
                task5 = TestUtil.createTask('[marketo] task test case 5', null, acc.Id, 'Completed', dueDate.addDays(5), false);
                insert new List<Task> {task3, task4, task5};
            }
        }
        Test.stopTest();

        List<Task> resultList = [SELECT Id, Subject FROM Task WHERE Id IN (:task1.Id, :task2.Id)];
        system.assertEquals(2, resultList.size(), 'Case 1-2: number of tasks');
        ld = [SELECT Id, LastActivityDate FROM Lead WHERE Id = :ld.Id];
        system.assertEquals(dueDate, ld.LastActivityDate, 'Case 1: LastActivityDate');
        con = [SELECT Id, LastActivityDate FROM Contact WHERE Id = :con.Id];
        system.assertEquals(dueDate, con.LastActivityDate, 'Case 2: LastActivityDate');

        if (!marketoUsers.isEmpty()) {
            resultList = [SELECT Id, Subject, WhoId, WhatId FROM Task WHERE Subject LIKE '[marketo]%' ORDER BY Subject DESC];
            system.assertEquals(3, resultList.size(), 'Case 3-5: number of tasks');
            system.assertEquals('[marketo] task test case 5', resultList[0].Subject, 'Case 5: task should remain unchanged');
            
            ld = [SELECT Id, LastActivityDate FROM Lead WHERE Id = :ld2.Id];
            system.assertEquals(dueDate.addDays(5), ld.LastActivityDate, 'Case 3: LastActivityDate');
            con = [SELECT Id, LastActivityDate FROM Contact WHERE Id = :con2.Id];
            system.assertEquals(dueDate.addDays(5), con.LastActivityDate, 'Case 4: LastActivityDate');

            List<MarketingActivity__c> markActivityList = [SELECT Id, Subject__c, Comments__c, Lead__c, Contact__c FROM MarketingActivity__c];
            system.assertEquals(2, markActivityList.size(), 'Case 3-4: number of MarketingActivity__c records');
            for (MarketingActivity__c ma : markActivityList) {
                system.assertEquals(task1.Description, ma.Comments__c, 'Case 3-4: Comments__c');
                if (ma.Subject__c == '[marketo] task test case 3') {
                    system.assertEquals(ld.Id, ma.Lead__c, 'Case 3: Lead__c');
                    system.assertEquals(null, ma.Contact__c, 'Case 3: Contact__c');
                } else if (ma.Subject__c == '[marketo] task test case 4') {
                    system.assertEquals(null, ma.Lead__c, 'Case 4: Lead__c');
                    system.assertEquals(con.Id, ma.Contact__c, 'Case 4: Contact__c');
                } else {
                    system.assert(false, 'Unknown MarketingActivity__c record: ' + ma);
                }
            }
        } 
    }
}