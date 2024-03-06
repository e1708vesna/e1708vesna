global class MyTrailheadScheduledAssignmentBatch implements Schedulable, Database.Batchable<sObject>{
    
    global void execute(SchedulableContext sc) {
      database.executebatch(new MyTrailheadScheduledAssignmentBatch());
   }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, AssignAfterNDays__c, Badge__c, DueInNDays__c, Profile__c FROM UserBadgeScheduledAssignment__c]);  
    }
    
    global void execute(Database.BatchableContext BC, List<UserBadgeScheduledAssignment__c> scope){
        Map<Date, List<UserBadgeScheduledAssignment__c>> scheduledBadgesByDate = new Map<Date, List<UserBadgeScheduledAssignment__c>>();
        List<trailheadapp__User_Badge__c> insertList = new List<trailheadapp__User_Badge__c>();
        for (UserBadgeScheduledAssignment__c usa : scope){
            Date tDate = system.today().addDays((Integer)usa.AssignAfterNDays__c * -1);
            if (!scheduledBadgesByDate.containsKey(tDate)){
                scheduledBadgesByDate.put(tDate, new List<UserBadgeScheduledAssignment__c>());
            }
            scheduledBadgesByDate.get(tDate).add(usa);
        }
        System.debug(Json.serializePretty(scheduledBadgesByDate));
        List<sObject> psaList = [SELECT AssigneeId, Assignee.Profile.Name profileName, DAY_ONLY(SystemModStamp) assignedDate FROM PermissionSetAssignment WHERE IsActive = true AND DAY_ONLY(SystemModStamp) =:scheduledBadgesByDate.keySet() AND PermissionSetId =: Label.MyTrailheadEndUserId GROUP BY AssigneeId, Assignee.Profile.Name, DAY_ONLY(SystemModStamp)];
        for (sObject psa : psaList){
            for (UserBadgeScheduledAssignment__c usa : scheduledBadgesByDate.get((Date) psa.get('assignedDate'))){
                String profileName = (String) psa.get('profileName');
                if (String.isBlank(usa.Profile__c) || usa.Profile__c == profileName){
                    insertList.add( new trailheadapp__User_Badge__c(trailheadapp__Assigned_Date__c = Date.Today(),
                                                                    trailheadapp__Badge__c = usa.Badge__c,
                                                                    trailheadapp__Due_Date__c = usa.DueInNDays__c == null ? null : Date.Today().addDays((Integer) usa.DueInNDays__c),
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