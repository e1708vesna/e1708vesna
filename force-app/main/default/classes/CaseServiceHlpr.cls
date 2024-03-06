/**
* @description Class to handle business functionality of service cloud cases.
* @author BRITE
*/
public inherited sharing class CaseServiceHlpr {
    
    /**
* @description Validate records that are merged with other cases. Only cases related to the same Account is allowed to be merged.
*              Runs before update of cases.
*/
    public static void validateMergeAction(List<Case> newCases, Map<Id, Case> caseOldMap) {
        Case oldCase;
        
        // for each record on which MasterRecordId is set, retrieve account ID of these master records
        Set<Id> masterRecordIdSet = new Set<Id> ();
        for (Case c : newCases) {
            if (c.MasterRecordId != null) {
                oldCase = caseOldMap.get(c.Id);
                if (oldCase.MasterRecordId == null) {
                    masterRecordIdSet.add(c.MasterRecordId);
                }
            }
        }
        if (!masterRecordIdSet.isEmpty()) {
            Map<Id, Case> masterRecordDetailMap = new Map<Id, Case> (
                [SELECT Id, AccountId FROM Case WHERE Id IN :masterRecordIdSet]
            );
            
            for (Case c : newCases) {
                if (c.MasterRecordId != null) {
                    oldCase = caseOldMap.get(c.Id);
                    if (oldCase.MasterRecordId == null) {
                        // only upon merge verify if account id is equal to the master record; not when something else has been changed
                        if (masterRecordDetailMap.containsKey(c.MasterRecordId) 
                            && c.AccountId != masterRecordDetailMap.get(c.MasterRecordId).AccountId) {
                                
                                c.addError(System.Label.CaseMergeDifferentAccountsNotAllowed);
                            }
                    }
                }
            }
        }
    }
    
    public static void routeUnclassifiedCases(List<Case> newCases, Map<Id, Case> caseOldMap) {
        List<Case> caseList = new List<Case>();
        for (Case c : newCases){
            if ('New'.equalsIgnoreCase(c.Status) &&
                c.Type != null && 
                c.SubType__c != null && 
                c.ServiceTopic__c != null && (
                    caseOldMap.get(c.Id).Type != c.Type ||
                    caseOldMap.get(c.Id).SubType__c != c.SubType__c ||
                    caseOldMap.get(c.Id).ServiceTopic__c != c.ServiceTopic__c)
               ){
                   caseList.add(c);
               }
        }
        if (caseList.size() > 0){
            assignOwner(caseList);
        }
    }
    
    /**
* @description Routes records to the right Queue based on the metadata mapping.
*              Runs before insert of cases.
*/
    public static void assignOwner(List<Case> caseList) {
        ServiceTeam__mdt serviceTeamOperationalSupport = ServiceTeam__mdt.getInstance('OperationalSupport');
        Set<String> caseTypeSet = new Set<String> ();
        Set<Id> accountIds = new Set<Id>();
        
        for(Case c : caseList) {
            if(c.Type != null && c.SubType__c != null && c.ServiceTopic__c != null) {
                caseTypeSet.add(c.Type); 
            }
            if (c.AccountId != null){
                accountIds.add(c.AccountId);
            }
        }
        Map<Id, Account> accountById = new Map<Id, Account>([SELECT Id, Owner.FirstName From Account WHERE Id in :accountIds]);
        List<CaseComplexity__mdt> caseComplexityMdtList = [SELECT 
                                                           Id, 
                                                           Type__c, 
                                                           SubType__c, 
                                                           ServiceTopic__c, 
                                                           Complexity__c,
                                                           Team__c, 
                                                           Team__r.Label,
                                                           Team__r.DeveloperName, 
                                                           Team__r.QueueDeveloperName__c,
                                                           Team__r.UnclassifiedQueueDeveloperName__c, 
                                                           Team__r.ZendeskEmail__c, 
                                                           Team__r.IsWorkingInZendesk__c,
                                                           Team__r.BusinessModelRouting__c,
                                                           Team__r.OmniFlowRouting__c,
                                                           Team__r.BaseSkill__c,
                                                           Team__r.RegionRouting__c
                                                           FROM CaseComplexity__mdt
                                                           WHERE Type__c IN :caseTypeSet];
        Map<String, CaseComplexity__mdt> complexityMap = new Map<String, CaseComplexity__mdt> ();
        Map<String, ServiceTeam__mdt> teamMap = new Map<String, ServiceTeam__mdt>();
        Set<String> queueNamesSet = new Set<String> ();
        for (CaseComplexity__mdt mdt : caseComplexityMdtList) {
            String key = mdt.Type__c + '__' + mdt.SubType__c + '__' + mdt.ServiceTopic__c;
            complexityMap.put(key.ToLowerCase(), mdt);
            teamMap.put(mdt.Team__r.DeveloperName, mdt.Team__r); 
            if (mdt.Team__r.QueueDeveloperName__c != null){
                queueNamesSet.add(mdt.Team__r.QueueDeveloperName__c);
            }
            if (mdt.Team__r.UnclassifiedQueueDeveloperName__c != null){
                queueNamesSet.add(mdt.Team__r.UnclassifiedQueueDeveloperName__c);
            }
        }
        List<Group> queueList = [SELECT Id, DeveloperName, Email FROM Group WHERE Type = 'Queue' AND DeveloperName IN :queueNamesSet];
        Map<String, Group> queueMap = new Map<String, Group> ();
        for(Group q : queueList){
            queueMap.put(q.DeveloperName, q);
        }
        String concat;
        ServiceTeam__mdt serviceTeam;
        for(Case c : caseList) {
            if (c.RouteToServiceTeamOnCreate__c == false) {
                c.RouteToServiceTeamOnCreate__c = true; //if a case gets splitted or cloned, this will still be defaulted to true.
                continue;
            } 
            if(c.ParentId == null){
                if(c.Type != null && c.SubType__c != null && c.ServiceTopic__c != null) {
                    concat = c.Type + '__' + c.SubType__c + '__' + c.ServiceTopic__c;
                    if(complexityMap.containsKey(concat.toLowerCase())) {
                        serviceTeam = complexityMap.get(concat.toLowerCase()).Team__r;
                        if (serviceTeam != null){                            
                            if ('AccountManagementPool'.equalsIgnoreCase(serviceTeam.DeveloperName) && serviceTeamOperationalSupport != null && (!'AM Pool'.equalsIgnoreCase(accountById.get(c.AccountId)?.Owner?.FirstName))){
                               	serviceTeam = serviceTeamOperationalSupport;
                            }
                            String queueName = getCorrectGroupFromTeam(serviceTeam, c);
                            if (queueMap.containsKey(queueName)) {
                                // if defined queue exists, set fields
                                c.UseBusinessModelForRouting__c = serviceTeam.BusinessModelRouting__c;
                                c.BusinessModelRouting__c = c.UseBusinessModelForRouting__c ? c.BusinessModel__c : null;
                                c.UseRegionForRouting__c = serviceTeam.RegionRouting__c;
                                c.RegionRouting__c = c.UseRegionForRouting__c ? c.CaseOriginRegion__c : null;
                                c.OmniBaseSkill__c = serviceTeam.BaseSkill__c;
                                c.OmniFlowRouting__c = serviceTeam.OmniFlowRouting__c;
                                c.OwnerId = queueMap.get(queueName).Id;
                                c.PreviousQueue__c = queueMap.get(queueName).DeveloperName;
                                c.PreviousQueueEmail__c = queueMap.get(queueName).Email;
                                c.PreviousQueueID__c= queueMap.get(queueName).Id;
                                
                            }
                        }
                    }
                    //else c.OwnerId = ''; //TBA: fall back queue
                }
            }
        }
    }
    /*
     * @name createFeedItemBeforeUpdate
     * @description If the Comments field is populated when the status changes, this will create a feeditem. This is because salesforce will not create it itself during a status update.
     * @param cases New cases in the trigger.
     * @param oldCaseMap map of the old cases by their Id.
     */
    public static void createFeedItemBeforeUpdate(List<Case> cases, Map<Id, Case> oldCaseMap) {
        List<FeedItem> feedItemList = new List<FeedItem>();
        for (Case c : cases) {
            if ( c.Status != oldCaseMap.get(c.Id).Status && String.IsNotBlank(c.Comments)) {
                feedItemList.add(new FeedItem(
                	Body = c.Comments,
                    ParentId = c.Id,
                    Visibility = 'InternalUsers'
                ));
                c.Comments = null;
            }
        }
        insert feedItemList;
    }
    
    @testVisible
    private static String getCorrectGroupFromTeam(ServiceTeam__mdt team, Case c){
        if (team.IsWorkingInZendesk__c){
            c.addError(String.format(System.Label.CaseRoutingZendeskTeam, new List<String>{team.Label}));
            return null;
        }
        if (team.UnclassifiedQueueDeveloperName__c != null && ( c.Type == null || c.SubType__c == null) || c.ServiceTopic__c == null ){
            return team.UnclassifiedQueueDeveloperName__c;
        }
        else {
            return team.QueueDeveloperName__c;
        }
    }
}