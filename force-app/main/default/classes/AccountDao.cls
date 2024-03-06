/**
 * @description Account DAO class for retrieving account data from the database.
 * @author BRITE
 */
public class AccountDao {

    /**
     * @description Return account details
     *
     * @param accountIdSet Set of account ID's for which details must be returned
     */
    public static List<Account> getDetails(Set<Id> accountIdSet) {
        if (accountIdSet == null || accountIdSet.isEmpty()) {
            return new List<Account> ();
        }
        
        return [SELECT Id, Name, Account_Status__c, Type
                FROM Account 
                WHERE Id IN :accountIdSet];
    }      
    
    /**
     * @description Return account details
     *
     * @param accountIdSet Set of account ID's for which details must be returned
     */
    public static List<Account> getPartnerDetails(Set<Id> accountIdSet) {
        if (accountIdSet == null || accountIdSet.isEmpty()) {
            return new List<Account> ();
        }
        
        return [Select Id, Referral__c From Account Where id in :accountIdSet];
    }      
    
    /**
     * @description Return account details
     *
     * @param accountIdSet Set of account ID's for which details must be returned
     */
    public static List<Account> getReferralPartnerDetails(Set<Id> accountIdSet) {
        if (accountIdSet == null || accountIdSet.isEmpty()) {
            return new List<Account> ();
        }

        return [Select Id, Referral__c From Account Where id in :accountIdSet];
    }

    public static List<Account> getAccountsWithOwnerName(Set<Id> accountIds) {
        return [SELECT Id, Owner.Name FROM Account WHERE Id IN :accountIds];
    }
}