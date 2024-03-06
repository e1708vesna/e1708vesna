/**
* @author (s)    : Brite
* @description   : LeadConverter helper class for updating Contacts, Accounts and Opportunities that were created during Lead conversion
*/
public class LeadConverter
{
    @Future
    public static void handleConvertedLeads(Set<Id> leadIds, Map<Id, String> accountStatusByAccountId)
    {
        Lead[] leads = LeadDao.getLeadConversionDetails(leadIds);
        
        handleConvertedLeads(leads, accountStatusByAccountId);
    }
    
    public static void handleConvertedLeadsDirect(Set<Id> leadIds, Map<Id, String> accountStatusByAccountId)
    {
        Lead[] leads = LeadDao.getLeadConversionDetails(leadIds);
        
        handleConvertedLeads(leads, accountStatusByAccountId);
    }
    
    
    public static void handleConvertedLeads(List<Lead> leads, Map<Id, String> accountStatusByAccountId)
    {
        Set<Id> LeadIds = (new Map<Id,SObject>(leads)).keySet();
        
        if (leads == null || leads.isEmpty()) {
            return;
        }
        Set<Id> accountIds              = new Set<Id>();
        Map<Id, Account> accountMap     = new Map<Id, Account>();
        Map<Id, Opportunity> opportunityMap     = new Map<Id, Opportunity>();
        Map<Id, Contact> contactMap     = new Map<Id, Contact>();
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Handover__c> handoverUpdateList = new List<Handover__c>();
        for (Lead lead : leads) {
            Contact contact;
            if (contactMap.containsKey(lead.ConvertedContactId)){
                contact         = contactMap.get(lead.ConvertedContactId);
            }
            else {
                contact         = lead.ConvertedContact;
            }
            Account account;
            accountIds.add(lead.ConvertedAccountId);
            if (accountMap.containsKey(lead.ConvertedAccountId)){
                account         = accountMap.get(lead.ConvertedAccountId);
            }
            else {
                account         = lead.ConvertedAccount;
            }
            
            Opportunity opportunity;
            if (opportunityMap.containsKey(lead.ConvertedOpportunityId)){
                opportunity         = opportunityMap.get(lead.ConvertedOpportunityId);
            }
            else {
                opportunity         = lead.ConvertedOpportunity;
            }
            //            System.debug(lead);
            //            System.debug(contact);
            //            System.debug(account);
            //            System.debug(opportunity);
            
            lead = updateLead(lead);
            // check if Lead converted to a new Contact
            if (contact != null && contact.ConvertedFromLead__c && !contact.ConvertedAutomationExecuted__c) {
                contact = updateNewContact(contact, lead);
                contactMap.put(contact.Id, contact);
            }
            else if (contact != null){
                contact = updateExistingContact(contact, lead);
                contactMap.put(contact.Id, contact);
            }
            // check if Lead converted to new Account
            if (account != null && account.ConvertedFromLead__c && !account.ConvertedAutomationExecuted__c) {
                
                account = updateExistingAccount(account, lead, accountStatusByAccountId);
                account = updateAccount(account, lead);
                account = updateAccountIndustry(account, lead);
                accountMap.put(account.Id, account);
            }
            else if (account != null){
                account = updateAccountIndustry(account, lead);
                account = updateExistingAccount(account, lead, accountStatusByAccountId);
                accountMap.put(account.Id, account);
            }
            if (opportunity != null) {
                opportunity = updateOpportunity(opportunity, lead);
                opportunities.add(opportunity);
                opportunityMap.put(opportunity.Id, opportunity);
            }
            
            /*if(mActivities.size()>0){
                marketingActivities = updateMarketingActivities(contact.Id,account.Id,mActivities);
            }*/
            
            for(Handover__c handoversToBeUpdated : lead.Handovers__r){
                handoversToBeUpdated.Account__c = account.Id;
                handoverUpdateList.add(handoversToBeUpdated);
            }
        }
        
        
        update handoverUpdateList;      
        update leads;
        update contactMap.values();
        
        update accountMap.values();
        update opportunityMap.values();
        //Amy - to be discussed with Jelle,
        //don't move this to UAT for now
        //if(!test.isRunningTest()) {
            consolidatePartnerType(accountIds, leads);
        //}
        consolidateRelationship(accountIds, leads);
        // Must be called after update Opportunities
        //PartnerUtility.copyLeadPartners(LeadIds);
    }
    
