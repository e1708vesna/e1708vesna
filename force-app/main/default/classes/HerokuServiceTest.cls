/**
 * @description   : AccountHelper test class
 * @author (s)    : BRITE
 */
@isTest
private class HerokuServiceTest {
	static String API_TOKEN_STORE_NAME = 'HerokuLicenseApp';
	static ApiTokenStore__c ats;
	
	@TestSetup
	static void setup() {
		//create the heroku access settings
		ats = new ApiTokenStore__c ( name=API_TOKEN_STORE_NAME, Url__c = 'https://mysite.nl/oauth/token',
        ClientId__c = '12345', ClientSecret__c = '45678',
        UserName__c = 'username', Password__c = 'password');
		insert ats;
	}
	
	@isTest
    static void restTestMethodsTest() {
    	//Code coverage for service alive test methods
    	HerokuService hs = new HerokuService();
		Test.startTest();
		String result = hs.getTestData1();
		system.assertEquals('["Yes It Works!"]', result);
		result = hs.getTestData2();
		system.assertEquals('["Yes It Works!"]', result);		
		Test.stopTest();
    }
    
	@isTest
    static void licenseTest() {
        // Check functionality for license attached to the License
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', recIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);

		List<MSRP__C> msrpList = new List<MSRP__C>();
        msrpList.add(TestUtil.createMSRP('8009633', 'EUR', 23.45, 0, Date.today(), null, false));
        msrpList.add(TestUtil.createMSRP('8009600', 'EUR', 17.15, 0, Date.today(), null, false));
        msrpList.add(TestUtil.createMSRP('8017816', 'EUR', 25.00, 0, Date.today(), null, false));
        msrpList.add(TestUtil.createMSRP('8015740', 'EUR', 78.10, 0, Date.today(), null, false));
		insert msrpList;

		//only 3 of the 4 msrp has export factors for all 3 ExportCode options
		List<ExportFactor__c> exportFactorList = new List<ExportFactor__c>();
        exportFactorList.add( new ExportFactor__c(
                                Name = '8009600', 
                                Description__c = 'AEWARE LICENSE FOR 50 BADGES', 
                                ExportCode__c = 'LICENSEQTY',
                                ExportFactor__c = 50));
        exportFactorList.add( new ExportFactor__c(
                                Name = '8017816', 
                                Description__c = 'AEOS SERV RULE ENGINE TILL 10', 
                                ExportCode__c = 'RULE ENG',
                                ExportFactor__c = 10));
        exportFactorList.add( new ExportFactor__c(
                                Name = '8015740', 
                                Description__c = 'AEOS SERV OFFLINE AUTH.', 
                                ExportCode__c = 'OFFL ENTR',
                                ExportFactor__c = 1));
		insert exportFactorList;

		List<PackageQuantity__c> packageQuantityList = new List<PackageQuantity__c>();

        packageQuantityList.add( new PackageQuantity__c(
                                Name = '8009600', 
                                SetQuantity__c = 40));
        insert packageQuantityList;



		List<LicenseItem__c> litList = new List<LicenseItem__c>();
        litList.add(TestUtil.createLicenseItem('lic1001_8009633', '8009633', lic.Id, msrpList[0].Id, false));
        litList.add(TestUtil.createLicenseItem('lic1001_8009600', '8009600', lic.Id, msrpList[1].Id, false));
        litList.add(TestUtil.createLicenseItem('lic1001_8017816', '8017816', lic.Id, msrpList[2].Id, false));
        litList.add(TestUtil.createLicenseItem('lic1001_8015740', '8015740', lic.Id, msrpList[3].Id, false));
		insert litList;

		//Create the new file that will be removed
		String fileName = 'MyFile.jar';
		Blob data = EncodingUtil.base64Decode('UEsDBBQACAgIACJkfE0AAAAAAAAAAAAAAAAIAAAAdGVzdC50eHSNkl1rgzAUhu/9FQd2Yy+U+NFiC70QdTDoaqmlvRxZczZkmkiSdvjvl7oxXFFZrvOc9+R583BCBltxBT8Cz18FwYqEkGTFAXziRZblfh9wILkoLWqUwGmNLyMH1rDN0ngHafacO0meZr0Jj0LWVMMVpSoFH5/g9ZhNeUauEGrBsBpDRxh+qV9RTuT4QTgf4H5SwH5HjpJqZLPRrJ0U7HLWk1JuTJzlxQA26cJggRv2qD1WSM2CzOzk6HI4sXuY43lOV2Af5vhJK2hQloJByc2YVg1Ekh5UtEpj/YEtNFJcSzao00BPTcyYRKWGWFvNwD6LuqagsKF/jN62Xfqut4hc4np9s0dalazU7d3CYJP1m5BozM06fD7BKE2l7nTdCVr8CooIWYYBMXB8WhLiQ5yY719Akm8P+3xjijvF+6wP+1aKDXKGXP/UGHN2nCgS1tb/LvZTbh+mq/8LUEsHCGyscKBaAQAAogMAAFBLAQIUABQACAgIACJkfE1srHCgWgEAAKIDAAAIAAAAAAAAAAAAAAAAAAAAAAB0ZXN0LnR4dFBLBQYAAAAAAQABADYAAACQAQAAAAA='); 
		ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        cv.VersionData = data;
        cv.Title = fileName;
        cv.PathOnClient = filename;
        insert cv;	

		//Relate the file to the License        
        ContentDocumentLink cdl = new ContentDocumentLink();        
		cdl.ContentDocumentId = ContentVersionDao.getById(cv.Id)[0].ContentDocumentId;
		cdl.LinkedEntityId = lic.Id;
		cdl.ShareType = 'V';
		insert cdl;	

		List<ContentDocumentLink> cdlList = ContentDocumentLinkDao.getByLinkedEntityId(lic.Id);
		system.assertEquals(1, cdlList.size(), 'One file should return');
		system.assertEquals(cdl.Id, cdlList[0].Id);

		Test.startTest();
    	HerokuService hs = new HerokuService();
    	hs.getLicenseJar(lic.Id);
    	
    	//Check that there is attached one new file and the previous one is deleted
		//Delete nopped out DvtH20190902 -> reactivated DvtH20200706
		cdlList = ContentDocumentLinkDao.getByLinkedEntityId(lic.Id);
		system.assertEquals(1, cdlList.size(), 'One file should return');
		system.assertNotEquals(cdl.Id, cdlList[0].Id);

		//verify file content
        CustomLog__c cl = [	SELECT Type__c, Message__c, Description__c 
							FROM CustomLog__c 
							WHERE Type__c = :CustomLog.INFO AND Message__c = 'License Text data'];
		//system.debug('>>' + cl.Description__c);

		String fileTxt = '';
		fileTxt += 'VERSION||1' + '\n';
		fileTxt += 'PRODUCT||AEOS' + '\n';
		fileTxt += 'LICENSE_MODEL_VERSION||1'+ '\n';
		fileTxt += 'SYSKEYPROVIDERID||Unknown'+ '\n';
		fileTxt += 'LICENSE KEY||lic1001'+ '\n';
		fileTxt += 'LICENSEE NAME||EndCustomer acc'+ '\n';
		fileTxt += 'IP ADDRESS 1||null'+ '\n';
		fileTxt += 'START DATE||'+ '\n';
		fileTxt += 'PERIOD||null'+ '\n';
		fileTxt += 'RENEWALPERIOD||30'+ '\n';
		fileTxt += '8009633|MSRP description|10'+ '\n';
		//fileTxt += '8009600|MSRP description|10'+ '\n'; //replaced by packageQuantity * Quantity
		fileTxt += '8009600|MSRP description|400'+ '\n';
		fileTxt += '8017816|MSRP description|10'+ '\n';
		fileTxt += '8015740|MSRP description|10'+ '\n';
		fileTxt += 'MaxBadges||500'+ '\n';
		fileTxt += 'MaxRuleEngineRules||100'+ '\n';
		fileTxt += 'MaxOffLineEntrances||10';

		system.assertEquals(fileTxt, cl.Description__c);
		Test.stopTest();
        
    }
}