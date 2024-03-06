/**
 * @description Partner__c DAO class for retrieving leadPartner data from the database.
 * @author BRITE
 */
public class LeadPartnerDao {

    /**
     * @description Return opportunity Partner Details
     *
     * @param leadIdSet Set of opportunity ID's for which opportunities must be returned
     */
    public static List<LeadPartner__c> getDetailsByLead(Set<Id> leadIdSet) {
        if (leadIdSet == null || leadIdSet.isEmpty()) {
            return new List<LeadPartner__c> ();
        }
        
        return [Select Id,
                 Lead__c,
                 AdyenForPlatforms__c,
                 PaymentOrchestration__c,
                 Referral__c, 
                 Partner__c, 
                 Charity__c, 
                 Platform__c, 
                 Consulting__c, 
                 SystemsIntegrator__c  
                 FROM LeadPartner__c 
                 Where Lead__c in :leadIdSet];
    }  
}