    public static Lead updateLead(Lead lead)
    {
        if(lead.SQL_Date__c == null) {
            lead.SQL_Date__c = Date.today();
        }
        // create a new Qualified Lead Record if a Partner_Referral and PartnerContact are set, but no ConvertedLead
        /* TO BE REMOVED */
        //if (lead.Partner_Referral__c != null && lead.PartnerContact__c != null && lead.ConvertedLead__c == null) {
            //lead.ConvertedLead__c = createNewQualifiedLead(lead).Id;
        //}
        /* TO BE REMOVED */
        return lead;
    }

    /* TO BE REMOVED */
    /*public static ConvertedLead__c createNewQualifiedLead(Lead lead)
    {
        ConvertedLead__c convertedLead = new ConvertedLead__c(
            Name                = lead.FirstName + ' ' + lead.LastName,
            LeadName__c         = lead.Id,
            Opportunity__c      = lead.ConvertedOpportunityId,
            PartnerReferral__c  = lead.Partner_Referral__c
        );
        
        insert convertedLead;
        
        return convertedLead;
    }*/
    /* TO BE REMOVED */
    
    public static Contact updateNewContact(Contact contact, Lead lead)
    {
        contact.Referralby__c               	= contact.ConvertedAutomationExecuted__c ? contact.Referralby__c : lead.Partner_Referral__c;
        contact.PartnerReferralContact__c       = contact.ConvertedAutomationExecuted__c ? contact.PartnerReferralContact__c : lead.PartnerContact__c;
        contact.PartnerReferralContactOwner__c  = contact.ConvertedAutomationExecuted__c ? contact.PartnerReferralContactOwner__c : lead.PartnerReferralContactOwner__c;
        contact.ConvertedAutomationExecuted__c  = true;
        //contact.ConvertedLeadOwner__c           = lead.OwnerId;
        contact.ConvertedLeadSource__c          = lead.CurrentLeadSource__c;
        contact.Converted_Campaign__c           = lead.Current_Campaign__c;
        contact.Converted_Lead_Source_Detail__c = lead.Current_Lead_Source_Detail__c;
        contact.ConvertedPartnerSource__c       = lead.PartnerSource__c;
        contact.ConvertedMessagesToSales__c     = lead.MessagesToSales__c;
        contact.ConvertedPointsOfEntry__c       = lead.PointsOfEntry__c;
        contact.LeadCreatedDate__c              = lead.CreatedDate;
        contact.Initial_Campaign__c             = lead.Initial_Campaign__c;
        contact.InitialLeadSource__c            = lead.InitialLeadSource__c;
        contact.Initial_Lead_Source_Detail__c   = lead.Initial_Lead_Source_Detail__c;
        contact.InitialPartnerSource__c         = lead.InitialPartnerSource__c;
        contact.CurrentLeadSource__c            = lead.CurrentLeadSource__c;
        contact.Current_Lead_Source_Detail__c   = lead.Current_Lead_Source_Detail__c;
        contact.SQL_Date__c = lead.SQL_Date__c;
        contact.SAL_Date__c = lead.SAL_Date__c;
        contact.MQL_Date__c  = lead.MQL_Date__c;
        contact.BehaviorScore__c = lead.BehaviorScore__c; //1178620863
        contact.LeadOrigin__c = lead.LeadOrigin__c;
        
        return contact;
    }
    
