public class Regions {

    public static Map<String, Regions__c> getRegionAssignments(Set<String> countries) {
        List<Regions__c>           regionAssignments        = new List<Regions__c>();
        Map<String, Regions__c>    regionAssignmentsMap     = new Map<String, Regions__c>();
        regionAssignments                                          = [
            SELECT Id, Region__c, Queue__c, Sales_Office__c, Country__c, State__c, Country_Code__c
            FROM Regions__c
            WHERE Country_Code__c IN :countries
        ];
        
        for (Regions__c regionAssignment : regionAssignments) {
            regionAssignmentsMap.put(regionAssignment.Country_Code__c + ' ' + regionAssignment.State__c, regionAssignment);
        }

        return regionAssignmentsMap;
    }

}