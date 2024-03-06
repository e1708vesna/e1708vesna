/**
 * @description   : UpgradeAssuranceContractItem DAO class for retrieving UpgradeAssuranceContractItem__c data from the database.
 * @author (s)    : Brite
 */
public class UpgradeAssuranceContractItemDao {

    /**
     * @description Get all upgrade assurance contract items for the given upgrade assurance contracts.
     *
     * @param uaContractIdSet Set of Upgrade Assurance Contract id's for which the contract items must be retrieved
     */
    public static List<UpgradeAssuranceContractItem__c> getContractItems(Set<Id> uaContractIdSet) {
        return [SELECT Id, UpgradeAssuranceContract__c, UnitPrice__c, SQLTimeStamp__c, PriceDate__c, LicenseItem__c,
                    ArticleNumber__c, Currency__c, Quantity__c, AdjustedQuantity__c, AdjustedUnitPrice__c, AdjustmentReason__c,
                    AdjustedTotalPriceFormula__c, TotalPrice__c
                FROM UpgradeAssuranceContractItem__c
                WHERE UpgradeAssuranceContract__c IN :uaContractIdSet];
    }
    
    /**
     * @description Get all upgrade assurance contract items for the given upgrade assurance contracts.
     *          Exclude Active Contracts
     * @param licItemIdSet Set of License Item id's for which the contract items must be retrieved
     */
    public static List<UpgradeAssuranceContractItem__c> getByLicenseItems(Set<Id> licItemIdSet) {
        Set<Id> recordTypeSet = new Set<Id>();
        recordTypeSet.add(RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType()));
        recordTypeSet.add(RecordTypeUtil.getRecordTypeIdByDevName('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType()));
        return [SELECT Id, Name, UpgradeAssuranceContract__c, UpgradeAssuranceContract__r.RecordTypeId, UnitPrice__c, SQLTimeStamp__c, PriceDate__c,
                    LicenseItem__c, ArticleNumber__c, Currency__c, InitialQuantity__c, ItemDescription__c,
                    LineNumber__c, NavisionExternalId__c, Quantity__c, UpgradeAssuranceContractTypeVersion__c, VersionCode__c
                FROM UpgradeAssuranceContractItem__c
                WHERE LicenseItem__c IN :licItemIdSet AND UpgradeAssuranceContract__r.RecordTypeId IN :recordTypeSet];
    }
    
    /**
     * @description Delete all UpgradeAssuranceContractItem records that are related to the given LicenseItem records
     *          Exclude Active Contracts
     * @param licenseItemIdSet Set of LicenseItem__c records
     */
    public static void deleteByLicenseItems(Set<Id> licenseItemIdSet) {
        Set<Id> recordTypeSet = new Set<Id>();
        recordTypeSet.add(RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType()));
        recordTypeSet.add(RecordTypeUtil.getRecordTypeIdByDevName('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType()));
        delete [SELECT Id, UpgradeAssuranceContract__r.RecordTypeId
                FROM UpgradeAssuranceContractItem__c 
                WHERE LicenseItem__c IN :licenseItemIdSet AND UpgradeAssuranceContract__r.RecordTypeId IN :recordTypeSet];
    }
    
}