    public static Contact updateExistingContact(Contact contact, Lead lead)
    {
        contact.CurrentLeadSource__c          = lead.CurrentLeadSource__c;
        contact.Current_Lead_Source_Detail__c = lead.Current_Lead_Source_Detail__c;
        contact.Preferred_Language__c         = lead.PreferredLanguage__c;
        contact.MailingCountry                = lead.Country;
        contact.BehaviorScore__c              = lead.BehaviorScore__c; //1178620863
        return contact;
    }
    
    //This method is only called to update the NEWLY created account. It does not update the account if it was already created prior to Lead Conversion
    public static Account updateAccount(Account account, Lead lead)
    {
        account.RecordTypeId = (lead.RecordTypeId == Constants.RT_ID_LEAD_PARTNER) ? Constants.RT_ID_ACC_PARTNER_V2 : Constants.RT_ID_ACC_BUSINESS;
        /* TO BE REMOVED */
        /*if (Lead.RecordTypeId == Constants.RT_ID_LEAD_PARTNER) {
            account.Account_Status__c = null;
            account.AccountType__c = 'Partner';
        }
        else {
            account.Account_Status__c = 'Prospect';
            account.AccountType__c = 'Merchant';
        }*/
        /* TO BE REMOVED */
        account.Referral__c               		= account.ConvertedAutomationExecuted__c ? account.Referral__c : lead.Partner_Referral__c;
        account.PartnerReferralContact__c       = account.ConvertedAutomationExecuted__c ? account.PartnerReferralContact__c : lead.PartnerContact__c;
        account.PartnerReferralContactOwner__c  = account.ConvertedAutomationExecuted__c ? account.PartnerReferralContactOwner__c : lead.PartnerReferralContactOwner__c;
        account.ConvertedAutomationExecuted__c = true;
        //account.ConvertedLeadOwner__c          = lead.OwnerId;
        if (account.InitialLeadSource__c == null){
            account.InitialLeadSource__c = lead.InitialLeadSource__c;
            account.InitialLeadSourceDetail__c = lead.Initial_Lead_Source_Detail__c;
        }
        if (account.Industry == lead.Industry && account.SubIndustry__c == null ){
            account.SubIndustry__c = lead.SubIndustry__c;
        }
        System.debug('****************************updateAccount*********************');
        System.debug('Merchant Core BusinessModel: ' + account.MerchantCoreBusinessModel__c);
        System.debug('Sub Business Model: ' + account.SubBusinessModel__c);
        if (String.isBlank(account.MerchantCoreBusinessModel__c)){
            account.MerchantCoreBusinessModel__c = lead.MerchantCoreBusinessModel__c;
            account.SubBusinessModel__c = lead.SubBusinessModel__c;
        }
        else if (account.MerchantCoreBusinessModel__c == lead.MerchantCoreBusinessModel__c && account.SubBusinessModel__c == null ){
            account.SubBusinessModel__c = lead.SubBusinessModel__c;
        }
        
        
        return account;
    }
    
    public static Account updateAccountIndustry(Account account, Lead lead)
    {
        if (account.Industry == lead.Industry && account.SubIndustry__c == null ){
            account.SubIndustry__c = lead.SubIndustry__c;
        }
        return account;
    }
    
    public static Account updateExistingAccount(Account account, Lead lead, Map<Id, String> accountStatusByAccountId)
    {
        
        if (String.isBlank(account.MerchantCoreBusinessModel__c)){
            account.MerchantCoreBusinessModel__c = lead.MerchantCoreBusinessModel__c;
            account.SubBusinessModel__c = lead.SubBusinessModel__c;
        }
        else if (account.MerchantCoreBusinessModel__c == lead.MerchantCoreBusinessModel__c && account.SubBusinessModel__c == null ){
            account.SubBusinessModel__c = lead.SubBusinessModel__c;
        }
        /* TO BE REMOVED */
        /*if (accountStatusByAccountId.containsKey(account.Id) && accountStatusByAccountId.get(account.Id) == 'Suspect') {
            account.SDR_Assignment__c = lead.SDR_Assignment__c == null ? account.SDR_Assignment__c : lead.SDR_Assignment__c;
        }*/
        /* TO BE REMOVED */
        return account;
    }
    
