@isTest
public class MGMHelperTest {
    
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
    
    
    /*private static Decimal defaultRounding = 20000;
    private static Map<Decimal, Decimal> buckets = new Map<Decimal, Decimal>{
        1000 => 250,
            50000 => 1000,
            100000 => 5000
    };*/
    @isTest static void testObfuscate(){
        System.assertEquals(100, MGMHelper.obfuscateValue(125));
        System.assertEquals(0, MGMHelper.obfuscateValue(49));
        System.assertEquals(1000, MGMHelper.obfuscateValue(1001));
        System.assertEquals(3750, MGMHelper.obfuscateValue(3658));
        System.assertEquals(120000, MGMHelper.obfuscateValue(115000));
        System.assertEquals(130000, MGMHelper.obfuscateValue(125000));
    }
    
    @isTest static void testGetExpectedMarginNoApplicableRates(){
        System.assertEquals(null, MGMHelper.calculateMGM('PlatformTakeRate__c', 20000));
    }
    
    @isTest static void testGetExpectedMargin(){
        insert (List<MGMTakeRates__c>) Json.deserialize(rateJson, List<MGMTakeRates__c>.Class);
        System.assertEquals(70000, MGMHelper.calculateMGM('PlatformTakeRate__c', 20055500));
        
    }
}