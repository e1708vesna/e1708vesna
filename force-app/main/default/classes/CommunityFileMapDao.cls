/**
 * @description   : CommunityFileMap DAO class for retrieving CommunityFileMap data from the database.
 * @author (s)    : BRITE
 */
public class CommunityFileMapDao {
    /**
     * Get Id CommunityFileMap by Developername__c
     * @param developerName String of the unique DeveloperName__c of the CommunityFileMap__c object
     * @return Id
     **/
     public static Id getIdByDeveloperName (String developerName) {
     	return [SELECT Id FROM CommunityFileMap__c WHERE DeveloperName__c = :developerName].Id;
     }
     
}