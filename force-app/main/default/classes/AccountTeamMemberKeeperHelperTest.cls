@isTest
public class AccountTeamMemberKeeperHelperTest {
	
    
    @isTest
    private static void testOwnerChangeAccount() {
        User testUser1 = TestUtil.createUser();
        User testUser2 = TestUtil.createUser2();
        Account acc = TestUtil.createAccount('TestAcc1', true, true);
        AccountTeamMember act1 = TestUtil.createAccountTeamMember(acc.Id, testUser1.Id, true, true);
        AccountTeamMember act2 = TestUtil.createAccountTeamMember(acc.Id, testUser2.Id, true, true);
        
        List<AccountTeamMember> actList = [Select Id From AccountTeamMember];
        System.assertEquals(3, actList.size(), 'Before owner change, there should be 3 accountTeamMembers');
        acc.OwnerId = testUser1.Id;
        update acc;
        actList = [Select Id From AccountTeamMember];
        System.assertEquals(3, actList.size(), 'after owner change, there should be 3 accountTeamMembers');
    }
}