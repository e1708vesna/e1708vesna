/**
 * @author (s)    : Brite
 * @description   :
 */

public without sharing class ClaimMemberHelper {
	private static Set<Id> newOldClaimMembers = new Set<Id>();
    
    private static boolean isClaimMemberNew(Id cmId){
        if (newOldClaimMembers.contains(cmId)){
            newOldClaimMembers.remove(cmId);
            return true;
        }
        else {
            return false;
        }
    }
    
    public static void addClaimMemberNew(Id cmId){
        newOldClaimMembers.add(cmId);
    }
    
    public static void updateClaimMemberOpportunity(List<OpportunityTeamMember> oppTMList){
        if (oppTMList == null || oppTMList.isEmpty()) {
            return;
        }
        List<ClaimMembers__c> cmListToUpdate = new List<ClaimMembers__c>();
        Map<Id, Set<Id>> userIdsByOpportunityId = new Map<Id, Set<Id>>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (OpportunityTeamMember tm : oppTMList){ //add teammember to userIdByOpportunityId map
            if (!userIdsByOpportunityId.containsKey(tm.OpportunityId)){
                userIdsByOpportunityId.put(tm.OpportunityId, new Set<Id>());
            }
            userIdsByOpportunityId.get(tm.OpportunityId).add(tm.UserId);
            userIds.add(tm.UserId);
        }
        List<ClaimMembers__c> cmListToProcess = new List<ClaimMembers__c>();
        //Query all related claimmembers related to the opportunity Team Member users (OF that opportunity) Where status = no claim started
        for (ClaimMembers__c cm : [SELECT ID, Account__c, Opportunity__c, User__c, EligibleForClaim__c FROM ClaimMembers__c WHERE User__c in: userIds AND Opportunity__c in: userIdsByOpportunityId.keySet() AND Status__c = 'No claim started' AND RecordType.DeveloperName = 'Regular']){
            if (userIdsByOpportunityId.get(cm.Opportunity__c).contains(cm.User__c)){
                cmListToProcess.add(cm);
                accountIds.add(cm.Account__c);
            }
        }
        
        Map<String, Id> opportunityTeamMemberBykey = new Map<String, Id>(); //Account + userId
        for (OpportunityTeamMember tm : [SELECT Id, OpportunityId, Opportunity.AccountId, UserId FROM OpportunityTeamMember WHERE Opportunity.StageName != 'Closed Lost' AND Opportunity.AccountId in: accountIds AND UserId in: userIds AND Id NOT IN: oppTMList ORDER BY CreatedDate DESC]){
            String key = '' + tm.Opportunity.AccountId + tm.UserId;
            if (!opportunityTeamMemberBykey.containsKey(key)){
                opportunityTeamMemberBykey.put(key, tm.OpportunityId);
            }
        }
        for (ClaimMembers__c cm : cmListToProcess){
            String key = '' + cm.Account__c + cm.User__c;
            if (opportunityTeamMemberBykey.containsKey(key)){
                cm.Opportunity__c = opportunityTeamMemberBykey.get(key);
                cmListToUpdate.add(cm);
            }
            else if (cm.EligibleForClaim__c) {
                cm.EligibleForClaim__c = false;
                cmListToUpdate.add(cm);
            }
        }
        update cmListToUpdate;
        
        Map<Id, List<ClaimMembers__c>> eligibleMembersByAccounts = fetchEligibleMembersByAccounts(getAccountIds(cmListToUpdate));
        updatePercentages(eligibleMembersByAccounts);
        List<ClaimMembers__c> updated = new List<ClaimMembers__c>();
        for (Id accountId : eligibleMembersByAccounts.keySet()) {
            updated.addAll(eligibleMembersByAccounts.get(accountId));
        }
        update updated;

    }
    
    public static void updateClaimMemberOpportunity(Set<Id> oppTmIds){
        if (oppTmIds == null || oppTmIds.isEmpty()) {
            return;
        }
        List<OpportunityTeamMember> oppTMList = [Select Id, OpportunityId, UserId FROM OpportunityTeamMember WHERE Id in: oppTmIds];
        List<ClaimMembers__c> cmListToUpdate = new List<ClaimMembers__c>();
        Map<Id, Set<Id>> userIdsByOpportunityId = new Map<Id, Set<Id>>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (OpportunityTeamMember tm : oppTMList){ //add teammember to userIdByOpportunityId map
            if (!userIdsByOpportunityId.containsKey(tm.OpportunityId)){
                userIdsByOpportunityId.put(tm.OpportunityId, new Set<Id>());
            }
            userIdsByOpportunityId.get(tm.OpportunityId).add(tm.UserId);
            userIds.add(tm.UserId);
        }
        List<ClaimMembers__c> cmListToProcess = new List<ClaimMembers__c>();
        //Query all related claimmembers related to the opportunity Team Member users (OF that opportunity) Where status = no claim started
        for (ClaimMembers__c cm : [SELECT ID, Account__c, Opportunity__c, User__c, EligibleForClaim__c FROM ClaimMembers__c WHERE User__c in: userIds AND Opportunity__c in: userIdsByOpportunityId.keySet() AND Status__c = 'No claim started' AND RecordType.DeveloperName = 'Regular']){
            if (userIdsByOpportunityId.get(cm.Opportunity__c).contains(cm.User__c)){
                cmListToProcess.add(cm);
                accountIds.add(cm.Account__c);
            }
        }
        
        Map<String, Id> opportunityTeamMemberBykey = new Map<String, Id>(); //Account + userId
        for (OpportunityTeamMember tm : [SELECT Id, OpportunityId, Opportunity.AccountId, UserId FROM OpportunityTeamMember WHERE Opportunity.StageName != 'Closed Lost' AND Opportunity.AccountId in: accountIds AND UserId in: userIds AND Id NOT IN: oppTmIds ORDER BY CreatedDate DESC]){
            String key = '' + tm.Opportunity.AccountId + tm.UserId;
            if (!opportunityTeamMemberBykey.containsKey(key)){
                opportunityTeamMemberBykey.put(key, tm.OpportunityId);
            }
        }
        for (ClaimMembers__c cm : cmListToProcess){
            String key = '' + cm.Account__c + cm.User__c;
            if (opportunityTeamMemberBykey.containsKey(key)){
                cm.Opportunity__c = opportunityTeamMemberBykey.get(key);
                cmListToUpdate.add(cm);
            }
            else if (cm.EligibleForClaim__c) {
                cm.EligibleForClaim__c = false;
                cmListToUpdate.add(cm);
            }
        }
        update cmListToUpdate;
        
        Map<Id, List<ClaimMembers__c>> eligibleMembersByAccounts = fetchEligibleMembersByAccounts(getAccountIds(cmListToUpdate));
        updatePercentages(eligibleMembersByAccounts);
        List<ClaimMembers__c> updated = new List<ClaimMembers__c>();
        for (Id accountId : eligibleMembersByAccounts.keySet()) {
            updated.addAll(eligibleMembersByAccounts.get(accountId));
        }
        update updated;

    }
    
    /**
     * Convert each OpportunityTeamMember, with TeamMemberRole 'Opportunity Owner' or 'Sales Manager', to a ClaimMember.
     * But only if no ClaimMember exist yet for its User
     *
     * @param oppTeamMembers
     */
    public static void copyTeamMembersToClaimMembers(List<OpportunityTeamMember> oppTeamMembers) {
        if (oppTeamMembers == null || oppTeamMembers.isEmpty()) {
            return;
        }

        new OpportunityTeamMemberConverter(oppTeamMembers).copyTeamMembersToClaimMembers();
    }
    
    
    public static void handleBeforeInsertTrigger(ClaimMembers__c[] newClaimMembers){
        Set<Id> userSet = new Set<Id>();
        for (ClaimMembers__c claimMember : newClaimMembers){
            userSet.add(claimMember.User__c);
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, IsIndustryExpert__c From User WHERE Id in: userSet AND IsIndustryExpert__c = True]);
        for (ClaimMembers__c claimMember : newClaimMembers){
            if (userMap.containsKey(claimMember.User__c)){
                claimMember.IsIndustryExpert__c = true;
            }
        }        
    }
    
    public static void handleBeforeTrigger(ClaimMembers__c[] newClaimMembers, Map<Id, ClaimMembers__c> oldClaimMembers) {

        if (newClaimMembers == null || newClaimMembers.isEmpty()) {
            return;
        }
        if (oldClaimMembers == null) {
            oldClaimMembers = new Map<Id, ClaimMembers__c>();
            
        }
        Map<Id, List<ClaimMembers__c>> eligibleMembersByAccounts = fetchEligibleMembersByAccounts(getAccountIds(newClaimMembers));
        updateEligibleForClaim(newClaimMembers, oldClaimMembers, eligibleMembersByAccounts);
        
        updatePercentages(eligibleMembersByAccounts);


        // build a List of Eligible ClaimMembers whose Percentages have been updated
        List<ClaimMembers__c> updated = new List<ClaimMembers__c>();
        for (Id accountId : eligibleMembersByAccounts.keySet()) {
            for (ClaimMembers__c eligibleMember : eligibleMembersByAccounts.get(accountId)) {
                // only add the ClaimMember to the list, if it has an Id and it's not in the given list of Trigger.new ClaimMembers
                if (eligibleMember.Id != null && (oldClaimMembers == null || !oldClaimMembers.containsKey(eligibleMember.Id))) {
                    updated.add(eligibleMember);
                }

            }
        }

        // update the Percentages of the Eligible ClaimMembers, but prevent the ClaimMembers Trigger from running
        TriggerStopper.stopClaimMembersTrigger = true;
        update updated;
        TriggerStopper.stopClaimMembersTrigger = false;
    }

    public static void handleAfterDelete(ClaimMembers__c[] oldClaimMembers)
    {
        if (oldClaimMembers == null || oldClaimMembers.isEmpty()) {
            return;
        }

        Map<Id, List<ClaimMembers__c>> eligibleMembersByAccounts = fetchEligibleMembersByAccounts(getAccountIds(oldClaimMembers));
        updatePercentages(eligibleMembersByAccounts);

        List<ClaimMembers__c> updated = new List<ClaimMembers__c>();
        for (Id accountId : eligibleMembersByAccounts.keySet()) {
            updated.addAll(eligibleMembersByAccounts.get(accountId));
        }

        update updated;
    }
    
    //Only returns accounts in eligibleMembersByAccounts of which the percentages should be updated
    private static void updateEligibleForClaim(ClaimMembers__c[] newClaimMembers, Map<Id, ClaimMembers__c> oldClaimMembers, Map<Id, List<ClaimMembers__c>> eligibleMembersByAccounts)
    {
        Map<Id, List<Claim__c>> regularClaimsByAccounts = fetchRegularClaimsByAccounts(eligibleMembersByAccounts.keySet());
        Set<Id> accountsToRecalculate = new Set<Id>();
        for (ClaimMembers__c claimMember : newClaimMembers) {
            if (claimMember.RecordTypeId == Constants.RT_ID_CLAIMMEMBER_REGULAR){
                if (!eligibleMembersByAccounts.containsKey(claimMember.Account__c)) {
                    eligibleMembersByAccounts.put(claimMember.Account__c, new List<ClaimMembers__c>());
                }
                List<ClaimMembers__c> eligibleMembers = eligibleMembersByAccounts.get(claimMember.Account__c);
                List<Claim__c> regularClaims          = regularClaimsByAccounts.get(claimMember.Account__c);
                
                ClaimMembers__c oldClaimMember = (oldClaimMembers != null) ? oldClaimMembers.get(claimMember.Id) : null;
                Boolean isNew                  = (oldClaimMember == null);
                Boolean isNewOld               = isClaimMemberNew(claimMember.Id);
                Boolean isChanged              = (oldClaimMember != null && oldClaimMember.EligibleForClaim__c != claimMember.EligibleForClaim__c);
                Boolean isChangedIndustryExpert =  (oldClaimMember != null && oldClaimMember.IsIndustryExpert__c != claimMember.IsIndustryExpert__c);
                
                
                // set EligibleForClaim to TRUE if
                // - the ClaimMember is newly created;
                // 		- OR it exists in the newOldClaimMembersSet
                // - the current amount of Eligible ClaimMembers for the Account is still less than 4;
                //      -OR the Claim member is an expert, and there is no expert claimmember yet.
                // - and the Account doesn't have any Claims of type 'Regular'
                // - and claimMember has recordtype 'Regular'
                boolean eligibilityChangedInCode = false;
                if (!claimMember.EligibleForClaim__c && 
                    (isNew || isNewOld) 
                    && eligibleMembers.size() < 4 
                    && (regularClaims == null || regularClaims.isEmpty()) 
                    && claimMember.RecordTypeId == Constants.RT_ID_CLAIMMEMBER_REGULAR) {
                        
                    claimMember.EligibleForClaim__c = true;
                    eligibilityChangedInCode = true;
                    accountsToRecalculate.add(claimMember.Account__c);
                }
                //Only recalculate accounts where there is a change in EligibleForClaim__c or Industry expert
                if ((!isNew && isChanged) || (!isNew && isChangedIndustryExpert) || ((isNew ) && claimMember.EligibleForClaim__c)){
                    accountsToRecalculate.add(claimMember.Account__c);
                }
                // check if EligibleForClaim is set to TRUE, either due to it being new or because it was manually set to TRUE by a user
                
                
                if (claimMember.EligibleForClaim__c){
                    if (isNew || isChanged || (isNewOld && eligibilityChangedInCode)) {
                        if (eligibleMembers.size() >= 4 ) {
                            // add an error message if the current amount of Eligible ClaimMembers for the Account is already at 4 or more
                            claimMember.EligibleForClaim__c = false;
                            claimMember.addError('One Account can have only 4 Eligible ClaimMembers at most');
                        }
                        eligibleMembers.add(claimMember);
                    }
                    if (isChangedIndustryExpert){
                        if (claimMember.Id != null) {
                            // use a loop instead of 'indexOf', as eligibleMembers is a List from an SOQL, while newClaimMembers is a List from a Trigger
                            for (Integer i = 0; i < eligibleMembers.size(); i++) {
                                if (claimMember.Id == eligibleMembers.get(i).Id) {
                                    eligibleMembers.remove(i); break;
                                }
                            }
                        }
                        eligibleMembers.add(claimMember);
                    }
                }
                
                if (!claimMember.EligibleForClaim__c) {
                    claimMember.Percentage__c = null;
                    
                    // if this is an existing ClaimMember, remove it from the list of Eligible Members
                    if (claimMember.Id != null) {
                        // use a loop instead of 'indexOf', as eligibleMembers is a List from an SOQL, while newClaimMembers is a List from a Trigger
                        for (Integer i = 0; i < eligibleMembers.size(); i++) {
                            if (claimMember.Id == eligibleMembers.get(i).Id) {
                                eligibleMembers.remove(i); break;
                            }
                        }
                    }
                }
            }
        }
        //Remove all accounts that have not been changed:
        eligibleMembersByAccounts.keySet().retainAll(accountsToRecalculate);
    }

    
    /**
     * Calculate the Percentage for each ClaimMember in the given Map.
     * Each key of the Map should be an Account Id and each List should contain all Eligible ClaimMembers for that Account.
     *
     * @param eligibleMembersByAccounts
     *
     * @return
     */
    private static void updatePercentages(Map<Id, List<ClaimMembers__c>> eligibleMembersByAccounts)
    {
        Map<Id, List<ClaimMembers__c>> approvedClaimsByAccounts = fetchRegularApprovedClaimMembersByAccounts(eligibleMembersByAccounts.keySet());
        
        for (Id accountId : eligibleMembersByAccounts.keySet()) {
            if (approvedClaimsByAccounts.containsKey(accountId)) {
                continue;
            }
            List<ClaimMembers__c> eligibleMembers = eligibleMembersByAccounts.get(accountId);
            if (eligibleMembers == null || eligibleMembers.isEmpty()) {
                continue;
            }

            Decimal basePercentage = 100;
            Integer industryExperts = 0;
            Boolean multipleCountries = false;
            /*
            // 	1. 100% deal with 1 Claim Member
            //  2. 140% deal with exactly 1 Industry Expert and 1 or more Non-Expert
            //	3. 100% Local Deal - Claim Members from same Sales Area
            //	4. 140% Global Deal - Claim Members from different Sales Areas
			*/
            if (eligibleMembers.size() > 1) {
            	String baseCountry     = eligibleMembers.get(0).ClaimMemberArea__c;
                for (ClaimMembers__c eligibleMember : eligibleMembers) {
                    if (eligibleMember.ClaimMemberArea__c != baseCountry) {
                        multipleCountries = true;
                        break;
                    }
                    if (eligibleMember.IsIndustryExpert__c) {
                        industryExperts++;
                    }
                }
            }
            if (multipleCountries || industryExperts == 1) { //Note that if there is only one industry expert, and no other claimmembers, the counter is still at 0, since we only count experts when total eligble claimmembers are bigger than 1.
                basePercentage = 140;
            }
            Decimal percentage = 100;
            if (eligibleMembers.size() > 0) {
                percentage = basePercentage / eligibleMembers.size();
            }

            for (ClaimMembers__c eligibleMember : eligibleMembers) {
                eligibleMember.Percentage__c = percentage;
            }
        }
        
    }

    /**
     * Get a Set of Account Ids from the given list of ClaimMembers
     *
     * @param claimMembers
     *
     * @return
     */
    private static Set<Id> getAccountIds(ClaimMembers__c[] claimMembers)
    {
        Set<Id> accountIds = new Set<Id>();

        for (ClaimMembers__c claimMember : claimMembers) {
            accountIds.add(claimMember.Account__c);
        }

        return accountIds;
    }

    /**
     * Fetch lists of Eligible ClaimMembers per Account
     *
     * @param accountIds The Accounts for whom the Eligible ClaimMembers should be fetched
     *
     * @return
     */
    private static Map<Id, List<ClaimMembers__c>> fetchEligibleMembersByAccounts(Set<Id> accountIds)
    {
        ClaimMembers__c[] claimMembers = [SELECT Id, Account__c, User__r.Name, ClaimMemberArea__c, EligibleForClaim__c, IsIndustryExpert__c, Percentage__c FROM ClaimMembers__c WHERE Account__c IN :accountIds AND EligibleForClaim__c = TRUE AND RecordTypeId = :Constants.RT_ID_CLAIMMEMBER_REGULAR];

        Map<Id, List<ClaimMembers__c>> eligibleMembersByAccounts = new Map<Id, List<ClaimMembers__c>>();

        for (ClaimMembers__c claimMember : claimMembers) {
            if (!eligibleMembersByAccounts.containsKey(claimMember.Account__c)) {
                eligibleMembersByAccounts.put(claimMember.Account__c, new List<ClaimMembers__c>());
            }
            eligibleMembersByAccounts.get(claimMember.Account__c).add(claimMember);
        }

        return eligibleMembersByAccounts;
    }

    /**
     * Fetch lists of Regular Claims per Account
     *
     * @param accountIds The Accounts for whom the Regular Claims should be fetched
     *
     * @return
     */
    private static Map<Id, List<Claim__c>> fetchRegularClaimsByAccounts(Set<Id> accountIds)
    {
        Claim__c[] claims = [SELECT Id, Account__c FROM Claim__c WHERE Account__c IN :accountIds AND RecordTypeId = :Constants.RT_ID_CLAIM_REGULAR];

        Map<Id, List<Claim__c>> regularClaimsByAccounts = new Map<Id, List<Claim__c>>();

        for (Claim__c claim : claims) {
            if (!regularClaimsByAccounts.containsKey(claim.Account__c)) {
                regularClaimsByAccounts.put(claim.Account__c, new List<Claim__c>());
            }
            regularClaimsByAccounts.get(claim.Account__c).add(claim);
        }

        return regularClaimsByAccounts;
    }

    /**
     * Fetch lists of Regular Claims per Account
     *
     * @param accountIds The Accounts for whom the Regular Claims should be fetched
     *
     * @return
     */
    private static Map<Id, List<ClaimMembers__c>> fetchRegularApprovedClaimMembersByAccounts(Set<Id> accountIds)
    {
        ClaimMembers__c[] claimMembers = [SELECT Id, Account__c FROM ClaimMembers__c WHERE Account__c IN :accountIds AND RecordTypeId = :Constants.RT_ID_CLAIMMEMBER_REGULAR AND ClaimMemberStatus__c = 'Approved'];

        Map<Id, List<ClaimMembers__c>> regularClaimMembersByAccounts = new Map<Id, List<ClaimMembers__c>>();

        for (ClaimMembers__c claimMember : claimMembers) {
            if (!regularClaimMembersByAccounts.containsKey(claimMember.Account__c)) {
                regularClaimMembersByAccounts.put(claimMember.Account__c, new List<ClaimMembers__c>());
            }
            regularClaimMembersByAccounts.get(claimMember.Account__c).add(claimMember);
        }

        return regularClaimMembersByAccounts;
    }

    /**
     * Add/Remove on update claimmember sharing
     * After update trigger
     */
    public static void updateClaimMemberShare(List<ClaimMembers__c> newClaimMemberList, Map<Id, ClaimMembers__c> oldClaimMemberMap){
        List<ClaimMembers__c> toProcessClaimMemberList = new List<ClaimMembers__c>();
        ClaimMembers__c oldCm;
        for(ClaimMembers__c newCm : newClaimMemberList) {
            oldCm = oldClaimMemberMap.get(newCm.Id);
            if (newCm.Account__c != oldCm.Account__c || newCm.Claim__c != oldCm.Claim__c || newCm.Opportunity__c != oldCm.Opportunity__c || newCm.User__c != oldCm.User__c) {
                toProcessClaimMemberList.add(newCm);
            }
        }
        if (!toProcessClaimMemberList.isEmpty()) {
            insertDeleteClaimMemberShare(toProcessClaimMemberList);
        }
    }

    /**
     * Add/Remove claimmember sharing
     * After insert/delete trigger
     */
    public static void insertDeleteClaimMemberShare(List<ClaimMembers__c> claimMemberList){
        try {
            Set<Id> accIdSet = new Set<Id>();
            //Collect all ClaimMembers for insert, update, delete
            for(ClaimMembers__c cm : claimMemberList) {
                if (cm.Account__c != null) {
                    accIdSet.add(cm.Account__c);
                }
            }
            //Get all ClaimMembers for these Claims
            List<ClaimMembers__c> cmAllInvolvedList = ([SELECT Id, Account__c, User__c, Opportunity__c, Claim__c, EligibleForClaim__c, RecordTypeId FROM ClaimMembers__c WHERE Account__c in :accIdSet]);
            

            //Get all involved Claimmember Id's to collect the existing sharings
            Set<Id> cmInvolvedIdSet = new Set<Id>();
            Set<Id> claimInvolvedIdSet = new Set<Id>();
            //Map all the ClaimMembers in a list per Claim Id
            Map<Id,List<ClaimMembers__c>> cmListByAccIdMap = new Map<Id,List<ClaimMembers__c>>();
            List<ClaimMembers__c> tmpCmList = new List<ClaimMembers__c>();
            for (ClaimMembers__c cmInvolved : cmAllInvolvedList) {
                if (cmInvolved.Account__c != null) {
                    if (cmInvolved.Claim__c != null) {
                        claimInvolvedIdSet.add(cmInvolved.Claim__c);                        
                    }
                    cmInvolvedIdSet.add(cmInvolved.Id);
                    tmpCmList = cmListByAccIdMap.get(cmInvolved.Account__c);
                    if (tmpCmList == null) {
                        tmpCmList = new List<ClaimMembers__c>();
                    }
                    tmpCmList.add(cmInvolved);
                    cmListByAccIdMap.put(cmInvolved.Account__c, tmpCmList);
                }
            }

            //Get all existing ClaimMember sharings
            List<ClaimMembers__Share> claimMemberShareList = [SELECT c.UserOrGroupId, c.RowCause, c.ParentId, c.Id, c.AccessLevel FROM ClaimMembers__Share c WHERE ParentId in: cmInvolvedIdSet];
            //Map all existing ClaimMember sharings per ParentId_UserOrGroupId
            Map<String,ClaimMembers__Share> cmShareByParentIdUserOrGroupIdMap = new Map<String,ClaimMembers__Share>(); 
            for(ClaimMembers__Share cmShare : claimMemberShareList) {
                cmShareByParentIdUserOrGroupIdMap.put((cmShare.ParentId + '_' + cmShare.UserOrGroupId),cmShare);
            }            

            //Get all existing Claim sharings
            system.debug(Limits.getQueries());
            List<Claim__Share> claimShareList = [SELECT c.UserOrGroupId, c.RowCause, c.ParentId, c.Id, c.AccessLevel FROM Claim__Share c WHERE ParentId in: claimInvolvedIdSet];
            Map<String,Claim__Share> claimShareByParentIdUserOrGroupIdMap = new Map<String,Claim__Share>(); 
            for(Claim__Share claimShare : claimShareList) {
                claimShareByParentIdUserOrGroupIdMap.put((claimShare.ParentId + '_' + claimShare.UserOrGroupId),claimShare);
            }            

            //Check existance ClaimMember share, else create
            List<ClaimMembers__Share> cmShareInsertList = new List<ClaimMembers__Share>();
            List<ClaimMembers__Share> cmShareDeleteList = new List<ClaimMembers__Share>();
            Set<Id> tmpUserIdSet;

            Map<String,Claim__Share> claimShareInsertMap = new Map<String,Claim__Share>();
            List<Claim__Share> claimShareInsertList = new List<Claim__Share>();
            List<Claim__Share> claimShareDeleteList = new List<Claim__Share>();

            for(Id accId : cmListByAccIdMap.keySet()) {
                tmpUserIdSet = new Set<Id>();
                for(ClaimMembers__c tmpCm : cmListByAccIdMap.get(accId)) {
                    //get user list for these claimMembers
                    if (tmpCm.User__c != null) {
                        tmpUserIdSet.add(tmpCm.User__c);
                    }
                }

                for(ClaimMembers__c tmpCm : cmListByAccIdMap.get(accId)) {
                    //Check/create for all users that have a claim to the Opportunity
                    for (Id usrId : tmpUserIdSet) {
                        //Remove from list if exist so only the to remove shares are left
                        if (null == cmShareByParentIdUserOrGroupIdMap.remove(tmpCm.Id + '_' + usrId)) {
                            //create share
                            cmShareInsertList.add(new ClaimMembers__Share(ParentId=tmpCm.Id, UserOrGroupId=usrId, AccessLevel='Edit', RowCause='Manual'));
                        }
                    }
					//COMMENT JELLE TALSTRA 19/08/2021 To also share for exception claimmembers, add fitlers here.
                    if (tmpCm.Claim__c != null && (tmpCm.EligibleForClaim__c || tmpCm.RecordTypeId == Constants.RT_ID_CLAIMMEMBER_EXCEPTION)) {
                        //Remove from list if exist so only the to remove shares are left
                        if (null == claimShareByParentIdUserOrGroupIdMap.remove(tmpCm.Claim__c + '_' + tmpCm.User__c)) {
                            //create share
                            claimShareInsertMap.put((tmpCm.Claim__c + '_' + tmpCm.User__c),new Claim__Share(ParentId=tmpCm.Claim__c, UserOrGroupId=tmpCm.User__c, AccessLevel='Read', RowCause='Manual'));
                        }
                    }
                }
            }

            Integer i = 0;
            Integer suc6Cnt = 0;
            Integer errCnt = 0;
            String suc6Msg = '';
            String errMsg = '';

            //ClaimMember sharing
            if (!cmShareInsertList.isEmpty()) {
                i = 0;
                suc6Cnt = 0;
                errCnt = 0;
                suc6Msg = '';
                errMsg = '';

                Database.SaveResult[] srList = Database.insert(cmShareInsertList,false);
                for(Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful
                        suc6Cnt++;
                        suc6Msg += 'Id: ' + cmShareInsertList[i].Id + '|ParentId:' + cmShareInsertList[i].ParentId + '|UserId:' + cmShareInsertList[i].UserOrGroupId + '\n'; 
                    }
                    else {
                        errCnt++;
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            errMsg += 'Id: ' + cmShareInsertList[i].Id + '|ParentId:' + cmShareInsertList[i].ParentId + '|UserId:' + cmShareInsertList[i].UserOrGroupId + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
                        }
                    }
                    i++;
                }
                if (suc6Cnt!=0) {
                    System.debug(LoggingLevel.INFO, 'Successfully inserted ' + suc6Cnt + ' ClaimMemberShare(s)');
                }
                if (errCnt!=0) {
                    System.debug(LoggingLevel.ERROR, 'Failed saving ' + errCnt + ' ClaimMemberShare(s): ' + errMsg);
                }        
            }

            // Delete the rest of the Manual shares
            for (ClaimMembers__Share cms : cmShareByParentIdUserOrGroupIdMap.values()) {
                if (cms.RowCause == 'Manual') {
                    cmShareDeleteList.add(cms);
                }
            }
            
            if (!cmShareDeleteList.isEmpty()) {
                i = 0;
                suc6Cnt = 0;
                errCnt = 0;
                suc6Msg = '';
                errMsg = '';

                Database.DeleteResult[] drList = Database.delete(cmShareDeleteList,false);
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        // Operation was successful
                        suc6Cnt++;
                        suc6Msg += 'Id: ' + cmShareDeleteList[i].Id + '\n'; 
                    }
                    else {
                        errCnt++;
                        // Operation failed, so get all errors                
                        for(Database.Error err : dr.getErrors()) {
                            errMsg += 'Id: ' + cmShareDeleteList[i].Id + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
                        }
                    }
                    i++;
                }
                if (suc6Cnt!=0) {
                    System.debug(LoggingLevel.INFO, 'Successfully deleted ' + suc6Cnt + ' ClaimMemberShare(s)');
                }
                if (errCnt!=0) {
                    System.debug(LoggingLevel.ERROR, 'Failed deleting ' + errCnt + ' ClaimMemberShare(s): ' + errMsg);
                }        
            }

            //Claim sharing
            claimShareInsertList = claimShareInsertMap.values();

            if (!claimShareInsertList.isEmpty()) {
                i = 0;
                suc6Cnt = 0;
                errCnt = 0;
                suc6Msg = '';
                errMsg = '';

                Database.SaveResult[] srList = Database.insert(claimShareInsertList,false);
                for(Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful
                        suc6Cnt++;
                        suc6Msg += 'Id: ' + claimShareInsertList[i].Id + '|ParentId:' + claimShareInsertList[i].ParentId + '|UserId:' + claimShareInsertList[i].UserOrGroupId + '\n'; 
                    }
                    else {
                        errCnt++;
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            errMsg += 'Id: ' + claimShareInsertList[i].Id + '|ParentId:' + claimShareInsertList[i].ParentId + '|UserId:' + claimShareInsertList[i].UserOrGroupId + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
                        }
                    }
                    i++;
                }
                if (suc6Cnt!=0) {
                    System.debug(LoggingLevel.INFO, 'Successfully inserted ' + suc6Cnt + ' ClaimShare(s)');
                }
                if (errCnt!=0) {
                    System.debug(LoggingLevel.ERROR, 'Failed saving ' + errCnt + ' ClaimShare(s): ' + errMsg);
                }        
            }

            // Delete the rest of the Manual shares
            for (Claim__Share cs : claimShareByParentIdUserOrGroupIdMap.values()) {
                if (cs.RowCause == 'Manual') {
                    claimShareDeleteList.add(cs);
                }
            }
            
            if (!claimShareDeleteList.isEmpty()) {
                i = 0;
                suc6Cnt = 0;
                errCnt = 0;
                suc6Msg = '';
                errMsg = '';

                Database.DeleteResult[] drList = Database.delete(claimShareDeleteList,false);
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        // Operation was successful
                        suc6Cnt++;
                        suc6Msg += 'Id: ' + claimShareDeleteList[i].Id + '\n'; 
                    }
                    else {
                        errCnt++;
                        // Operation failed, so get all errors                
                        for(Database.Error err : dr.getErrors()) {
                            errMsg += 'Id: ' + claimShareDeleteList[i].Id + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
                        }
                    }
                    i++;
                }
                if (suc6Cnt!=0) {
                    System.debug(LoggingLevel.INFO, 'Successfully deleted ' + suc6Cnt + ' ClaimShare(s)');
                }
                if (errCnt!=0) {
                    System.debug(LoggingLevel.ERROR, 'Failed deleting ' + errCnt + ' ClaimShare(s): ' + errMsg);
                }        
            }

        }
        catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Inserting / Deleting Claim(Member) shares failed: ' + ex.getMessage());
        }
    }
    
    public static void handleAfterInsertTriggerSharing(ClaimMembers__c[] newClaimMembers){
        ClaimMemberSharingUtil shareHelper = ClaimMemberSharingUtil.getInstance();
        ClaimSharingUtil claimShareHelper = ClaimSharingUtil.getInstance();
        Set<Id> claimMembersIds = new Set<Id>();
        Set<Id> claimIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ClaimMembers__c cm : newClaimMembers){
            if (cm.EligibleSalesLead__c != null || cm.AssignedApproverId__c != null) {
                claimMembersIds.add(cm.Id);
            }
            if (cm.Account__c != null){
                accountIds.add(cm.Account__c);
            }
        }
        claimMembersIds.addAll((new Map<Id,ClaimMembers__c>([SELECT Id FROM ClaimMembers__c WHERE Account__c in: accountIds])).keySet());
        if (claimMembersIds.size() > 0 ) {
            shareHelper.storeClaimMember(claimMembersIds);
            shareHelper.commitClaimMembers();
        }
        
        //Also recalculate sharing for the claims
        claimIds.addAll((new Map<Id,Claim__c>([SELECT Id FROM Claim__c WHERE Account__c in: accountIds])).keySet());
        if (claimIds.size() > 0 ) {
            claimShareHelper.storeClaims(claimIds);
            claimShareHelper.commitClaims();
        }
    }
    
    public static void handleAfterUpdateTriggerSharing(ClaimMembers__c[] newClaimMembers, Map<Id, ClaimMembers__c> oldClaimMemberMap){
        ClaimMemberSharingUtil shareHelper = ClaimMemberSharingUtil.getInstance();
        ClaimSharingUtil claimShareHelper = ClaimSharingUtil.getInstance();
        
        Set<Id> oldClaimIds = new Set<Id>();
        Set<Id> claimMembersIds = new Set<Id>();
        Set<Id> claimIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ClaimMembers__c cm : newClaimMembers){
            Id oldAccountId = cm.Account__c;
            id newAccountId = oldClaimMemberMap.get(cm.Id).Account__c;
            //If account has changed, recalculate sharing for all claimmembers related to the old AND new account
            if (newAccountId != oldAccountId){
                if (newAccountId != null){
                    accountIds.add(newAccountId);
                }
                if (oldAccountId != null){
                    accountIds.add(oldAccountId);
                }
                if (newAccountId == null) {
                    claimMembersIds.add(cm.Id);//Also store this claimmember for the instance where the new account is empty.
                }
            }
            //if salesLead has changed, recalculated sharing for the claimmembers on that account.
            else if (cm.EligibleSalesLead__c != oldClaimMemberMap.get(cm.Id).EligibleSalesLead__c){
                accountIds.add(cm.Account__c);
                claimMembersIds.add(cm.Id); //Also store the ClaimMember for when the account is empty
            }
            else if (cm.AssignedApproverId__c != oldClaimMemberMap.get(cm.Id).AssignedApproverId__c){
                accountIds.add(cm.Account__c);
                claimMembersIds.add(cm.Id); //Also store the ClaimMember for when the account is empty
            }
            //if claim changed, recalculate sharing for that claim and the old one.
            if (cm.Claim__c != oldClaimMemberMap.get(cm.Id).Claim__c) {
                accountIds.add(cm.Account__c);
                if (cm.Claim__c != null) {
                	claimIds.add(cm.Claim__c);
                }
                if (oldClaimMemberMap.get(cm.Id).Claim__c != null) {
                    claimIds.add(oldClaimMemberMap.get(cm.Id).Claim__c);
                    oldClaimIds.add(oldClaimMemberMap.get(cm.Id).Claim__c);//Also recalculate old claim
                }
            }
        }
        claimMembersIds.addAll((new Map<Id,ClaimMembers__c>([SELECT Id FROM ClaimMembers__c WHERE Account__c in: accountIds])).keySet());
        if (claimMembersIds.size() > 0 ) {
            shareHelper.storeClaimMember(claimMembersIds);
            shareHelper.commitClaimMembers();
        }
        //Also recalculate sharing for the claims
        //if the claim was edited on the ClaimMember, also query the account of the old Claim to be recalculated
        for (Claim__c claim : [SELECT Account__c FROM Claim__c WHERE Id in: oldClaimIds]){
            if(claim.Account__c != null) {
            	accountIds.add(claim.Account__c);
            }
        }
        claimIds.addAll((new Map<Id,Claim__c>([SELECT Id FROM Claim__c WHERE Account__c in: accountIds])).keySet());
        if (claimIds.size() > 0 ) {
            claimShareHelper.storeClaims(claimIds);
            claimShareHelper.commitClaims();
        }
    }
    
    public static void handleAfterDeleteTriggerSharing(ClaimMembers__c[] oldClaimMembers){
        ClaimMemberSharingUtil shareHelper = ClaimMemberSharingUtil.getInstance();
        ClaimSharingUtil claimShareHelper = ClaimSharingUtil.getInstance();
        Set<Id> claimMembersIds = new Set<Id>();
        Set<Id> claimIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ClaimMembers__c cm : oldClaimMembers){
            if (cm.Account__c != null){
                accountIds.add(cm.Account__c);
            }
        }
        claimMembersIds.addAll((new Map<Id,ClaimMembers__c>([SELECT Id FROM ClaimMembers__c WHERE Account__c in: accountIds])).keySet());
        if (claimMembersIds.size() > 0 ) {
            shareHelper.storeClaimMember(claimMembersIds);
            shareHelper.commitClaimMembers();
        }
        claimIds.addAll((new Map<Id,Claim__c>([SELECT Id FROM Claim__c WHERE Account__c in: accountIds])).keySet());
        if (claimIds.size() > 0 ) {
            claimShareHelper.storeClaims(claimIds);
            claimShareHelper.commitClaims();
        }
    }
    
    public static void handleAfterUndeleteTriggerSharing(ClaimMembers__c[] newClaimMembers){
        ClaimMemberSharingUtil shareHelper = ClaimMemberSharingUtil.getInstance();
        ClaimSharingUtil claimShareHelper = ClaimSharingUtil.getInstance();
        Set<Id> claimMembersIds = new Set<Id>();
        Set<Id> claimIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (ClaimMembers__c cm : newClaimMembers){
            if (cm.Account__c != null){
                accountIds.add(cm.Account__c);
            }
            claimMembersIds.add(cm.Id);
        }
        claimMembersIds.addAll((new Map<Id,ClaimMembers__c>([SELECT Id FROM ClaimMembers__c WHERE Account__c in: accountIds])).keySet());
        if (claimMembersIds.size() > 0 ) {
            shareHelper.storeClaimMember(claimMembersIds);
            shareHelper.commitClaimMembers();
        }
        claimIds.addAll((new Map<Id,Claim__c>([SELECT Id FROM Claim__c WHERE Account__c in: accountIds])).keySet());
        if (claimIds.size() > 0 ) {
            claimShareHelper.storeClaims(claimIds);
            claimShareHelper.commitClaims();
        }
    }
}