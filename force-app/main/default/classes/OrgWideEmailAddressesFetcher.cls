/*
 * @name OrgWideEmailAddressesFetcher
 * @author Service
 * @group Invocable Apex
 * @description This class contains the invocable method to retrieve Org-Wide email addresses and match them against Email to Case addresses.
 */
public with sharing class OrgWideEmailAddressesFetcher {

    // Inner class to represent the response structure.
    // This will contain the list of Org-Wide Email Addresses that match with Email to Case addresses.
    public class OrgWideEmailCollection {
        @InvocableVariable
        public OrgWideEmailWrapperApexDefined[] records; // Matched Org-Wide Email Addresses
        @InvocableVariable
        public Boolean isPreferredEmailValid; // Indicates if the preferred email is valid and matched
    }
    
    /*
     * @name fetchOrgWideEmailAddresses
     * @description Fetches the Org-Wide Email Addresses and match them against Email to Case addresses accessible for the current User's Profile and checks if the preferred email exists in the list.
     * @param preferredEmails List of email strings that represent the User's Preferred Email.
     * @return List<OrgWideEmailCollection> - List containing a collection of wrapped Org-Wide Email Addresses.
     */
    @InvocableMethod(label='Fetch Org Wide Email Addresses' description='Fetches org-wide email addresses and checks against preferred email')
    public static List<OrgWideEmailCollection> fetchOrgWideEmailAddresses(List<String> preferredEmails) {
        // Extract the preferred email from the list if available.
        String preferredEmail = getPreferredEmail(preferredEmails);
        // Retrieve the Email to Case addresses
        Set<String> emailToCaseAddresses = getEmailToCaseAddresses();

        // Initialize the response collection.
        OrgWideEmailCollection collection = new OrgWideEmailCollection();
        collection.records = new List<OrgWideEmailWrapperApexDefined>();
        collection.isPreferredEmailValid = false;

        // Populate the collection with matched Org-Wide Email Addresses
        populateOrgWideAddresses(collection, emailToCaseAddresses, preferredEmail);

        return new List<OrgWideEmailCollection> {collection};
    }

    /*
     * Extracts the Preferred Email from the input list, typically the first item.
     */
    private static String getPreferredEmail(List<String> preferredEmails) {
        // Return the first email if the list is not empty; otherwise, return null.
        return (preferredEmails != null && !preferredEmails.isEmpty()) ? preferredEmails[0] : null;
    }

    /*
     * Fetches the Email to Case addresses.
     */
    private static Set<String> getEmailToCaseAddresses() {
        Set<String> emailToCaseAddresses = new Set<String> ();

        // Perform SOQL query to retrieve Email to Case addresses.
        for (EmailServicesAddress esa : [SELECT Id, LocalPart 
                                            FROM EmailServicesAddress 
                                            WHERE Function.FunctionName = 'EmailToCase' 
                                            ORDER BY DeveloperName]) {
            // Use a composite key combining LocalPart and '@adyen.com' as unique identifier.
            emailToCaseAddresses.add(esa.LocalPart + '@adyen.com');
        }

        return emailToCaseAddresses;
    }

    /*
     * Populates the response collection with Org-Wide Email Addresses that match Email to Case addresses.
     */
    private static void populateOrgWideAddresses(OrgWideEmailCollection collection, Set<String> emailToCaseAddresses, String preferredEmail) {
        // Query for the Org-Wide Email Addresses associated with the current User's Profile.
        List<OrgEmailAddressSecurity> orgEmailSecurityRecords = [
            SELECT OrgWideEmailAddressId, OrgWideEmailAddress.Address, OrgWideEmailAddress.DisplayName 
            FROM OrgEmailAddressSecurity 
            WHERE ParentId = :UserInfo.getProfileId()];
        
        // Iterate over the fetched Org-Wide Email Addresses and match them with Email to Case addresses.
        for (OrgEmailAddressSecurity ows : orgEmailSecurityRecords) {
            // Check if the current Org-Wide Email Address is in the Email to Case map.
            if (emailToCaseAddresses.contains(ows.OrgWideEmailAddress.Address)) {
                // Create a wrapper object if there's a match.
                OrgWideEmailWrapperApexDefined wrapper = new OrgWideEmailWrapperApexDefined();
                wrapper.emailId = ows.OrgWideEmailAddressId;
                wrapper.email = ows.OrgWideEmailAddress.Address;
                wrapper.displayName = ows.OrgWideEmailAddress.DisplayName;

                // Add the wrapped address to the collection.
                collection.records.add(wrapper);

                // Check if the preferred email matches the current email and set the flag if it does.
                if (ows.OrgWideEmailAddress.Address.equalsIgnoreCase(preferredEmail)) {
                    collection.isPreferredEmailValid = true;
                }
            }
        }
    }
}