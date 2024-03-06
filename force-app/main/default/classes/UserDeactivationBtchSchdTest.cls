/**
 * @author (s)    : Brite
 * @description   : UserDeactivationBtchSchd Test Class
 */
@IsTest
private class UserDeactivationBtchSchdTest {
    final static String JOB_NAME_PREFIX = 'UserDeactivationBtchSchd';

    /**
     * @Description test deactivation of the user
     * Deactivate Test
     */
    @isTest static void UserDeactivationBtchSchdTest() {
        SchedulerSettings__c ss = TestUtil.createSchedulerSettings('JOB_NAME_PREFIX', true);

        User partnerUser = TestUtil.createCommunityUser('Steen', 'Adyen v2 Partner Community User', true);

        User usr = [SELECT Id, IsActive FROM User WHERE Alias = 'testos'];
        System.assertEquals(true, usr.IsActive, 'Case 1: User should be activated');

        Test.startTest();

        UserDeactivationBtchSchd udBtchSchd = new UserDeactivationBtchSchd();
        udBtchSchd.inactiveDays = -1;
        udBtchSchd.inactiveDaysAfterActivation = -1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            udBtchSchd.execute(null, udBtchSchd.getDataSet());

            udBtchSchd.scheduleWakeup ();
            udBtchSchd.scheduleStop ();
            udBtchSchd.scheduleSolo ();
        }
        
        Test.StopTest();

        usr = [SELECT Id, IsActive FROM User WHERE Alias = 'testos'];
        System.assertEquals(false, usr.IsActive, 'Case 1: User should be deactivated');
    }
    /**
     * @Description test deactivation of the user with LastActivationDate__c filled
     */
     @isTest static void UserNoDeactivationBtchSchdTest() {
        SchedulerSettings__c ss = TestUtil.createSchedulerSettings('JOB_NAME_PREFIX', true);

        User partnerUser = TestUtil.createCommunityUser('Steen', 'Adyen v2 Partner Community User', true);

        User usr = [SELECT Id, IsActive FROM User WHERE Alias = 'testos'];
        System.assertEquals(true, usr.IsActive, 'Case 2: User should be activated');

        Test.startTest();

        UserDeactivationBtchSchd udBtchSchd = new UserDeactivationBtchSchd();
        udBtchSchd.inactiveDays = -1;
        udBtchSchd.inactiveDaysAfterActivation = 1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            udBtchSchd.execute(null, udBtchSchd.getDataSet());

            udBtchSchd.scheduleWakeup ();
            udBtchSchd.scheduleStop ();
            udBtchSchd.scheduleSolo ();
        }
        
        Test.StopTest();

        usr = [SELECT Id, IsActive FROM User WHERE Alias = 'testos'];
        //System.assertEquals(true, usr.IsActive, 'Case 2: User should not be deactivated');
    }
    
}