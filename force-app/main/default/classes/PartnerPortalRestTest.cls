@isTest
public class PartnerPortalRestTest {

    private static String endpoint = '/services/apexrest/PartnerPortal/';
    
    @isTest
    private static void testHttpGet(){
        //Create Account
        Account partnerAccount = TestUtil.createAccount('Partner Account', false, true);
        TestUtil.createPartnerType(partnerAccount, true);
        Contact partnerContact = TestUtil.createContact('Partner', 'partner@example.com', partnerAccount.Id, true);
        //Create Leads
        List<Lead> leadList = new List<Lead>();
        For (Integer i = 0; i < 5; i++){
            Lead ld = TestUtil.createLead('Test Lead ' + i, Constants.RT_ID_LEAD_V2, False);
            ld.Partner_Referral__c = partnerAccount.Id;
            ld.PartnerContact__c = partnerContact.Id;
            ld.LastName             = 'Johnsson' + i;
            ld.Company              = 'Johnsson Corp.';
            ld.Title                = 'Manager';
            ld.Type__c              = 'Merchant';
            ld.Email                = 'Johnsson@corp.com.fake';
            ld.Website              = 'https://www.adyen.com';
            ld.MerchantCoreBusinessModel__c = 'Digital';
            ld.Industry             = 'Retail';
            ld.SubIndustry__c       = 'Other';
            ld.Street               = 'Fakestreet 1';
            ld.PostalCode           = '1234AB';
            ld.Country              = 'Netherlands';
            ld.SalesChannelSingle__c= 'Mobile';
            ld.Company_Segment__c   = '25 - 50 million';
            ld.Status               = 'Open';
            ld.ProcessedByLeanData__c = true;
            leadList.add(ld);
        }
        insert leadList;
        //Convert some leads
        
        
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = endpoint + partnerAccount.Id + '/ReferralRecords'; //Request URL
        req.addParameter('statuses', 'In Review,In Sales Pitch');
        
        Date dateFrom = Date.today().addDays(-1); 
        Date dateTill = Date.today().addDays(1); 
        req.addParameter('createdDateFrom', dateFrom.day() + '/' + dateFrom.month() + '/' + dateFrom.year());
        req.addParameter('createdDateTill', dateTill.day() + '/' + dateTill.month() + '/' + dateTill.year());
        req.addParameter('numberOfRecords', '4');
        req.addParameter('offset', '0');
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        For (Integer i = 0; i < 1; i++){
            runDatabaseLeadConvert(leadList[i].Id, null, null, true);
        }
        Test.stopTest();
        PartnerPortalRest.getRequest();
        System.debug('httpGet');
        System.debug(res.responseBody.toString());
        System.assertEquals(200, res.statusCode, 'Expected status code 200 (OK)');
        
        Map<String, Object> responseMap = (Map<String, Object>) Json.deserializeUntyped(res.responseBody.toString());
        List<Object> records = (List<Object>) responseMap.get('records');
        
        System.assertEquals(4, responseMap.get('totalSize'), 'Expected 4 records to be returned (in metadata)');
        System.assertEquals(4, records.size(), 'Expected 4 records to be returned (in list)');
        System.assertEquals(5, responseMap.get('totalRecords'), 'Expected 5 records in the database');
        
    }
    
    
    @isTest
    private static void testHttpGetDateParameters(){
        //Create Account
        Account partnerAccount = TestUtil.createAccount('Partner Account', false, true);
        TestUtil.createPartnerType(partnerAccount, true);
        Contact partnerContact = TestUtil.createContact('Partner', 'partner@example.com', partnerAccount.Id, true);
        //Create Leads
        List<Lead> leadList = new List<Lead>();
        For (Integer i = 0; i < 3; i++){
            Lead ld = TestUtil.createLead('Test Lead ' + i, Constants.RT_ID_LEAD_V2, False);
            ld.Partner_Referral__c = partnerAccount.Id;
            ld.PartnerContact__c = partnerContact.Id;
            ld.LastName             = 'Johnsson' + i;
            ld.Company              = 'Johnsson Corp.';
            ld.Title                = 'Manager';
            ld.Type__c              = 'Merchant';
            ld.Email                = 'Johnsson@corp.com.fake';
            ld.Website              = 'https://www.adyen.com';
            ld.Industry             = 'Retail';
            ld.SubIndustry__c       = 'Other';
            ld.Street               = 'Fakestreet 1';
            ld.PostalCode           = '1234AB';
            ld.Country              = 'Netherlands';
            ld.MerchantCoreBusinessModel__c = 'Digital';
            ld.SalesChannelSingle__c= 'Mobile';
            ld.Company_Segment__c   = '25 - 50 million';
            ld.Status               = 'Open';
            ld.ProcessedByLeanData__c = true;
            leadList.add(ld);
        }
        insert leadList;
        //Convert some leads
        String date1 = '"2000-01-02T11:27:54.14Z"';
        String date2 = '"2000-01-03T11:27:54.14Z"';
        String date3 = '"2000-01-04T11:27:54.14Z"';
        
        Test.setCreatedDate(leadList[0].Id, (DateTime)json.deserialize(date1, datetime.class));
        Test.setCreatedDate(leadList[1].Id, (DateTime)json.deserialize(date2, datetime.class));
        Test.setCreatedDate(leadList[2].Id, (DateTime)json.deserialize(date3, datetime.class));
        
        update leadList;
        leadList = [Select Id, CreatedDate From Lead ORder BY CreatedDate ASC];
        System.debug('CreatedDate: ' + leadList[2].CreatedDate);
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = endpoint + partnerAccount.Id + '/ReferralRecords'; //Request URL
        req.addParameter('statuses', 'In Review');
        
        req.addParameter('createdDateFrom', '02/01/2000');
        req.addParameter('createdDateTill', '04/01/2000');
        req.addParameter('numberOfRecords', '4');
        req.addParameter('offset', '0');
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Test.stopTest();
        PartnerPortalRest.getRequest();
        System.debug('httpGet');
        System.debug(res.responseBody.toString());
        System.assertEquals(200, res.statusCode, 'Expected status code 200 (OK)');
        
        Map<String, Object> responseMap = (Map<String, Object>) Json.deserializeUntyped(res.responseBody.toString());
        List<Object> records = (List<Object>) responseMap.get('records');
        System.debug(JSON.serializePretty(records, true));
        System.assertEquals(3, responseMap.get('totalSize'), 'Expected 3 records to be returned (in metadata)');
        System.assertEquals(3, records.size(), 'Expected 3 records to be returned (in list)');
        System.assertEquals(3, responseMap.get('totalRecords'), 'Expected 5 records in the database');
        
    }
    
