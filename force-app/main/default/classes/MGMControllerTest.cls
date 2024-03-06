@isTest
public class MGMControllerTest {

    
    private final static String rateJson = '[ {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EQSQA2"' + 
        '  },' + 
        '  "VolumeTo__c" : 75000.00,' + 
        '  "EcomTakeRate__c" : 0.00,' + 
        '  "MinimumInvoiceAmount__c" : 100.00,' + 
        '  "PlatformTakeRate__c" : 0.00,' + 
        '  "PosTakeRate__c" : 0.00,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.00,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '}, {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EPjQAM"' + 
        '  },' + 
        '  "VolumeFrom__c" : 75000.00,' + 
        '  "VolumeTo__c" : 300000.00,' + 
        '  "EcomTakeRate__c" : 1.25,' + 
        '  "PlatformTakeRate__c" : 0.98,' + 
        '  "PosTakeRate__c" : 0.64,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.80,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '}, {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EPoQAM"' + 
        '  },' + 
        '  "VolumeFrom__c" : 300000.00,' + 
        '  "VolumeTo__c" : 1000000.00,' + 
        '  "EcomTakeRate__c" : 0.99,' + 
        '  "PlatformTakeRate__c" : 0.80,' + 
        '  "PosTakeRate__c" : 0.58,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.61,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '}, {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EPtQAM"' + 
        '  },' + 
        '  "VolumeFrom__c" : 1000000.00,' + 
        '  "VolumeTo__c" : 3000000.00,' + 
        '  "EcomTakeRate__c" : 0.80,' + 
        '  "PlatformTakeRate__c" : 0.66,' + 
        '  "PosTakeRate__c" : 0.39,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.51,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '}, {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EPyQAM"' + 
        '  },' + 
        '  "VolumeFrom__c" : 3000000.00,' + 
        '  "VolumeTo__c" : 6250000.00,' + 
        '  "EcomTakeRate__c" : 0.60,' + 
        '  "PlatformTakeRate__c" : 0.48,' + 
        '  "PosTakeRate__c" : 0.29,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.41,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '}, {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EQ3QAM"' + 
        '  },' + 
        '  "VolumeFrom__c" : 6250000.00,' + 
        '  "VolumeTo__c" : 12500000.00,' + 
        '  "EcomTakeRate__c" : 0.53,' + 
        '  "PlatformTakeRate__c" : 0.42,' + 
        '  "PosTakeRate__c" : 0.23,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.31,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '}, {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EQ8QAM"' + 
        '  },' + 
        '  "VolumeFrom__c" : 12500000.00,' + 
        '  "VolumeTo__c" : 25000000.00,' + 
        '  "EcomTakeRate__c" : 0.43,' + 
        '  "PlatformTakeRate__c" : 0.35,' + 
        '  "PosTakeRate__c" : 0.19,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.28,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '}, {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EQDQA2"' + 
        '  },' + 
        '  "VolumeFrom__c" : 25000000.00,' + 
        '  "VolumeTo__c" : 50000000.00,' + 
        '  "EcomTakeRate__c" : 0.37,' + 
        '  "PlatformTakeRate__c" : 0.31,' + 
        '  "PosTakeRate__c" : 0.16,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.24,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '}, {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EQIQA2"' + 
        '  },' + 
        '  "VolumeFrom__c" : 50000000.00,' + 
        '  "VolumeTo__c" : 100000000.00,' + 
        '  "EcomTakeRate__c" : 0.31,' + 
        '  "PlatformTakeRate__c" : 0.25,' + 
        '  "PosTakeRate__c" : 0.14,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.18,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '}, {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EPuQAM"' + 
        '  },' + 
        '  "VolumeFrom__c" : 100000000.00,' + 
        '  "VolumeTo__c" : 500000000.00,' + 
        '  "EcomTakeRate__c" : 0.20,' + 
        '  "PlatformTakeRate__c" : 0.16,' + 
        '  "PosTakeRate__c" : 0.10,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.15,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '}, {' + 
        '  "attributes" : {' + 
        '    "type" : "MGMTakeRates__c",' + 
        '    "url" : "/services/data/v55.0/sobjects/MGMTakeRates__c/a3p0Q0000007EQNQA2"' + 
        '  },' + 
        '  "VolumeFrom__c" : 500000000.00,' + 
        '  "EcomTakeRate__c" : 0.20,' + 
        '  "PlatformTakeRate__c" : 0.14,' + 
        '  "PosTakeRate__c" : 0.08,' + 
        '  "UnifiedCommerceTakeRate__c" : 0.14,' + 
        '  "CurrencyIsoCode" : "EUR"' + 
        '} ]';
    
    @isTest static void initComponent(){
        MGMController.Wrapper wr = MGMController.initComponent(null);
        System.assertEquals(null, wr);
        
        Account acc = TestUtil.createAccount('TestAcc', true , false);
        acc.MerchantCoreBusinessModel__c = 'Platforms';
        insert acc;
        Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), false);
        opp.EstimatedATV__c = 1;
		opp.NumberOfTransactionsAMonth__c = 200000;
        opp.CurrencyIsoCode = 'EUR';
        opp.Sales_channel__c = 'Adyen for Platforms';
        insert opp;
        wr = MGMController.initComponent(opp.Id);
        
        System.assertEquals(opp.CurrencyIsoCode, wr.currencyIsoCode);
        System.assertEquals(null, wr.error);
        System.assertEquals(acc.MerchantCoreBusinessModel__c, wr.pillar);
        System.assertEquals(opp.Sales_channel__c, wr.salesChannel);
        
    }
    @isTest static void pushToOpportunity(){
        Account acc = TestUtil.createAccount('TestAcc', true, false);
        acc.MerchantCoreBusinessModel__c = 'Platforms';
        insert acc;
        Opportunity opp = TestUtil.createOpportunity(acc.Id, UserInfo.getUserId(), false);
        opp.EstimatedATV__c = 1;
		opp.NumberOfTransactionsAMonth__c = 200000;
        opp.CurrencyIsoCode = 'EUR';
        opp.Sales_channel__c = 'Adyen for Platforms';
        insert opp;
        
        MGMController.pushToOpportunity(opp.Id, 200, 400, 'MYR');
        opp = [SELECT Id, YearlyProcessingVolume__c, FullExpectedMonthlyGrossMargin__c FROM Opportunity WHERE Id =: opp.Id LIMIT 1];
        System.assertEquals(400, opp.FullExpectedMonthlyGrossMargin__c);
    }
    
    @isTest static void testGetExpectedMarginHappy(){
        insert (List<MGMTakeRates__c>) Json.deserialize(rateJson, List<MGMTakeRates__c>.Class);
        MGMController.WrapperCalculation wr = MGMController.calculateMonthlyMargin(20055500*12, 'Platforms', 'Adyen for Platforms', 'EUR');  
        System.assertEquals(390000.00, wr.monthlyMargin);
        wr = MGMController.calculateMonthlyMargin(20055500*12, 'NotPlatforms', 'Adyen for Platforms', 'EUR');  
        System.assertEquals(390000.00, wr.monthlyMargin);
        wr = MGMController.calculateMonthlyMargin(20055500*12, 'NotPlatforms', 'Ecom', 'EUR');  
        System.assertEquals(480000.00, wr.monthlyMargin);
        wr = MGMController.calculateMonthlyMargin(20055500*12, 'NotPlatforms', 'POS', 'EUR');  
        System.assertEquals(240000.00, wr.monthlyMargin);
        wr = MGMController.calculateMonthlyMargin(20055500*12, 'NotPlatforms', 'Omnichannel', 'EUR');  
        System.assertEquals(360000.00, wr.monthlyMargin);
       
   }
    
    @isTest static void testGetExpectedMarginUnHappyNoTakeRates(){
        MGMController.WrapperCalculation wr = MGMController.calculateMonthlyMargin(20055500*12, 'DoesNotExist', 'DoesNotExist', 'EUR');  
        System.assertEquals('Monthly Margin cannot be estimated based on this information.', wr.error);
    }
}