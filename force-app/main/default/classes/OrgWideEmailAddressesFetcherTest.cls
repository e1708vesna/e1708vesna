@isTest
public class OrgWideEmailAddressesFetcherTest {

    // Test method to verify that when the preferred email does not match any Org-Wide Email Addresses,
    // the isPreferredEmailValid remains false.
    @isTest
    static void fetchOrgWideEmailAddressesTestWithNonMatchingPreferredEmail() {
        // Set up test data with a preferred email that is not in the mock 'Email to Case' map.
        List<String> preferredEmails = new List<String>{'nonmatching@example.com'};

        Test.startTest();
        // Invoke the method to test.
        List<OrgWideEmailAddressesFetcher.OrgWideEmailCollection> results = OrgWideEmailAddressesFetcher.fetchOrgWideEmailAddresses(preferredEmails);
        Test.stopTest();

        // Assert that the result set is as expected: one collection with no records and false isPreferredEmailValid.
        Assert.areEqual(1, results.size(), 'There should be one result set in the list.');
        OrgWideEmailAddressesFetcher.OrgWideEmailCollection resultCollection = results[0];
        Assert.isFalse(resultCollection.isPreferredEmailValid, 'The preferred email flag should be false for a non-matching email.');
    }

    // This test method verifies that when the preferred email matches an Org-Wide Email Address and an 'Email to Case' address in the test context,
    // the isPreferredEmailValid flag is set to true.
    @isTest
    static void fetchOrgWideEmailAddressesTestAsSupportUser() {
        String BASIC_SERVICE_PROFILE = 'Basic Service';

        // retrieve email-to-case addresses
        List<EmailServicesAddress> emailToCaseAddresses = [
            SELECT LocalPart
            FROM EmailServicesAddress
            WHERE Function.FunctionName = 'EmailToCase'
        ];
        Set<String> emailToCaseFullAddresses = new Set<String> ();
        for (EmailServicesAddress esa : emailToCaseAddresses) {
            emailToCaseFullAddresses.add(esa.LocalPart + '@adyen.com');
        }

        // retrieve org-wide email addresses for the user's profile
        List<OrgEmailAddressSecurity> orgWideAddresses = [
            SELECT OrgWideEmailAddress.Address 
            FROM OrgEmailAddressSecurity 
            WHERE Parent.Name = :BASIC_SERVICE_PROFILE AND OrgWideEmailAddress.Address IN :emailToCaseFullAddresses
        ];

        if (orgWideAddresses.size() > 0) {
            User agent = ServicesTestUtil.createUser('Basic Service', 'ServiceGenericUser', false);
            agent.LastName = 'skillsAgent';
            agent.PreferredDefaultEmail__c = orgWideAddresses[0].OrgWideEmailAddress.Address;
            insert agent;
        
            ServicesTestUtil.assignPermissionsToUser(
                new List<User>{agent},
                new Set<String> {ServicesTestUtil.SERVICE_AGENT_PERMISSION_SET_GROUP_NAME},
                new Set<String> (),
                true);
    
            List<String> preferredEmails = new List<String>{orgWideAddresses[0].OrgWideEmailAddress.Address};
    
            System.runAs(agent) {
                Test.startTest();
                // Invoke the method to test.
                List<OrgWideEmailAddressesFetcher.OrgWideEmailCollection> results = OrgWideEmailAddressesFetcher.fetchOrgWideEmailAddresses(preferredEmails);
                Test.stopTest();
    
                // Assertions to ensure the test method behaves as expected.
                Assert.areEqual(1, results.size(), 'There should be one result set in the list.');
                OrgWideEmailAddressesFetcher.OrgWideEmailCollection resultCollection = results[0];
                Assert.isTrue(resultCollection.isPreferredEmailValid, 'The preferred email flag should be true for a matching email.');
                Assert.areEqual(orgWideAddresses.size(), resultCollection.records.size(), 'Number of addresses that will be shown to the user.');
            }
        }
    }
}