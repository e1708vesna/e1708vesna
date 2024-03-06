/**
 * @description   : UpgradeAssuranceConfirmationCtrl test class
 * @author (s)    : BRITE
 */
@isTest
public with sharing class UpgradeAssuranceConfirmationCtrlTest {

    @isTest
    public static void testController() {
        
        Test.startTest();
        
        Id accRecIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Id uacRecIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Account acc = TestUtil.createAccount('EndCustomer acc', accRecIdEndCustomer, true);
        License__c lic = TestUtil.createLicense('lic1001', acc.Id, true);
        UpgradeAssuranceContract__c uac = TestUtil.createUpgradeAssuranceContract(uacRecIdPendingContract, lic.Id, true);
        
		system.assertEquals(false, uac.AcceptTermsAndConditions__c, 'Case1: Upgrade Assurance Contract not accepted yet!');

        PageReference uaccPage = Page.UpgradeAssuranceConfirmation;
        Test.setCurrentPage(uaccPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',uac.Id);
        ApexPages.currentPage().getParameters().put('signedby','test@test.com');
        ApexPages.currentPage().getParameters().put('SignedDate','2020-01-01');        

        UpgradeAssuranceConfirmationCtrl uaccc = new UpgradeAssuranceConfirmationCtrl();
        UpgradeAssuranceContract__c uacTmp = uaccc.getUpgradeAssuranceContract();

		system.assertEquals(uac.Id, uacTmp.Id, 'Case3: Record should be returned!');
		
        Test.stopTest();        
    }
}