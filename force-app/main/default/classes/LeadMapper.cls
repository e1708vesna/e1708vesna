/**
* @author Sales - Amy
* @group Service
* @description Handles all field overrides for lead trigger
*/
public class LeadMapper {
    public Map<Id, Lead> convertedLeads = new Map<Id, Lead>();
    public Map<Id, Account> convertedAccounts = new Map<Id, Account>();
    public Map<Id, Contact> convertedContacts = new Map<Id, Contact>();
    public Map<Id, Opportunity> convertedOpportunities = new Map<Id, Opportunity>();
    public static Map<String, List<LeadConversionMappings__mdt>> overrideMappings = new Map<String, List<LeadConversionMappings__mdt>>();

    public LeadMapper(Map<Id, Lead> convertedLeads) {
        this.convertedLeads = convertedLeads;
    }

    public void handleMappings() {
        Time runStartTime = DateTime.now().time();
        prepareData();
        updateConvertedAccounts();
        updateConvertedContacts();
        updateConvertedOpportunities();
        doDML();
        Time runEndTime = DateTime.now().time();
        Utils.createRuntimeLog(runStartTime, runEndTime, 'LeadMapper', 'handleMappings', 'Runtime for LeadMapper');
    }

    public void prepareData() {
        prepareConvertedRecords();
        processOverrideMappings();
    }

    public void prepareConvertedRecords() {
        for(Lead lead : convertedLeads.values()) {
            convertedAccounts.put(lead.ConvertedAccountId, lead.ConvertedAccount);
            convertedContacts.put(lead.ConvertedContactId, lead.ConvertedContact);
            if(lead.ConvertedOpportunity != null) {
                convertedOpportunities.put(lead.ConvertedOpportunityId, lead.ConvertedOpportunity);
            }
        }
    }


    /**
	 * fetches all lead conversion override mappings
	 * and creates a map of Target Object to their mappings
	 * @param none
	 * @return none
	 */
    public void processOverrideMappings() {
        for(LeadConversionMappings__mdt mapping : LeadDAORefactored.fetchOverrideMappings()) {
            String targetObject = mapping.TargetObject__c;
            if(overrideMappings.containsKey(targetObject)) {
                overrideMappings.get(targetObject).add(mapping);
            }
            else {
                overrideMappings.put(targetObject, new List<LeadConversionMappings__mdt>{mapping});
            }
        }
    }

    public static void stampSalesQualifiedDate(List<Lead> newLeads) {
        for (Lead lead : newLeads) {
            if (lead.SQL_Date__c == null && lead.IsConverted == true) {
                lead.SQL_Date__c = Date.today();
            }
        }
    }

    /**
	 * overrides fields on converted account
	 * @param none
	 * @return none
	 */
    public void updateConvertedAccounts() {
        List<LeadConversionMappings__mdt> mappings = overrideMappings.get('Account');
        for (Lead lead : convertedLeads.values()) {
            Id convertedAccountId = lead.ConvertedAccountId;
            if (convertedAccountId != null) {
                Account account = convertedAccounts.get(convertedAccountId);
                Boolean isExisting = account.ConvertedAutomationExecuted__c;
                for (LeadConversionMappings__mdt mapping : mappings) {
                    String targetField = mapping.TargetField__c;
                    String sourceField = mapping.SourceField__c;
                    if (account != null) {
                        if (mapping.OverrideBehavior__c == 'Always') {
                            if(mapping.TargetObjectNovelty__c == 'All') {
                                account.put(targetField, lead.get(sourceField));
                            }
                            if (mapping.TargetObjectNovelty__c == 'New' && !isExisting) {
                                account.put(targetField, lead.get(sourceField));
                            }
                            if (mapping.TargetObjectNovelty__c == 'Existing' && isExisting) {
                                account.put(targetField, lead.get(sourceField));
                            }
                        }
                        /**
                        * right now we don't map anything on for this override behavior
                        * hence, commenting this code for increasing test coverage
                        * uncomment if such mapping requirements arise :)
                        */
                        /*else if(mapping.OverrideBehavior__c == 'Only when Blank') {
                            String targetFieldValue = (String)account.get(targetField);
                            if(!String.isBlank(targetFieldValue)) {
                                account.put(targetField, lead.get(sourceField));
                            }
                        }*/
                    }
                }
                updateDependentValues();
            }
        }
    }

    /**
	 * overrides fields on converted contact
	 * @param none
	 * @return none
	 */
    public void updateConvertedContacts() {
        List<LeadConversionMappings__mdt> mappings = overrideMappings.get('Contact');
        for(Lead lead : convertedLeads.values()) {
            Id convertedContactId = lead.ConvertedContactId;
            if(convertedContactId != null) {
                Contact contact = this.convertedContacts.get(convertedContactId);
                Boolean isExisting = contact.ConvertedAutomationExecuted__c;
                for(LeadConversionMappings__mdt mapping : mappings) {
                    String targetField = mapping.TargetField__c;
                    String sourceField = mapping.SourceField__c;
                    if(contact != null) {
                        if(mapping.TargetObjectNovelty__c == 'All') {
                            contact.put(targetField, lead.get(sourceField));
                        }
                        if(mapping.OverrideBehavior__c == 'Always') {
                            if(mapping.TargetObjectNovelty__c == 'New' && !isExisting) {
                                contact.put(targetField, lead.get(sourceField));
                            }
                            if(mapping.TargetObjectNovelty__c == 'Existing' && isExisting) {
                                contact.put(targetField, lead.get(sourceField));
                            }
                        }
                        /**
                        * right now we don't map anything on for this override behavior
                        * hence, commenting this code for increasing test coverage
                        * uncomment the code if such mapping requirements arise :)
                        */
                        /*else if(mapping.OverrideBehavior__c == 'Only when Blank') {
                            String targetFieldValue = (String)contact.get(targetField);
                            if(!String.isBlank(targetFieldValue)) {
                                contact.put(targetField, lead.get(sourceField));
                            }
                        }*/
                        contact.ConvertedAutomationExecuted__c = true;
                    }
                }
            }
        }
    }

