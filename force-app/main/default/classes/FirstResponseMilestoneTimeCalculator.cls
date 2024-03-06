global class FirstResponseMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        //This is NOT bulkified!
        Case c = [SELECT Priority, Account.ServiceLevel__c FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
        try {
            if ('VIP'.equals(c.Account.ServiceLevel__c)){
                switch on c.Priority {
                    when 'Urgent' {		// when block 1
                        return 1;
                    }	
                    when 'High' {		// when block 2
                        return 180;
                    }
                    when 'Medium' {		// when block 3
                        return 360;
                    }
                    when else {		  // default block, optional
                        return 1080;
                    }
                }
            }
            else {
                switch on c.Priority {
                    when 'Urgent' {		// when block 1
                        return 30;
                    }	
                    when 'High' {		// when block 2
                        return 240;
                    }
                    when 'Medium' {		// when block 3
                        return 480;
                    }
                    when else {		  // default block, optional
                        return 1440;
                    }
                }
            }   
        }
        catch (Exception e){
            
        }
        return 1440;
    }
}