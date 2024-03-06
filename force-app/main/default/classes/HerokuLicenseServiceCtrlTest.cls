/**
 * @description   : HerokuLicenseServiceCtrl test class
 * @author (s)    : BRITE
 */
@isTest
public class HerokuLicenseServiceCtrlTest {
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
	
	/**
	 * Test the Custom Button Controler class for running the Heroku service 
	 **/
    static testMethod void customButtonHerokuTest() {
        // Check functionality for license attached to the License
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', recIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        MSRP__C msrp = TestUtil.createMSRP('12345', 'EUR', 23.45, 0, Date.today(), null, true);
        LicenseItem__c lit = TestUtil.createLicenseItem('12345', '12345', lic.Id, msrp.Id, true);
        
    	//PageReference pageRef = Page.HerokuLicenseService;
    	//Test.setCurrentPage(pageRef); 
    	  
		Test.startTest();
    	HerokuLicenseServiceCtrl hlsc = new HerokuLicenseServiceCtrl(null);
    	//Case 1:
    	hlsc.objId = lic.Id; 
    	system.assertEquals(lic.Id, hlsc.getObjId(), 'Case 1: License Id should be filled in objId');
    	
    	//Case 2:
    	hlsc.getLicenseJar();
    	
		List<ContentDocumentLink> cdlList = ContentDocumentLinkDao.getByLinkedEntityId(lic.Id);
		system.assertEquals(1, cdlList.size(), 'Case 2: One file should return');
    	
		Test.stopTest();
    }    
}