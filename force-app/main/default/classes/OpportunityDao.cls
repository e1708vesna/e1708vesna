/**
 * @description Opportunity DAO class for retrieving opportunity data from the database.
 * @author BRITE
 */
public class OpportunityDao {
    
    /**
     * @description Return opportunity details based on account IDs.
     *
     * @param accountIdSet Set of account ID's for which opportunities must be returned
     */
    public static List<Opportunity> getOpportunitiesBasedOnAccount(Set<Id> accountIdSet) {
        if (accountIdSet == null || accountIdSet.isEmpty()) {
            return new List<Opportunity> ();
        }
        
        return [SELECT Id, Name, Sales_channel__c, CreatedDate, Account.Id, Account.Name
                FROM Opportunity 
                WHERE AccountId IN :accountIdSet];
    }

    /* @Description queries referral opportunities according to stage
     * @Param statuses opportunity stages by which the records have to be filtered
     * @Return List<Lead>
     */
    public static List<Opportunity> getReferralOpportunitiesByStage(Set<String> stages) {
        return [SELECT Id, PartnerContactEmail__c, PartnerManagerEmail__c, StageName, PartnerNotified__c
                FROM Opportunity
                WHERE Referral_by_account__c != NULL
                AND PartnerReferralContact__c != NULL
                AND StageName IN :stages
                AND PartnerNotified__c = false];
    }
}