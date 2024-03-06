@isTest
public class OpportunityLineItemTriggerTest {

    @isTest
    private static void deleteAndUndeleteOpportunity(){

        account acc = TestUtil.createAccount('Test acc', true, true);
        Opportunity opp = TestUtil.createOpportunity(acc.id, UserInfo.getUserId(), true);
        opp = [Select Id, PriceBook2Id FROM Opportunity WHERE ID =: opp.Id];
        
        System.debug(opp.Pricebook2Id);
        
        product2 p = TestUtil.createProduct('TestProduct', true);
        PriceBookEntry pbEntryStandard = TestUtil.createPricebookEntry(p.id, Test.getStandardPricebookId(), true);
        PriceBookEntry pbEntry = TestUtil.createPricebookEntry(p.id, opp.Pricebook2Id, true);
        
        OpportunityLineItem oli = TestUtil.createOpportunityLineItem(opp.Id, pbEntry.Id, true);
        History__c h = new History__c(ParentId__c = oli.Id, RecordId__c = oli.Id, NewValue__c = 'New', OldValue__c = 'old', fieldName__c = 'TestField');
        insert h;
        
        List<History__c> hList = [SELECT ID from History__c WHERE Id =: h.Id];
        System.assertEquals(1, hList.size());
        delete opp;
        hList = [SELECT ID from History__c WHERE Id =: h.Id];
        system.debug([SELECT Id FROM OpportunityLineItem WHERE Id = : oli.Id].size());
        System.assertEquals(0, hList.size());
        undelete opp;
        hList = [SELECT ID from History__c WHERE Id =: h.Id];
        System.assertEquals(1, hList.size());
    }
    
    @isTest
    private static void deleteAndUndeleteOpportunityLineItem(){

        account acc = TestUtil.createAccount('Test acc', true, true);
        Opportunity opp = TestUtil.createOpportunity(acc.id, UserInfo.getUserId(), true);
        opp = [Select Id, PriceBook2Id FROM Opportunity WHERE ID =: opp.Id];
        
        System.debug(opp.Pricebook2Id);
        
        product2 p = TestUtil.createProduct('TestProduct', true);
        PriceBookEntry pbEntryStandard = TestUtil.createPricebookEntry(p.id, Test.getStandardPricebookId(), true);
        PriceBookEntry pbEntry = TestUtil.createPricebookEntry(p.id, opp.Pricebook2Id, true);
        
        OpportunityLineItem oli = TestUtil.createOpportunityLineItem(opp.Id, pbEntry.Id, true);
        History__c h = new History__c(ParentId__c = oli.Id, RecordId__c = oli.Id, NewValue__c = 'New', OldValue__c = 'old', fieldName__c = 'TestField');
        insert h;
        
        List<History__c> hList = [SELECT ID from History__c WHERE Id =: h.Id];
        System.assertEquals(1, hList.size());
        delete oli;
        hList = [SELECT ID from History__c WHERE Id =: h.Id];
        System.assertEquals(0, hList.size());
        /* OpportunityLineItems are not undeletable.
        undelete oli;
        hList = [SELECT ID from History__c WHERE Id =: h.Id];
        System.assertEquals(1, hList.size());
		*/
    }
}