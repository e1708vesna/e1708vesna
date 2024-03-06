/**
 * @description   : UpgradeAssuranceContract DAO class for retrieving UpgradeAssuranceContract__c data from the database.
 * @author (s)    : Brite
 */
public class UpgradeAssuranceContractDao {

    /**
     * @description Get all (not Activated!) upgrade assurance contract records.
     *
     * @param licenseIdSet Set of License id's for which related upgrade assurance contracts must be retrieved
     */
    public static List<UpgradeAssuranceContract__c> getByLicenseId(Set<Id> licenseIdSet) {
        Set<Id> recordTypeSet = new Set<Id>();
        recordTypeSet.add(RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType()));
        recordTypeSet.add(RecordTypeUtil.getRecordTypeIdByDevName('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType()));
        return [SELECT Id, StartDateLine__c, License__c, recordTypeId
                FROM UpgradeAssuranceContract__c
                WHERE License__c IN :licenseIdSet AND recordTypeId in :recordTypeSet];
    }

    /**
     * @description Get all upgrade assurance contract records.
     *
     * @param licenseIdSet Set of License id's for which related upgrade assurance contracts must be retrieved
     */
    public static List<UpgradeAssuranceContract__c> getById(Set<Id> idSet) {
        return [SELECT u.YourReference__c, u.YourOrder__c, u.Version__c, u.UpgradeAssuranceValue__c, u.Status__c, 
        		u.StartDate__c, u.StartDateLine__c, u.Stage__c, u.SignedDate__c, u.SignedBy__c, u.RecordTypeId, 
        		u.PercentageDiscountDate__c, u.PartnerDiscountPercentage__c, u.OutstandingLineAmount__c, 
        		u.NavisionUaNumber__c, u.Name, u.LineAmount__c, u.LicenseeName__c, u.License__r.Name, 
        		u.License__c, u.IsDeleted, u.Id, u.Handler__c, u.FlatFeeUa__c, 
        		u.Exception__c, u.EndDate__c, u.EndDateLine__c, u.EndCustomer__r.CustomerCode__c, u.EndCustomer__c, 
        		u.Email__c, u.DocumentType__c, u.Currency__c, u.ContractDuration__c,
				u.ChannelPartner__c, u.ChannelPartner__r.Name, u.CalculationPercentage__c, u.CalculationMethod__c, 
                u.Billing__c, u.BillingValueUa__c, u.Approved__c,
				u.AdditionalConditions__c, u.AdditionalConditionsReason__c, u.Active__c, u.AcceptTermsAndConditions__c,
                u.RequestUnlock__c, u.Lock__c, Declined__c  
        		FROM UpgradeAssuranceContract__c u
                WHERE Id IN :idSet];
    }
    
    /**
     * @description Get the latest date of activated upgrade assurance contract records.
     *
     * @param licenseIdSet Set of License id's for which related upgrade assurance contracts must be retrieved
     */
    public static List<AggregateResult> getLatestActivatedByLicenseId(Set<Id> licenseIdSet) {
        Set<Id> recordTypeSet = new Set<Id>();
        //recordTypeSet.add(RecordTypeUtil.getRecordTypeIdByDevName('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType()));
        
        return [SELECT MAX(EndDateLine__c) maxEndDate, License__c 
                FROM UpgradeAssuranceContract__c
                WHERE License__c IN :licenseIdSet AND Stage__c = 'Order' GROUP BY License__c];
    }
}