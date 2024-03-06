/**
 * @description TriggerHelper for the business logic on opportunity database actions
 * @author BRITE
 */
public without sharing class OpportunityHelper {

    private static Map<Id, Set<Id>> teamMembers = new Map<Id, Set<Id>>();
    
    public static void storeTeamMembers(List<Opportunity> newOppList) {
        List<OpportunityTeamMember> memberList = [SELECT ID, OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId in: newOppList];
        for (OpportunityTeamMember member : memberList) {
            if (!teamMembers.containsKey(member.OpportunityId)){
                teamMembers.put(member.OpportunityId, new Set<Id>());
            }
            teamMembers.get(member.OpportunityId).add(member.UserId);
        }
    }
    
    public static void validateTeamMembers(List<Opportunity> newOppList) {
        Set<Id> oppWithError = new Set<Id>();
        List<OpportunityTeamMember> memberList = [SELECT ID, OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId in: newOppList];
        Map<Id, Set<Id>> memberMap = new Map<Id, Set<Id>>();
        for (OpportunityTeamMember member : memberList) {
            if (!memberMap.containsKey(member.OpportunityId)){
                memberMap.put(member.OpportunityId, new Set<Id>());
            }
            memberMap.get(member.OpportunityId).add(member.UserId);
        }
        for (Id oppId : teamMembers.keyset()){
            if (!memberMap.containsKey(oppId)){
                oppWithError.add(oppId);
            }
            else {
                for (Id userId : teamMembers.get(oppId)){
                    if (!memberMap.get(oppId).contains(userId)){
                        oppWithError.add(oppId);
                    }
                }
            }
        }
        for (Opportunity opp : newOppList){
            if (oppWithError.contains(opp.Id)){
                opp.addError('Please check "Keep Opportunity Team" to continue.');
            }
        }
    }
    
    /**
     * @description Populate fields 'Name' and 'Type'.
     *              Runs before insert of a new opportunity.
     * 
     * @param newOppList List of created opportunities
     */
    public static void updateFieldsOnInsert(List<Opportunity> newOppList) {
        if (newOppList == null || newOppList.isEmpty()) {
            return;
        }
        
        // get account name
        Set<Id> accIdSet = new Set<Id> ();
        Set<Id> usrIdSet = new Set<Id> ();
        for (Opportunity opp : newOppList) {
            if (opp.AccountId != null) {
                accIdSet.add(opp.AccountId);
            }
            if (opp.Referral_by_account__c != null) {
                accIdSet.add(opp.Referral_by_account__c);
            }
            
            usrIdSet.add(opp.OwnerId);
        }
        Map<Id, Account> accountMap = new Map<Id, Account> (AccountDao.getDetails(accIdSet));
        Map<Id, User> userMap = new Map<Id, User> (UserDao.getDetails(usrIdSet));
        
        // update opportunity name
        Account acc;
        Integer iYear = DateTime.now().year();
        User currUser = UserDao.getCurrentUserDetails();
        User owner;
        Map<String, Pricebook2> pricebook2Map = Pricebook2Dao.getPricebook2Map();
        for (Opportunity opp : newOppList) {
            acc = accountMap.get(opp.AccountId);
            
            // opportunity name
            opp.Name = opp.Name.left(45) + ' - ';
            if (acc != null) {
                opp.Name += acc.Name.left(50);
                
                
                
                /* JTalstra Removed 2021-08-31, Account Statusses are deprecated
                // opportunity type
                if (Constants.ACC_LIST_STATUS_NEWBUSINESS.contains(acc.Account_Status__c)) {
                    opp.Type = Constants.OPP_TYPE_NEWBUSINESS;
                } else if (acc.Account_Status__c == Constants.ACC_STATUS_LIVEANDTRANSACTING) {
                    if (currUser.UserRole != null && currUser.UserRole.Name.contains('Account Manage')) {
                        opp.Type = Constants.OPP_TYPE_ACCOUNTMGMT;
                    } else {
                        opp.Type = Constants.OPP_TYPE_SALESMNGR;
                    }
                }*/
                
            } 
            opp.Name = (opp.Name 
                            + ' - ' + (opp.Sales_channel__c == null ? '' : opp.Sales_channel__c) 
                            + ' - ' + iYear)
                        .left(120);
            
            // set/correct record type if opportunity is created via lead conversion
            if (opp.ConvertedFromLead__c) {
                             
                /** not applicable for full adyen refactored anymore
                if (owner != null && !owner.Profile.Name.toUpperCase().startsWith('ADYEN V2 ')) {
                    // record type update should only be for users with 'old' profiles
                    if (opp.Sales_channel__c == 'POS') {
                        opp.RecordTypeId = Constants.RT_ID_OPP_POS;
                    } else if (opp.Sales_channel__c == 'Ecom' || opp.Sales_channel__c == 'Mobile') {
                        opp.RecordTypeId = Constants.RT_ID_OPP_ECOM;
                    }
                } **/
            }
            
            // change owner if opportunity is created via lead conversion
            //@TODO DvtH20190125 temporary disabled on request
            //if (opp.OwnerAfterLeadConversion__c != null) {
            //    opp.OwnerId = opp.OwnerAfterLeadConversion__c;
            //}
                        
            // opportunity source commented as this field is no more used 
           // setOpportunitySource(opp, accountMap);
            
            // set close date for converted lead
            if (opp.Is_Sourced_From_Lead__c) {
                opp.CloseDate = Date.today().addDays(180);
            }
 
            // set default price book for users with multiple pricebooks
            if (opp.Pricebook2Id == null) {
                if (opp.CurrencyIsoCode == 'EUR' && pricebook2Map.containsKey('EUR')) {
                    opp.Pricebook2Id = pricebook2Map.get('EUR').Id;
                } else if (opp.CurrencyIsoCode == 'USD' && pricebook2Map.containsKey('USD')) {
                    opp.Pricebook2Id = pricebook2Map.get('USD').Id;
                } else if (opp.CurrencyIsoCode == 'GBP' && pricebook2Map.containsKey('GBP')) {
                    opp.Pricebook2Id = pricebook2Map.get('GBP').Id;
                }
            }
            // set Stage date if it is not filled in yet
            setStageDate(opp);
        }
    }
    
    /**
     * @description Populate field 'Name'.
     *              Runs before update of a changed opportunity.
     * 
     * @param newOppList List of created opportunities
     * @param oldOppMap Map of opportunties with previous values
     */
    public static void updateFieldsOnUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        if (newOppList == null || newOppList.isEmpty() || oldOppMap == null || oldOppMap.isEmpty()) {
            return;
        }
        
        // get account name
        Set<Id> accIdSet = new Set<Id> ();
        Opportunity oldOpp;
        
        for (Opportunity opp : newOppList) {
            oldOpp = oldOppMap.get(opp.Id);
         
            if ((opp.AccountId != oldOpp.AccountId && opp.AccountId != null)
                    || opp.Sales_channel__c != oldOpp.Sales_channel__c
                    || opp.Region__c != oldOpp.Region__c
                    || opp.Name != oldOpp.Name) {
                    
                // only retrieve account data if opportunity name must be rebuild
                accIdSet.add(opp.AccountId);
            }
            if (opp.Referral_by_account__c != null) {
                accIdSet.add(opp.Referral_by_account__c);
            }
          
        }
        Map<Id, Account> accountMap = new Map<Id, Account> (AccountDao.getDetails(accIdSet));
        
        // update opportunity fields
        Account acc;
        for (Opportunity opp : newOppList) {
            acc = accountMap.get(opp.AccountId);
            /*
            if (!(acc == null && opp.AccountId != null)) {
                // only update opportunity name if a relevant field has been changed
                opp.Name = determineOpportunityName(opp.Name, (acc == null ? '' : acc.Name), opp.Sales_channel__c, opp.CreatedDate.year());
            }
            */
            
            // opportunity source commented as this field is no more used 
            //setOpportunitySource(opp, accountMap);stage
            if (opp.StageName != oldOpp.StageName) {
                opp.Old_Stage__c = oldOpp.StageName;
            }
            // set previous hardware quantity
            if (opp.Total_Quantity_Hardware__c != oldOpp.Total_Quantity_Hardware__c) {
                opp.Old_Total_quantity_hardware__c = String.valueOf(oldOpp.Total_Quantity_Hardware__c);
            }
            // set Stage date if it is not filled in yet
            setStageDate(opp);
        }
    }
    
    public static void afterUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        Set<Id> oppIdsClosedLost = new Set<Id>();
        for (Opportunity opp : newOppList){
            if (opp.StageName == 'Closed Lost' && oldOppMap.get(opp.Id).StageName != 'Closed Lost'){
                oppIdsClosedLost.add(opp.Id);
                System.debug('OpportunityWasSetToClosedLost');
            }
        }
        Set<Id> oppTmIds = (new Map<Id, OpportunityTeamMember>([SELECT Id FROM OpportunityTeamMember WHERE OpportunityId in: oppIdsClosedLost]).keySet());
        if (!oppTmIds.isEmpty()){
            
            System.debug('OpportunityWasSetToClosedLost and there was a teammember');
        	ClaimMemberHelper.updateClaimMemberOpportunity(oppTmIds);
        }
    }
    
    public static void beforeDelete(Map<Id, Opportunity> oldOppMap){
        Set<Id> oppTmIds = (new Map<Id, OpportunityTeamMember>([SELECT Id FROM OpportunityTeamMember WHERE OpportunityId in: oldOppMap.keySet()]).keySet());
        if (!oppTmIds.isEmpty()){
        	ClaimMemberHelper.updateClaimMemberOpportunity(oppTmIds);
        }
    }
    
    
    /*public static void updateReferral(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        Set<Id> newReferralIdSet = new Set<Id>();
        for (Opportunity opp : newOppList) {
            if ((oldOppMap == null && opp.Referral_by_account__c != null ) || (oldOppMap != null && opp.Referral_by_account__c != oldOppMap.get(opp.Id).Referral_by_account__c)) {
                newReferralIdSet.add(opp.Id);
            }
        }
        PartnerUtility.newReferralPartnerFromOpp(newReferralIdSet);
    }*/
    
    /**
     * @description If account has been changed, update the name of all related opportunties
     */
    /*
    public static void updateOpportunityName(List<Account> accList, Map<Id, Account> oldAccMap) {
        if (oldAccMap == null || oldAccMap.isEmpty()) {
            return;
        }

        // get all accounts with updated names        
        Set<Id> accIdSet = new Set<Id> ();
        Account oldAcc;
        for (Account acc : accList) {
            oldAcc = oldAccMap.get(acc.Id);
            if (oldAcc != null && acc.Name != oldAcc.Name) {
                accIdSet.add(acc.Id);
            }
        }
        
        // get all related opportunities
        if (!accIdSet.isEmpty()) {
            List<Opportunity> oppList = OpportunityDao.getOpportunitiesBasedOnAccount(accIdSet);
            if (!oppList.isEmpty()) {
                // update opportunity names
                List<Opportunity> oppUpdateList = new List<Opportunity> ();
                for (Opportunity opp : oppList) {
                    oppUpdateList.add(new Opportunity(Id = opp.Id, 
                                                      Name = determineOpportunityName(opp.Name, opp.Account.Name, opp.Sales_channel__c, opp.CreatedDate.year())));
                }
                
                Database.update(oppUpdateList, false);
            }
        }
    }
    */
    
    /**
     * @description populate Opportunity Source field
     * Commenting this method as this field is no more used.
     */
    /*
    private static void setOpportunitySource(Opportunity opp, Map<Id, Account> accountMap) {
        Account refAcc = accountMap.get(opp.Referral_by_account__c);
        if (Constants.OPP_LIST_LEADSOURCE_DIGITMARKETING.contains(opp.LeadSource)) {
            opp.Opportunity_Source__c = Constants.OPP_OPPSOURCE_DIGITMARKETING;
            
        } else if (opp.LeadSource == Constants.OPP_LEADSOURCE_PARTNER
                    || (opp.Referral_by_account__c != null && (refAcc.Type == Constants.ACC_TYPE_PARTNER || refAcc.Type == Constants.ACC_TYPE_CONSULTANT))) {
            opp.Opportunity_Source__c = Constants.OPP_OPPSOURCE_PARTNERSHIP;
            
        } else if (Constants.OPP_LIST_LEADSOURCE_EVENT.contains(opp.LeadSource)) {
            opp.Opportunity_Source__c = Constants.OPP_OPPSOURCE_EVENTS;
            
        } else if (Constants.OPP_LIST_LEADSOURCE_REFERRAL.contains(opp.LeadSource)) {
            opp.Opportunity_Source__c = Constants.OPP_OPPSOURCE_REFERRAL;
            
        } else if (opp.LeadSource == Constants.OPP_LEADSOURCE_INBOUNDCALL) {
            opp.Opportunity_Source__c = Constants.OPP_OPPSOURCE_INBOUNDCALL;
            
        } else if (Constants.OPP_LIST_LEADSOURCE_SALESSELFGEN.contains(opp.LeadSource)
            || opp.Opportunity_Source__c == null) {
            opp.Opportunity_Source__c = Constants.OPP_OPPSOURCE_SALESSELFGEN;
        }
    } **/
    
    /**
     * @description If not set, set the date of stage.
     *              Runs upon create and update of an opportunity
     */
    @testVisible
    private static void setStageDate(Opportunity opp) {
        if (opp.StageName == 'SCOTSMAN' && opp.ScotsmanDate__c == null) {
            opp.ScotsmanDate__c = Date.today();
        } else if (opp.StageName == 'Proposal/RFP Sent' && opp.Detailed_Proposal_Sent_Date__c == null) {
            opp.Detailed_Proposal_Sent_Date__c = Date.today();
        } else if (opp.StageName == 'Negotiation' && opp.Negotiation_Date__c == null) {
            opp.Negotiation_Date__c = Date.today();
        } else if (opp.StageName == 'Commitment' && opp.Commitment_Date__c == null) {
            opp.Commitment_Date__c = Date.today();
        } else if (opp.StageName == 'Contract signed' && opp.Contract_Signed_Date__c == null) {
            opp.Contract_Signed_Date__c = Date.today();
        } else if (opp.StageName == 'Transacting' && opp.Live_Stage_Date__c == null) {
            opp.Live_Stage_Date__c = Date.today();
        } else if (opp.StageName == 'Closed Lost' && opp.Closed_Lost_Date__c == null) {
            opp.Closed_Lost_Date__c = Date.today();
        } 
    }
    
    /**
     * @description Construct opportunity name 
     */
    @testVisible
    private static string determineOpportunityName(String oppName, String accName, String salesChannel, Integer year) {
        Integer iName = oppName.indexOf(' - ');
        if (oppName.startsWith('- ')) {
            oppName = 'Opportunity';
        } else if (iName > 0 ) {
            oppName = oppName.left(iName);
        } else {
            oppName = oppName.left(45);
        }
        
        return (oppName
                + ' - ' + (accName == null ? '' : accName.left(50))
                + ' - ' + (salesChannel == null ? '' : salesChannel) 
                + ' - ' + year)
                .left(120);
    }
    }