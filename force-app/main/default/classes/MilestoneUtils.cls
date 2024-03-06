public class MilestoneUtils {
    public static void completeMilestone(List<Id> caseIds, String milestoneName, DateTime complDate) {  
        completeMilestone(caseIds, new List<String>{milestoneName}, complDate);
    }
    
    public static void completeMilestone(List<Id> caseIds, List<String> milestoneNames, DateTime complDate) {  
        List<CaseMilestone> cmsToUpdate;
        if (milestoneNames == null || milestoneNames.size() == 0){
            cmsToUpdate = [select Id, completionDate
                           from CaseMilestone cm
                           where caseId in :caseIds 
                           and completionDate = null];
        }
        else {
            cmsToUpdate = [select Id, completionDate
                           from CaseMilestone cm
                           where caseId in :caseIds and cm.MilestoneType.Name=:milestoneNames 
                           and completionDate = null];
        }
        if (cmsToUpdate != null && cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            update cmsToUpdate;
        }
    }
}