    public static Opportunity updateOpportunity(Opportunity opportunity, Lead lead)
    {
        // check if a new Opportunity was created during Lead conversion
        if (opportunity.ConvertedFromLead__c && !opportunity.ConvertedAutomationExecuted__c) {
            opportunity = updateOpportunity(opportunity, lead, lead.ConvertedContact, lead.ConvertedAccount);
        }
        
        //opportunity.ConvertedLeadOwner__c = lead.OwnerId;
        
        return opportunity;
    }
    
    public static Opportunity updateOpportunity(Opportunity opportunity, Lead lead, Contact contact, Account account)
    {
        Map<String, Pricebook2> pricebook2Map = Pricebook2Dao.getPricebook2Map();
        
        
        
        if (opportunity != null && opportunity.Referral_by_account__c == lead.Partner_Referral__c) {
            System.debug('opportunity.Referral_by_account__c != null && opportunity.Referral_by_account__c == lead.Partner_Referral__c');
            opportunity.ReferralAddedDate__c = (lead.ReferralAddedDate__c > opportunity.ReferralAddedDate__c) ? lead.ReferralAddedDate__c : opportunity.ReferralAddedDate__c;
        }
        else {
            System.debug('ELSE: ConvertedAutomationExecuted__c: ' + opportunity.ConvertedAutomationExecuted__c);
            opportunity.Referral_by_account__c               = opportunity.ConvertedAutomationExecuted__c ? opportunity.Referral_by_account__c : lead.Partner_Referral__c;
            opportunity.PartnerReferralContact__c               = opportunity.ConvertedAutomationExecuted__c ? opportunity.PartnerReferralContact__c : lead.PartnerContact__c;
            opportunity.PartnerReferralContactOwner__c               = opportunity.ConvertedAutomationExecuted__c ? opportunity.PartnerReferralContactOwner__c : lead.PartnerReferralContactOwner__c;
            opportunity.ReferralAddedDate__c               = opportunity.ConvertedAutomationExecuted__c ? opportunity.ReferralAddedDate__c : lead.ReferralAddedDate__c;
        }
        
        opportunity.ConvertedAutomationExecuted__c       = true;
        /*if (opportunity.Opportunity_Primary_Contact__c == null) {
opportunity.Opportunity_Primary_Contact__c = (contact.ConvertedFromLead__c) ? contact.Id : null;
}*/     /*TO BE REMOVED*/
        //opportunity.ConvertedOpportunityForNewAccount__c = (account.ConvertedFromLead__c) ? true : false;
        opportunity.Pricebook2Id                         = (pricebook2Map.containsKey(lead.CurrencyIsoCode)) ? pricebook2Map.get(lead.CurrencyIsoCode).Id : null;
        opportunity.Is_Sourced_From_Lead__c              = true;
        opportunity.Sales_channel__c                     = lead.SalesChannelSingle__c;
        /*TO BE REMOVED*/

        opportunity.CloseDate                            = Date.today().addDays(180);
        opportunity.RecordTypeId                         = Constants.RT_ID_OPP_SALES;
         return opportunity;
    }

