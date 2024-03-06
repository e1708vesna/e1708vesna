global class MyTrailheadScheduledTrailmixBatch implements Schedulable, Database.Batchable<sObject>{
    
    global void execute(SchedulableContext sc) {
      database.executebatch(new MyTrailheadScheduledTrailmixBatch());
   }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, AssignAfterNDays__c, Trailmix__c, DueInNDays__c, Profile__c FROM TrailmixScheduledAssignment__c]);  
    }
    
    global void execute(Database.BatchableContext BC, List<TrailmixScheduledAssignment__c> scope){
        Map<Date, List<TrailmixScheduledAssignment__c>> scheduledBadgesByDate = new Map<Date, List<TrailmixScheduledAssignment__c>>();
        List<trailheadapp__Trailmix_Assignment__c> insertList = new List<trailheadapp__Trailmix_Assignment__c>();
        for (TrailmixScheduledAssignment__c usa : scope){
            Date tDate = system.today().addDays((Integer)usa.AssignAfterNDays__c * -1);
            if (!scheduledBadgesByDate.containsKey(tDate)){
                scheduledBadgesByDate.put(tDate, new List<TrailmixScheduledAssignment__c>());
            }
            scheduledBadgesByDate.get(tDate).add(usa);
        }
        System.debug(Json.serializePretty(scheduledBadgesByDate));
        List<sObject> psaList = [SELECT AssigneeId, Assignee.Profile.Name profileName, DAY_ONLY(SystemModStamp) assignedDate FROM PermissionSetAssignment WHERE IsActive = true AND DAY_ONLY(SystemModStamp) =:scheduledBadgesByDate.keySet() AND PermissionSetId =: Label.MyTrailheadEndUserId GROUP BY AssigneeId, Assignee.Profile.Name, DAY_ONLY(SystemModStamp)];
        for (sObject psa : psaList){
            for (TrailmixScheduledAssignment__c usa : scheduledBadgesByDate.get((Date) psa.get('assignedDate'))){
                String profileName = (String) psa.get('profileName');
                if (String.isBlank(usa.Profile__c) || usa.Profile__c == profileName){
                    insertList.add( new trailheadapp__Trailmix_Assignment__c(//trailheadapp__Assigned_Date__c = Date.Today(),
                                                                    trailheadapp__Trailmix__c = usa.Trailmix__c,
                                                                    trailheadapp__Due_At__c = usa.DueInNDays__c == null ? null : Date.Today().addDays((Integer) usa.DueInNDays__c),
                                                                    trailheadapp__User__c = (ID) psa.get('AssigneeId')
                                                                   ));
                }
            }
        }
        Database.insert(insertList, false);
    }
    
    global void finish(Database.BatchableContext BC){
    }
}