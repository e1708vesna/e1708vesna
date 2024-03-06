/**
 * @description   : Class for testing functionality of Ugrade Assurance Contract Activation batch
 * @author (s)    : Brite
 */
@isTest
private class UpgrAssurContrctCloneLghtCtrlTest {
    
    @testSetup
    public static void setup() {
        // create MSRP data
        List<MSRP__c> msrpList = new List<MSRP__c> ();
        msrpList.add(TestUtil.createMSRP('art1002', 'EUR', 25, 0, Date.today().addMonths(-1), Date.today().addMonths(1), false));
        msrpList.add(TestUtil.createMSRP('art1002', 'EUR', 24, 5, Date.today().addMonths(-1), Date.today().addMonths(1), false));
        msrpList.add(TestUtil.createMSRP('art1002', 'EUR', 23, 0, Date.today().addMonths(3), Date.today().addMonths(5), false));
        msrpList.add(TestUtil.createMSRP('art1003', 'EUR', 15, 0, Date.today().addDays(-20), Date.today().addDays(-5), false));
        msrpList.add(TestUtil.createMSRP('art1003', 'EUR', 20, 0, Date.today().addDays(-2), null, false));
        msrpList.add(TestUtil.createMSRP('art1003', 'GBP', 21, 0, Date.today().addDays(-2), null, false));
        
        insert msrpList;
    }
    
    
    @isTest
    public static void testClone () {
    	Integer thisYear = Date.today().Year();
    	
        // case 1: Create UpgradeAssuranceContract
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        
        //primary test data
		License__c lic = TestUtil.createLicense('lic1002', acc.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear,1,1), Date.newInstance(thisYear,12,31), false);
		MSRP__c msrp2 = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear+1,1,1), Date.newInstance(thisYear+1,12,31), false);
		insert new List<MSRP__c> {msrp, msrp2};
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, false);
        
        insert uac;
        List<UpgradeAssuranceContract__c> uacNewList = [
				SELECT u.YourReference__c, u.YourOrder__c, u.Version__c, u.UpgradeAssuranceValue__c, u.Status__c, u.StartDate__c, 
						u.StartDateLine__c, u.Stage__c, u.SignedDate__c, u.SignedBy__c, u.RecordTypeId, u.PercentageDiscountDate__c, 
						u.PartnerDiscountPercentage__c, u.OutstandingLineAmount__c, u.NavisionUaNumber__c, u.Name, u.LineAmount__c,
						 u.LicenseeName__c, u.License__c, u.IsDeleted, u.Invoice__c, u.Id, 
						 u.Handler__c, u.FlatFeeUa__c, u.Exception__c, u.EndDate__c, u.EndDateLine__c, u.EndCustomer__c, 
						 u.Email__c, u.DocumentType__c, u.Currency__c, u.ContractDuration__c, 
						 u.ChannelPartner__c, u.CalculationPercentage__c, u.CalculationMethod__c, u.Billing__c, u.BillingValueUa__c, 
						 u.Approved__c, u.AdditionalConditions__c, 
						 u.AdditionalConditionsReason__c, u.Active__c, u.AcceptTermsAndConditions__c  
        		FROM UpgradeAssuranceContract__c u];

        system.assertEquals(1, uacNewList.size(), 'Case 1: a new Upgrade Assurance Contract should have been created');
    	
    	Id rtIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
    	
    	uac.RecordTypeId = rtIdActivatedContract;
    	uac.Stage__c = 'Order';
    	uac.SignedDate__c = Date.today();
    	uac.AcceptTermsAndConditions__c = true;
    	uac.AdditionalConditions__c = true;
		uac.AdditionalConditionsReason__c = 'For my UnitTest';
        //First Approve
        uac.Approved__c = true;
    	update uac;

        List<UpgradeAssuranceContractItem__c> uaciList = [SELECT u.UpgradeAssuranceContract__r.License__c, 
        		u.UpgradeAssuranceContract__r.NavisionUaNumber__c, u.UpgradeAssuranceContract__c, u.Name, 
        		u.LineNumber__c, u.LicenseItem__r.LineNumber__c, u.LicenseItem__r.ArticleNumber__c, u.LicenseItem__r.ArtNo__c, 
        		u.LicenseItem__r.Item__c, u.LicenseItem__c, u.Id 
        		FROM UpgradeAssuranceContractItem__c u 
        		WHERE u.UpgradeAssuranceContract__c = :uac.Id];
        UpgradeAssuranceContractItem__c uacItem = uaciList[0];

		// Change UpgradeAssuranceContractItem fields
        uacItem.AdjustedQuantity__c = 7;
        uacItem.AdjustedUnitPrice__c = 1059;
        uacItem.AdjustmentReason__c = 'Unit test adjust';
		update uacItem;

    	//Case 2: Clone automation
    	Test.startTest();
    	
    	UpgrAssurContrctCloneLghtCtrl.cloneUpgrAssContr(uac.Id);

    	Test.stopTest();
    	
    	Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());

    	List<UpgradeAssuranceContract__c> uacList = [
				SELECT u.YourReference__c, u.YourOrder__c, u.Version__c, u.UpgradeAssuranceValue__c, u.Status__c, u.StartDate__c, 
						u.StartDateLine__c, u.Stage__c, u.SignedDate__c, u.SignedBy__c, u.RecordTypeId, u.PercentageDiscountDate__c, 
						u.PartnerDiscountPercentage__c, u.OutstandingLineAmount__c, u.NavisionUaNumber__c, u.Name, u.LineAmount__c,
						 u.LicenseeName__c, u.License__c, u.IsDeleted, u.Invoice__c, u.Id, 
						 u.Handler__c, u.FlatFeeUa__c, u.Exception__c, u.EndDate__c, u.EndDateLine__c, u.EndCustomer__c, 
						 u.Email__c, u.DocumentType__c, u.Currency__c, u.ContractDuration__c, 
						 u.ChannelPartner__c, u.CalculationPercentage__c, u.CalculationMethod__c, u.Billing__c, u.BillingValueUa__c, 
						 u.Approved__c, u.AdditionalConditions__c, 
						 u.AdditionalConditionsReason__c, u.Active__c, u.AcceptTermsAndConditions__c  
        		FROM UpgradeAssuranceContract__c u 
				WHERE Id != :uac.Id];

        system.assertEquals(1, uacList.size(), 'Case 2: a new Upgrade Assurance Contract clone should have been created');
        uac = uacList[0];
        system.assertEquals('New', uac.Stage__c, 'Case 2: Stage should be set to New');
        system.assertEquals(rtIdClonedContract, uac.RecordTypeId, 'Case 2: Record type shlould be set to ');
        system.assertEquals(uacNewList[0].StartDate__c, uac.StartDate__c, 'Case 2: StartDate__c should be unchanged');
        system.assertEquals(uacNewList[0].EndDateLine__c.addDays(1), uac.StartDateLine__c, 'Case 2: StartDateLine__c should be StartDateLine__c + 1 day');
        system.assertEquals(null, uac.Invoice__c, 'Case 2: Invoice__c needs to be cleared');
        
        uaciList = [SELECT u.UpgradeAssuranceContract__r.License__c, 
        		u.UpgradeAssuranceContract__r.NavisionUaNumber__c, u.UpgradeAssuranceContract__c, u.Name, 
        		u.LineNumber__c, u.LicenseItem__r.LineNumber__c, u.LicenseItem__r.ArticleNumber__c, u.LicenseItem__r.ArtNo__c, 
        		u.LicenseItem__r.Item__c, u.LicenseItem__c, u.Id , u.AdjustedQuantity__c, u.AdjustedUnitPrice__c, u.AdjustmentReason__c
        		FROM UpgradeAssuranceContractItem__c u 
        		WHERE u.UpgradeAssuranceContract__c = :uac.Id];
        
        system.assertEquals(licItem.Id, uaciList[0].LicenseItem__c,'License lookup need to copied');
        system.assertEquals(7, uaciList[0].AdjustedQuantity__c,'Upgrade Assurance Contract Item fields should have been copied');
        system.assertEquals(1059, uaciList[0].AdjustedUnitPrice__c,'Upgrade Assurance Contract Item fields should have been copied');
        system.assertEquals('Unit test adjust', uaciList[0].AdjustmentReason__c,'Upgrade Assurance Contract Item fields should have been copied');

	}

    @isTest
    public static void testCloneDeletedLicItem () {
    	Integer thisYear = Date.today().Year();
    	
        // case 1: Create UpgradeAssuranceContract
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        
        //primary test data
        License__c lic = TestUtil.createLicense('lic1002', acc.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear,1,1), Date.newInstance(thisYear,12,31), true);
        MSRP__c msrp2 = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear+1,1,1), Date.newInstance(thisYear+1,12,31), true);
        MSRP__c msrp3 = TestUtil.createMSRP('art1002', 'EUR', 23.65, 0, Date.newInstance(thisYear,1,1), Date.newInstance(thisYear,12,31), true);
        MSRP__c msrp4 = TestUtil.createMSRP('art1002', 'EUR', 23.65, 0, Date.newInstance(thisYear+1,1,1), Date.newInstance(thisYear+1,12,31), true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        LicenseItem__c licItem2 = TestUtil.createLicenseItem('licItemNbr2', 'art1002', lic.Id, msrp3.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, false);

        insert uac;
        List<UpgradeAssuranceContract__c> uacNewList = [
				SELECT u.YourReference__c, u.YourOrder__c, u.Version__c, u.UpgradeAssuranceValue__c, u.Status__c, u.StartDate__c, 
						u.StartDateLine__c, u.Stage__c, u.SignedDate__c, u.SignedBy__c, u.RecordTypeId, u.PercentageDiscountDate__c, 
						u.PartnerDiscountPercentage__c, u.OutstandingLineAmount__c, u.NavisionUaNumber__c, u.Name, u.LineAmount__c,
						 u.LicenseeName__c, u.License__c, u.IsDeleted, u.Invoice__c, u.Id, 
						 u.Handler__c, u.FlatFeeUa__c, u.Exception__c, u.EndDate__c, u.EndDateLine__c, u.EndCustomer__c, 
						 u.Email__c, u.DocumentType__c, u.Currency__c, u.ContractDuration__c, 
						 u.ChannelPartner__c, u.CalculationPercentage__c, u.CalculationMethod__c, u.Billing__c, u.BillingValueUa__c, 
						 u.Approved__c, u.AdditionalConditions__c, 
						 u.AdditionalConditionsReason__c, u.Active__c, u.AcceptTermsAndConditions__c  
        		FROM UpgradeAssuranceContract__c u];

        system.assertEquals(1, uacNewList.size(), 'Case 1: a new Upgrade Assurance Contract should have been created');
    	
    	Id rtIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
    	
    	uac.RecordTypeId = rtIdActivatedContract;
    	uac.Stage__c = 'Order';
    	uac.SignedDate__c = Date.today();
    	uac.AcceptTermsAndConditions__c = true;
    	uac.AdditionalConditions__c = true;
		uac.AdditionalConditionsReason__c = 'For my UnitTest';
        //First Approve
        uac.Approved__c = true;
    	update uac;

        List<UpgradeAssuranceContractItem__c> uaciList = [SELECT u.UpgradeAssuranceContract__r.License__c, 
        		u.UpgradeAssuranceContract__r.NavisionUaNumber__c, u.UpgradeAssuranceContract__c, u.Name, 
        		u.LineNumber__c, u.LicenseItem__r.LineNumber__c, u.LicenseItem__r.ArticleNumber__c, u.LicenseItem__r.ArtNo__c, 
        		u.LicenseItem__r.Item__c, u.LicenseItem__c, u.Id 
        		FROM UpgradeAssuranceContractItem__c u 
        		WHERE u.UpgradeAssuranceContract__c = :uac.Id];
        system.assertEquals(2, uaciList.size(), 'Case 1: 2 new Upgrade Assurance Contract items should have been created');

        UpgradeAssuranceContractItem__c uacItem = uaciList[0];

		// Delete a license item
  		delete licItem2;

    	//Case 2: Clone automation
    	Test.startTest();
    	
    	UpgrAssurContrctCloneLghtCtrl.cloneUpgrAssContr(uac.Id);

    	Test.stopTest();
    	
    	Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());

    	List<UpgradeAssuranceContract__c> uacList = [
				SELECT u.YourReference__c, u.YourOrder__c, u.Version__c, u.UpgradeAssuranceValue__c, u.Status__c, u.StartDate__c, 
						u.StartDateLine__c, u.Stage__c, u.SignedDate__c, u.SignedBy__c, u.RecordTypeId, u.PercentageDiscountDate__c, 
						u.PartnerDiscountPercentage__c, u.OutstandingLineAmount__c, u.NavisionUaNumber__c, u.Name, u.LineAmount__c,
						 u.LicenseeName__c, u.License__c, u.IsDeleted, u.Invoice__c, u.Id, 
						 u.Handler__c, u.FlatFeeUa__c, u.Exception__c, u.EndDate__c, u.EndDateLine__c, u.EndCustomer__c, 
						 u.Email__c, u.DocumentType__c, u.Currency__c, u.ContractDuration__c, 
						 u.ChannelPartner__c, u.CalculationPercentage__c, u.CalculationMethod__c, u.Billing__c, u.BillingValueUa__c, 
						 u.Approved__c, u.AdditionalConditions__c, 
						 u.AdditionalConditionsReason__c, u.Active__c, u.AcceptTermsAndConditions__c  
        		FROM UpgradeAssuranceContract__c u 
				WHERE Id != :uac.Id];

        system.assertEquals(1, uacList.size(), 'Case 2: a new Upgrade Assurance Contract clone should have been created');
        uac = uacList[0];
        system.assertEquals('New', uac.Stage__c, 'Case 2: Stage should be set to New');
        system.assertEquals(rtIdClonedContract, uac.RecordTypeId, 'Case 2: Record type shlould be set to ');
        system.assertEquals(uacNewList[0].StartDate__c, uac.StartDate__c, 'Case 2: StartDate__c should be unchanged');
        system.assertEquals(uacNewList[0].EndDateLine__c.addDays(1), uac.StartDateLine__c, 'Case 2: StartDateLine__c should be StartDateLine__c + 1 day');
        system.assertEquals(null, uac.Invoice__c, 'Case 2: Invoice__c needs to be cleared');
        
        uaciList = [SELECT u.UpgradeAssuranceContract__r.License__c, 
        		u.UpgradeAssuranceContract__r.NavisionUaNumber__c, u.UpgradeAssuranceContract__c, u.Name, 
        		u.LineNumber__c, u.LicenseItem__r.LineNumber__c, u.LicenseItem__r.ArticleNumber__c, u.LicenseItem__r.ArtNo__c, 
        		u.LicenseItem__r.Item__c, u.LicenseItem__c, u.Id , u.AdjustedQuantity__c, u.AdjustedUnitPrice__c, u.AdjustmentReason__c
        		FROM UpgradeAssuranceContractItem__c u 
        		WHERE u.UpgradeAssuranceContract__c = :uac.Id];
        
        system.assertEquals(1, uaciList.size(), 'Case 1: 1 new Upgrade Assurance Contract items should have been created');
	}


    @isTest
    public static void testCloneWithExisting () {
    	Integer thisYear = Date.today().Year();
    	
        // case 1: Create UpgradeAssuranceContract
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
    	Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
    	Id rtIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        
        //primary test data
        License__c lic = TestUtil.createLicense('lic1002', acc.Id, true);
        MSRP__c msrp = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear,1,1), Date.newInstance(thisYear,12,31), true);
        MSRP__c msrp2 = TestUtil.createMSRP('art1001', 'EUR', 23.45, 0, Date.newInstance(thisYear+1,1,1), Date.newInstance(thisYear+1,12,31), true);
        LicenseItem__c licItem = TestUtil.createLicenseItem('licItemNbr1', 'art1001', lic.Id, msrp.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, false);
        
    	uac.RecordTypeId = rtIdActivatedContract;
    	uac.Stage__c = 'Order';
    	uac.SignedDate__c = Date.today();
    	uac.AcceptTermsAndConditions__c = true;
        
        insert uac;
        
        UpgradeAssuranceContract__c uacClone = uac.clone(false, false, false, false); 
        uacClone.StartDate__c = Date.today().addYears(1);
        uacClone.StartDateLine__c = Date.today().addYears(1);
        uacClone.RecordTypeId = rtIdClonedContract;
        uacClone.invoice__c = null;
    	uacClone.Stage__c = 'New';
        
        insert uacClone;


    	List<UpgradeAssuranceContract__c> uacExistList = [SELECT Id, License__c, StartDateLine__c FROM UpgradeAssuranceContract__c WHERE RecordTypeId = :RtIdClonedContract];// AND StartDateLine__c = NEXT_YEAR];
    	for (UpgradeAssuranceContract__c uacx : uacExistList) {
			System.assertEquals(lic.Id, uacx.License__c, 'Case x: License should be the same');
			System.assertEquals(uacClone.StartDateLine__c, uacx.StartDateLine__c, 'Case x: Date should be the same');
    	}
		System.assertEquals(1, uacExistList.size(), 'Case x: one should have been found');



        List<UpgradeAssuranceContract__c> uacNewList = [SELECT Id, License__c, RecordTypeId FROM UpgradeAssuranceContract__c where Id = : uacClone.Id];
		System.assertEquals(rtIdClonedContract, uacNewList[0].RecordTypeId, 'Case 1: Recordtype should not be manupilated by other processes');   	
		System.assertEquals(lic.Id, uacNewList[0].License__c, 'Case 1: License should be the same');   	
		
        uacNewList = [SELECT Id FROM UpgradeAssuranceContract__c];
        system.assertEquals(2, uacNewList.size(), 'Case 1: 2 Upgrade Assurance Contracts should have been created');
        
		//for existing filter check
        Account acc2 = TestUtil.createAccount('EndCustomer acc2', accRecIdEndCustomer, true);
        License__c lic2 = TestUtil.createLicense('lic1003', acc2.Id, true);
        MSRP__c msrp3 = TestUtil.createMSRP('art1002', 'EUR', 27.85, 0, Date.newInstance(thisYear,1,1), Date.newInstance(thisYear,12,31), true);
        MSRP__c msrp4 = TestUtil.createMSRP('art1002', 'EUR', 27.85, 0, Date.newInstance(thisYear+1,1,1), Date.newInstance(thisYear+1,12,31), true);
        LicenseItem__c licItem2 = TestUtil.createLicenseItem('licItemNbr2', 'art1001', lic2.Id, msrp3.Id, true);
        UpgradeAssuranceContract__c uac2 = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic2.Id, false);
        
    	uac2.RecordTypeId = rtIdActivatedContract;
    	uac2.Stage__c = 'Order';
    	uac2.SignedDate__c = Date.today();
    	uac2.AcceptTermsAndConditions__c = true;
    	
    	insert uac2;

        uacNewList = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM UpgradeAssuranceContract__c];
        system.assertEquals(3, uacNewList.size(), 'Case 2: Max 3 Upgrade Assurance Contracts should be present');
    	
    	for (UpgradeAssuranceContract__c uactmp : uacNewList) {
    		system.debug('Rt Id:   ' + uactmp.RecordTypeId);
    		system.debug('Rt Name: ' + uactmp.RecordType.DeveloperName);
    	}
    	
    	// Case 3:
    	Test.startTest();
    	
    	UpgrAssurContrctCloneLghtCtrl.cloneUpgrAssContr(uac.Id);
    	    
    	Test.stopTest();
    	
        uacNewList = [SELECT Id FROM UpgradeAssuranceContract__c];
        system.assertEquals(3, uacNewList.size(), 'Case 3: Clone, Max 4 Upgrade Assurance Contracts should be present');

	}
}