/*
 * @Name DuplicateCaseCtrlTest
 * @Author Service
 * @Group Test Class
 * @Description Test class for the DuplicateCaseCtrl
 */
@isTest
private class DuplicateCaseCtrlTest {

    /*
     * @Description Test method for the getDuplicateCases function in the DuplicateCaseCtrl class.
     * This method sets up mock data for Cases with potential duplicates, then checks if the controller's function correctly identifies them.
     */
    @isTest static void getDuplicateCasesTest() {

        // Creating test data for Account, Contact and Cases.
        Account testAccount = ServicesTestUtil.createAccount('Test Account', Constants.RT_ID_ACC_BUSINESS, true);
        Contact testContact = ServicesTestUtil.createContact(testAccount.Id, 'Ben', 'ben@adyen.com.fake', true);
        
        // Creating an original case for testing duplicate detection.
        Case originCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, testAccount.Id, testContact.Id, false);
        originCase.Subject = 'Duplicate Case Test';
        originCase.SuppliedEmail = 'case1@example.com.fake';
        originCase.Status = 'New';
        
        // Creating potential duplicate cases for various scenarios.
        // Duplicate based on Subject and Contact.
        Case sameContactCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, testAccount.Id, testContact.Id, false); 
        sameContactCase.Subject = originCase.Subject;
        sameContactCase.SuppliedEmail = 'another.email@example.com.fake';
        sameContactCase.Status = 'New';
        
        // Duplicate based on Subject and Contact, but with different SuppliedEmail.
        Case sameContactManualCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, testAccount.Id, testContact.Id, false); 
        sameContactManualCase.Subject = originCase.Subject;
        sameContactManualCase.SuppliedEmail = 'another.email@example.com.fake';
        sameContactManualCase.Status = 'New';
        
        // Duplicate based on Subject and SuppliedEmail.
        Case sameSuppliedEmailCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, testAccount.Id, null, false); 
        sameSuppliedEmailCase.Subject = originCase.Subject;
        sameSuppliedEmailCase.SuppliedEmail = originCase.SuppliedEmail;
        sameSuppliedEmailCase.Status = 'New';
        
        // Case with the same Subject but different Contact and SuppliedEmail. Should not be considered a duplicate.
        Case differentCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, testAccount.Id, null, false);
        differentCase.Subject = originCase.Subject;
        differentCase.SuppliedEmail = 'yet.again.another.email@example.com.fake';
        differentCase.Status = 'New';

        // Inserting test data.
        insert new List<Case>{originCase, sameContactCase, sameContactManualCase, sameSuppliedEmailCase, differentCase};

        // Mocking SOSL search results for the duplicate check.
        Test.setFixedSearchResults(new List<Id> {sameContactCase.Id, sameContactManualCase.Id, sameSuppliedEmailCase.Id, differentCase.Id});

        // Begin test context.
        Test.startTest();

        // Calling the method to test.
        DuplicateCaseCtrl.DuplicateCaseWrapper result = DuplicateCaseCtrl.getDuplicateCases(originCase.Id);
        
        // End test context.
        Test.stopTest();

        // Asserts to validate the behavior of the method.
        Assert.areEqual(3, result.count, 'Expected 3 query results');
        Set<Id> duplicateCaseIds = new Set<Id>();
        for(Case c : result.duplicateCases) {
            duplicateCaseIds.add(c.Id);
        }
        Assert.isTrue(duplicateCaseIds.contains(sameContactCase.Id), 'sameContactCase should be identified as a duplicate.');
        Assert.isTrue(duplicateCaseIds.contains(sameContactManualCase.Id), 'sameContactManualCase should be identified as a duplicate.');
        Assert.isTrue(duplicateCaseIds.contains(sameSuppliedEmailCase.Id), 'sameSuppliedEmailCase should be identified as a duplicate.');
        Assert.isFalse(duplicateCaseIds.contains(differentCase.Id), 'differentCase should not be identified as a duplicate.');
    }
}