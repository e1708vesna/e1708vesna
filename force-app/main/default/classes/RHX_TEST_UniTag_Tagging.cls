/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_UniTag_Tagging
*/
@isTest
public class RHX_TEST_UniTag_Tagging {
    @isTest
	public static void RHX_Testmethod() {
        Account testAccount = (Account)TestDataFactory.createSObject('Account', new Map<String, Object> {
                'BillingCountry' => 'Colombia'
        });
        Opportunity testOpportunity = (Opportunity)TestDataFactory.createSObject('Opportunity', new Map<String, Object>{
                'Pricebook2Id' => Test.getStandardPricebookId(),
                'RegionCountry__c' => 'NL'
        });
        UniTag__Tagging__c testUniTag1 = (UniTag__Tagging__c)TestDataFactory.createSObject('UniTag__Tagging__c');
        UniTag__Tagging__c testUniTag = (UniTag__Tagging__c)TestDataFactory.createSObject('UniTag__Tagging__c', new Map<String, Object> {
                'UniTag__sObject_Type__c' => 'Opportunity',
                'UniTag__Record_Id__c' => testOpportunity.Id
        });
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testUniTag);
        Test.startTest();
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
        Test.stopTest();
    }
}