public class AccountTeamMemberDao {
	/**
     * @description Return accountteammember details
     *
     * @param accountIdSet Set of account ID's for which details must be returned
     */
    public static List<AccountTeamMember> getActiveMembersByAccountId(Set<Id> accountIdSet, Set<Id> excludedAccountIdSet) {
        if (accountIdSet == null || accountIdSet.isEmpty()) {
            return new List<AccountTeamMember> ();
        }
        return [Select Id, AccountId, AccountAccessLevel, CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel, TeamMemberRole, UserId 
                FROM AccountTeamMember 
                WHERE User.IsActive = true 
                AND AccountId in: accountIdSet 
                AND AccountId not in: excludedAccountIdSet];
    }      
}