@isTest
public class AccountTeamMemberDaoTest {

    
    @isTest
    public static void testGetDetailsByAccountId() {
        // case 1a: null check
        List<AccountTeamMember> resultList = AccountTeamMemberDao.getActiveMembersByAccountId(null, null);
        system.assertNotEquals(null, resultList, 'Case 1a: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1a: number of results returned');

        // case 1b: empty set check
        resultList = AccountTeamMemberDao.getActiveMembersByAccountId(new Set<Id> (), new Set<Id>());
        system.assertNotEquals(null, resultList, 'Case 1b: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 1b: number of results returned');
        
        // case 2: known account ID
        Account acc = TestUtil.createAccount('TestAcc1', true, true);
        resultList = AccountTeamMemberDao.getActiveMembersByAccountId(new Set<Id> {acc.Id}, new Set<Id>());
        system.assertNotEquals(null, resultList, 'Case 2: resultList is null');
        system.assertEquals(1, resultList.size(), 'Case 2: number of results returned');
        
        // case 3: exclude known account ID
        resultList = AccountTeamMemberDao.getActiveMembersByAccountId(new Set<Id> {acc.Id}, new Set<Id> {acc.Id} );
        system.assertNotEquals(null, resultList, 'Case 3: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 3: number of results returned');
        
        // case 4: unknown account ID
        resultList = AccountTeamMemberDao.getActiveMembersByAccountId(new Set<Id> {'0010Q00000EXvFcQAL'}, new Set<Id>());
        system.assertNotEquals(null, resultList, 'Case 4: resultList is null');
        system.assertEquals(0, resultList.size(), 'Case 4: number of results returned');
    }
}