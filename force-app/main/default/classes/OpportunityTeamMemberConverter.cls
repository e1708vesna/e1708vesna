/**
* @author (s)    : Brite
* @description   : A class for converting OpportunityTeamMembers to ClaimMembers
*/

public class OpportunityTeamMemberConverter
{
    
    
    Map<Id, OpportunityTeamMember> otmById  = new Map<Id, OpportunityTeamMember>();
    Set<Id> userIds = new Set<Id>();
    /**
    * Initialize the converter.
    * Compile a Set of OpportunityTeamMember ids for which ClaimMembers should be created,
    * and a Set of User ids for whom ClaimMember may already exist.
    *
    * @param oppTeamMembers
    */
    public OpportunityTeamMemberConverter(OpportunityTeamMember[] oppTeamMembers)
    {
        for (OpportunityTeamMember oppTeamMember : oppTeamMembers) {
            this.otmById.put(oppTeamMember.Id, oppTeamMember);
        }
    }
    
    /**
    * Converted the Set of OpportunityTeamMembers, that were compiled on initialization, to ClaimMembers
    */
    public void copyTeamMembersToClaimMembers() {
        OpportunityTeamMember[] oppTeamMembers = fetchOpportunityTeamMemberBasedOnProfile();
        for (OpportunityTeamMember oppTeamMember : oppTeamMembers) {
            this.userIds.add(oppTeamMember.UserId);
        }
        Map<Id, Set<Id>> accountUsers          = fetchAccountUsers();
        Map<Id, Map<Id, ClaimMembers__c>> claimMembersByAccountId = fetchAccountClaimMember();
        List<ClaimMembers__c> newClaimMembers = new List<ClaimMembers__c>();
        
        // convert each OpportunityTeamMember to a ClaimMember, if no ClaimMember exist yet for its User
        for (OpportunityTeamMember oppTeamMember : oppTeamMembers) {
            if (oppTeamMember.Opportunity.StageName != 'Closed Lost') {
                Set<Id> userIds = accountUsers.get(oppTeamMember.Opportunity.AccountId);
                if (userIds == null || !userIds.contains(oppTeamMember.UserId)) {
                    ClaimMembers__c tempClaimMember = new ClaimMembers__c(
                        Account__c                      = oppTeamMember.Opportunity.AccountId,
                        Opportunity__c                  = oppTeamMember.OpportunityId,
                        User__c                         = oppTeamMember.UserId,
                        OwnerId                         = oppTeamMember.UserId,
                        ClaimMemberArea__c              = oppTeamMember.User.SalesCountry__c == 'United States' ? oppTeamMember.User.SalesArea__c : oppTeamMember.User.SalesCountry__c,
                        // SalesCountry__c                 = oppTeamMember.User.SalesArea__c,
                        // SalesOffice__c                  = oppTeamMember.User.SalesOffice__c,
                        Status__c                       = 'No claim started',
                        PosAdvanceClaimStatus__c        = null,
                        RecordtypeId                    = Constants.RT_ID_CLAIMMEMBER_REGULAR,
                        CurrencyIsoCode                 = oppTeamMember.User.DefaultCurrencyIsoCode,
                        EligibleSalesLead__c            = oppTeamMember.User.ManagerId,
                        HistoricalEligibleSalesLead__c  = oppTeamMember.User.Manager__c
                    );
                    if (String.isBlank(tempClaimMember.ClaimMemberArea__c)){
                        otmById.get(oppTeamMember.Id).addError('This Opportunity Team Member cannot be added because the SalesCountry and/or the SalesArea has not been populated on the user record. Please contact an administrator for help.');
                    }
                    // don't set EligibleForClaim, as this will be done in the ClaimMembers Trigger
                    newClaimMembers.add(tempClaimMember);
                }
                else if (userIds != null && userIds.contains(oppTeamMember.UserId)){ //ClaimMember is already there on the account
                    Id accountId = oppTeamMember.Opportunity.AccountId;
                    Id claimMemberId = claimMembersByAccountId.get(accountId).get(oppTeamMember.UserId).Id;
                    newClaimMembers.add(new ClaimMembers__c(
                        id = claimMemberId
                    ));
                    ClaimMemberHelper.addClaimMemberNew(claimMemberId);
                }
            }
            
        }
        
        upsert newClaimMembers;
    }
    
