/**
 * @description Test class to test the functionality of class CaseServiceHlpr.
 */
@isTest
private class CaseServiceHlprTest {

    @isTest
    private static void validateMergeActionRelatedAccount() {
        // test merge of two cases related to the same account
        Account acc = ServicesTestUtil.createAccount('test account 1', null, true);
        Case masterCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, false);
        Case mergedCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, false);
        insert new List<Case> {masterCase, mergedCase};


        try {
            merge masterCase mergedCase;
        } catch (Exception ex) {
            // error NOT expected
            System.assert(false, 'Merge should NOT throw an exception; ' + ex.getMessage());
        }
    }

    @isTest
    private static void validateCaseCommentOnStatusChange() {
        Account acc = ServicesTestUtil.createAccount('test account 1', null, true);
        Case caseRecord = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, true);
        caseRecord.Status = 'In Progress';
        caseRecord.Comments = 'In Progress Comment';
        
        Test.startTest();
        update caseRecord;
        Test.stopTest();
        
        //Can't filter on body
        Boolean feedItemFound = false;
        for (FeedItem fi : [SELECT Id, Body FROM FeedItem WHERE ParentId =: caseRecord.Id]) {
            if (fi.Body.Equals(caseRecord.Comments)) {
                feedItemFound = true;
            }
        }
        Assert.isTrue(feedItemFound, 'Internal Comment');
        
    }
    
    @isTest
    private static void validateCaseCommentNonStatusChange() {
        Account acc = ServicesTestUtil.createAccount('test account 1', null, true);
        Case caseRecord = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc.Id, null, true);
        caseRecord.Comments = 'Internal Comment';
        
        Test.startTest();
        update caseRecord;
        Test.stopTest();
        
        //Can't filter on body
        Boolean feedItemFound = false;
        for (FeedItem fi : [SELECT Id, Body FROM FeedItem WHERE ParentId =: caseRecord.Id]) {
            System.debug(fi.body);
            if (fi.Body.Equals(caseRecord.Comments)) {
                feedItemFound = true;
            }
        }
        Assert.isFalse(feedItemFound, 'The internal comment should not have been found as a regular feeditem.');
        
    }
    
    
    @isTest
    private static void validateMergeActionNotRelatedAccount() {
        // test merge of two cases NOT related to the same account
        Account acc1 = ServicesTestUtil.createAccount('test account 1', null, false);
        Account acc2 = ServicesTestUtil.createAccount('test account 2', null, false);
        insert new List<Account> {acc1, acc2};
        Case masterCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc1.Id, null, false);
        Case mergedCase = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, acc2.Id, null, false);
        insert new List<Case> {masterCase, mergedCase};

        try {
            merge masterCase mergedCase;
            System.assert(false, 'Merge should throw an exception');
        } catch (Exception ex) {
            // error expected
            System.assert(ex.getMessage().contains(System.Label.CaseMergeDifferentAccountsNotAllowed), 'Error message');
        }
    }
