/**
* @author Sales
* @group Service
* @description Handles all automations after successful lead conversion
* Current Processes: Updating related Handovers, Creating Partner Types & Relationships
*/
public class LeadPostConversionProcessor {

    private Map<Id, Lead> leadsWithRelatedRecords = new Map<Id, Lead>();
    private Set<Id> convertedAccountIds = new Set<Id>();
    private Set<Id> convertedOpportunityIds = new Set<Id>();
    private List<Handover__c> handoversToUpdate = new List<Handover__c>();
    private List<PartnerType__c> partnerTypesToInsert = new List<PartnerType__c>();
    private List<Relationship__c> relationshipsToInsert = new List<Relationship__c>();

    public LeadPostConversionProcessor(Map<Id, Lead> leadsWithRelatedRecords) {
        this.leadsWithRelatedRecords = leadsWithRelatedRecords;
        extractAccountIds();
        extractOpportunityIds();
    }

    public void extractAccountIds() {
        for(Lead lead : leadsWithRelatedRecords.values()) {
            convertedAccountIds.add(lead.convertedAccountId);
        }
    }

    public void extractOpportunityIds() {
        for(Lead lead : leadsWithRelatedRecords.values()) {
            if(lead.ConvertedOpportunityId != null) {
                convertedOpportunityIds.add(lead.ConvertedOpportunityId);
            }
        }
    }

    public void handleProcessing() {
        updateHandovers();
        consolidatePartnerTypes();
        consolidateRelationships();
        if(!handoversToUpdate.isEmpty() || !partnerTypesToInsert.isEmpty() || !relationshipsToInsert.isEmpty()) {
            doDML();
        }
    }

    /**
	 * Updates related Handovers with the Converted Account Id
	 * @param None
	 * @return None
	 */
    public void updateHandovers() {
        for(Lead lead : leadsWithRelatedRecords.values()) {
            if(lead.Handovers__r != null) {
                for(Handover__c handOver : lead.Handovers__r) {
                    handOver.Account__c = lead.ConvertedAccountId;
                    handoversToUpdate.add(handOver);
                }
            }
        }
    }

    /**
	 * Creates New Partner Type(s) related to Converted Account(s), only if
	 * there are no existing Partner Type(s) (identified using UniqueIdentifier__c)
	 * @param none
	 * @return none
	 */
    public void consolidatePartnerTypes() {
        Set<String> uniqueIdentifiers = consolidateExistingUniqueIdentifiers('PartnerType__c', convertedAccountIds);
        for(Lead lead : leadsWithRelatedRecords.values()) {
            if (lead.PartnerTypesLead__r != null) {
                for(PartnerType__c partnerTypeLead : lead.PartnerTypesLead__r) {
                    String accountExternalId = lead.ConvertedAccountId + ' - ' + partnerTypeLead.Type__c + ' - ' + partnerTypeLead.SubType__c;
                    if(uniqueIdentifiers.contains(accountExternalId)) {
                        //Do nothing if it already exists. Keeping it here to make it easier to iterate on the behaviour.
                    }
                    else {
                        PartnerType__c partnerTypeAccount = partnerTypeLead.clone(false, true, false, false);
                        partnerTypeAccount.Lead__c = null;
                        partnerTypeAccount.Account__c = lead.convertedAccountId;
                        partnerTypeAccount.UniqueIdentifier__c = accountExternalId;
                        partnerTypesToInsert.add(partnerTypeAccount);
                    }
                }
            }
        }
    }

    /**
	 * Creates new Relationship(s) related to Converted Account(s) & Opportunitie(s), only if
	 * there are no existing Relationship(s) (identified using UniqueIdentifier__c)
	 * @param none
	 * @return none
	 */
    public void consolidateRelationships() {
        system.debug('consolidating relationships -- ');
        if(!convertedAccountIds.isEmpty()) {
            Set<String> uniqueIdentifiersAccount = consolidateExistingUniqueIdentifiers('Relationship__c', convertedAccountIds);
            system.debug('account unique identifiers -- ' + uniqueIdentifiersAccount);
            consolidateAccountRelationships(uniqueIdentifiersAccount);
        }
        if(!convertedOpportunityIds.isEmpty()) {
            Set<String> uniqueIdentifiersOpportunity = consolidateExistingUniqueIdentifiers('Relationship__c', convertedOpportunityIds);
            consolidateOpportunityRelationships(uniqueIdentifiersOpportunity);
        }
    }

