/**
* @author (s)    : Brite
* @description   : LeadHelper helper class for updating custom Lead fields
*/
public without sharing class LeadHelper {
    
    /**
* When an opportunity has been converted, check if an opportunity has been created for a partner lead.
*
* If a Lead is newly converted, call the LeadConverter to update the converted Contacts, Accounts and Opportunities
*/
    public static void handleAfterUpdateTrigger(List<Lead> newList, Map<Id,Lead> oldLeadsMap) {
        Set<Id> convertedLeads = new Set<Id>();
        Set<Id> convertedAccounts = new Set<Id>();
        Map<Id,lead> leadAccountMap = new Map<Id,lead> ();
        Boolean hasBypassValidation = FeatureManagement.checkPermission('Bypass_Validation');
        Id profileId = userinfo.getProfileId();
        String profileName = '';
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:profileId];
        If(profileList != null && profileList.size() > 0){
            profileName = profileList[0].Name;
        }
        
        for (Lead ld : [SELECT Id, ConvertedAccountId, ConvertedAccount.CreatedDate, ConvertedAccount.RecordTypeId
                        FROM Lead WHERE Id IN :newList]) {
                            if(null<>ld.ConvertedAccountId){
                                leadAccountMap.put(ld.id,ld);
                            }
                        }
        
        for (Lead ld : newList) {
            
            Lead oldLead = (oldLeadsMap.containsKey(ld.Id)) ? oldLeadsMap.get(ld.Id) : null;
            
            //Disabled this for the new Account Type functionality
            //if(ld.IsConverted && ld.RecordTypeId == Constants.RT_ID_LEAD_PARTNER && ld.ConvertedAccountId != null && leadAccountMap.get(ld.id).ConvertedAccount.CreatedDate != system.now() && leadAccountMap.get(ld.id).ConvertedAccount.RecordTypeId != Constants.RT_ID_ACC_PARTNER_V2){
            //    ld.addError('You cannot convert a Partner Lead to a non-Partner Account');
            //}
            
            if(ld.IsConverted && ld.RecordTypeId == Constants.RT_ID_LEAD_PARTNER && ld.ConvertedOpportunityId != null && ld.ConvertedOpportunity.CreatedDate != system.now()){
                ld.addError('You cannot convert a Partner Lead to an Opportunity. Please click on the checkbox indicating that you do not want to create an Opportunity');
            }
            
            if(ld.IsConverted && ld.Partner_Referral__c == null && (profileName == 'Adyen v2 Partnership' || profileName == 'Adyen v2 Partnership Lead') && ld.ConvertedOpportunityId != null && ld.ConvertedOpportunity.CreatedDate != system.now()){
                ld.addError('You can not convert a non-referral Lead, please transfer ownership of this Lead to Sales.');                
            }
            //Added By Jelle Talstra
            //2020-12-22 https://app.asana.com/0/927137240552881/1199598935411231
            //2021-02-09 added Bypass_Validation custom permission check
            //2021-06-02 allowing to convert without an Opportunity in case account is live account RT_ID_ACC_Live
            /*if(hasBypassValidation == false && ld.IsConverted && oldLeadsMap.get(ld.id).IsConverted == false && ld.RecordTypeId == Constants.RT_ID_LEAD_INBOUND2 && ld.ConvertedOpportunityId == null && leadAccountMap.get(ld.id).ConvertedAccount.RecordTypeId != Constants.RT_ID_ACC_COMPETITOR && leadAccountMap.get(ld.id).ConvertedAccount.RecordTypeId != Constants.RT_ID_ACC_Live){
                ld.addError('You must convert an Inbound Lead to an Opportunity. Please unselect the \'Don\'t create an opportunity upon conversion\' checkbox.');                
            }*/
            
            if (ld.IsConverted && oldLead != null && !oldLead.IsConverted) {
                convertedLeads.add(ld.Id);
                
            }
        }
        
        if (!convertedLeads.isEmpty()) {
            if (System.isFuture() || System.isBatch()) {
                LeadConverter.handleConvertedLeadsDirect(convertedLeads, AccountHelper.accountStatusByAccountIdBeforeTrigger);
            }
            else {
                LeadConverter.handleConvertedLeads(convertedLeads, AccountHelper.accountStatusByAccountIdBeforeTrigger);
            }
        }
    }
    
    public static void handleFieldsOnInsert(List<Lead> newLeads) {
        regionUpdate(newLeads);
        Set<Id> usrIdSet = new Set<Id>();
        Map<Id,User> usrMap;
        User usr;
        
        Id currentUserId = UserInfo.getUserId();
        //On normal insert CreatedById == null!
        usrIdSet.add(currentUserId);
        
        for(Lead ld : newLeads) {
            if (ld.CreatedById != null) {
                usrIdSet.add(ld.CreatedById);
            }
        }
        usrMap = new Map<Id,User>(UserDao.getDetails(usrIdSet));
        
        for(Lead ld : newLeads) {
            if (ld.CreatedById == null) {
                usr = usrMap.get(currentUserId);
            } else {
                usr = usrMap.get(ld.CreatedById);
            }
            if (usr.IsActive && !'Standard'.equals(usr.UserType)) {
                ld.Partner_Referral__c = usr.AccountId;   //Account of user
                ld.PartnerContact__c = usr.ContactId;   //Contact of user
                
            }
            
        }
    }
    
    
    
    //Handles before Convertion Logic
    public static void handleFieldsBeforeConvertion(List<Lead> newLeads, Map<Id,Lead> oldLeadsMap){
        regionUpdate(newLeads);
        List<Lead> convertedLeadList = new List<Lead>();
        //Get the leads that have been converted
        for (Lead ld : newLeads){
            if (ld.isConverted && !(oldLeadsMap.get(ld.Id).isConverted)){
                convertedLeadList.add(ld);
            }
        }
        if (convertedLeadList.size() > 0){
            convertedLeadList = LeadConverter.handleConvertedLeadsBeforeUpdate(convertedLeadList);
        }
    }
    
    public static void handleFieldsAfterInsert(List<Lead> newLeads) {
        Set<Id> usrIdSet = new Set<Id>();
        Map<Id,User> usrMap;
        User usr;
        List<Lead> updateLeads = new List<Lead>();
        
        Id currentUserId = UserInfo.getUserId();
        
        for(Lead ld : newLeads) {
            if (ld.CreatedById == ld.OwnerId) {
                usrIdSet.add(ld.CreatedById);
            }
        }
        usrMap = new Map<Id,User>(UserDao.getDetails(usrIdSet));
        
        for(Lead ld : newLeads) {
            if (usrMap.containsKey(ld.CreatedById)){
                usr = usrMap.get(ld.CreatedById);
                if (usr != null && usr.IsActive && !'Standard'.equals(usr.UserType)) {
                    //Lead needs to be assigned to the Partner Referral (Account) record owner which is the partner manager
                    //Reassign Ownership of the Lead, Note you cannot update the OwnerId in the before trigger!!
                    updateLeads.add(new Lead(Id = ld.Id, OwnerId = usr.Account.OwnerId));
                }
            }
        }
        if (!updateLeads.isempty()) {
            update (updateLeads);
        }
    }
    
    public static void regionUpdate(List<Lead> newLeads){
        Set<String> countries   = new Set<String> ();
        List<Lead> changedLeads = new List<Lead> ();
        List<Lead> updateCountryLeads  = new List<Lead> ();
        
        for (Lead ld : newLeads) {
            if (String.isNotEmpty (ld.CountryCode)) {
                updateCountryLeads.add (ld);
                countries.add (ld.CountryCode);
            }
        }
        
        Map<String, Regions__c> regionAssignmentMap = Regions.getRegionAssignments(countries);
        Regions__c regionAssignment;
        
        String ldState = null;
        for (Lead ld : updateCountryLeads) {
            if ('US'.equalsIgnoreCase(ld.CountryCode)) {
                ldState = ld.StateCode;
            } else {
                ldState = null;
            }
            
            regionAssignment = regionAssignmentMap.get(ld.CountryCode + ' ' + ld.StateCode);
            if (regionAssignment != null) {
                ld.Region__c = regionAssignment.Region__c;
                ld.Queue__c = regionAssignment.Queue__c;
                ld.SalesOffice__c = regionAssignment.Sales_Office__c;
            }
        }
    }    
    
    /**
	 * in case of a partner lead, validates if the lead
	 * is converted without associated partner types /
	 * without type & subtype in existing partner types
	 * @param List<Lead> - leads that are getting updated
	 * @return none
	 */
    public static void validatePartnerType(Map<Id, Lead> newLeads) {
        List<Id> flaggedLeads = new List<Id>();
        List<Lead> leadWithPartnerTypes = LeadDAO.getLeadConversionDetails(newLeads.keySet());
        for(Lead lead : leadWithPartnerTypes) {
            if(lead.RecordType.DeveloperName == 'PartnerLead' && lead.isConverted) {
                if(lead.NumberOfPartnerTypes__c == 0 || lead.NumberOfPartnerTypes__c == null) {
                    flaggedLeads.add(lead.Id);
                }
                else {
                    if(checkAssociatedPartnerTypes(lead.PartnerTypesLead__r) == false) {
                        flaggedLeads.add(lead.Id);
                    }
                }
            } 
        }
        if(!flaggedLeads.isEmpty()) {
           for(Id flaggedLead : flaggedLeads) {
            newLeads.get(flaggedLead).addError(System.Label.LeadPartnerTypeValidation);
        	} 
        }
    }
    
    /**
	 * checks if any of the partner types has either 
	 * type or sub-type not populated
	 * @param List<PartnerType__c> - partner types to be checked
	 * @return boolean - true if both populated, false otherwise
	 */
    public static boolean checkAssociatedPartnerTypes(List<PartnerType__c> partnerTypes) {
        Boolean result = true;
        for(PartnerType__c partnerType : partnerTypes) {
            if(partnerType.Type__c != 'Undefined') {
            	if(String.isEmpty(partnerType.Type__c) || String.isEmpty(partnerType.SubType__c)) {
                	result = false;
                	break;
            	}
         	}
        }
           
       return result; 
	}

    /**
	 * when marketo creates incomplete leads in salesforce,
	 * we need to block its creation. This is marked by
	 * setting the checkbox 'Do not sync to SFDC' to true
	 * @param List<PartnerType__c> - partner types to be checked
	 * @return boolean - true if both populated, false otherwise
	 */
    public static void blockIncompleteLeadCreation(List<Lead> newLeads) {
        for(Lead lead : newLeads) {
            if(lead.DoNotSyncToSFDC__c == true) {
                lead.addError(Constants.blockLeadSyncErrorMessage);
            }
        }
    }
}