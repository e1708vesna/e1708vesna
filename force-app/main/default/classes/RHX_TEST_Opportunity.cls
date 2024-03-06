/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_Opportunity
*/
@isTest
public class RHX_TEST_Opportunity {
    @isTest
    public static void RHX_Testmethod() {
        Account testAccount = (Account)TestDataFactory.createSObject('Account', new Map<String, Object> {
                      'BillingCountry' => 'Colombia'
              });
        Opportunity testOpportunity = (Opportunity)TestDataFactory.createSObject('Opportunity', new Map<String, Object>{
                    'AccountId' => testAccount.Id,
                    'RegionCountry__c' => 'NL'
            });
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testOpportunity);
        Test.startTest();
        rh2.ParentUtil.UpsertRollupTestRecords(sourceList);
        Test.stopTest();
    }
}