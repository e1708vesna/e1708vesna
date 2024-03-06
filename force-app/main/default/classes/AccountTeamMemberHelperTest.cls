/**
 * @description Test class for testing functionality of class AccountTeamMemberHelper
 * @author BRITE
 */
@isTest
private class AccountTeamMemberHelperTest {

    @testSetup
    private static void setup(){
    	Test.startTest();
        User tmpUser = TestUtil.createUser();
        
        System.debug('First OwnerId: ' + tmpUser.Id);
        Account acc = new Account (Name = 'Test Account7', 
                                    OwnerId = tmpUser.Id, 
                                    BillingCountry = 'United States', 
                                    Account_Status__c = Constants.ACC_STATUS_LIVEANDTRANSACTING);
        insert acc;
    	Test.stopTest();
    }

    @isTest
    public static void testOwnerAddToAccountTeam() {
        String roleName = 'Account Owner';
        String accountAccessLevelInit = 'Edit';
        String caseAccessLevelInit = 'Edit';
        String contactAccessLevelInit = 'Edit';
        String opportunityAccessLevelInit = 'Edit';
		User tmpUser = TestUtil.createUser2();
        //Case 1: Add Account owner to the Account Team
        Id currentUserId = UserInfo.getUserId();
        Account acc = [SELECT Name, OwnerId, BillingCountry, Account_Status__c FROM Account WHERE Name = 'Test Account7']; 
        acc.OwnerId = tmpUser.Id;
        update acc;

        Test.startTest();
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(acc.Id);
        List<AccountTeamMember> accTeamMemberList = [
                Select Id, AccountId, UserId, TeamMemberRole, AccountAccessLevel, 
                CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel 
                From AccountTeamMember 
                where AccountId in : accIdSet and TeamMemberRole = :roleName and UserId = :tmpUser.Id];
        system.assertEquals(1, accTeamMemberList.size(), 'Case 1: TeamMemberRole should exist');
        system.assertEquals(tmpUser.Id, accTeamMemberList[0].UserId, 'Case 1: Owner should be set in the AccountTeam');
        system.assertEquals(roleName, accTeamMemberList[0].TeamMemberRole, 'Case 1: TeamMemberRole should be set to ' + roleName);
        system.assertEquals(accountAccessLevelInit, accTeamMemberList[0].AccountAccessLevel, 'Case 1: AccountAccessLevel should be ' + accountAccessLevelInit);
        system.assertEquals(caseAccessLevelInit, accTeamMemberList[0].CaseAccessLevel, 'Case 1: CaseAccessLevel should be ' + caseAccessLevelInit);
        //Controlled By Parent system.assertEquals(contactAccessLevelInit, accTeamMemberList[0].ContactAccessLevel, 'Case 1: ContactAccessLevel should be ' + contactAccessLevelInit);
        system.assertEquals(opportunityAccessLevelInit, accTeamMemberList[0].OpportunityAccessLevel, 'Case 1: OpportunityAccessLevel should be ' + opportunityAccessLevelInit);

        //Case 2: Change Account owner in the Account Team
        
        acc.OwnerId = currentUserId;
        update acc;

        Account tmpAccount = [select id, OwnerId from Account where id = :acc.Id];
        system.assertEquals(currentUserId, acc.OwnerId, 'Case 2: Owner should be changed');

        accTeamMemberList = [
                Select Id, AccountId, UserId, TeamMemberRole, AccountAccessLevel, 
                CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel 
                From AccountTeamMember 
                where AccountId in : accIdSet and TeamMemberRole = :roleName and UserId =: currentUserId];

        system.assertEquals(1, accTeamMemberList.size(), 'Case 2: only 1 TeamMemberRole should exist');
        system.assertEquals(currentUserId, accTeamMemberList[0].UserId, 'Case 2: Owner should be set in the AccountTeam');
        system.assertEquals(roleName, accTeamMemberList[0].TeamMemberRole, 'Case 2: TeamMemberRole should be set to ' + roleName);
        system.assertEquals(accountAccessLevelInit, accTeamMemberList[0].AccountAccessLevel, 'Case 2: AccountAccessLevel should be ' + accountAccessLevelInit);
        system.assertEquals(caseAccessLevelInit, accTeamMemberList[0].CaseAccessLevel, 'Case 2: CaseAccessLevel should be ' + caseAccessLevelInit);
        //Controlled By Parent system.assertEquals(contactAccessLevelInit, accTeamMemberList[0].ContactAccessLevel, 'Case 2: ContactAccessLevel should be ' + contactAccessLevelInit);
        system.assertEquals(opportunityAccessLevelInit, accTeamMemberList[0].OpportunityAccessLevel, 'Case 2: OpportunityAccessLevel should be ' + opportunityAccessLevelInit);
        Test.stopTest();

    }

