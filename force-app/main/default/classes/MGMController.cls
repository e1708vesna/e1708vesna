public with sharing class MGMController {

    //Wrapper class used to initiate the lightning component
    public Class Wrapper {
        @AuraEnabled public String error;
        @AuraEnabled public Decimal proccessingVolume;
        @AuraEnabled public String pillar;
        @AuraEnabled public String salesChannel;
        @AuraEnabled public String currencyIsoCode;
        
        public void addError(String message){
            if (String.isBlank(this.error)){
                this.error = message;
            }
            else {
                this.error += '\r\n' + message;
            }
        }
    }
    
    //Wrapper class to return the calculation results to the lightning component
    public Class WrapperCalculation {
        @AuraEnabled public String error;
        @AuraEnabled public Decimal monthlyMargin;
        @AuraEnabled public String currencyIsoCode;
        
        public void addError(String message){
            if (String.isBlank(this.error)){
                this.error = message;
            }
            else {
                this.error += '\r\n' + message;
            }
        }
    }
    
    //Initiate the 
    @AuraEnabled
    public static Wrapper initComponent(String recordId) {
        if (recordId == null || String.isEmpty(recordId)) {
            return null;
        }
        Wrapper w = new Wrapper();
        Opportunity opp;
        if (recordId != null && ((ID) recordId).getSObjectType().getDescribe().getName() == 'Opportunity'){
            List<Opportunity> oppList = [SELECT Id, Sales_channel__c, Account.MerchantCoreBusinessModel__c, YearlyProcessingVolume__c, CurrencyIsoCode FROM Opportunity WHERE ID =: recordId];
            if (oppList != null && oppList.size() > 0){
                opp = oppList[0];
            }
        }
        if (opp == null) {
            return w;
        }
        w.currencyIsoCode = opp.CurrencyIsoCode;
        if (opp.YearlyProcessingVolume__c != null) {
            w.proccessingVolume = (opp.YearlyProcessingVolume__c / 12).setScale(2);
        }
        w.pillar = opp.Account?.MerchantCoreBusinessModel__c;
        w.salesChannel = opp.Sales_channel__c;
        return w;
    }
    
	//Calculates and returns the expected mothly gross margin on the opportunity.
	@AuraEnabled
    public static WrapperCalculation calculateMonthlyMargin(Decimal proccessingVolume, String pillar, String salesChannel, String currencyIsoCode) {  
        CurrencyConverter cv = new CurrencyConverter();
        WrapperCalculation w = new WrapperCalculation();
        Decimal monthlyProcessingVolume = proccessingVolume;
        Decimal convertedMonthlyProcessingVolume = cv.convert(monthlyProcessingVolume, currencyIsoCode, 'EUR');
        if ('Platforms'.equals(pillar)) {
            w.monthlyMargin = cv.convert(MGMHelper.calculateMGM('PlatformTakeRate__c', convertedMonthlyProcessingVolume), 'EUR', currencyIsoCode);
            w.currencyIsoCode = currencyIsoCode;
        }
        else {
            switch on salesChannel {
                when 'Adyen for Platforms' {
                    w.monthlyMargin = cv.convert(MGMHelper.calculateMGM('PlatformTakeRate__c', convertedMonthlyProcessingVolume), 'EUR', currencyIsoCode);
                    w.currencyIsoCode = currencyIsoCode;
                }
                when 'Ecom' {
            		w.monthlyMargin = cv.convert(MGMHelper.calculateMGM('EcomTakeRate__c', convertedMonthlyProcessingVolume), 'EUR', currencyIsoCode);
                    w.currencyIsoCode = currencyIsoCode;
                }
                when 'POS' {
                    w.monthlyMargin = cv.convert(MGMHelper.calculateMGM('PosTakeRate__c', convertedMonthlyProcessingVolume), 'EUR', currencyIsoCode);
                    w.currencyIsoCode = currencyIsoCode;
                }
                when 'Omnichannel' {
                    w.monthlyMargin = cv.convert(MGMHelper.calculateMGM('UnifiedCommerceTakeRate__c', convertedMonthlyProcessingVolume), 'EUR', currencyIsoCode);
                    w.currencyIsoCode = currencyIsoCode;
                }
                when else {
                    w.addError('Monthly Margin cannot be estimated based on this information.');
                }
            }
        }
        return w;
    }
    
    //Sets the monlthy gross margin and proccessingVolume on the opportunity
    @AuraEnabled
    public static void pushToOpportunity(Id recordId, Decimal proccessingVolume, Decimal monthlyGrossMargin, String currencyIsoCode) { 
        update new Opportunity(Id = recordId, FullExpectedMonthlyGrossMargin__c = monthlyGrossMargin, IsMarginCalculatorUsed__c = true);
        //update new Opportunity(Id = recordId, Monthly_Volume__c = proccessingVolume * 12, Total_Gross_Margin_Services_Products__c = monthlyGrossMargin, CurrencyIsoCode = currencyIsoCode);
        return;
    }
    
}