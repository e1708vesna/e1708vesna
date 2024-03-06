/**
 * @description   : PackageQuantity DAO class for retrieving additional msrp data for the license jar
 * @author (s)    : Brite
 */
public class PackageQuantityDao {

    /**
     * @description Get PackageQuantity by Name
     */
    public static List<PackageQuantity__c> getByName(Set<String> artNoSet) {
        return [SELECT Id, Name, SetQuantity__c
                FROM PackageQuantity__c
                WHERE Name IN :artNoSet];
    }

    /**
     * @description Get All PackageQuantity
     */
    public static List<PackageQuantity__c> getAll() {
        return [SELECT Id, Name, SetQuantity__c
                FROM PackageQuantity__c LIMIT 10000];
    }
}