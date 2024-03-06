/**
 * @description Case DAO class for retrieving case data from the database.
 * @author BRITE
 */
public with sharing class CaseDao {

    /**
     * @description Return case details
     *
     * @param caseIdSet Set of case ID's for which details must be returned
     */
    public static List<Case> getDetails(Set<Id> caseIdSet) {
        if (caseIdSet == null || caseIdSet.isEmpty()) {
            return new List<Case> ();
        }
        
        return [SELECT Id, Status
                FROM Case 
                WHERE Id IN :caseIdSet];
    }      
    
    @InvocableMethod(label='Get Case details')
    public static List<Result> getCaseDetails(List<InputValues> InputValueList){

        Set<Id> selectedCaseIdsSet = new Set<Id>(InputValueList[0].ids);
        List<Case> caseList = new List<Case> ();
        if (!selectedCaseIdsSet.isEmpty()) {
            caseList = [SELECT Id, ContactEmail
                        FROM Case
                        WHERE Id IN :selectedCaseIdsSet AND ContactEmail != NULL];
        }
        System.debug(caseList);

        List<Result> resultList = new List<Result> ();
        Result result = new Result ();
        result.outputCaseCollection = caseList;
        resultList.add(result);
  
        return resultList;
        
    }
    
    public class InputValues {
        @InvocableVariable(label='ids')
        public List<Id> ids;
    }

    public class Result {
        @InvocableVariable()
        public Case[] outputCaseCollection;
    } 

}