    @isTest
    private static void testHttpGetInvalidInput(){
        String AccountId = '0010000';
        
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = endpoint + accountId + '/ReferralRecords'; //Request URL
        req.addParameter('statuses', 'NonExisting,NonExisting2');
        req.addParameter('createdDateFrom', 'InvalidDate');
        req.addParameter('createdDateTill', 'InvalidDate');
        req.addParameter('numberOfRecords', 'NonInteger');
        req.addParameter('offset', 'NonInteger');
        
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PartnerPortalRest.getRequest();
        Test.stopTest();
        System.debug(res.responseBody.toString());
    }
    
    /**
     * Convert the given Lead to initiate the AfterUpdate of the Lead Trigger
     *
     * @param leadId
     *
     * @return
     */
    private static Database.LeadConvertResult runDatabaseLeadConvert(Id leadId, Id accountId, Id opportunityId, boolean createOpportunity)
    {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setConvertedStatus('Converted');
        if (accountId != null) {
            lc.setAccountId(accountId);
        }
        if (opportunityId != null) {
            lc.setOpportunityId(opportunityId);
        }
        lc.donotcreateopportunity = createOpportunity ? false : true;
        Database.LeadConvertResult lcr = Database.convertLead(lc); // initiate AfterUpdate of the Lead Trigger

        return lcr;
    }
    
}