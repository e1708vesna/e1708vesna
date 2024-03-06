/**
 * @description   : Account DAO class for retrieving Account data from the database.
 * @author (s)    : BRITE
 */
public class AccountDao {

    /**
     * @description Get accounts by ID with all its Licenses
     */
    public static List<Account> getByIdWithLicenses(Set<Id> endCustomerIdSet) {
        return [SELECT Id,
                    (SELECT Id, EndCustomer__c, ChannelPartner__c FROM LicensesCustomer__r)
                FROM Account
                WHERE Id IN :endCustomerIdSet];
    }

    /**
     * Get all Accounts with the as channelpartner the idSet
     */
     /*
     public static List<Account> getByChannelPartner(Set<Id> channelPartnerIdSet) {
     	return [select Id, ChannelPartner__c from Account where ChannelPartner__c in: channelPartnerIdSet];
     }
     */
}