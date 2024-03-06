/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_ExceptionRequestMember
*/
@isTest
public class RHX_TEST_ExceptionRequestMember {
       @isTest
       public static void RHX_Testmethod() {
              Account testAccount = (Account)TestDataFactory.createSObject('Account', new Map<String, Object> {
                      'BillingCountry' => 'Colombia'
              });
           
              ExceptionRequest__c testExceptionRequest = (ExceptionRequest__c)TestDataFactory.createSobject('ExceptionRequest__c', new Map<String,Object>{
                  'TypeOfException__c' => 'Cost Price Adjustment',
                  'Context__c' => 'Test Context',
                  'Account__c' => testAccount.Id,
                  'ExpectedMonthlyGrossMargin__c' => 500
              });
              
              ExceptionRequestMember__c testExceptionRequestMember = (ExceptionRequestMember__c)TestDataFactory.createSobject('ExceptionRequestMember__c', new Map<String,Object>{
                      'ExceptionRequest__c' => testExceptionRequest.Id
              });
           
           	  List<sObject> sourceList = new List<sObject>();
              sourceList.add(testExceptionRequestMember);
              Test.startTest();
              rh2.ParentUtil.UpsertRollupTestRecords(sourceList);
              Test.stopTest();
       }
}