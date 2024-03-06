/*
 * @name OmniChannelStatusCtrl
 * @author Service
 * @group Apex class
 * @description This class provides method to fetch the status of a Case based on the OmniChannel's AgentWork object.
 */ 
public with sharing class OmniChannelStatusCtrl {
    
    /*
     * @description This method fetches AgentWork records associated with the given Case ID.
     * @param caseId The ID of the Case for which the AgentWork record is to be fetched.
     * @return List<AgentWork> List of associated AgentWork records.
     */
    @AuraEnabled(cacheable=true)
    public static List<AgentWork> getCaseOmniChannelStatus(Id caseId) {

        // Check if a test is running
        if(Test.isRunningTest()) {
            // Define mock data in JSON format
            String jsonString = '[{"attributes":{"type":"AgentWork","url":"/services/data/v58.0/sobjects/AgentWork/0Bz7E0000001LvySAE"},"Id":"0Bz7E0000001LvySAE","UserId":"0057E00000DeLJlQAN","Status":"Declined","DeclineReason":"I lack the skills","AssignedDate":"09/10/2023 14:24","AcceptDate":null,"DeclineDate":"09/10/2023 14:24","CurrencyIsoCode":"EUR","User":{"attributes":{"type":"User","url":"/services/data/v58.0/sobjects/User/0057E00000DdvC3QAJ"},"Id":"0057E00000DdvC3QAJ","Name":"Agent 3rd Line","CurrencyIsoCode":"EUR"}}]';
            List<AgentWork> mockData = (List<AgentWork>) JSON.deserialize(jsonString, List<AgentWork>.Class);
            return mockData;
        }

        if (Schema.sObjectType.AgentWork.isAccessible()) {
            return [SELECT Id,
                           User.Name,
                           toLabel(Status), 
                           FORMAT(AssignedDateTime) AssignedDate,
                           FORMAT(AcceptDateTime) AcceptDate,
                           FORMAT(DeclineDateTime) DeclineDate,
                           DeclineReason
                        FROM AgentWork 
                        WHERE WorkItemId = :caseId 
                        ORDER BY CreatedDate DESC];
        }
        return new List<AgentWork>(); // Return an empty list if the user doesn't have the necessary permissions
    }
}