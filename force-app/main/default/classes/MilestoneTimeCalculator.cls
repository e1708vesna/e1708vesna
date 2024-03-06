//Placeholder
global class MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {  

    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Case c = [SELECT Priority FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
        if (c.Priority != null && c.Priority.equals('High')){
              if (mt.Name != null && mt.Name.equals('m1')) { return 7;}
              else { return 5; }
        }
        else {
            return 18;
        }                
     }
}