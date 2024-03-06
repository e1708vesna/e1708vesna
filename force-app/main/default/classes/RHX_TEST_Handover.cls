/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_Handover
*/
@isTest
public class RHX_TEST_Handover {
	@isTest
	public static void RHX_Testmethod() {

        Handover__c testHandover = (Handover__c)TestDataFactory.createSObject('Handover__c', new Map<String, Object> {
                'Desired_AM_Region__c' => 'Berlin',
                'Umbrella_Region__c' => 'Germany',
                'AMRejectionReason__c' => 'Need More Information',
                'AMPoolRejectionReason__c' => 'Need More Information'
        });


        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testHandover);
        Test.startTest();
        rh2.ParentUtil.UpsertRollupTestRecords(sourceList);
        Test.stopTest();
    }
}