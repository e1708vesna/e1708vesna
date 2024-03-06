public class CurrencyConverter {
    private Map<String, CurrencyType> conversions = null;
    private String corporateIso = null;
    private String userIso = null;
    
    private String currencyJsonString = '[ {' + 
        '  "attributes" : {' + 
        '    "type" : "CurrencyType",' + 
        '    "url" : "/services/data/v55.0/sobjects/CurrencyType/01L240000004W63EAE"' + 
        '  },' + 
        '  "Id" : "01L240000004W63EAE",' + 
        '  "IsCorporate" : true,' + 
        '  "IsoCode" : "EUR",' + 
        '  "ConversionRate" : 1.000000,' + 
        '  "DecimalPlaces" : 2' + 
        '}, {' +  
        '  "attributes" : {' + 
        '    "type" : "CurrencyType",' + 
        '    "url" : "/services/data/v55.0/sobjects/CurrencyType/01L240000004W6XEAU"' + 
        '  },' + 
        '  "Id" : "01L240000004W6XEAU",' + 
        '  "IsCorporate" : false,' + 
        '  "IsoCode" : "USD",' + 
        '  "ConversionRate" : 1.130000,' + 
        '  "DecimalPlaces" : 2' + 
        '} ]';
    /**
* Initialize corporate currencies setup in Setup.
*/
    private void initCorpCurrencies() {
        // build once only
        if (null != this.conversions) return;
        
        // build map
        this.conversions = new Map<String, CurrencyType>();
        List<CurrencyType> currencies;
        if (Test.isRunningTest()){
            currencies = (List<CurrencyType>)Json.deserialize(currencyJsonString, List<CurrencyType>.Class);
        }
        else {
            currencies = [select Id, IsCorporate, IsoCode, ConversionRate, DecimalPlaces from CurrencyType where IsActive=true];
        }
        
        for (CurrencyType cur : currencies) {
            this.conversions.put(cur.IsoCode, cur);
            if (cur.IsCorporate) this.corporateIso = cur.IsoCode;
        }
    }
    
    
    
    /**
* Convert between two known currencies.
*/
    public Decimal convert(Decimal value, String fromIso, String toIso) {
        if (String.isEmpty(fromIso) || String.isEmpty(toIso)) {
            return value;
        }
        this.initCorpCurrencies();
        // ensure valid to/from ISO
        if (!this.conversions.containsKey(fromIso)) {
            throw new UnknownCurrencyException('Unable to find active from ISO currency ');
        }
        if (!this.conversions.containsKey(toIso)) {
            throw new UnknownCurrencyException('Unable to find active to ISO currency ');
        }
        
        // if same currencies we simply round
        if (fromIso.equalsIgnoreCase(toIso)) {
            return value.setScale(this.conversions.get(fromIso.toUpperCase()).DecimalPlaces, System.RoundingMode.HALF_UP);
        }
        
        // get values and then rate
        final CurrencyType fromCur = this.conversions.get(fromIso.toUpperCase());
        final Decimal fromRate = fromCur.ConversionRate;
        final CurrencyType toCur = this.conversions.get(toIso.toUpperCase());
        final Decimal toRate = toCur.ConversionRate;
        final Decimal rate = toRate/fromRate;
        
        // calc
        final Decimal result = value * rate;
        final Decimal resultRounded = result.setScale(toCur.DecimalPlaces, System.RoundingMode.HALF_UP);
        
        // return
        return resultRounded;
    }
    
    public class UnknownCurrencyException extends Exception {
        
    }
}