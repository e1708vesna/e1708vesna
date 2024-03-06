global with sharing class FetchOrgWideEmailAddresses {

    @InvocableMethod(label='Get Org-Wide Email Addresses' description='Fetches Org-Wide Email Addresses for use in Flows.')
    global static List<List<OrgWideEmailWrapper>> getOrgWideEmailAddresses() {
        List<OrgWideEmailAddress> orgEmails = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress];
        List<OrgWideEmailWrapper> wrappers = new List<OrgWideEmailWrapper>();
        for (OrgWideEmailAddress email : orgEmails) {
            wrappers.add(new OrgWideEmailWrapper(email));
        }
        System.debug('Wrappers ' + wrappers);
        return new List<List<OrgWideEmailWrapper>> {wrappers};
    }

    global class OrgWideEmailWrapper {
        @InvocableVariable(label='ID')
        public Id emailId;

        @InvocableVariable(label='Email Address')
        public String emailAddr;

        @InvocableVariable(label='Display Name')
        public String displayName;

        public OrgWideEmailWrapper(OrgWideEmailAddress email) {
            System.debug('email ' + email);
            this.emailId = email.Id;
            this.emailAddr = email.Address;
            this.displayName = email.DisplayName;
        }
    }
}