/**
* @author Sales
* @group Service
* @description Handles all validations for lead trigger
*/
public class LeadValidator {

    private Map<Id, Lead> leadsWithRelatedRecords = new Map<Id, Lead>();
    private Map<Id, Lead> newLeads = new Map<Id, Lead>();
    private static Map<Id, Lead> partnerLeads = new Map<Id, Lead>();

    public LeadValidator(Map<Id, Lead> leadsWithRelatedRecords, Map<Id, Lead> newLeads) {
        this.leadsWithRelatedRecords = leadsWithRelatedRecords;
        this.newLeads = newLeads;
        filterPartnerLeads();
    }

    public void handleValidation() {
        if(!FeatureManagement.checkPermission('Bypass_Validation')) {
            validateRequiredFields(leadsWithRelatedRecords);
            if(!partnerLeads.isEmpty()) {
                validatePartnerLeadOpportunities(partnerLeads.values());
                validatePartnerType(partnerLeads);
            }
        }
    }

    /**
	 * a partner lead cannot be converted
	 * to a new /existing opportunity
	 * @param List<Lead> - leads that are getting converted
	 * @return none
	 */
    public void validatePartnerLeadOpportunities(List<Lead> partnerLeads) {
        for(Lead lead : partnerLeads) {
            if(lead.ConvertedOpportunityId != null) {
                newLeads.get(lead.Id).addError(System.Label.PartnerLeadValidationNoOpportunityAllowed);
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
    public void validatePartnerType(Map<Id, Lead> partnerLeads) {
        List<Id> flaggedLeads = new List<Id>();
        for(Lead lead : partnerLeads.values()) {
            if(lead.NumberOfPartnerTypes__c == 0 || lead.NumberOfPartnerTypes__c == null) {
                    flaggedLeads.add(lead.Id);
                }
                else {
                    if(checkAssociatedPartnerTypes(lead.PartnerTypesLead__r) == false) {
                        flaggedLeads.add(lead.Id);
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
	 * validates if required fields on lead are blank
	 * and throws a user friendly error message
	 * @param newLeads - leads getting converted
	 * @param convertedAccounts - accounts to which leads are converted
	 * @param convertedContacts - contacts to which leads are converted
	 * @param convertedOpportunities - opportunities to which leads are converted
	 * @return none
	 */
    public void validateRequiredFields(Map<Id, Lead> leads) {
        Map<Id, String> leadToError = new Map<Id, String>();
        List<Lead> leadsToBeValidated = checkExistingRecords(leads.values());
        for(Lead lead : leadsToBeValidated) {
            List<String> blankFields = new List<String>();
            if(String.isBlank(lead.Title)) {
                blankFields.add('Title');
            }
            if(String.isBlank(lead.Email)) {
                blankFields.add('Email');
            }
            if(String.isBlank(lead.Website)) {
                blankFields.add('Website');
            }
            if(String.isBlank(lead.MerchantCoreBusinessModel__c)) {
                blankFields.add('Merchant Core Business Model & Sub Business Model');
            }
            if(!String.isBlank(lead.MerchantCoreBusinessModel__c) && String.isBlank(lead.SubBusinessModel__c) && lead.MerchantCoreBusinessModel__c == 'Platforms') {
                blankFields.add('Sub Business Model');
            }
            if(String.isBlank(lead.Industry)) {
                blankFields.add('Industry & Sub Industry');
            }
            if(!String.isBlank(lead.Industry) && String.isBlank(lead.SubIndustry__c)) {
                blankFields.add('Sub Industry');
            }
            if(lead.RecordTypeId != constants.RT_ID_LEAD_PARTNER) {
                if(String.isBlank(lead.Company_Segment__c)) {
                    blankFields.add('Addressable Company Segment');
                }
                if(String.isBlank(lead.SalesChannelSingle__c)) {
                    blankFields.add('Sales Channel');
                }
            }
            if(!blankFields.isEmpty()) {
                leadToError.put(lead.Id, generateErrorMessage(blankFields));
            }
        }

        if(!leadToError.isEmpty()) {
            for(Id flaggedLead : leadToError.keySet()) {
                newLeads.get(flaggedLead).addError(leadToError.get(flaggedLead));
            }
        }
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

    public void filterPartnerLeads() {
        for(Lead lead : leadsWithRelatedRecords.values()) {
            if(lead.recordTypeId == Constants.RT_ID_LEAD_PARTNER) {
                partnerLeads.put(lead.Id, lead);
            }
        }
    }


    /**
	 * checks if any of the partner types has either
	 * type or sub-type not populated
	 * @param List<PartnerType__c> - partner types to be checked
	 * @return boolean - true if both populated, false otherwise
	 */
    public boolean checkAssociatedPartnerTypes(List<PartnerType__c> partnerTypes) {
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
	 * before validating require fields on lead
	 * we try to populate some of the empty values
	 * from converted account/contact/opportunity
	 * @param newLeads - leads getting converted
	 * @param convertedAccounts - accounts to which leads are converted
	 * @param convertedContacts - contacts to which leads are converted
	 * @param convertedOpportunities - opportunities to which leads are converted
	 * @return List<Lead> - processed leads
	 */
    public static List<Lead> checkExistingRecords(List<Lead> newLeads) {
        for(Lead lead : newLeads) {
            Account account = lead.ConvertedAccount;
            Contact contact = lead.ConvertedContact;
            Opportunity opportunity = lead.ConvertedOpportunity;
            if(account != null && account.ConvertedAutomationExecuted__c == true) {
                lead.Company_Segment__c = lead.Company_Segment__c != null ? lead.Company_Segment__c : account.Company_Segment__c;
                lead.Country = lead.Country != null ? lead.Country : account.BillingCountry;
                lead.Website = lead.Website != null ? lead.Website : account.Website;
                lead.MerchantCoreBusinessModel__c = lead.MerchantCoreBusinessModel__c != null ? lead.MerchantCoreBusinessModel__c : account.MerchantCoreBusinessModel__c;
                lead.SubBusinessModel__c = lead.SubBusinessModel__c != null ? lead.SubBusinessModel__c : account.SubBusinessModel__c;
                lead.Industry = lead.Industry != null ? lead.Industry : account.Industry;
                lead.SubIndustry__c = lead.SubIndustry__c != null ? lead.SubIndustry__c : account.SubIndustry__c;
            }

            if(contact != null && contact.ConvertedAutomationExecuted__c == true) {
                lead.FirstName = lead.FirstName == null ? contact.FirstName : lead.FirstName;
                lead.Email = lead.Email != null ? lead.Email : contact.Email;
                lead.Title = lead.Title != null ? lead.Title : contact.Title;
            }

            if(opportunity != null && opportunity.ConvertedAutomationExecuted__c == true) {
                lead.SalesChannelSingle__c = lead.SalesChannelSingle__c != null? lead.SalesChannelSingle__c : opportunity.Sales_channel__c;
            }
        }
        return newLeads;
    }

    /**
	 * dynamically generates error message for required fields validation
	 * @param List<String> required fields which are blank
	 * @return String - error message
	 */
    public static String generateErrorMessage(List<String> blankFields) {
        String errorMessage = System.Label.LeadConversionRequiredFields + ' ' + String.join(blankFields, ', ');
        return errorMessage;
    }
}