    //Handles to pre conversion logic on lead
    public static List<Lead> handleConvertedLeadsBeforeUpdate(List<Lead> convertedLeadList){
        Set<Id> convertedAccountIdSet = new Set<Id>();
        Set<Id> convertedContactIdSet = new Set<Id>();
        Set<Id> convertedOpportunityIdSet = new Set<Id>();
        Map<Id, Account> convertedAccountMap;
        Map<Id, Contact> convertedContactMap;
        Map<Id, Opportunity> convertedOpportunityMap;
        
        //Get the leads that have been converted and its related contact and account
        for (Lead ld : convertedLeadList){
            if (ld.convertedAccountId != null){
                convertedAccountIdSet.add(ld.convertedAccountId);             
            }
            if (ld.convertedContactId != null){
                convertedContactIdSet.add(ld.convertedContactId);             
            }
            if (ld.convertedOpportunityId != null){
                convertedOpportunityIdSet.add(ld.convertedOpportunityId);             
            }
        }        
        //TODO: Move to DAO Class
        //Query the related contacts and accounts
        //ANALYSIS - Null checks missing, only query if the sets are not null
        convertedAccountMap = New Map<Id,Account>([Select Id, ConvertedAutomationExecuted__c, ConvertedFromLead__c, Company_Segment__c, BillingCountry, Industry, SubIndustry__c, Website, MerchantCoreBusinessModel__c, SubBusinessModel__c FROM Account WHERE Id in :convertedAccountIdSet]);
        convertedContactMap = New Map<Id,Contact>([Select Id, FirstName, LastName, Title, Email  FROM Contact WHERE Id in :convertedContactIdSet]);
        convertedOpportunityMap = New Map<Id,Opportunity>([Select Id, Sales_channel__c FROM Opportunity WHERE Id in :convertedOpportunityIdSet]);
        
        //Loop through the convertedLeads and set the corresponding fields.
        for (Lead ld : convertedLeadList){
            Contact cont = convertedContactMap.get(ld.convertedContactId);
            Account acc = convertedAccountMap.get(ld.convertedAccountId);
            Opportunity opp = convertedOpportunityMap.get(ld.convertedOpportunityId);
            if (cont != null){
                //Amy - validation in place for firstname on lead, not needed
                ld.FirstName = (String) getNewFieldValue(ld.FirstName, cont.FirstName);
                //Amy - validation in place for lastname on lead, not needed
                ld.LastName = (String) getNewFieldValue(ld.LastName, cont.LastName);
                //Amy - validation in place for email on lead, not needed
                ld.Email = (String) getNewFieldValue(ld.Email, cont.Email);
                //Amy - needed?
                ld.Title = (String) getNewFieldValue(ld.Title, cont.Title);
                
            }
            if (opp != null){
                ld.SalesChannelSingle__c = (String) getNewFieldValue(ld.SalesChannelSingle__c, opp.Sales_channel__c);
            }
            if (acc != null){
                ld.Company_Segment__c = (String) getNewFieldValue(ld.Company_Segment__c, acc.Company_Segment__c);
                ld.Country = (String) getNewFieldValue(ld.Country, acc.BillingCountry);
                ld.Website = (String) getNewFieldValue(ld.Website, acc.Website);
                String leadIndustry = ld.Industry;
                ld.Industry = (String) getNewFieldValue(ld.Industry, acc.Industry);
                if (ld.Industry != leadIndustry){
                    ld.SubIndustry__c = acc.SubIndustry__c;
                }
                
                String leadMerchantCoreBusinessModel = ld.MerchantCoreBusinessModel__c;
                ld.MerchantCoreBusinessModel__c = (String) getNewFieldValue(ld.MerchantCoreBusinessModel__c, acc.MerchantCoreBusinessModel__c);
                if (ld.MerchantCoreBusinessModel__c != leadMerchantCoreBusinessModel){
                    ld.SubBusinessModel__c = acc.SubBusinessModel__c;
                }
            }
            //Amy - TBD with Puck / Matthijs
            if (!FeatureManagement.checkPermission('Bypass_Validation')){
                List<String> fieldsWithError = new List<String>();
                String errorMessage = 'Please check the following fields before converting this lead: ';
                if (String.isBlank(ld.Country)){
                    fieldsWithError.add('Country');
                }
                /*if (String.isBlank(ld.Company_Segment__c)){
                    fieldsWithError.add('Company Segment');
                }*/
                if (String.isBlank(ld.Website)){
                    fieldsWithError.add('Website');
                }
                if (String.isBlank(ld.Title)){
                    fieldsWithError.add('Title');
                }
                //can be removed
                if (String.isBlank(ld.Email)){
                    fieldsWithError.add('Email');
                }
                if (String.isBlank(ld.FirstName)){
                    fieldsWithError.add('FirstName');
                }
                //can be removed
                if (String.isBlank(ld.Company)){
                    fieldsWithError.add('Company');
                }
                if (ld.RecordTypeId != constants.RT_ID_LEAD_PARTNER){
                    if (String.isBlank(ld.Company_Segment__c)){
                        fieldsWithError.add('Company Segment');
                    }
                    if (String.isBlank(ld.MerchantCoreBusinessModel__c)){
                        fieldsWithError.add('Merchant Core Business Model');
                    }
                    //Amy - Can be made configurable
                    //Industry
                    Set<String> validIndustryValues = new Set<String>{
                        'Consumer & Business Services', 
                            'Delivery Services', 
                            'Entertainment & Amusement', 
                            'Financial Services', 
                            'Food & Beverage', 
                            'Gambling', 
                            'Hospitality & Travel', 
                            'Internet, Media, Software & Apps',
                            'Non-Profit Organizations',
                            'Other',
                            'Public Services',
                            'Retail',
                            'Transportation & Mobility'
                            };
                                boolean validIndustryValue = false;
                    for (String validValue : validIndustryValues){
                        if (validValue.Equals(ld.Industry)){
                            validIndustryValue = true;
                            break;
                        }
                    }
                    //Amy - Industry and sub industry not dependent picklist?
                    if (acc.ConvertedFromLead__c && !acc.ConvertedAutomationExecuted__c){ //Converted to a new account
                        if (String.isBlank(ld.Industry) || (!validIndustryValue)){
                            fieldsWithError.add('Industry');
                        }
                        if (!'Other'.Equals(ld.Industry) && String.isBlank(ld.SubIndustry__c)){
                            fieldsWithError.add('Sub Industry');
                        }
                    }
                    else { //Converted to an existing account
                        if (String.isBlank(ld.Industry)){
                            fieldsWithError.add('Industry');
                        }
                    }
                    if (opp != null && String.isBlank(ld.SalesChannelSingle__c)){
                        fieldsWithError.add('Sales Channel');
                    }
                }
                if (fieldsWithError.size() > 0){
                    errorMessage += fieldsWithError[0];
                    for (integer i = 1; i < fieldsWithError.size(); i++){
                        errorMessage += ', ' + fieldsWithError[i];
                    }
				ld.addError(errorMessage);
                }
            }
            
        }
        return convertedLeadList;
    }
    
