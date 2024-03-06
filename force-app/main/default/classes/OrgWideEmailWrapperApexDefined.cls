/*
 * @name OrgWideEmailWrapperApexDefined
 * @description A wrapper class used to represent Org-Wide Email Address records with specific fields
 * meant for use with LWC.
 */
public class OrgWideEmailWrapperApexDefined {

    @AuraEnabled 
    // Unique identifier for the Org-Wide Email Address record.
    public Id emailId;

    @AuraEnabled 
    // The actual Email Address value of the Org-Wide Email Address record.
    public String email;

    @AuraEnabled 
    // Display name associated with the Org-Wide Email Address.
    public String displayName;
}