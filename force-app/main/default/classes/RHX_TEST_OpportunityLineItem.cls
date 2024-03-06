/**
* @author Sales
* @group Test Class
* @description Test Class for RHX_OpportunityLineItem
*/
@isTest
public class RHX_TEST_OpportunityLineItem {
    @isTest
	public static void RHX_Testmethod() {
        Account testAccount = (Account)TestDataFactory.createSobject('Account', new Map<String,Object>{
             'BillingCountry' => 'Netherlands'
        });
        
        Opportunity testOpportunity = (Opportunity)TestDataFactory.createSobject('Opportunity', new Map<String,Object>{
            'AccountId' => testAccount.Id,
            'StageName' => 'SCOTSMAN',
            'CloseDate' => Date.today().addDays(5),
            'RecordTypeId' => Constants.RT_ID_OPP_SALES,
            'RegionCountry__c' => 'NL'
        });
        testOpportunity = [Select Id, PriceBook2Id FROM Opportunity WHERE ID =: testOpportunity.Id];
        
        Product2 testProduct = (Product2)TestDataFactory.createSobject('Product2', new Map<String,Object>{
            'Product_Type__c' => 'Service',
            'isActive' => true,
            'CurrencyIsoCode' => 'EUR'
        });
        
        PriceBookEntry testPriceStandard = (PriceBookEntry)TestDataFactory.createSobject('PriceBookEntry', new Map<String,Object>{
            'Pricebook2Id' => Test.getStandardPricebookId(),
            'Product2Id' => testProduct.id,
            'UnitPrice' => 100.00,
            'CurrencyIsoCode' => 'EUR',
            'IsActive' => true,
            'Product_Cost_Price__c' => 20
        });
        
        PriceBookEntry testPrice = (PriceBookEntry)TestDataFactory.createSobject('PriceBookEntry', new Map<String,Object>{
            'Pricebook2Id' => testOpportunity.Pricebook2Id,
            'Product2Id' => testProduct.id,
            'UnitPrice' => 100.00,
            'CurrencyIsoCode' => 'EUR',
            'IsActive' => true,
            'Product_Cost_Price__c' => 20
        });
        
        OpportunityLineItem testLineItem = (OpportunityLineItem)TestDataFactory.createSobject('OpportunityLineItem', new Map<String,Object>{
            'OpportunityId' => testOpportunity.Id,
            'PricebookEntryId' => testPrice.Id,
            'Quantity' => 2
        });
        
        List<sObject> sourceList = new List<sObject>();
        sourceList.add(testLineItem);
        Test.startTest();
        rh2.ParentUtil.UpsertRollupTestRecords(sourceList);
        Test.stopTest();
    }
}