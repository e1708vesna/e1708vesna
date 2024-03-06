/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_Partner
*/
@isTest
public class RHX_TEST_Partner {
    @isTest
    public static void RHX_Testmethod() {
        Id partnerAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PartnerAccountv2').getRecordTypeId();
        
        Account testAccount = (Account)TestDataFactory.createSObject('Account', new Map<String, Object> {
                'BillingCountry' => 'Colombia',
                'RecordTypeId' => partnerAccount
                    });
        Opportunity testOpportunity = (Opportunity)TestDataFactory.createSObject('Opportunity');
        
        Partner__c testPartner = (Partner__c)TestDataFactory.createSobject('Partner__c', new Map<String, Object> {
            'Account__c' => testAccount.Id,
            'IsCharity__c' => true,
            'Partner__c' => testAccount.Id
		});
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testPartner);
        Test.startTest();
    	rh2.ParentUtil.UpsertRollupTestRecords(sourceList);
        Test.stopTest();
    }
}