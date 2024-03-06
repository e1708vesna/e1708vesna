/**
* @author (s)    : Brite
* @description   : parternUtility helper class for maintaining the Partner__c custom object
*/

public class PartnerUtility {
    /*public static boolean updateReferral = true; //this stattic variable can be set to false to let the triggers of Account and Opportunity know not to update the referral By fields.
    
    
    
    
    //@description   : to be always called in the before trigger of Partner to update the unique key.
    public static void setMatchKey(List<Partner__c> newPartnerList){
        Id emptyId = '000000000000000000';
        for (Partner__c p : newPartnerList){
            p.MatchKey__c = '' + (p.Partner__c != null ? p.Partner__c : emptyId);
            p.MatchKey__c += (p.Account__c != null ? p.Account__c : emptyId);
            p.MatchKey__c += (p.Opportunity__c != null ? p.Opportunity__c : emptyId);
            
        }
    }
    
    
    //@description   : 	To be called when Referral_by_account__c on Opportunity is changed.
    //					Creates or updates Partner Record. 
    //					Deselects to Referral Checkbox on old partner, if the resulting partner is empty, deletes it instead.
    public static void newReferralPartnerFromOpp(Set<Id> OpportunityIdSet){
        //Query opportunity and related partners
        
        List<Partner__c> partnersDeleteList = new List<Partner__c>();
        List<Partner__c> partnersUpsertList = new List<Partner__c>();
        List<Opportunity> oppList = OpportunityDAO.getOpportunitiesPartnerDetails(OpportunityIdSet);
        for (Opportunity opp : oppList){
            boolean partnerExists = false;
            for (Partner__c partner : opp.Partners__r){
				//Check if this partner is the new referral partner, set referral to true if so.                
                if (partner.Partner__c == opp.Referral_by_account__c){
                    partner.IsReferral__c = true;
                    partnersUpsertList.add(partner);
                    partnerExists = true;
                }
                //If not the new referral partner, but referral is true. Set it to false.
                else {
                    if (partner.IsReferral__c == true){
                        partner.IsReferral__c = false;
                        if (isPartnerEmpty(partner)){
                            partnersDeleteList.add(partner);
                        }
                        else {
                            partnersUpsertList.add(partner);
                        }
                    }
                }
            }
            //If the referral partner does not yet exist, create it.
            if (!partnerExists && opp.Referral_by_account__c != null){
                partnersUpsertList.add(new Partner__c(Partner__c = opp.Referral_by_account__c, isReferral__c = true, Opportunity__c = opp.Id, Account__c = opp.AccountId));
            }
        }
        delete partnersDeleteList;
        upsert partnersUpsertList;
    }
    
    //@description   : 	To be called when Referral__c on Account is changed.
    //					Creates or updates Partner Record. 
    //					Deselects to Referral Checkbox on old partner, if the resulting partner is empty, deletes it instead.
    public static void newReferralPartnerFromAcc(Set<Id> AccountIdSet){
        if (AccountIdSet == null || AccountIdSet.isEmpty()) {
        	return;
        }
        //Query Account and related partners
        
        List<Partner__c> partnersDeleteList = new List<Partner__c>();
        List<Partner__c> partnersUpsertList = new List<Partner__c>();
        List<Account> accList = AccountDao.getPartnerDetails(AccountIdSet);
        for (Account acc : accList){
            boolean partnerExists = false;
            for (Partner__c partner : acc.Partners2__r){   
                if (partner.Opportunity__c == null) {
                    //Check if this partner is the new referral partner, set referral to true if so. 
                    if (partner.Partner__c == acc.Referral__c){
                        partner.IsReferral__c = true;
                        partnersUpsertList.add(partner);
                        partnerExists = true;
                    }
                    //If not the new referral partner, but referral is true. Set it to false.
                    else {
                        if (partner.IsReferral__c == true){
                            partner.IsReferral__c = false;
                            if (isPartnerEmpty(partner)){
                                partnersDeleteList.add(partner);
                            }
                            else {
                                partnersUpsertList.add(partner);
                            }
                        }
                    }
                }
            }
            //If the referral partner does not yet exist, create it.
            if (!partnerExists && acc.Referral__c != null){
                partnersUpsertList.add(new Partner__c(Partner__c = acc.Referral__c, isReferral__c = true, Account__c = acc.Id));
            }
        }
        delete partnersDeleteList;
        upsert partnersUpsertList;
    }
    
    //@description   : 	Sets Referral__c on Account, Referral_by_account__c on Opportunity when there is a new referral partner
    //					Removes referral checkbox from other partners, and deletes that partner if the resulting partner has no role.
    //					Can be called from the before insert and update trigger
    public static void newReferralPartner(List<Partner__c> newPartnerList, Map<Id, Partner__c> oldPartnerMap){
        Map<Id, Partner__c> partnersInTransactionMap = new Map<Id, Partner__c>();
        List<Partner__c> partnersDeleteList = new List<Partner__c>();
        List<Partner__c> partnersUpdateList = new List<Partner__c>();
        Map<Id, Partner__c> opportunityReferralPartnerMap = new Map<Id, Partner__c>();
        Map<Id, Partner__c> accountReferralPartnerMap = new Map<Id, Partner__c>();
        for (Partner__c partner : newPartnerList){
            if (partner.Id != null){
                partnersInTransactionMap.put(partner.Id, partner);
            }
            if (partner.isReferral__c && (oldPartnerMap == null || !oldPartnerMap.get(partner.Id).isReferral__c)){
                if (partner.Opportunity__c != null) {
                    //is new referral partner
                    opportunityReferralPartnerMap.put(partner.Opportunity__c, partner);
                }
                else {
                    //is account referral partner
                    accountReferralPartnerMap.put(partner.Account__c, partner);
                }                
            }
            
        }
        
        //Query the related opportunity and its related Referral Partners
        List<Opportunity> oppList = OpportunityDao.getOpportunitiesReferralPartnerDetails(opportunityReferralPartnerMap.keySet());
        for (Opportunity opp : oppList){
            Partner__c newReferralPartner = opportunityReferralPartnerMap.get(opp.Id);
            opp.Referral_by_account__c = newReferralPartner.Partner__c; 
            for (Partner__c referralPartner : opp.Partners__r){
                if (referralPartner.Id != newReferralPartner.Id){
                    referralPartner.IsReferral__c = false;
                    if (isPartnerEmpty(referralPartner)){
                        partnersDeleteList.add(new Partner__c(Id = referralPartner.Id));
                    }
                    //if the partner is already in the trigger, update it in triggerMap, else update it.
                    else if (partnersInTransactionMap.containsKey(referralPartner.Id)){
                        partnersInTransactionMap.get(referralPartner.Id).IsReferral__c = false;
                    }
                    else {
                        partnersUpdateList.add(referralPartner);
                    }
                }
            }
        }
        
        //Query the related Account and its related Referral Partners
        List<Account> accList = AccountDao.getReferralPartnerDetails(accountReferralPartnerMap.keySet());
        for (Account acc : accList){
            Partner__c newReferralPartner = accountReferralPartnerMap.get(acc.Id);
            acc.Referral__c = newReferralPartner.Partner__c; 
            for (Partner__c referralPartner : acc.Partners2__r){
                if (referralPartner.Opportunity__c == null){
                    if (referralPartner.Id != newReferralPartner.Id){
                        referralPartner.IsReferral__c = false;
                        if (isPartnerEmpty(referralPartner)){
                            partnersDeleteList.add(new Partner__c(Id = referralPartner.Id));
                        }
                        //if the partner is already in the trigger, update it in triggerMap, else update it.
                        else if (partnersInTransactionMap.containsKey(referralPartner.Id)){
                            partnersInTransactionMap.get(referralPartner.Id).IsReferral__c = false;
                        }
                        else {
                            partnersUpdateList.add(referralPartner);
                        }
                    }
                }
            }
        }
        
        
        
        updateReferral = false;
        update oppList;
        update accList;
        updateReferral = true;
        delete partnersDeleteList;
        update partnersUpdateList;
        
    }
    //@description   : 	removes Referral__c on Account, Referral_by_account__c on Opportunity when a referral from partner is removed
    //					Can be called from the after update trigger
    public static void removeReferralPartner(List<Partner__c> newPartnerList, Map<Id, Partner__c> oldPartnerMap){
        List<Opportunity> opportunityUpdateList = new List<Opportunity>();
        List<Account> accountUpdateList = new List<Account>();
        Map<Id, Partner__c> opportunityReferralPartnerMap = new Map<Id, Partner__c>();
        Map<Id, Partner__c> accountReferralPartnerMap = new Map<Id, Partner__c>();
        for (Partner__c partner : newPartnerList){
            if (!partner.isReferral__c && oldPartnerMap.get(partner.Id).isReferral__c) {
                //referral removed
                if (partner.Opportunity__c != null) {
                    //Opportunity Partner
                    opportunityReferralPartnerMap.put(partner.Opportunity__c, partner);
                }
                else {
                    //Account Partner
                    accountReferralPartnerMap.put(partner.Account__c, partner);
                }
            }
        }
        
        //Query the related opportunity
        List<Opportunity> oppList = OpportunityDao.getOpportunitiesPartnerDetails(opportunityReferralPartnerMap.keySet());
        for (Opportunity opp : oppList){
            Partner__c oldReferralPartner = opportunityReferralPartnerMap.get(opp.Id);
            if (oldReferralPartner.Partner__c == opp.Referral_by_account__c && opp.Referral_by_account__c != null){
                opp.Referral_by_account__c = null;
                opportunityUpdateList.add(opp);
            }
            else {
                //Do nothing when it is not filled with the old partner, this means it is already updated.
            }
        }
        
        //Query the related account
        List<Account> accList = AccountDao.getPartnerDetails(accountReferralPartnerMap.keySet());
        for (Account acc : accList){
            Partner__c oldReferralPartner = accountReferralPartnerMap.get(acc.Id);
            if (oldReferralPartner.Partner__c == acc.Referral__c && acc.Referral__c != null){
                acc.Referral__c = null;
                accountUpdateList.add(acc);
            }
            else {
                //Do nothing when it is not filled with the old partner, this means it is already updated.
            }
        }
        update opportunityUpdateList;
        update accountUpdateList;
    }
    
    //@description   : 	If a referral Partner__c is deleted, update Referral_by_account__c on Opportunity and Referral__c on Account
    //					Can be called from the after delete trigger
    public static void afterDeletePartners(List<Partner__c> oldPartnerList){
        List<Opportunity> opportunityUpdateList = new List<Opportunity>();
        List<Account> accountUpdateList = new List<Account>();
        Map<Id, partner__c> opportunityReferralPartnerMap = new Map<Id, Partner__c>();
        Map<Id, partner__c> accountReferralPartnerMap = new Map<Id, Partner__c>();
        for (Partner__c partner : oldPartnerList){
            if (partner.IsReferral__c){
                if (partner.Opportunity__c != null) {
                    opportunityReferralPartnerMap.put(partner.Opportunity__c, partner);
                }
                else {
                    accountReferralPartnerMap.put(partner.Account__c, partner);
                }
            }
        }
        
        
        
        //Query related opportunity
        List<Opportunity> oppList = OpportunityDao.getOpportunitiesPartnerDetails(opportunityReferralPartnerMap.keySet());
        for (Opportunity opp : oppList){
            Partner__c oldReferralPartner = opportunityReferralPartnerMap.get(opp.Id);
            if (oldReferralPartner.Partner__c == opp.Referral_by_account__c && opp.Referral_by_account__c != null){
                opp.Referral_by_account__c = null;
                opportunityUpdateList.add(opp);
            }
            else {
                //Do nothing when it is not filled with the old partner, this means it has already been updated.
            }
        }
        
        
        //Query related Account
        List<Account> accList = AccountDao.getReferralPartnerDetails(accountReferralPartnerMap.keySet());
        for (Account acc : accList){
            Partner__c oldReferralPartner = accountReferralPartnerMap.get(acc.Id);
            if (oldReferralPartner.Partner__c == acc.Referral__c && acc.Referral__c != null){
                acc.Referral__c = null;
                accountUpdateList.add(acc);
            }
            else {
                //Do nothing when it is not filled with the old partner, this means it has already been updated.
            }
        }
        
        update opportunityUpdateList;
        update accountUpdateList;
        
    }
    
    
    //@description   : 	Copies lead partners from Lead to its ConvertedOpportunity
    public static void copyLeadPartners(Set<Id> leadIds){
        List<Lead> Leads = LeadDao.getLeadPartnerDetails(leadIds);
        List<Lead> merchantLeads = new List<Lead>();
        List<Lead> partnerLeads = new List<Lead>();
        for (Lead ld : leads){
            if (ld.ConvertedOpportunityId != null){
                merchantLeads.add(ld);
            }
            else if (ld.ConvertedAccountId != null){
                partnerLeads.add(ld);
            }
        }
        if (merchantLeads.size() > 0){
            copyLeadPartnersToOpportunity(merchantLeads);
        }
        if (partnerLeads.size() > 0) {
            copyLeadPartnersToAccount(partnerLeads);
        }
                
    }
    
    //@description   : 	Copies lead partners from Lead to its ConvertedOpportunity
    public static void copyLeadPartnersToOpportunity(List<Lead> Leads){
        Map<Id, List<LeadPartner__c>> leadToPartnerMap = new Map<Id, List<LeadPartner__c>>();
        Map<Id, Map<Id, Partner__c>> opportunityToNewPartnerMap = new Map<Id, Map<Id, Partner__c>>();
        Map<Id, Id> opportunityToReferralPartnerMap = new Map<Id, Id>();
        //Create Opportunity to New Partner map
        List<Id> opportunityIds = new List<Id>();
        for (Lead ld : leads){
            if (ld.ConvertedOpportunityId != null){
                Map<Id, Partner__c> tempPartnerMap = convertLeadPartner(ld.Lead_Partners__r ,ld.ConvertedOpportunityId, ld.ConvertedAccountId);
                // Loop through partners to make a map of referral partners
                for (Partner__c tempPartner : tempPartnerMap.values()){
                    if (tempPartner.IsReferral__c){
                        tempPartner.IsReferral__c = false;
                        //do not copy referrals through this method. Let that be handled through the lead conversion mapping.
                        //opportunityToReferralPartnerMap.put(ld.ConvertedOpportunityId, tempPartner.Partner__c);
                    }
                }
                
                
                //Populate the new OpportunityPartnerMap
                //Opportunity Already Exist in the map? Will only be true when two leads are converted to the same opportunity.
                if (opportunityToNewPartnerMap.containsKey(ld.ConvertedOpportunityId)){
                    Map<Id, Partner__c> partnerMap = opportunityToNewPartnerMap.get(ld.ConvertedOpportunityId);
                    
                    for (Partner__c tempPartner : tempPartnerMap.values()){
                        if (partnerMap.containsKey(tempPartner.Partner__c)){
                            Partner__c mergedPartner = mergePartners(partnerMap.get(tempPartner.Partner__c) , tempPartner, opportunityToReferralPartnerMap.get(ld.ConvertedOpportunityId));
                            partnerMap.put(mergedPartner.Partner__c, mergedPartner);
                        }
                        else {
                            partnerMap.put(tempPartner.Partner__c, tempPartner);
                        }
                    }
                }
                else {
                    opportunityToNewPartnerMap.put(ld.ConvertedOpportunityId, tempPartnerMap);
                }
            }
        }
        
        //Create Opportunity to Existing Partner map
        List<Partner__c> opportunityPartners = PartnerDao.getDetailsByOpportunity(opportunityToNewPartnerMap.keySet());
        
        Map<Id, Map<Id, Partner__c>> opportunityToExistingPartnerMap = new Map<Id, Map<Id, Partner__c>>();
        
        for (Partner__c partner : opportunityPartners){
            if (opportunityToExistingPartnerMap.containsKey(partner.Opportunity__c)){
                Map<Id, Partner__c> existingMap = opportunityToExistingPartnerMap.get(partner.Opportunity__c); 
                existingMap.put(partner.Partner__c, partner); 
                //opportunityToExistingPartnerMap.put(partner.Opportunity__c, existingMap);
            }
            else {
                Map<Id, Partner__c> newMap = new Map<Id, Partner__c>();
                newMap.put(partner.Partner__c, partner);
                opportunityToExistingPartnerMap.put(partner.Opportunity__c, newMap);   
            }
        }
        
        Map<Id, Map<Id, Partner__c>> opportunityToFinalPartnerMap =  new Map<Id, Map<Id, Partner__c>>();
        //Merge New and Existing Opportunity PartnerMap
        for (Id oppId :  opportunityToNewPartnerMap.keySet()){
            
            Map<Id, Partner__c> opportunityPartnerMap = new Map<Id, Partner__c>(); 
            if (opportunityToExistingPartnerMap.containsKey(oppId)){
                opportunityPartnerMap = deduplicatePartner(opportunityToExistingPartnerMap.get(oppId) , opportunityToNewPartnerMap.get(oppId), opportunityToReferralPartnerMap.get(oppId));
            }
            else {
                opportunityPartnerMap = opportunityToNewPartnerMap.get(oppId);
            }
            opportunityToFinalPartnerMap.put(oppId, opportunityPartnerMap);
        }
        
        List<Partner__c> partnerUpsertList = new List<Partner__c>();
        List<Partner__c> partnerDeleteList = new List<Partner__c>();
        
        for (Map<Id, Partner__c> partnerMap: opportunityToFinalPartnerMap.values()){
            for (Partner__c partner : partnerMap.values()){
                if (isPartnerEmpty(partner)){
                    if (partner.Id != null) {
                        partnerDeleteList.add(Partner);
                    }
                }
                else {
                    partnerUpsertList.add(Partner);
                }
            }
        }
        delete partnerDeleteList;
        upsert partnerUpsertList;
    }
    
    //@description   : 	Copies lead partners from Lead to its ConvertedAccount
    public static void copyLeadPartnersToAccount(List<Lead> Leads){
        Map<Id, List<LeadPartner__c>> leadToPartnerMap = new Map<Id, List<LeadPartner__c>>();
        Map<Id, Map<Id, Partner__c>> accountToNewPartnerMap = new Map<Id, Map<Id, Partner__c>>();
        Map<Id, Id> accountToReferralPartnerMap = new Map<Id, Id>();
        //Create account to New Partner map
        List<Id> accountIds = new List<Id>();
        for (Lead ld : leads){
            if (ld.ConvertedAccountId != null){
                Map<Id, Partner__c> tempPartnerMap = convertLeadPartner(ld.Lead_Partners__r , null, ld.ConvertedAccountId);
                //This could be more effecient if we do this in the convertLeadPartner method. Not that good for readability. Improvements are marginal.
                // Loop through partners to make a map of referral partners
                for (Partner__c tempPartner : tempPartnerMap.values()){
                    if (tempPartner.IsReferral__c){
                        tempPartner.IsReferral__c = false;
                        //do not copy referrals through this method. Let that be handled through the lead conversion mapping.
                        //accountToReferralPartnerMap.put(ld.ConvertedAccountId, tempPartner.Partner__c);
                    }
                }
                //Populate the new accountPartnerMap
                //Account Already Exist in the map? Will only be true when two leads are converted to the same account.
                if (accountToNewPartnerMap.containsKey(ld.ConvertedAccountId)){
                    Map<Id, Partner__c> partnerMap = accountToNewPartnerMap.get(ld.ConvertedAccountId);
                    
                    for (Partner__c tempPartner : tempPartnerMap.values()){
                        if (partnerMap.containsKey(tempPartner.Partner__c)){
                            Partner__c mergedPartner = mergePartners(partnerMap.get(tempPartner.Partner__c) , tempPartner, accountToReferralPartnerMap.get(ld.ConvertedAccountId));
                            partnerMap.put(mergedPartner.Partner__c, mergedPartner);
                        }
                        else {
                            partnerMap.put(tempPartner.Partner__c, tempPartner);
                        }
                    }
                }
                else {
                    accountToNewPartnerMap.put(ld.ConvertedAccountId, tempPartnerMap);
                }
            }
        }
        
        //Create Account to Existing Partner map
        List<Partner__c> accountPartners = PartnerDao.getDetailsByAccount(accountToNewPartnerMap.keySet());
        
        Map<Id, Map<Id, Partner__c>> accountToExistingPartnerMap = new Map<Id, Map<Id, Partner__c>>();
        
        for (Partner__c partner : accountPartners){
            if (partner.Opportunity__c == null) {
                if (!accountToExistingPartnerMap.containsKey(partner.Account__c)){
                    accountToExistingPartnerMap.put(partner.Account__c, new Map<Id, Partner__c>());
                }
                accountToExistingPartnerMap.get(partner.Account__c).put(partner.Partner__c, partner);
            }
        }
        
        Map<Id, Map<Id, Partner__c>> accountToFinalPartnerMap =  new Map<Id, Map<Id, Partner__c>>();
        //Merge New and Existing Opportunity PartnerMap
        for (Id accId :  accountToNewPartnerMap.keySet()){
            
            Map<Id, Partner__c> accountPartnerMap = new Map<Id, Partner__c>(); 
            if (accountToExistingPartnerMap.containsKey(accId)){
                accountPartnerMap = deduplicatePartner(accountToExistingPartnerMap.get(accId) , accountToNewPartnerMap.get(accId), accountToReferralPartnerMap.get(accId));
            }
            else {
                accountPartnerMap = accountToNewPartnerMap.get(accId);
            }
            accountToFinalPartnerMap.put(accId, accountPartnerMap);
        }
        
        List<Partner__c> partnerUpsertList = new List<Partner__c>();
        List<Partner__c> partnerDeleteList = new List<Partner__c>();
        
        for (Map<Id, Partner__c> partnerMap: accountToFinalPartnerMap.values()){
            for (Partner__c partner : partnerMap.values()){
                if (isPartnerEmpty(partner)){
                    if (partner.Id != null) {
                        partnerDeleteList.add(Partner);
                    }
                }
                else {
                    partnerUpsertList.add(Partner);
                }
            }
        }
        delete partnerDeleteList;
        upsert partnerUpsertList;
    }
    
    
    //@description   : 	If two accounts are merged, handle the deduplication of the resulting partnerList
    //					must be called from the afterDelete trigger.
    public static void afterMergeAccountPartner(List<Account> oldAccountList){
        Map<Id, List<Partner__c>> partnerAccountToPartnerList = new  Map<Id, List<Partner__c>>();
        Map<Id, List<Partner__c>> partnerOpportunityToPartnerList = new  Map<Id, List<Partner__c>>();
        Map<Id, List<Partner__c>> AccountToPartnerList = new  Map<Id, List<Partner__c>>();
        Map<Id, List<Partner__c>> OpportunityToPartnerList = new  Map<Id, List<Partner__c>>();
        List<Partner__c> partnersToDelete = new List<Partner__c>();
        List<Partner__c> partnersToUpdate = new List<Partner__c>();        
        Id masterRecordId;
        for (Account acc : oldAccountList){
            if (acc.MasterRecordId != null){
                masterRecordId = acc.MasterRecordId;
                break; //masterRecordId is the same for all in the transaction.
            }
        }
        if (masterRecordId != null){ 
            List<Account> masterAccountList = AccountDao.getPartnerDetails(new Set<Id> {masterRecordId});
            Account masterAccount;
            if (masterAccountList.size() > 0) {
                masterAccount = masterAccountList[0];
            }
            Id partnerReferral = masterAccount.Referral__c;
            
            List<Partner__c> AccountPartnerList = masterAccount.Partners2__r;
            List<Partner__c> PartnerList = masterAccount.Partners1__r;
            //Account can be a partner, have a partner, or both. 
            if (AccountPartnerList != null) { //Account has a partner. 
                for (Partner__c p : AccountPartnerList){ //Loop through partners and sort them into Account Partners and Opportunity Partners
                    if (p.Opportunity__c == null) {//Account Partner
                        if (partnerAccountToPartnerList.containsKey(p.Partner__c)){
                            partnerAccountToPartnerList.get(p.Partner__c).add(p);
                        }
                        else { //Opportunity Partner
                            List<Partner__c> pList = new List<Partner__c>();
                            pList.add(p);
                            partnerAccountToPartnerList.put(p.Partner__c, pList);
                        }
                    }
                    else {
                        if (partnerOpportunityToPartnerList.containsKey(p.Partner__c)){
                            partnerOpportunityToPartnerList.get(p.Partner__c).add(p);
                        }
                        else {
                            List<Partner__c> pList = new List<Partner__c>();
                            pList.add(p);
                            partnerOpportunityToPartnerList.put(p.Partner__c, pList);
                        }
                    }
                }
                for (List<Partner__c> pList : partnerAccountToPartnerList.values()){ //Loop through Account Partners
                    if (pList.size() > 1){ //Merged accounts had same partner, needs to be deduplicated
                        Partner__c pKeep = pList[0];
                        for (integer i = 1; i < pList.size(); i++){
                            pKeep = mergePartners(pKeep, pList[i], partnerReferral);
                            partnersToDelete.add(pList[i]);
                        }
                        partnersToUpdate.add(pKeep);
                    }
                    else { 
                        if (pList[0].isReferral__c == true && pList[0].Partner__c != partnerReferral){
                            pList[0].isReferral__c = false;
                            if (isPartnerEmpty(pList[0])){
                                partnersToDelete.add(pList[0]);
                            }
                            else {
                                partnersToUpdate.add(pList[0]);
                            }
                        }
                        else { //update partner to set Matchkey.
                            partnersToUpdate.add(pList[0]);
                        }
                    }
                }
                
                for (List<Partner__c> pList : partnerOpportunityToPartnerList.values()){ //Loop through Opportunity Partners
                    if (pList.size() > 1){ //Merged accounts had same partner, needs to be deduplicated
                        Partner__c pKeep = pList[0];
                        for (integer i = 1; i < pList.size(); i++){
                            pKeep = mergePartners(pKeep, pList[i], pList[i].Opportunity__r.Referral_by_account__c);
                            partnersToDelete.add(pList[i]);
                        }
                        partnersToUpdate.add(pKeep);
                    }
                    else { //update partner to set Matchkey.
                        partnersToUpdate.add(pList[0]);
                    }
                }
            }
            //Account is a partner itself
            if (PartnerList != null){
                for (Partner__c p : PartnerList){ //Loop through partners and sort them into Account Partners and Opportunity Partners
                    if (p.Opportunity__c == null) { //Account Partner
                        if (AccountToPartnerList.containsKey(p.Account__c)){
                            AccountToPartnerList.get(p.Account__c).add(p);
                        }
                        else { 
                            List<Partner__c> pList = new List<Partner__c>();
                            pList.add(p);
                            AccountToPartnerList.put(p.Account__c, pList);
                        }
                    }
                    else { //Opportunity Partner
                        if (OpportunityToPartnerList.containsKey(p.Opportunity__c)){
                            OpportunityToPartnerList.get(p.Opportunity__c).add(p);
                        }
                        else {
                            List<Partner__c> pList = new List<Partner__c>();
                            pList.add(p);
                            OpportunityToPartnerList.put(p.Opportunity__c, pList);
                        }
                    }
                }
                for (List<Partner__c> pList : AccountToPartnerList.values()){ //Loop through Account Partners
                    if (pList.size() > 1){ //Merged accounts had same partner, needs to be deduplicated
                        Partner__c pKeep = pList[0];
                        for (integer i = 1; i < pList.size(); i++){
                            pKeep = mergePartners(pKeep, pList[i], null);
                            partnersToDelete.add(pList[i]);
                        }
                        partnersToUpdate.add(pKeep);
                    }
                    else { //update partner to set Matchkey.
                        partnersToUpdate.add(pList[0]);
                    }
                }
                
                for (List<Partner__c> pList : OpportunityToPartnerList.values()){ //Loop through Opportunity Partners
                    if (pList.size() > 1){ //Merged accounts had same partner, needs to be deduplicated
                        Partner__c pKeep = pList[0];
                        for (integer i = 1; i < pList.size(); i++){
                            pKeep = mergePartners(pKeep, pList[i], null);
                            partnersToDelete.add(pList[i]);
                        }
                        partnersToUpdate.add(pKeep);
                    }
                    else { //update partner to set Matchkey.
                        partnersToUpdate.add(pList[0]);
                    }
                    
                }
            }
        }
        //mergePartners
        updateReferral = false;
        delete partnersToDelete;
        update partnersToUpdate;
        updateReferral = true;
    }
    
    
    
    
    //@description   : 	Helper method to check if a Partner__c record still has an active role.
    private static boolean isPartnerEmpty(Partner__c partner){
        if (!partner.isReferral__c && !partner.IsCharity__c && !partner.IsPlatform__c && !partner.IsAdyenForPlatforms__c && !partner.IsPaymentOrchestration__c && !partner.IsConsulting__c && !partner.IsSystemsIntegrator__c){
            return true;
        }
        return false;
        
    }
    
    //@description   : 	Helper method to convert LeadPartner__c records into Partner__c records
    //@Parameters	 : 	lPartners:		List of LeadPartners to be converted to Partner__c
    //					opportunityId:	The opportunity the resulting Partners should relate to.
    //					AccountId:		The Account the resulting Partners should relate to.
    //@ReturnValue	 :	Map of PartnerAccountId to the resulting partner List.
    private static Map<Id, Partner__c> convertLeadPartner(List<LeadPartner__c> lPartners, Id OpportunityId, Id accountId){
        Map<Id, Partner__c> partnerList = new Map<Id, Partner__c>();
        for (LeadPartner__c lPartner : lPartners) {
            Partner__c partner = new Partner__c();
            partner.Partner__c = lPartner.Partner__c;
            partner.Opportunity__c = OpportunityId;
            partner.Account__c = AccountId;
            partner.IsPlatform__c = lPartner.Platform__c;
            partner.IsConsulting__c = lPartner.Consulting__c;
            partner.IsReferral__c = lPartner.Referral__c;
            partner.IsSystemsIntegrator__c = lPartner.SystemsIntegrator__c;
            partner.IsCharity__c = lPartner.Charity__c;
            partner.IsAdyenForPlatforms__c = lPartner.AdyenForPlatforms__c;
            partner.IsPaymentOrchestration__c = lPartner.PaymentOrchestration__c;
            partnerList.put(lPartner.Partner__c ,partner);
        }
        return partnerList;
    }
    
    //@description   : 	Helper method to deduplicate two partnerAccountId to PartnerList Maps
    //@Parameters	 : 	existingPartners:		Map of PartnerAccountId to PartnerList
    //					newPartners:			Map of PartnerAccountId to PartnerList
    //					referralPartnerId:		Id of the referral account.
    //@ReturnValue	 :	Map of PartnerAccountId to the resulting partner List.
    private static Map<Id, Partner__c> deduplicatePartner(Map<Id, Partner__c> existingPartners, Map<Id, Partner__c> newPartners, Id referralPartnerId){
        Map<Id, Partner__c> returnMap = new Map<Id, Partner__c>();
        //Check if there are existing partners that do not match new partners
        for (Id partnerAccountId : existingPartners.keySet()){
            if (!newPartners.containsKey(partnerAccountId)){
                Partner__c existingPartner = existingPartners.get(partnerAccountId);
                if (referralPartnerId != null && existingPartner.isReferral__c){
                    existingPartner.isReferral__c = false;
                    returnMap.put(existingPartner.Partner__c, existingPartner);
                }
            }
        }
        //Match new partners to existing partners
        for (Id partnerAccountId : newPartners.keySet()){
            if (existingPartners.containsKey(partnerAccountId)){
                Partner__c existingPartner = mergePartners(existingPartners.get(partnerAccountId), newPartners.get(partnerAccountId), referralPartnerId);
                returnMap.put(existingPartner.Partner__c, existingPartner);
            }
            else {
                Partner__c newPartner = newPartners.get(partnerAccountId);
                returnMap.put(newPartner.Partner__c, newPartner);
            }
        }
        
        return returnMap;
    }
    
    
    //@description   : 	Helper method to merge two Partner__c records in memory (does not persist to database)
    //@Parameters	 : 	existingPartner:		Map of PartnerAccountId to PartnerList, (!this partner is updated in memory!)
    //					newPartner:			Map of PartnerAccountId to PartnerList
    //					referralPartnerId:		Id of the referral account.
    //@ReturnValue	 :	merged existingPartner record.
    private static Partner__c mergePartners(Partner__c existingPartner, Partner__c newPartner, Id referralPartnerId){
        existingPartner.isPlatform__c = (newPartner.isPlatform__c || existingPartner.isPlatform__c) ? true : false;
        existingPartner.IsConsulting__c = (newPartner.IsConsulting__c || existingPartner.IsConsulting__c) ? true : false;
        
        //Referral is true when referralPartnerId equals the newPartner, or when it was already true for the existing partner and there is no new referral.
        if ((referralPartnerId != null && referralPartnerId == newPartner.Partner__c) || (referralPartnerId == null && existingPartner.isReferral__c)){
            existingPartner.isReferral__c = true;
        }
        else {
            existingPartner.isReferral__c = false;
        }
        existingPartner.isSystemsIntegrator__c = (newPartner.isSystemsIntegrator__c || existingPartner.isSystemsIntegrator__c) ? true : false;
        existingPartner.isCharity__c = (newPartner.isCharity__c || existingPartner.isCharity__c) ? true : false;
        existingPartner.IsAdyenForPlatforms__c = (newPartner.IsAdyenForPlatforms__c || existingPartner.IsAdyenForPlatforms__c) ? true : false;
        existingPartner.IsPaymentOrchestration__c = (newPartner.IsPaymentOrchestration__c || existingPartner.IsPaymentOrchestration__c) ? true : false;
        return existingPartner;
    }*/
    
    
}