/*
// TODO: Refactor class to not be dependent on the Case Taxonomy Values anymore.
    @isTest
    private static void assignQueueResultsFound() {
        // assign the case to an existing queue
        CaseComplexity__mdt caseComplexity = [
            SELECT Id, Type__c, SubType__c, ServiceTopic__c, Team__c, Team__r.QueueDeveloperName__c
            FROM CaseComplexity__mdt
            WHERE Type__c != null AND SubType__c = 'Other' AND ServiceTopic__c != null 
            AND Team__c != null AND Team__r.QueueDeveloperName__c != null LIMIT 1];
        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, null, null, false);
        c.Type = caseComplexity.Type__c;
        c.SubType__c = caseComplexity.SubType__c;
        c.ServiceTopic__c = caseComplexity.ServiceTopic__c;

        try {
            insert c;
        } catch (exception ex) {
            System.assert(false, 'Assigning should NOT throw an exception; ' + ex.getMessage());
        }

        // verify if the saved owner is a queue
        c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
        System.assert(String.valueOf(c.OwnerId).startsWith('00G'), 'Case owner should be a queue');
    }
    
    @isTest
    private static void rerouteAfterClassificationQueueResultsFound() {
        // assign the case to an existing queue
        CaseComplexity__mdt caseComplexity = [
            SELECT Id, Type__c, SubType__c, ServiceTopic__c, Team__c, Team__r.QueueDeveloperName__c
            FROM CaseComplexity__mdt
            WHERE Type__c != null AND SubType__c = 'Other' AND ServiceTopic__c != null 
            AND Team__c != null AND Team__r.QueueDeveloperName__c != null LIMIT 1];
        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, null, null, false);
        c.Type = caseComplexity.Type__c;
        c.SubType__c = caseComplexity.SubType__c;
        c.ServiceTopic__c = null;
		insert c;
        c.ServiceTopic__c = caseComplexity.ServiceTopic__c;
        try {
            update c;
        } catch (exception ex) {
            System.assert(false, 'Assigning should NOT throw an exception; ' + ex.getMessage());
        }

        // verify if the saved owner is a queue
        c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
        System.assert(String.valueOf(c.OwnerId).startsWith('00G'), 'Case owner should be a queue');
    }

    @isTest
    private static void assignQueueResultsNotFound() {
        // assign the case to an existing queue
        CaseComplexity__mdt caseComplexity = [
            SELECT Id, Type__c, SubType__c, ServiceTopic__c, Team__c, Team__r.QueueDeveloperName__c
            FROM CaseComplexity__mdt
            WHERE Type__c != null AND SubType__c = 'Other' AND ServiceTopic__c != null 
            AND Team__c != null AND Team__r.QueueDeveloperName__c != null LIMIT 1];

        Case c = ServicesTestUtil.createCase(Constants.RT_ID_CASE_SERVICECASE, null, null, false);
        c.Type = caseComplexity.Type__c;
        c.SubType__c = caseComplexity.SubType__c;
        c.ServiceTopic__c = null;

        try {
            insert c;
        } catch (exception ex) {
            System.assert(false, 'Assigning should NOT throw an exception; ' + ex.getMessage());
        }

        // verify if the saved owner is NOT a queue
        c = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
        System.assert(String.valueOf(c.OwnerId).startsWith('005'), 'Case owner should be an user');
    }
    
    @isTest
    private static void methodGetCorrectGroupFromTeam(){
        String unclassifiedQueueName = 'Unclassified';
        String classifiedQueueName = 'classified';
        ServiceTeam__mdt team = New ServiceTeam__mdt(Label = 'TestTeam', DeveloperName = 'TestTeam', UnclassifiedQueueDeveloperName__c = unclassifiedQueueName, QueueDeveloperName__c = classifiedQueueName, IsWorkingInZendesk__c = false);
        ServiceTeam__mdt zendeskTeam = New ServiceTeam__mdt(Label = 'TestTeam', DeveloperName = 'TestTeam', UnclassifiedQueueDeveloperName__c = unclassifiedQueueName, QueueDeveloperName__c = classifiedQueueName, IsWorkingInZendesk__c = true);
        Case unclassifiedCase = new Case();
        Case classifiedCase = new Case(Type = 'Account', SubType__c = 'Account Management', ServiceTopic__c = 'Change My Account Code');
        System.assertEquals(unclassifiedQueueName, CaseServiceHlpr.getCorrectGroupFromTeam(team, unclassifiedCase), 'Expected UnclassifiedQueue to be returned.');
        System.assertEquals(classifiedQueueName, CaseServiceHlpr.getCorrectGroupFromTeam(team, classifiedCase), 'Expected classifiedQueue to be returned.');
        System.assertEquals(null, CaseServiceHlpr.getCorrectGroupFromTeam(zendeskTeam, unclassifiedCase), 'Expected no queue retuned on a zendesk team.');
        System.assertEquals(null, CaseServiceHlpr.getCorrectGroupFromTeam(zendeskTeam, classifiedCase), 'Expected no queue retuned on a zendesk team.');
    }*/

}