    public void consolidateAccountRelationships(Set<String> uniqueIdentifiers) {
        for(Lead lead : leadsWithRelatedRecords.values()) {
            system.debug(lead.RelationshipLeads__r  + ' do we have relationships?');
            if (lead.RelationshipLeads__r != null) {
                for(Relationship__c relationshipLead : lead.RelationshipLeads__r) {
                    String accountExternalId = lead.ConvertedAccountId + '-' + relationshipLead.PartnerType__c;
                    if(uniqueIdentifiers.contains(accountExternalId)) {
                        system.debug('nothing found..');
                        //Do nothing if it already exists. Keeping it here to make it easier to iterate on the behaviour.
                    }
                    else {
                        Relationship__c relationshipAccount = relationshipLead.clone(false, true, false, false);
                        relationshipAccount.Lead__c = null;
                        relationshipAccount.Account__c = lead.ConvertedAccountId;
                        relationshipAccount.UniqueIdentifier__c = accountExternalId;
                        relationshipsToInsert.add(relationshipAccount);
                    }
                }
            }
        }
    }

    public void consolidateOpportunityRelationships(Set<String> uniqueIdentifiers) {
        for(Lead lead : leadsWithRelatedRecords.values()) {
            if (lead.RelationshipLeads__r != null) {
                for(Relationship__c relationshipLead : lead.RelationshipLeads__r) {
                    String opportunityExternalId = lead.ConvertedAccountId + '-' + relationshipLead.PartnerType__c + '-' + lead.ConvertedOpportunityId;
                    if(uniqueIdentifiers.contains(opportunityExternalId)) {
                        //Do nothing if it already exists. Keeping it here to make it easier to iterate on the behaviour.
                    }
                    else {
                        Relationship__c relationshipOpportunity = relationshipLead.clone(false, true, false, false);
                        relationshipOpportunity.Lead__c = null;
                        relationshipOpportunity.Account__c = lead.ConvertedAccountId;
                        relationshipOpportunity.Opportunity__c = lead.ConvertedOpportunityId;
                        relationshipOpportunity.UniqueIdentifier__c = opportunityExternalId;
                        relationshipsToInsert.add(relationshipOpportunity);
                    }
                }
            }
        }
    }

    /**
	 * Finds out existing Unique Identifiers related to Partner Types / Relationships
	 * @param objectType : Object for which UniqueIdentifier__c needs to be found
	 * @param convertedIds : can be set of Account / Opportunity id(s)
	 * @return Set<String> : Existing Unique Identifiers for either Partner Types / Relationships
	 */
    public Set<String> consolidateExistingUniqueIdentifiers(String objectType, Set<Id> convertedIds) {
        Set<String> externalIds = new Set<String>();
        List<sObject> recordsInContext = new List<sObject>();
        if(objectType == 'PartnerType__c') {
            recordsInContext = (List<sObject>)LeadDAORefactored.fetchPartnerTypes(convertedIds);
            system.debug(recordsInContext);
        }
        else if(objectType == 'Relationship__c') {
            recordsInContext = (List<sObject>)LeadDAORefactored.fetchRelationships(convertedIds);
        }
        for(sObject record : recordsInContext) {
            String uniqueIdentifier = (String)record.get('UniqueIdentifier__c');
            externalIds.add(uniqueIdentifier);
        }
        return externalIds;
    }

    public void doDML() {
        try {
            if(!handoversToUpdate.isEmpty()) {
                update handoversToUpdate;
            }
            if(!partnerTypesToInsert.isEmpty()) {
                insert partnerTypesToInsert;
            }
            if(!relationshipsToInsert.isEmpty()) {
                system.debug(relationshipsToInsert + ' relationships to insert..');
                insert relationshipsToInsert;
            }
        }
        catch(Exception e) {
            system.debug(e.getmessage());
            ApexDebugLog.Error errorLog = new ApexDebugLog.Error(
                    'LeadPostConversionProcessor',
                    'doDML',
                    'Lead Post Conversion Processing Failed',
                    e
            );
            ApexDebugLog.createLog(new List<ApexDebugLog.Error>{errorLog});
        }
    }
}