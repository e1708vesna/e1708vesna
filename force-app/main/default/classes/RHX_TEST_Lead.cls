/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_Lead
*/
@isTest
public class RHX_TEST_Lead {
    @isTest
    public static void RHX_Testmethod() {
        Id inboundLeadRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('InboundLeadV2').getRecordTypeId();
        Lead testLead = (Lead)TestDataFactory.createSObject('Lead', new Map<String, Object> {
                'RecordTypeId' => inboundLeadRecordType,
                'Status' => 'Open'
        });
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testLead);
        Test.startTest();
        rh2.ParentUtil.UpsertRollupTestRecords(sourceList);
        Test.stopTest();
    }
}