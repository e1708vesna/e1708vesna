/**
 * @description Partner__c DAO class for retrieving lead data from the database.
 * @author BRITE
 */
public class PartnerDao {

    /**
     * @description Return opportunity Partner Details
     *
     * @param opportunityIdSet Set of opportunity ID's for which opportunities must be returned
     */
    public static List<Partner__c> getDetailsByOpportunity(Set<Id> opportunityIdSet) {
        if (opportunityIdSet == null || opportunityIdSet.isEmpty()) {
            return new List<Partner__c> ();
        }
        
        return [Select Id, 
                                                
                Account__c, Partner__c, 
                                                Opportunity__c,
                                                IsAdyenForPlatforms__c, 
                                                IsPaymentOrchestration__c,
                                                IsPlatform__c, 
                                                IsConsulting__c, 
                                                IsReferral__c, 
                                                IsSystemsIntegrator__c, 
                                                IsCharity__c 
                                                FROM Partner__c 
                                                WHERE Opportunity__c in :opportunityIdSet];
    }  
    
    
    /**
     * @description Return Account Partner Details
     *
     * @param accountIdSet Set of Account ID's for which opportunities must be returned
     */
    public static List<Partner__c> getDetailsByAccount(Set<Id> accountIdSet) {
        if (accountIdSet == null || accountIdSet.isEmpty()) {
            return new List<Partner__c> ();
        }
        
        return [Select Id, 
                Account__c,                                
                Partner__c, 
                                                Opportunity__c,
                                                IsAdyenForPlatforms__c, 
                                                IsPaymentOrchestration__c,
                                                IsPlatform__c, 
                                                IsConsulting__c, 
                                                IsReferral__c, 
                                                IsSystemsIntegrator__c, 
                                                IsCharity__c 
                                                FROM Partner__c 
                                                WHERE Account__c in :accountIdSet];
    }  
}