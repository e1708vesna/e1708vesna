/**
 * @description Lead DAO class for retrieving lead data from the database.
 * @author BRITE
 */
public class LeadDao {
    /**
     * @description Return all fields and related records which are needed to handle the logic after lead conversion.
     *
     * @param leadIdSet Set of Lead ID's for which Lead details must be returned
     */
    public static List<Lead> getLeadConversionDetails(Set<Id> leadIdSet) {
        if (leadIdSet == null || leadIdSet.isEmpty()) {
            return new List<Lead> ();
        }
        
        return [SELECT
                            Id,
                            FirstName,
                            LastName,
                			isConverted, //Amy
                			NumberOfPartnerTypes__c, //Amy
                			/*ConvertedLead__c,*/
                            ConvertedContactId,
                            ConvertedAccountId,
                            ConvertedOpportunityId,
                            Type__c,
                            Partner_Referral__c,
                            OwnerId,
                            CurrencyIsoCode,
                            CurrentLeadSource__c,
                            Current_Campaign__c,
                            Current_Lead_Source_Detail__c,
                			PartnerContact__c,
                            PartnerSource__c,
                			PartnerReferralContactOwner__c,
                            MessagesToSales__c,
                            MerchantCoreBusinessModel__c,
                            PreferredLanguage__c,
                			Country,
                            PointsOfEntry__c,
                            CreatedDate,
                            Industry,
                            Initial_Campaign__c,
                            InitialLeadSource__c,
                            Initial_Lead_Source_Detail__c,
                            InitialPartnerSource__c,
                            LeadDescription__c,
                            SalesChannelSingle__c,
                            //SDR_Assignment__c,
                            SubIndustry__c,
                            SubBusinessModel__c,
                            RecordTypeId,
                			RecordType.DeveloperName, //Amy
                            BehaviorScore__c, //Amy
                            ReferralAddedDate__c,
                            SQL_Date__c,
                            SAL_Date__c,
                            MQL_Date__c,
                            LeadOrigin__c,

                            ConvertedContact.BehaviorScore__c, //Amy
                            ConvertedContact.ConvertedFromLead__c,
                            ConvertedContact.ConvertedAutomationExecuted__c,
                            ConvertedContact.Referralby__c,
                            ConvertedContact.PartnerReferralContact__c,
                            ConvertedContact.PartnerReferralContactOwner__c,
                            
                
                			ConvertedAccount.Referral__c,
                            ConvertedAccount.PartnerReferralContact__c,
                            ConvertedAccount.PartnerReferralContactOwner__c,
                            ConvertedAccount.Account_Status__c,
                            ConvertedAccount.AccountType__c,
                            ConvertedAccount.ConvertedFromLead__c,
                            ConvertedAccount.ConvertedAutomationExecuted__c,
                            ConvertedAccount.Industry,
                            ConvertedAccount.RecordTypeId,
                            //ConvertedAccount.SDR_Assignment__c,
                            ConvertedAccount.SubIndustry__c,
                            ConvertedAccount.InitialLeadSource__c,
                            ConvertedAccount.InitialLeadSourceDetail__c,
                            ConvertedAccount.MerchantCoreBusinessModel__c,
                            ConvertedAccount.SubBusinessModel__c,
                
                
                            ConvertedOpportunity.ConvertedFromLead__c,
                            ConvertedOpportunity.ConvertedAutomationExecuted__c,
                            
                            ConvertedOpportunity.Opportunity_Primary_Contact__c,
                            ConvertedOpportunity.ReferralAddedDate__c,
                            ConvertedOpportunity.PartnerReferralContact__c,
                            ConvertedOpportunity.PartnerReferralContactOwner__c,
                            ConvertedOpportunity.Referral_by_account__c,
                            ConvertedOpportunity.Referral_by_account__r.OwnerId,
                            (SELECT Id, Lead__c, Account__c FROM Handovers__r),
                            (SELECT Id, Type__c, SubType__c, Status__c, LastStatusChange__c FROM PartnerTypesLead__r),
                            (SELECT Id, Lead__c, Account__c, Opportunity__c, PartnerType__c FROM RelationshipLeads__r)
                
                            FROM Lead
                            WHERE Id IN :leadIdSet
        ];
    }

    /* @Description queries referral leads according to lead status
     * @Param statuses lead statutes by which the records have to be filtered
     * @Return List<Lead>
     */
    public static List<Lead> getReferralLeadsByStatus(Set<String> statuses) {
        return [SELECT Id, PartnerContactEmail__c, PartnerManagerEmail__c, Status, PartnerNotified__c
                FROM Lead
                WHERE Partner_Referral__c != NULL
                AND PartnerContact__c != NULL
                AND Status IN :statuses
                AND PartnerNotified__c = false
               ];
    }
}