    /**
	 * overrides fields on converted opportunities
	 * @param none
	 * @return none
	 */
    public void updateConvertedOpportunities() {
        List<LeadConversionMappings__mdt> mappings = overrideMappings.get('Opportunity');
        for(Lead lead : convertedLeads.values()) {
            Id convertedOpportunityId = lead.ConvertedOpportunityId;
            if(convertedOpportunityId != null) {
                Opportunity opportunity = convertedOpportunities.get(convertedOpportunityId);
                Boolean isExisting = opportunity.ConvertedAutomationExecuted__c;
                if(isExisting) {
                    if(opportunity.Referral_by_account__c == lead.Partner_Referral__c) {
                    	opportunity.ReferralAddedDate__c = (lead.ReferralAddedDate__c > opportunity.ReferralAddedDate__c) ? lead.ReferralAddedDate__c : opportunity.ReferralAddedDate__c;
                	}
                }
                for(LeadConversionMappings__mdt mapping : mappings) {
                    String targetField = mapping.TargetField__c;
                    String sourceField = mapping.SourceField__c;
                    if(opportunity != null) {
                        if(mapping.TargetObjectNovelty__c == 'All') {
                            opportunity.put(targetField, lead.get(sourceField));
                        }
                        if(mapping.OverrideBehavior__c == 'Always') {
                            if(mapping.TargetObjectNovelty__c == 'New' && !isExisting) {
                                opportunity.put(targetField, lead.get(sourceField));
                            }
                            if(mapping.TargetObjectNovelty__c == 'Existing' && isExisting) {
                                opportunity.put(targetField, lead.get(sourceField));
                            }
                        }
                        /**
                        * right now we don't map anything on for this override behavior
                        * hence, commenting this code for increasing test coverage
                        * uncomment the code if such mapping requirements arise :)
                        */
                        /*else if(mapping.OverrideBehavior__c == 'Only when Blank') {
                            String targetFieldValue = (String)opportunity.get(targetField);
                            if(!String.isBlank(targetFieldValue)) {
                                opportunity.put(targetField, lead.get(sourceField));
                            }
                        }*/
                        opportunity.RecordTypeId = Constants.RT_ID_OPP_SALES;
                        opportunity.CloseDate = Date.today().addDays(180);
                        opportunity.ConvertedAutomationExecuted__c = true;
                    }
                }
            }
        }
    }
    
    
    /**
	 * overrides dependent picklist values
	 * only applicable for account
	 * @param none
	 * @return none
	 */
    public void updateDependentValues() {
        for(Lead lead : convertedLeads.values()) {
            if(lead.convertedAccountId != null) {
                Account account = convertedAccounts.get(lead.convertedAccountId);
                account.RecordTypeId = lead.RecordTypeId == Constants.RT_ID_LEAD_INBOUND2 ? Constants.RT_ID_ACC_BUSINESS : Constants.RT_ID_ACC_PARTNER_V2;
                if(account.ConvertedAutomationExecuted__c == true) {
                    if(account != null) {
                        if(String.isBlank(account.Industry)) {
                            account.Industry = lead.Industry;
                            account.SubIndustry__c = lead.SubIndustry__c;
                        }
                        if(!String.isBlank(account.Industry) && String.isBlank(account.SubIndustry__c) && account.Industry == lead.Industry) {
                            account.SubIndustry__c = lead.SubIndustry__c;
                        }
                        if(String.isBlank(account.MerchantCoreBusinessModel__c)) {
                            account.MerchantCoreBusinessModel__c = lead.MerchantCoreBusinessModel__c;
                            account.SubBusinessModel__c = lead.SubBusinessModel__c;
                        }
                        if(!String.isBlank(account.MerchantCoreBusinessModel__c) && String.isBlank(account.SubBusinessModel__c) && account.MerchantCoreBusinessModel__c == lead.MerchantCoreBusinessModel__c) {
                            account.SubBusinessModel__c = lead.SubBusinessModel__c;
                        }
                    }
                }
                else {
                    account.Industry = lead.Industry;
                    account.SubIndustry__c = lead.SubIndustry__c;
                    account.MerchantCoreBusinessModel__c = lead.MerchantCoreBusinessModel__c;
                    account.SubBusinessModel__c = lead.SubBusinessModel__c;
                    account.ConvertedAutomationExecuted__c = true;
                }
            }
        }
    }

    /**
	 * collates all the records to be
	 * overriden and updates them, if the
	 * update  fails it also logs the error
	 * @param none
	 * @return none
	 */
    public void doDML() {
        try {
            if(!convertedAccounts.isEmpty()) {
                update this.convertedAccounts.values();
            }
            if(!convertedContacts.isEmpty()) {
                system.debug(convertedContacts.isEmpty() + ' are converted contacts empty?');
                system.debug(this.convertedContacts.values());
                update convertedContacts.values();
            }
            if(!convertedOpportunities.isEmpty()) {
                update this.convertedOpportunities.values();
            }
        }
        catch(Exception e) {
            System.debug('exception -- ' + e.getMessage());
            ApexDebugLog.Error errorLog = new ApexDebugLog.Error(
                    'LeadMapper',
                    'doDML',
                    'Lead Override Failed',
                    e
            );  
            ApexDebugLog.createLog(new List<ApexDebugLog.Error>{errorLog});
        }
    }
}