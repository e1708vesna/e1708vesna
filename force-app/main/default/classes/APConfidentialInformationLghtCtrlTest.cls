@isTest
public class APConfidentialInformationLghtCtrlTest {

    
    @isTest private static void testController(){
        //Create Account
        //Create AccountTeamMembers // Own user auto
        //Create AccountPlan
        //Create SoW
        //init component
        
        
        Account acc = TestUtil.createAccount('Test Account', true, true);
        AccountPlan__c ap = TestUtil.createAccountPlan('Test AccountPlan', acc.Id, true);
        ap = [SELECT Id, APConfidentialInformation__c FROM AccountPlan__c WHERE Id =: ap.Id ];
        system.assert(ap.APConfidentialInformation__c != null);
        
        //value;
        //error;
        //count;
        //mvm; //merchant volume /month
        //vmoa;//Volume / month on Adyen
        //confidentialInformationId;
        APConfidentialInformationLghtCtrl.Wrapper w = APConfidentialInformationLghtCtrl.retrieveValues(ap.Id);
        System.assertEquals(null, w.value);
        System.assertEquals(null, w.error);
        System.assertEquals(0, w.count);
        System.assertEquals(null, w.mvm);
        System.assertEquals(null, w.vmoa);
        System.assertEquals(ap.APConfidentialInformation__c, w.confidentialInformationId);
        
        
        ShareOfWallet__C sow = TestUtil.createShareOfWallet(ap.Id, false);
        sow.VolumeMonthOnAdyen__c = 200;
        sow.VolumeMonth__c = null;
        insert sow;
        w = APConfidentialInformationLghtCtrl.retrieveValues(ap.Id);
        System.debug(Json.serializePretty(w));
        System.assertEquals(null, w.value);
        System.assertEquals('VolumeMonth__c is not populated on atleast one Share of Wallet record', w.error);
        System.assertEquals(1, w.count);
        System.assertEquals(null, w.mvm);
        System.assertEquals(null, w.vmoa);
        System.assertEquals(ap.APConfidentialInformation__c, w.confidentialInformationId);
        
        sow.VolumeMonthOnAdyen__c = null;
        sow.VolumeMonth__c = 0;
        update sow;
        
        w = APConfidentialInformationLghtCtrl.retrieveValues(ap.Id);
        System.debug(Json.serializePretty(w));
        System.assertEquals(null, w.value);
        System.assertEquals('VolumeMonth__c is zero on atleast one Share of Wallet record\r\nVolumeMonthOnAdyen__c is not populated on atleast one Share of Wallet record', w.error);
        System.assertEquals(1, w.count);
        System.assertEquals(null, w.mvm);
        System.assertEquals(null, w.vmoa);
        System.assertEquals(ap.APConfidentialInformation__c, w.confidentialInformationId);
        
        sow.VolumeMonthOnAdyen__c = 200;
        sow.VolumeMonth__c = 1000;
        update sow;
        w = APConfidentialInformationLghtCtrl.retrieveValues(ap.Id);
        System.debug(Json.serializePretty(w));
        System.assertEquals(20, w.value);
        System.assertEquals(null, w.error);
        System.assertEquals(1, w.count);
        //System.assertEquals(1000, w.mvm);
        //System.assertEquals(200, w.vmoa);
        System.assertEquals(ap.APConfidentialInformation__c, w.confidentialInformationId);
        
    }
}