    /**
    * Fetch the OpportunityTeamMembers for which ClaimMembers should be created
    *
    * @return
    */
    private OpportunityTeamMember[] fetchOpportunityTeamMember()
    {
        return [SELECT Opportunity.AccountId, Opportunity.RecordType.DeveloperName, OpportunityId, UserId, User.SalesCountry__c, User.SalesArea__c, User.DefaultCurrencyIsoCode, User.ManagerId, User.Manager__c 
                FROM OpportunityTeamMember 
                WHERE Id IN :THIS.otmById.keySet() 
                	AND Opportunity.RecordTypeId IN: Constants.OPP_RECORDTYPES_CLAIMMEMBERCREATION];
    }
    
    /**
    * Fetch the OpportunityTeamMembers for which ClaimMembers should be created
    *
    * @return
    */
    private OpportunityTeamMember[] fetchOpportunityTeamMemberBasedOnProfile()
    {
        
        return [SELECT Opportunity.AccountId, Opportunity.RecordType.DeveloperName, Opportunity.StageName, OpportunityId, UserId, User.SalesCountry__c, User.SalesArea__c, User.DefaultCurrencyIsoCode, User.ManagerId, User.Manager__c 
                FROM OpportunityTeamMember 
                WHERE Id IN :THIS.otmById.keySet() 
                	AND Opportunity.RecordTypeId IN: Constants.OPP_RECORDTYPES_CLAIMMEMBERCREATION 
                	AND (User.Profile.Name = 'Adyen v2 Sales' OR User.Profile.Name = 'Adyen v2 Sales Lead')
                	AND UserId != :Label.UnmanagedUser
                	AND (NOT User.UserRole.DeveloperName LIKE 'Business_Development_Manager%')
               ];
    }
    
    
    /**
    * Fetch Sets of User ids, mapped to Account ids, for whom regular ClaimMembers already exist
    *
    * @return
    */
    private Map<Id, Set<Id>> fetchAccountUsers()
    {
        ClaimMembers__c[] claimMembers = [SELECT Account__c, User__c FROM ClaimMembers__c WHERE RecordTypeId = :Constants.RT_ID_CLAIMMEMBER_REGULAR AND User__c IN :THIS.userIds];
        Map<Id, Set<Id>> accountUsers  = new Map<Id, Set<Id>>();
        
        // for each Account, build a Set with User Ids for whom ClaimMembers already exist
        for (ClaimMembers__c claimMember : claimMembers) {
            Id accountId = claimMember.Account__c;
            Set<Id> ids  = accountUsers.containsKey(accountId) ? accountUsers.get(accountId) : new Set<Id>();
            
            ids.add(claimMember.User__c);
            
            accountUsers.put(accountId, ids);
        }
        
        return accountUsers;
    }
    
    /**
    * Fetch Sets of User ids, mapped to Account ids, for whom regular ClaimMembers already exist
    *
    * @return
    */
        /**
    * Fetch claimMembers, mapped to Account ids, for whom regular ClaimMembers already exist
    *
    * @return
    */
    private Map<Id, Map<Id, ClaimMembers__c>> fetchAccountClaimMember()
    {
        ClaimMembers__c[] claimMembers = [SELECT Id, Account__c, User__c FROM ClaimMembers__c WHERE RecordTypeId = :Constants.RT_ID_CLAIMMEMBER_REGULAR AND User__c IN :THIS.userIds];
        Map<Id, Map<Id, ClaimMembers__c>> accountclaimMembers  = new Map<Id, Map<Id, ClaimMembers__c>>();
        
        // for each Account, build a Set with User Ids for whom ClaimMembers already exist
        for (ClaimMembers__c claimMember : claimMembers) {
            Id accountId = claimMember.Account__c;
            Map<Id, ClaimMembers__c> claimMemberMap  = accountclaimMembers.containsKey(accountId) ? accountclaimMembers.get(accountId) : new Map<Id, ClaimMembers__c>();
            
            claimMemberMap.put(claimMember.User__c, claimMember);
            
            accountclaimMembers.put(accountId, claimMemberMap);
        }
        
        return accountclaimMembers;
    }
}