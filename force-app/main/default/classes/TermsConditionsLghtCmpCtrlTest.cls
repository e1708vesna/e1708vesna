/**
 * @description   : TermsConditionsLghtCmpCtrl test class
 * @author (s)    : BRITE
 */
@isTest
public with sharing class TermsConditionsLghtCmpCtrlTest {
    @isTest
    public static void testFunctions() {
    	//Create custom object record to share files on the Community
    	String developerName = 'GENERAL';
    	CommunityFileMap__c cfm = new CommunityFileMap__c (DeveloperName__c = developerName);
    	insert cfm;   	
    	
		String title = 'TermsAndConditions_test.dat';
		Blob data = EncodingUtil.base64Decode('UEsDBBQACAgIACJkfE0AAAAAAAAAAAAAAAAIAAAAdGVzdC50eHSNkl1rgzAUhu/9FQd2Yy+U+NFiC70QdTDoaqmlvRxZczZkmkiSdvjvl7oxXFFZrvOc9+R583BCBltxBT8Cz18FwYqEkGTFAXziRZblfh9wILkoLWqUwGmNLyMH1rDN0ngHafacO0meZr0Jj0LWVMMVpSoFH5/g9ZhNeUauEGrBsBpDRxh+qV9RTuT4QTgf4H5SwH5HjpJqZLPRrJ0U7HLWk1JuTJzlxQA26cJggRv2qD1WSM2CzOzk6HI4sXuY43lOV2Af5vhJK2hQloJByc2YVg1Ekh5UtEpj/YEtNFJcSzao00BPTcyYRKWGWFvNwD6LuqagsKF/jN62Xfqut4hc4np9s0dalazU7d3CYJP1m5BozM06fD7BKE2l7nTdCVr8CooIWYYBMXB8WhLiQ5yY719Akm8P+3xjijvF+6wP+1aKDXKGXP/UGHN2nCgS1tb/LvZTbh+mq/8LUEsHCGyscKBaAQAAogMAAFBLAQIUABQACAgIACJkfE1srHCgWgEAAKIDAAAIAAAAAAAAAAAAAAAAAAAAAAB0ZXN0LnR4dFBLBQYAAAAAAQABADYAAACQAQAAAAA='); 
		ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        cv.VersionData = data;
        cv.Title = title;
        cv.PathOnClient = title;
        cv.Community__c = true;
        insert cv;	
        
        Test.startTest();
        
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        uac.email__c = 'test@test.test';

		system.assertEquals(false, uac.AcceptTermsAndConditions__c, 'Case1: Upgrade Assurance Contract not accepted yet!');

		String contentDocumentId = TermsConditionsLghtCmpCtrl.getApexTermsAndConditionsFileId (title);   
		system.assert((contentDocumentId.length() > 14), 'Case2: Id need to be returned');

        //First Approve
        uac.Approved__c = true;
        update uac;

        TermsConditionsLghtCmpCtrl.acceptTermAndConditions(uac);
        List<UpgradeAssuranceContract__c> upgradeAssuranceContractList = [select Id, SignedDate__c from UpgradeAssuranceContract__c];        
		system.assertEquals(Date.today(), upgradeAssuranceContractList[0].SignedDate__c, 'Case3: Signed date should be filled!');
        
        UpgradeAssuranceContract__c uacTmp = TermsConditionsLghtCmpCtrl.getUAC (uac.Id);
		system.assertEquals(uac.Id, uacTmp.Id, 'Case4: Record should be returned!');
        
        Map<String, FieldParams> fieldParamsMap = TermsConditionsLghtCmpCtrl.getFieldParams ();
		system.assertNotEquals(0, fieldParamsMap.size(), 'Case5: A map with field params of the Upgrade Assurance Contract should be returned!');
		
        Test.stopTest();
        
    }

    @isTest
    public static void testBulkFunctions() {
        
        Test.startTest();
        
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
		system.assertEquals(false, uac.AcceptTermsAndConditions__c, 'Case1: Upgrade Assurance Contract not accepted yet!');


        //First Approve
        uac.Approved__c = true;
        update uac;

        List<UpgradeAssuranceContract__c> uacList = new List<UpgradeAssuranceContract__c>();
        uacList.add(uac);

        TermsConditionsLghtCmpCtrl.acceptTermAndConditionsBulk(uacList);
        List<UpgradeAssuranceContract__c> upgradeAssuranceContractList = [select Id, SignedDate__c from UpgradeAssuranceContract__c];        
		system.assertNotEquals(Date.today(), upgradeAssuranceContractList[0].SignedDate__c, 'Case2: Signed date should not be filled!');
        
        UpgradeAssuranceContract__c uacTmp = TermsConditionsLghtCmpCtrl.getUAC (uac.Id);
		system.assertEquals(uac.Id, uacTmp.Id, 'Case3: Record should be returned!');
        
        Map<String, FieldParams> fieldParamsMap = TermsConditionsLghtCmpCtrl.getFieldParams ();
		system.assertNotEquals(0, fieldParamsMap.size(), 'Case5: A map with field params of the Upgrade Assurance Contract should be returned!');
		
        Test.stopTest();
        
    }

}