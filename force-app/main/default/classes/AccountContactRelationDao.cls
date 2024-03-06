/**
 * @description   : AccountContactRelation DAO class for retrieving Account-Contact direct/indirect relations from the database.
 * @author (s)    : BRITE
 */
public class AccountContactRelationDao {

    /**
     * @description Retrieve account-contact (direct/indirect) relations based on contact ID.
     */
    public static List<AccountContactRelation> getByContactId(Set<Id> contactIdSet) {
        return [SELECT Id, AccountId, ContactId, IsActive, IsDirect 
                FROM AccountContactRelation
                WHERE IsActive = true AND ContactId IN :contactIdSet];
    }

    /**
     * @description Retrieve account-contact (direct/indirect) relations based on account ID.
     */
    public static List<AccountContactRelation> getByAccountId(Set<Id> accountIdSet) {
        return [SELECT Id, AccountId, ContactId, IsActive, IsDirect 
                FROM AccountContactRelation
                WHERE IsActive = true AND AccountId IN :accountIdSet];
    }

}