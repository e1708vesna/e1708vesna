/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_PartnerType
*/
@isTest
public class RHX_TEST_PartnerType {
    @isTest
	public static void RHX_Testmethod() {
        Id businessAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
        
        Account testAccount = (Account)TestDataFactory.createSObject('Account', new Map<String, Object> {
                'BillingCountry' => 'Colombia',
                'RecordTypeId' => businessAccount
        });

        PartnerType__c testPartnerType = (PartnerType__c)TestDataFactory.createSObject('PartnerType__c', new Map<String, Object> {
                'Type__c' => 'Value Added Service (VAS)',
                'SubType__c' => 'Order Management Systems (OMS)',
                'Account__c' => testAccount.Id
        });
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testPartnerType);
        Test.startTest();
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
        Test.stopTest();
    }
}