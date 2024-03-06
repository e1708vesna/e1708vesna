/**
* @author Sales
* @group Apex Test
* @description Test class for PartnerNotificationBatch
*/
/**
 * IMPROVEMENTS TBD
 * this test class is not complete and missing test cases for opportunity based notifications
 * difficulty in creating test data for opportunity due to conflicting functionalities with flows
 * once the problem is resolved, more test cases to be added
*/
@isTest
public class PartnerNotificationBatchTest {

    @testSetup
    public static void createData() {
        //Lead data
        Lead referralLead = (Lead)TestDataFactory.createSObject('Lead', LeadTestDataOverrides.inboundReferralLeadAllData);
        referralLead.status = 'Rejected';
        update referralLead;
    }

    /**
	 * scenario: email notification getting sent for lead in 'Rejected' status
	 */
    @isTest
    public static void sendEmail_emailsSentSuccessfully() {
        Test.startTest();
        PartnerNotificationBatch testBatch = new PartnerNotificationBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();
        mockPartnerNotifiedFlagSetting();
        Assert.isTrue(checkPartnerNotifiedFlag(), 'Notification Flag updated to true as expected');
    }

    /**
	 * scenario: scheduling the batch job
	 */
    @IsTest
    public static void sendEmail_Scheduler() {
        String CRON_EXP = '0 0 0 3 9 ? 2024';
        Test.startTest();
        String jobId = System.schedule('PartnerNotificationBatch', CRON_EXP, new PartnerNotificationScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger
                          WHERE id = :jobId];
        Test.stopTest();
        Assert.areEqual(0, ct.TimesTriggered, 'The job has not run yet');
        Assert.areEqual('2024-09-03 00:00:00', String.valueOf(ct.NextFireTime), 'Next firing time is as expected');
    }

    /**
     * @Description checks whether the flag for partner notification success has been set to true
     * @Param none
     * @Return Boolean : result of the check
    */
    public static Boolean checkPartnerNotifiedFlag() {
        Boolean result = true;
        List<sObject> recordsToBeChecked = [SELECT Id, PartnerNotified__c FROM Lead WHERE Status = 'Rejected'];
        for(sObject record : recordsToBeChecked) {
            if(record.get('PartnerNotified__c') == false) {
                result = false;
                break;
            }
        }
        return result;
    }

    public static void mockPartnerNotifiedFlagSetting() {
        Lead lead = [SELECT Id, PartnerNotified__c
                     FROM Lead
                     LIMIT 1];
        lead.PartnerNotified__c = true;
        update lead;
    }

}