/**
* @author Sales
* @group DAO
* @description Handles all queries related to Lead
*/
public class LeadDAORefactored {
    public static Map<Id, Lead> getLeadConversionDetails(Set<Id> leadIdSet) {
        if (leadIdSet == null || leadIdSet.isEmpty()) {
            return new Map<Id, Lead> ();
        }

        Map<Id, Lead> leads = new Map<Id, Lead>(
                [SELECT
                /* Lead Fields */
                Id,
                FirstName,
                LastName,
                Email,
                IsConverted,
                NumberOfPartnerTypes__c,
                Company_Segment__c,
                ConvertedContactId,
                ConvertedAccountId,
                ConvertedOpportunityId,
                Type__c,
                Partner_Referral__c,
                OwnerId,
                CurrentLeadSource__c,
                Current_Campaign__c,
                Current_Lead_Source_Detail__c,
                PartnerContact__c,
                PartnerSource__c,
                PartnerReferralContactOwner__c,
                MessagesToSales__c,
                PreferredLanguage__c,
                Country,
                PointsOfEntry__c,
                CreatedDate,
                Industry,
                SubIndustry__c,
                Initial_Campaign__c,
                InitialLeadSource__c,
                Initial_Lead_Source_Detail__c,
                InitialPartnerSource__c,
                SalesChannelSingle__c,
                MerchantCoreBusinessModel__c,
                SubBusinessModel__c,
                RecordTypeId,
                RecordType.DeveloperName,
                BehaviorScore__c,
                ReferralAddedDate__c,
                SQL_Date__c,
                SAL_Date__c,
                MQL_Date__c,
                LeadOrigin__c,
                Website,
                Title,

                /* Contact Fields */
                ConvertedContact.BehaviorScore__c,
                ConvertedContact.ConvertedFromLead__c,
                ConvertedContact.ConvertedAutomationExecuted__c,
                ConvertedContact.Referralby__c,
                ConvertedContact.PartnerReferralContact__c,
                ConvertedContact.PartnerReferralContactOwner__c,
                ConvertedContact.MailingCountry,
                ConvertedContact.CurrentLeadSource__c,
                ConvertedContact.Current_Lead_Source_Detail__c,
                ConvertedContact.Preferred_Language__c,
                ConvertedContact.ConvertedLeadSource__c,
                ConvertedContact.Converted_Campaign__c,
                ConvertedContact.Converted_Lead_Source_Detail__c,
                ConvertedContact.ConvertedPartnerSource__c,
                ConvertedContact.ConvertedMessagesToSales__c,
                ConvertedContact.ConvertedPointsOfEntry__c,
                ConvertedContact.LeadCreatedDate__c,
                ConvertedContact.Initial_Campaign__c,
                ConvertedContact.InitialLeadSource__c,
                ConvertedContact.Initial_Lead_Source_Detail__c,
                ConvertedContact.InitialPartnerSource__c,
                ConvertedContact.SQL_Date__c,
                ConvertedContact.SAL_Date__c,
                ConvertedContact.MQL_Date__c,
                ConvertedContact.LeadOrigin__c,
                ConvertedContact.Title,
                ConvertedContact.FirstName,
                ConvertedContact.Email,

                /* Account Fields */
                ConvertedAccount.Referral__c,
                ConvertedAccount.PartnerReferralContact__c,
                ConvertedAccount.PartnerReferralContactOwner__c,
                ConvertedAccount.Account_Status__c,
                ConvertedAccount.AccountType__c,
                ConvertedAccount.ConvertedFromLead__c,
                ConvertedAccount.ConvertedAutomationExecuted__c,
                ConvertedAccount.Industry,
                ConvertedAccount.RecordTypeId,
                ConvertedAccount.SubIndustry__c,
                ConvertedAccount.InitialLeadSource__c,
                ConvertedAccount.InitialLeadSourceDetail__c,
                ConvertedAccount.MerchantCoreBusinessModel__c,
                ConvertedAccount.SubBusinessModel__c,
                ConvertedAccount.Company_Segment__c,
                ConvertedAccount.BillingCountry,
                ConvertedAccount.Website,

                /* Opportunity Fields */
                ConvertedOpportunity.ConvertedFromLead__c,
                ConvertedOpportunity.ConvertedAutomationExecuted__c,
                ConvertedOpportunity.ReferralAddedDate__c,
                ConvertedOpportunity.PartnerReferralContact__c,
                ConvertedOpportunity.PartnerReferralContactOwner__c,
                ConvertedOpportunity.Referral_by_account__c,
                ConvertedOpportunity.Sales_channel__c,

                /* Child Records */
                (SELECT Id, Lead__c, Account__c FROM Handovers__r),
                (SELECT Id, Type__c, SubType__c, Status__c, LastStatusChange__c FROM PartnerTypesLead__r),
                (SELECT Id, Lead__c, Account__c, Opportunity__c, PartnerType__c FROM RelationshipLeads__r)

                FROM Lead
                WHERE Id IN :leadIdSet
                AND IsConverted = true
            ]);
            return leads;
    }

    public static List<LeadConversionMappings__mdt> fetchOverrideMappings() {
        return [SELECT DeveloperName, SourceField__c, TargetField__c, TargetObject__c, TargetObjectNovelty__c, OverrideBehavior__c
                FROM LeadConversionMappings__mdt];
    }


    public static List<PartnerType__c> fetchPartnerTypes(Set<Id> accountIds) {
        return [SELECT Id, UniqueIdentifier__c, Account__c, Type__c, SubType__c, Status__c, LastStatusChange__c
                FROM PartnerType__c
                WHERE Account__c IN :accountIds];

    }

    public static List<Relationship__c> fetchRelationships(Set<Id> convertedIds) {
        String objectName = new List<Id>(convertedIds)[0].getSObjectType().getDescribe().getName();
        List<Relationship__c> relationships = new List<RelationShip__c>();
        if(objectName == 'Account') {
            relationships =  [SELECT Id, UniqueIdentifier__c, Account__c
                    FROM Relationship__c
                    WHERE Account__c IN :convertedIds];
        }
        else if(objectName == 'Opportunity') {
            relationships = [SELECT Id, UniqueIdentifier__c, Account__c
                             FROM Relationship__c
                             WHERE Opportunity__c IN :convertedIds];
        }
        return relationships;
    }
}