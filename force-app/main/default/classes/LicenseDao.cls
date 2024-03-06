/**
 * @description   : License__c DAO class for retrieving License__c and nested LicenseItem__c data from the database.
 * @author (s)    : Brite
 */
public class LicenseDao {
    /**
     * Get all License__c with linked LicenseItem__c  records
     */
     public static List<License__c> getById(Set<Id> LicenseIdSet) {
     	return [Select l.Version__c, l.VersionDescription__c, l.ValidityPeriodDays__c, l.ValidityDateStart__c, 
     			l.ValidityDateEnd__c, l.UpgradeAssuranceContract__c, l.SystemkeyProvider__c, l.Status__c, 
     			l.SQLTimeStamp__c, l.RenewalPeriod__c,  
     			l.NumberOfTemporaryLicenses__c, l.NavisionExternalId__c, l.Name, l.LicenseeName__c, 
     			l.LicenseValue__c, l.LicenseType__c, l.LicenseTypeVersion__c, l.LicenseTypeCode__c, 
     			l.KeyType__c, l.Imported__c, l.Id, l.ExportDateTime__c, 
     			l.EndCustomer__r.Type, l.EndCustomer__r.Name, l.EndCustomer__c, 
     			l.DateCreationKey__c, l.Currency__c, l.Additional_Information__c, 
     			l.ChannelPartner__r.Type, l.ChannelPartner__r.Name,	l.ChannelPartner__c,
     			l.ExtraInfo__c, l.ExtraLicenseKey__c, l.IpAddress1__c, 
     			 
     			(Select Id, Name, License__c, Quantity__c, InitialQuantity__c, VersionCode__c, LicenseTypeVersion__c, Item__c,
     			UnitPrice__c, PriceDate__c, Currency__c, LineNumber__c, TotalPrice__c, NavisionExternalId__c, ItemDescription__c, 
     			ArticleNumber__c, ArtNo__c, SQLTimeStamp__c From LicenseItems__r) 
     			
     			From License__c l where Id in :LicenseIdSet];
     }
     
     /**
      * @description Get all license items that belongs to the given licenses
      *
      * @param licenseIdSet Set of license IDs
      */
     public static List<LicenseItem__c> getLicenseItems(Set<Id> licenseIdSet) {
         return [SELECT Id, License__c, ArticleNumber__c, ArtNo__c, Currency__c, InitialQuantity__c, ItemDescription__c, Name,
                        LicenseTypeVersion__c, LineNumber__c, NavisionExternalId__c, PriceDate__c,
                        Quantity__c, SQLTimeStamp__c, TotalPrice__c, UnitPrice__c, VersionCode__c
                 FROM LicenseItem__c
                 WHERE License__c IN :licenseIdSet];
                 
     }

     /**
     * @description Get all Licenses with its end customer accounts of which channel parter is one of 
     *              the accounts mentioned in set channelPartnerIdSet
     */
     public static List<License__c> getByChannelPartner(Set<Id> channelPartnerIdSet) {
     	return [SELECT Id, EndCustomer__c, ChannelPartner__c 
                FROM License__c 
                WHERE ChannelPartner__c in: channelPartnerIdSet];
     }

     /**
     * @description Get all Licenses with its channel partners of which end customer account is one of 
     *              the accounts mentioned in set endCustomerIdSet
     */
    public static List<License__c> getByEndCustomer(Set<Id> endCustomerIdSet) {
        return [SELECT Id, EndCustomer__c, ChannelPartner__c 
               FROM License__c 
               WHERE EndCustomer__c IN :endCustomerIdSet];
    }

    /**
      * @description Get all Licenses by id set
      *              
      * @param idSet Set of license IDs
      */
     public static List<License__c> getLicenseById(Set<Id> idSet) {
     	return [SELECT Id, Currency__c 
                FROM License__c 
                WHERE Id in: idSet];
     }

     /**
      * @description Get licenses by id with upgrade assurance contract details.
      *
      * @param idSet Set of license IDs
      */
     public static List<License__c> getByIdWithUACDetails(Set<Id> idSet) {
         return [SELECT Id, TotalUACValue__c, NumberUACs__c, NumberActiveUACs__c, NumberOpenUACs__c, LastActivatedUAC__c, 
                    (SELECT Id, Active__c, CombinedBillingAmount__c, StartDate__c, StartDateLine__c, EndDate__c, Stage__c, RecordType.DeveloperName
                     FROM UpgradeAssurances__r 
                     ORDER BY StartDateLine__c DESC)
                 FROM License__c
                 WHERE Id IN :idSet];
     }

}