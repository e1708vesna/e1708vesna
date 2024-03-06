/**
 * @description   : ExportFactor DAO class for retrieving additionl msrp data for the license jar
 * @author (s)    : Brite
 */
public class ExportFactorDao {

    /**
     * @description Get ExportFactors by Name
     */
    public static List<ExportFactor__c> getByName(Set<String> artNoSet) {
        return [SELECT Id, Name, Description__c, ExportCode__c, ExportFactor__c
                FROM ExportFactor__c
                WHERE Name IN :artNoSet];
    }

    /**
     * @description Get ExportFactors by Name
     */
    public static List<ExportFactor__c> getAll() {
        return [SELECT Id, Name, Description__c, ExportCode__c, ExportFactor__c
                FROM ExportFactor__c ORDER BY ExportFactor__c DESC LIMIT 1000];
    }
}