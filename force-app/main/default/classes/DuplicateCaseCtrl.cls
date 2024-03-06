/*
 * @name DuplicateCaseCtrl
 * @author Service
 * @group Apex Class
 * @description This class contains method that retrieves the duplicate Cases based on the Subject.
 */

 public with sharing class DuplicateCaseCtrl {

    /*
     * @description Wrapper class to hold both the count of duplicate cases and the list of duplicate cases.
     */
    public class DuplicateCaseWrapper {
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public List<Case> duplicateCases;
    }

    /*
     * @description Determines if the SuppliedEmail of a Case record matches the current Case's email fields.
     * @param c The Case to compare.
     * @param currentCase The current Case record being checked.
     * @return Boolean Indicates if the SuppliedEmail matches.
     */
    private static Boolean isMatchingSuppliedEmail(Case c, Case currentCase) {
        return String.isNotBlank(c.SuppliedEmail) && (c.SuppliedEmail == currentCase.SuppliedEmail || c.SuppliedEmail == currentCase.ContactEmail);
    }
    
    /*
     * @description Determines if the ContactEmail of a Case record matches the current Case's email fields.
     * @param c The Case to compare.
     * @param currentCase The current Case record being checked.
     * @return Boolean Indicates if the ContactEmail matches.
     */
    private static Boolean isMatchingContactEmail(Case c, Case currentCase) {
        return String.isNotBlank(c.ContactEmail) && (c.ContactEmail == currentCase.ContactEmail || c.ContactEmail == currentCase.SuppliedEmail);
    }

    /*
     * @description Determines if a Case record is a duplicate based on the subject and email fields.
     * @param c The Case to compare.
     * @param currentCase The current Case record being checked.
     * @return Boolean Indicates if the Case record is a duplicate.
     */
    private static Boolean isDuplicate(Case c, Case currentCase) {
        if ((c.Subject == currentCase.Subject && (isMatchingSuppliedEmail(c, currentCase) || isMatchingContactEmail(c, currentCase)))){
            return true;
        }
        return false;
    }

    /*
     * @description Retrieves the duplicate Cases based on matching Subject and Email fields.
     * @param currentCaseId The ID of the current Case record being checked.
     * @return DuplicateCaseWrapper Contains the count and list of duplicate cases.
     */
    @AuraEnabled(cacheable=true)
    public static DuplicateCaseWrapper getDuplicateCases(String currentCaseId) {

        DuplicateCaseWrapper result = new DuplicateCaseWrapper();

        if(!Schema.sObjectType.Case.isAccessible()) {
            throw new SecurityException('You do not have permission to read Case records.');
        }
        else {
            Case currentCase = [
                SELECT Id, SuppliedEmail, ContactEmail, Subject 
                FROM Case 
                WHERE Id = :currentCaseId
                ];

            List<List<sObject>> searchResults = [
                FIND :currentCase.Subject IN NAME FIELDS 
                RETURNING Case(Id, CaseNumber, AccountId, Account.Name, ContactId, Contact.Name, Subject, SuppliedEmail, ContactEmail, Status, OwnerId, Owner.Name, CreatedDate 
                    WHERE Id != :currentCaseId AND IsClosed = false
                    ORDER BY CreatedDate DESC)
                ];

            List<Case> foundCases = (List<Case>) searchResults[0];
            result.duplicateCases = new List<Case>();

            for (Case c : foundCases) {
                if (isDuplicate(c, currentCase)) {
                    result.duplicateCases.add(c);
                }
            }
        }
        
        result.count = result.duplicateCases.size();
        return result;
    }
}