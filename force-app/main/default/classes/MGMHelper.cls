public without sharing class MGMHelper {

    
    private static Map<Decimal, Decimal> ROUNDING_BUCKETS = new Map<Decimal, Decimal>{
        1000 => 100, //any value till 1000 will be rounded to the nearest 100
            10000 => 250, //any value till 10000 will be rounded to the nearest 250
            50000 => 1000,
            100000 => 5000
    };
    private static final Decimal ROUNDING_DEFAULT = 10000; //Anything above the last bucket will be rounded to this value;
    
    //Calculate the monthly gross margin
    public static Decimal calculateMGM(String field, Decimal volume){
        List<MGMTakeRates__c> applicableRates = [SELECT 
                                                 Id, 
                                                 volumeFrom__c,
                                                 VolumeTo__c,
                                                 EcomTakeRate__c,
                                                 MinimumInvoiceAmount__c,
                                                 PlatformTakeRate__c, 
                                                 PosTakeRate__c, 
                                                 UnifiedCommerceTakeRate__c 
                                                 FROM MGMTakeRates__c 
                                                 WHERE (volumeFrom__c = null OR volumeFrom__c <= :volume) AND (VolumeTo__c = null OR VolumeTo__c > :volume)
                                                ORDER BY volumeFrom__c ASC];
        if (applicableRates != null && applicableRates.size() > 0) {
            MGMTakeRates__c rate = applicableRates[0];
            Decimal obfuscatedValue = obfuscateValue(((Decimal) rate.get(field)) / 100 * volume);
            Decimal returnedValue = (rate.MinimumInvoiceAmount__c == null || (obfuscatedValue > rate.MinimumInvoiceAmount__c)) ? obfuscatedValue : rate.MinimumInvoiceAmount__c;
            return returnedValue;
        }
        return null;
    }
    
    //This method obfuscates the value by assigning it to a bucket.
    @TestVisible
    private static Decimal obfuscateValue(Decimal value){
        Decimal obfuscatedValue;
        Decimal roundTo = ROUNDING_DEFAULT;
        for (Decimal breakpoint : ROUNDING_BUCKETS.keySet()){
            if (value < breakpoint){
                roundTo = ROUNDING_BUCKETS.get(breakpoint);
                break;
            }
            
        }
        Integer multiplier = (Integer) ((value / roundTo) + 0.5);
        return roundTo * multiplier;
    }
}