    @isTest
    public static void testInactiveOwnerAddToAccountTeam() {
        String roleName = 'Account Owner';
        String accountAccessLevelInit = 'Edit';
        String caseAccessLevelInit = 'Edit';
        String contactAccessLevelInit = 'Edit';
        String opportunityAccessLevelInit = 'Edit';

        //Case 1: Add Account owner to the Account Team
        Id currentUserId = UserInfo.getUserId();

        Account acc = [SELECT Name, OwnerId, BillingCountry, Account_Status__c FROM Account WHERE Name = 'Test Account7']; 
        Id tmpUserId = acc.OwnerId;

        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(acc.Id);

        List<AccountTeamMember> accTeamMemberList = [
            Select Id, AccountId, UserId, TeamMemberRole, AccountAccessLevel, 
            CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel 
            From AccountTeamMember 
            where AccountId in : accIdSet and TeamMemberRole = :roleName];
        system.assertEquals(1, accTeamMemberList.size(), 'Case 1: only 1 TeamMemberRole should exist');
        system.assertEquals(tmpUserId, accTeamMemberList[0].UserId, 'Case 1: Owner should be set in the AccountTeam');
        system.assertEquals(roleName, accTeamMemberList[0].TeamMemberRole, 'Case 1: TeamMemberRole should be set to ' + roleName);
        system.assertEquals(accountAccessLevelInit, accTeamMemberList[0].AccountAccessLevel, 'Case 1: AccountAccessLevel should be ' + accountAccessLevelInit);
        system.assertEquals(caseAccessLevelInit, accTeamMemberList[0].CaseAccessLevel, 'Case 1: CaseAccessLevel should be ' + caseAccessLevelInit);
        //Controlled By Parent system.assertEquals(contactAccessLevelInit, accTeamMemberList[0].ContactAccessLevel, 'Case 1: ContactAccessLevel should be ' + contactAccessLevelInit);
        system.assertEquals(opportunityAccessLevelInit, accTeamMemberList[0].OpportunityAccessLevel, 'Case 1: OpportunityAccessLevel should be ' + opportunityAccessLevelInit);

        Test.startTest();
        User tmpUser = new User(Id = acc.OwnerId, IsActive = false);
        update tmpUser;
        Test.stopTest();

        system.runAs(new User(Id=currentUserId)) {
            //update acc;
        }

        //List<AccountTeamMember> accTeamMemberList = [
        accTeamMemberList = [
                Select Id, AccountId, UserId, TeamMemberRole, AccountAccessLevel, 
                CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel 
                From AccountTeamMember 
                where AccountId in : accIdSet and TeamMemberRole = :roleName];
        system.assertEquals(1, accTeamMemberList.size(), 'Case 1: only 1 TeamMemberRole should exist');
        system.assertEquals(tmpUserId, accTeamMemberList[0].UserId, 'Case 1: Owner should be set in the AccountTeam');
        system.assertEquals(roleName, accTeamMemberList[0].TeamMemberRole, 'Case 1: TeamMemberRole should be set to ' + roleName);

        //Changed since spring 2020 update, inactive users will switch to readonly for Opportunity and Account!
        //system.assertEquals(accountAccessLevelInit, accTeamMemberList[0].AccountAccessLevel, 'Case 1: AccountAccessLevel should be ' + accountAccessLevelInit);

        //system.assertEquals(caseAccessLevelInit, accTeamMemberList[0].CaseAccessLevel, 'Case 1: CaseAccessLevel should be ' + caseAccessLevelInit);
        //Controlled By Parent system.assertEquals(contactAccessLevelInit, accTeamMemberList[0].ContactAccessLevel, 'Case 1: ContactAccessLevel should be ' + contactAccessLevelInit);
        //system.assertEquals(opportunityAccessLevelInit, accTeamMemberList[0].OpportunityAccessLevel, 'Case 1: OpportunityAccessLevel should be ' + opportunityAccessLevelInit);

        //Case 2: try Change Account owner in the Account Team withinactive user

        system.runAs(new User(Id=currentUserId)) {
            acc.OwnerId = currentUserId;
            update acc;
        }

        Account tmpAccount = [select id, OwnerId from Account where id = :acc.Id];
        system.assertNotEquals(tmpUserId, acc.OwnerId, 'Case 2: Owner should not be changed');

        accTeamMemberList = [
                Select Id, AccountId, UserId, TeamMemberRole, AccountAccessLevel, 
                CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel 
                From AccountTeamMember 
                where AccountId in : accIdSet and TeamMemberRole = :roleName];

        system.assertEquals(1, accTeamMemberList.size(), 'Case 2: only 1 TeamMemberRole should exist');

    }

}