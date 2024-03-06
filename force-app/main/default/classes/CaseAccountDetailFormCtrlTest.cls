/**
 * @name caseAccountDetailFormCtrlTest
 * @author Service
 * @group Test Class
 * @description Test class to verify the correctness of the methods in the controller class caseAccountDetailFormCtrl.
 */
@isTest
private class CaseAccountDetailFormCtrlTest {

    @isTest
    private static void getAccountDataTestNoCaseId() {
        CaseAccountDetailFormCtrl.AccountData resultData = caseAccountDetailFormCtrl.getAccountData(null);

        Assert.isNull(resultData, 'Method should not return anything');
    }

    @isTest
    private static void getAccountDataTestCaseWithAccount() {
        Account acc = ServicesTestUtil.createAccount('test account 1', null, false);
        acc.BusinessAsUsual__c = 'Some text';
        insert acc;
        Case serviceCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, true);

        Test.startTest();

        CaseAccountDetailFormCtrl.AccountData resultData = caseAccountDetailFormCtrl.getAccountData(serviceCase.Id);

        Test.stopTest();

        Assert.isNotNull(resultData);
        Assert.areEqual(acc.Id, resultData.recordId, 'AccountId');
        Assert.areEqual(acc.BusinessAsUsual__c, resultData.businessAsUsual, 'Business As Usual value');
    }

    @isTest
    private static void getAccountDataTestCaseWithoutAccount() {
        Case serviceCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, null, null, true);

        Test.startTest();

        CaseAccountDetailFormCtrl.AccountData resultData = caseAccountDetailFormCtrl.getAccountData(serviceCase.Id);

        Test.stopTest();

        Assert.isNull(resultData, 'Method should not return anything');
    }
    
}