    //Returns the masterfield when it is filled in,
    //if it is not filled, it returns the slaveField
    private static object getNewFieldValue(object masterField, object slaveField){
        if (masterField == null){
            return slaveField;
        }
        else if(masterField instanceof String){ //amy - why do we have this check in place?
            String masterString = (String) masterField;
            if (String.isBlank(masterString)){
                return slaveField;
            }
        }
        return masterField;
    }
    
    // Commented the lines of code below as I am deploying a bugfix from TestV2 to UAT to Production and this logic isn't ready yet to move to the UAT environment    
    private static void consolidatePartnerType(Set<Id> accountIds, List<Lead> leadList){
        Map<String, PartnerType__c> pTypeUpsertListByExternalId = new Map<String, PartnerType__c>();
        Map<String, PartnerType__c> partnerTypeByExternalId = new Map<String, PartnerType__c>();
        for (PartnerType__c pType : [SELECT Id, UniqueIdentifier__c, Account__c, Type__c, SubType__c, Status__c, LastStatusChange__c FROM PartnerType__c WHERE Account__c in: accountIds]){
            partnerTypeByExternalId.put(pType.UniqueIdentifier__c, pType);
            system.debug('amy - iterating over pType - ' + pType);
        }
        for (Lead ld : leadList){
            if (ld.PartnerTypesLead__r != null) {
                for (PartnerType__c pTypeLd : ld.PartnerTypesLead__r){
                    PartnerType__c pTypeAcc;
                    String accExternalId = ld.ConvertedAccountId + ' - ' + pTypeLd.Type__c + ' - ' + pTypeLd.SubType__c;
                    if (partnerTypeByExternalId.containsKey(accExternalId)){
                        //Do nothing if it already exists. Keeping it here to make it easier to iterate on the behaviour.
                    }
                    else {
                        pTypeAcc = pTypeLd.clone(false, true, false, false);
                        pTypeAcc.Lead__c = null;
                        pTypeAcc.Account__c = ld.ConvertedAccountId;
                        pTypeAcc.UniqueIdentifier__c = accExternalId;
                        partnerTypeByExternalId.put(accExternalId, pTypeAcc);
                        pTypeUpsertListByExternalId.put(accExternalId, pTypeAcc);
                    }
                }
            }
        }
        //system.debug('error point -- ' + pTypeUpsertListByExternalId.values());
        upsert pTypeUpsertListByExternalId.values(); 
    } 
    
