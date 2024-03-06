/**
 * @description   : AccountShare DAO class for retrieving AccountShare data from the database.
 * @author (s)    : BRITE
 */
public class AccountShareDao {
    /**
     * @description Return a list of AccountShare records that have the Account Id on the AccountId field.
     * 
     * @param accountIdSet Set of Account Ids that should match the AccountId field.
     * @return Returns either an empty list or a List with the details of the AccountShare.
     */
    public static List<AccountShare> getByAccountId(Set<Id> accountIdSet) {
   		return [Select a.UserOrGroupId, a.RowCause, a.OpportunityAccessLevel, a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.Id, a.ContactAccessLevel, a.CaseAccessLevel, a.AccountId, a.AccountAccessLevel From AccountShare a where RowCause = 'Manual' and AccountId in :accountIdSet];
   		//String qu = 'Select a.UserOrGroupId, a.RowCause, a.OpportunityAccessLevel, a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.Id, a.ContactAccessLevel, a.CaseAccessLevel, a.AccountId, a.AccountAccessLevel From AccountShare a where AccountId in :accountIdSet';
   		//return Database.query(qu);
    }
}