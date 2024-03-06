/**
* @author (s)    : Brite
* @description   : LeadParternUtility helper class for maintaining the LeadPartner__c custom object
*/

public class LeadPartnerUtility {
    /*public static boolean updateReferral = true; //this stattic variable can be set to false to let the triggers of Account and Opportunity know not to update the referral By fields.
    
    //@description   : to be always called in the before trigger of Partner to update the unique key.
    public static void setMatchKey(List<LeadPartner__c> newPartnerList){
        for (LeadPartner__c p : newPartnerList){
            p.MatchKey__c = '' + p.Partner__c + p.Lead__c;
        }
    }
    
    //@description   : 	To be called when Referral__c on Lead is changed.
    //					Creates or updates Partner Record. 
    //					Deselects to Referral Checkbox on old partner, if the resulting partner is empty, deletes it instead.
    public static void newReferralPartnerFromLead(Set<Id> LeadIdSet){
        //Query opportunity and related partners
        
        List<LeadPartner__c> partnersDeleteList = new List<LeadPartner__c>();
        List<LeadPartner__c> partnersUpsertList = new List<LeadPartner__c>();
        List<Lead> ldList = LeadDao.getLeadPartnerDetails(LeadIdSet);
        
        for (Lead ld : ldList){
            boolean partnerExists = false;
            for (LeadPartner__c partner : ld.Lead_Partners__r){                
                if (partner.Partner__c == ld.Partner_Referral__c){
                    partner.Referral__c = true;
                    partnersUpsertList.add(partner);
                    partnerExists = true;
                }
                else {
                    if (partner.Referral__c == true){
                        partner.Referral__c = false;
                        if (isPartnerEmpty(partner)){
                            partnersDeleteList.add(partner);
                        }
                        else {
                            partnersUpsertList.add(partner);
                        }
                    }
                }
            }
            if (!partnerExists && ld.Partner_Referral__c != null){
                
                partnersUpsertList.add(new LeadPartner__c(Partner__c = ld.Partner_Referral__c, Referral__c = true, Lead__c = ld.Id));
            }
        }
        delete partnersDeleteList;
        upsert partnersUpsertList;
    }
    
    
    //@description   : 	Sets Referral__c on Lead when there is a new referral partner
    //					Removes referral checkbox from other partners, and deletes that partner if the resulting partner has no role.
    //					Can be called from the before insert and update trigger
    public static void newReferralPartner(List<LeadPartner__c> newPartnerList, Map<Id, LeadPartner__c> oldPartnerMap){
        Map<Id, LeadPartner__c> partnersInTransactionMap = new Map<Id, LeadPartner__c>();
        List<LeadPartner__c> partnersDeleteList = new List<LeadPartner__c>();
        List<LeadPartner__c> partnersUpdateList = new List<LeadPartner__c>();
        Map<Id, LeadPartner__c> referralPartnerMap = new Map<Id, LeadPartner__c>();
        for (LeadPartner__c partner : newPartnerList){
            if (partner.Id != null){
                partnersInTransactionMap.put(partner.Id, partner);
            }
            if (partner.Referral__c && (oldPartnerMap == null || (!oldPartnerMap.get(partner.Id).Referral__c && partner.Lead__c != null))){
                //is new referral partner
                referralPartnerMap.put(partner.Lead__c, partner);
            }
        }
        //Query the related opportunity and its related Referral Partners
        List<Lead> ldList = LeadDao.getLeadReferralPartnerDetails(referralPartnerMap.keySet());
        for (Lead ld : ldList){
            LeadPartner__c newReferralPartner = referralPartnerMap.get(ld.Id);
            ld.Partner_Referral__c = newReferralPartner.Partner__c; 
            for (LeadPartner__c referralPartner : ld.Lead_Partners__r){
                if (referralPartner.Partner__c != newReferralPartner.Partner__c){
                    referralPartner.Referral__c = false;
                    if (isPartnerEmpty(referralPartner)){
                        partnersDeleteList.add(new LeadPartner__c(Id = referralPartner.Id));
                    }
                    //if the partner is already in the trigger, update it in triggerMap, else update it.
                    else if (partnersInTransactionMap.containsKey(referralPartner.Id)){
                        partnersInTransactionMap.get(referralPartner.Id).Referral__c = false;
                    }
                    else {
                        partnersUpdateList.add(referralPartner);
                    }
                }
            }
        }
        updateReferral = false;
        update ldList;
        updateReferral = true;
        delete partnersDeleteList;
        update partnersUpdateList;
        
    }
    
    //@description   : 	removes Referral__c on Lead when a referral from a partner record is removed
    //					Can be called from the after update trigger
    public static void removeReferralPartner(List<LeadPartner__c> newPartnerList, Map<Id, LeadPartner__c> oldPartnerMap){
        List<LeadPartner__c> partnerDeleteList = new List<LeadPartner__c>();
        List<Lead> LeadUpdateList = new List<Lead>();
        Map<Id, LeadPartner__c> referralPartnerMap = new Map<Id, LeadPartner__c>();
        for (LeadPartner__c partner : newPartnerList){
            if (!partner.Referral__c && oldPartnerMap.get(partner.Id).Referral__c && partner.Lead__c != null){
                //referral removed
                referralPartnerMap.put(partner.Lead__c, partner);
                if (isPartnerEmpty(partner)){
                    //partnerDeleteList.add(new LeadPartner__c(Id = partner.Id));
                }
            }
        }
        
        //Query the related opportunity
        List<Lead> ldList = LeadDao.getLeadPartnerDetails(referralPartnerMap.keySet());
        for (Lead ld : ldList){
            LeadPartner__c oldReferralPartner = referralPartnerMap.get(ld.Id);
            if (oldReferralPartner.Partner__c == ld.Partner_Referral__c && ld.Partner_Referral__c != null){
                ld.Partner_Referral__c = null;
                LeadUpdateList.add(ld);
            }
            else {
                //Do nothing when it is not filled with the old partner, this means it is already updated.
            }
        }
        update LeadUpdateList;
        delete partnerDeleteList;
    }
    
    //@description   : 	If a referral LeadPartner__c is deleted, update Referral__c on Lead
    //					Can be called from the after delete trigger
    public static void afterDeletePartners(List<LeadPartner__c> oldPartnerList){
        List<Lead> LeadUpdateList = new List<Lead>();
        Map<Id, LeadPartner__c> referralPartnerMap = new Map<Id, LeadPartner__c>();
        for (LeadPartner__c partner : oldPartnerList){
            if (partner.Referral__c){
                referralPartnerMap.put(partner.Lead__c, partner);
            }
        }
        List<Lead> ldList = LeadDao.getLeadPartnerDetails(referralPartnerMap.keySet());
        for (Lead ld : ldList){
            LeadPartner__c oldReferralPartner = referralPartnerMap.get(ld.Id);
            if (oldReferralPartner.Partner__c == ld.Partner_Referral__c && ld.Partner_Referral__c != null){
                ld.Partner_Referral__c = null;
                LeadUpdateList.add(ld);
            }
            else {
                //Do nothing when it is not filled with the old partner, this means it is already updated.
            }
        }
        update LeadUpdateList;
        
    }
    
    //@description   : 	If two (or more) leads are merged, handle the deduplication of the resulting partnerList
    //					must be called from the afterDelete trigger.
    public static void afterMergeLeadPartner(List<Lead> oldLeadList){
        Map<Id, List<LeadPartner__c>> partnerToLeadPartnerList = new  Map<Id, List<LeadPartner__c>>();
        Id masterRecordId;
        //Set<Id> mergedLeads = new Set<Id>();
        List<LeadPartner__c> partnersToDelete = new List<LeadPartner__c>();
        List<LeadPartner__c> partnersToUpdate = new List<LeadPartner__c>();
        List<Lead> slaveLeadList = new List<Lead>();
        for (Lead ld : oldLeadList){
            if (ld.MasterRecordId != null){
                //mergedLeads.add(ld.Id);
                masterRecordId = ld.MasterRecordId;
                slaveLeadList.add(ld);
            }
        }
        
        if (masterRecordId != null){
            
            List<Lead> masterLeadList = LeadDao.getLeadPartnerDetails(new Set<Id> {masterRecordId});
            Lead masterLead;
            if (masterLeadList.size() > 0) {
                masterLead = masterLeadList[0];
            }
            Id partnerReferral = masterLead.Partner_Referral__c;  
            for (Lead slaveLd : slaveLeadList){
                if (slaveld.Partner_Referral__c != null && masterLead.Partner_Referral__c != null && slaveld.Partner_Referral__c != masterLead.Partner_Referral__c){
                    slaveld.addError('You are not allowed to merge two referral Leads');
                }
                
            }
            List<LeadPartner__c> LeadPartnerList = LeadPartnerDao.getDetailsByLead(new Set<Id>{masterRecordId});
            for (LeadPartner__c lp : LeadPartnerList){
                if (partnerToLeadPartnerList.containsKey(lp.Partner__c)){
                    partnerToLeadPartnerList.get(lp.Partner__c).add(lp);
                }
                else {
                    List<LeadPartner__c> lpList = new List<LeadPartner__c>();
                    lpList.add(lp);
                    partnerToLeadPartnerList.put(lp.Partner__c, lpList);
                }
            }
            for (List<LeadPartner__c> lpList : partnerToLeadPartnerList.values()){
                if (lpList.size() > 1){
                    LeadPartner__c lpKeep = lpList[0];
                    for (integer i = 1; i < lpList.size(); i++){
                        lpKeep = mergePartners(lpKeep, lpList[i], partnerReferral);
                        partnersToDelete.add(lpList[i]);
                    }
                    partnersToUpdate.add(lpKeep);
                }
                else {
                    if (lpList[0].Referral__c == true && lpList[0].Partner__c != partnerReferral){
                        lpList[0].Referral__c = false;
                        if (isPartnerEmpty(lpList[0])){
                            partnersToDelete.add(lpList[0]);
                        }
                        else {
                            partnersToUpdate.add(lpList[0]);
                        }
                    }
                    else {
                        partnersToUpdate.add(lpList[0]);
                    }
                    //donothing, maybe an update to set matchkey
                }
            }
            //mergePartners
            updateReferral = false;
            delete partnersToDelete;
            updateReferral = true;
            update partnersToUpdate;
        }
        
    }
    
    //@description   : 	Helper method to check if a Partner__c record still has an active role.
    private static boolean isPartnerEmpty(LeadPartner__c partner){
        if (!partner.Referral__c && !partner.Charity__c && !partner.AdyenForPlatforms__c && !partner.PaymentOrchestration__c && !partner.Platform__c && !partner.Consulting__c && !partner.SystemsIntegrator__c){
            return true;
        }
        return false;
    }
    
    
    
    
    
    
    //@description   : 	Helper method to deduplicate two partnerAccountId to PartnerList Maps
    //@Parameters	 : 	existingPartners:		Map of PartnerAccountId to PartnerList
    //					newPartners:			Map of PartnerAccountId to PartnerList
    //					referralPartnerId:		Id of the referral account.
    //@ReturnValue	 :	Map of PartnerAccountId to the resulting partner List.
    
    private static Map<Id, LeadPartner__c> deduplicatePartner(Map<Id, LeadPartner__c> existingPartners, Map<Id, LeadPartner__c> newPartners, Id referralPartnerId){
        Map<Id, LeadPartner__c> returnMap = new Map<Id, LeadPartner__c>();
        //Match new partners to existing partners
        for (Id partnerAccountId : newPartners.keySet()){
            if (existingPartners.containsKey(partnerAccountId)){
                LeadPartner__c existingPartner = mergePartners(existingPartners.get(partnerAccountId), newPartners.get(partnerAccountId), referralPartnerId);
                returnMap.put(existingPartner.Partner__c, existingPartner);
            }
            else {
                LeadPartner__c newPartner = newPartners.get(partnerAccountId);
                returnMap.put(newPartner.Partner__c, newPartner);
            }
        }
        
        return returnMap;
    }
    //@description   : 	Helper method to merge two LeadPartner__c records in memory (does not persist to database)
    //@Parameters	 : 	existingPartner:		Map of PartnerAccountId to PartnerList, (!this partner is updated in memory!)
    //					newPartner:			Map of PartnerAccountId to PartnerList
    //					referralPartnerId:		Id of the referral account.
    //@ReturnValue	 :	merged existingPartner record.
    
    private static LeadPartner__c mergePartners(LeadPartner__c existingPartner, LeadPartner__c newPartner, Id referralPartnerId){
        existingPartner.Platform__c = (newPartner.Platform__c || existingPartner.Platform__c) ? true : false;
        existingPartner.Consulting__c = (newPartner.Consulting__c || existingPartner.Consulting__c) ? true : false;
        
        //Referral is true when referralPartnerId equals the newPartner, or when it was already true for the existing partner and there is no new referral.
        if ((referralPartnerId != null && referralPartnerId == newPartner.Partner__c) || (referralPartnerId == null && existingPartner.Referral__c)){
            existingPartner.Referral__c = true;
        }
        else {
            existingPartner.Referral__c = false;
        }
        existingPartner.SystemsIntegrator__c = (newPartner.SystemsIntegrator__c || existingPartner.SystemsIntegrator__c) ? true : false;
        existingPartner.Charity__c = (newPartner.Charity__c || existingPartner.Charity__c) ? true : false;
        existingPartner.AdyenForPlatforms__c = (newPartner.AdyenForPlatforms__c || existingPartner.AdyenForPlatforms__c) ? true : false;
        existingPartner.PaymentOrchestration__c = (newPartner.PaymentOrchestration__c || existingPartner.PaymentOrchestration__c) ? true : false;
        return existingPartner;
    }
    */
    
}