    private static void consolidateRelationship(Set<Id> accountIds, List<Lead> leadList){
        //accountIds: set with converted account ids 
        Map<String, Relationship__c> rShipUpsertListByExternalId = new Map<String, Relationship__c>();
        Map<String, Relationship__c> relationshipByExternalId = new Map<String, Relationship__c>();
        //iterate over all the relationships that are related to converted accounts and add them to map
        for (Relationship__c rShip : [SELECT Id, UniqueIdentifier__c, Account__c FROM Relationship__c WHERE Account__c in: accountIds]){
            relationshipByExternalId.put(rShip.UniqueIdentifier__c, rShip);
        }
        for (Lead ld : leadList){
            if (ld.RelationshipLeads__r != null) {
                for (Relationship__c rShipLd : ld.RelationshipLeads__r){
                    Relationship__c rShip;
                    String accExternalId = ld.ConvertedAccountId + '-' + rShipLd.PartnerType__c;
                    if (relationshipByExternalId.containsKey(accExternalId)){
                        //Do nothing if it already exists. Keeping it here to make it easier to iterate on the behaviour.
                        System.debug('Relationship already exists');
                    }
                    else {
                        rShip = rShipLd.clone(false, true, false, false);
                        rShip.Lead__c = null;
                        rShip.Account__c = ld.ConvertedAccountId;
                        rShip.UniqueIdentifier__c = accExternalId;
                        relationshipByExternalId.put(accExternalId, rShip);
                        rShipUpsertListByExternalId.put(accExternalId, rShip);
                    }
                    if (ld.ConvertedOpportunityId != null){
                        String oppExternalId = ld.ConvertedAccountId + '-' + rShipLd.PartnerType__c + '-' + ld.ConvertedOpportunityId;
                        if (relationshipByExternalId.containsKey(oppExternalId)){
                            //Do nothing if it already exists. Keeping it here to make it easier to iterate on the behaviour.
                        }
                        else {
                            rShip = rShipLd.clone(false, true, false, false);
                            rShip.Lead__c = null;
                            rShip.Account__c = ld.ConvertedAccountId;
                            rShip.Opportunity__c = ld.ConvertedOpportunityId;
                            rShip.UniqueIdentifier__c = oppExternalId;
                            relationshipByExternalId.put(oppExternalId, rShip);
                            rShipUpsertListByExternalId.put(oppExternalId, rShip);
                        }
                    }
                }
            }
        }
        upsert relationshipByExternalId.values(); 
    } 
}