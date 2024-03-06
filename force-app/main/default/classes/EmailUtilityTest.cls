/**
* @author Sales
* @group Test
* @description Test class for EmailUtility
* name updating.
*/
@isTest
public class EmailUtilityTest {

    @TestSetup
    public static void createTestData() {
        UserRole testRole = new UserRole(Name = 'Test Role', DeveloperName = 'TestRole');
        insert testRole;

        List<Group> testGroups = new List<Group>();
        Group testQueue1 = new Group( Name= 'Test Queue 1', DeveloperName = 'TestQueue1', Type = 'Queue');
        testGroups.add(testQueue1);
        Group testQueue2 = new Group( Name= 'Test Queue 2', DeveloperName = 'TestQueue2', Type = 'Queue');
        testGroups.add(testQueue2);
        Group testPublicGroup = new Group(Name = 'Test Public Group', DeveloperName = 'TestPublicGroup', Type = 'Regular');
        testGroups.add(testPublicGroup);
        insert testGroups;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<User> testUsers = new List<User>();
        User testUser1 = new User(
                Alias = 'standt',
                Email='emailutilitytest@test.com',
                EmailEncodingKey='UTF-8',
                LastName='Testing',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='emailutilitytest1@test.com',
                UserRoleId = testRole.Id);
        testUsers.add(testUser1);
        User testUser2 = new User(
                Alias = 'standt',
                Email='emailutilitytest@test.com',
                EmailEncodingKey='UTF-8',
                LastName='Testing',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='emailutilitytest2@test.com',
                UserRoleId = testRole.Id);
        testUsers.add(testUser2);
        insert testUsers;
        
        List<GroupMember> groupMembers = new List<GroupMember>();
        GroupMember publicGroupMember = new GroupMember(UserOrGroupId = testUser1.Id, GroupId = testPublicGroup.Id);
        groupMembers.add(publicGroupMember);
        GroupMember queueMember1 = new GroupMember(UserOrGroupId = testUser1.Id, GroupId = testQueue1.Id);
        groupMembers.add(queueMember1);
        GroupMember queueMember2 = new GroupMember(UserOrGroupId = testUser1.Id, GroupId = testQueue2.Id);
        groupMembers.add(queueMember2);
        GroupMember queueMember3 = new GroupMember(UserOrGroupId = testUser2.Id, GroupId = testQueue2.Id);
        groupMembers.add(queueMember3);
        insert groupMembers;
        
        createHandoverData();
    }

    /* @Scenario: Sending email to role(s) */
    @IsTest
    public static void sendEmailToRoleTest() {
        Handover__c testHandover = [SELECT Id FROM Handover__c LIMIT 1];
        List<EmailWrapper> emails = new List<EmailWrapper>();
        List<List<EmailWrapper>> container = new List<List<EmailWrapper>>();
        EmailWrapper email = new EmailWrapper();
        email.mappingName = 'TestRecordRole';
        email.recordId = testHandover.Id;
        emails.add(email);
        container.add(emails);
        Test.startTest();
        EmailUtility.sendEmail(container);
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        Assert.areEqual(1, emailInvocations, 'Email was successfully sent');
    }

    /* @Scenario: Sending email to queue(s) */
    @IsTest
    public static void sendEmailToQueueTest() {
        Handover__c testHandover = [SELECT Id FROM Handover__c LIMIT 1];
        List<EmailWrapper> emails = new List<EmailWrapper>();
        List<List<EmailWrapper>> container = new List<List<EmailWrapper>>();
        EmailWrapper email = new EmailWrapper();
        email.mappingName = 'TestRecordQueue';
        email.recordId = testHandover.Id;
        emails.add(email);
        container.add(emails);
        Test.startTest();
        EmailUtility.sendEmail(container);
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        Assert.areEqual(1, emailInvocations, 'Email was successfully sent');
    }

    /* @Scenario: Sending email to public group(s) */
    /*@IsTest
    public static void sendEmailToPublicGroupTest() {
        Handover__c testHandover = [SELECT Id FROM Handover__c LIMIT 1];
        List<EmailWrapper> emails = new List<EmailWrapper>();
        List<List<EmailWrapper>> container = new List<List<EmailWrapper>>();
        EmailWrapper email = new EmailWrapper();
        email.mappingName = 'TestRecordPublicGroup';
        email.recordId = testHandover.Id;
        emails.add(email);
        container.add(emails);
        Test.startTest();
        EmailUtility.sendEmail(container);
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        Assert.areEqual(1, emailInvocations, 'Email was successfully sent');
    }*/

    /* @Description to avoid mixed DML Error */
    @future
    public static void createHandoverData() {
        Handover__c testHandover = new Handover__c();
        testHandover.Desired_AM_Region__c = 'Berlin';
        testHandover.Umbrella_Region__c = 'Germany';
        insert testHandover;
    }

}