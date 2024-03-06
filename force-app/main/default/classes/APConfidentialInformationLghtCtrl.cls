public without sharing class APConfidentialInformationLghtCtrl {
    
    public Class Wrapper {
        @AuraEnabled public Decimal value;
        @AuraEnabled public String error;
        @AuraEnabled public Integer count;
        @AuraEnabled public String mvm; //merchant volume /month
        @AuraEnabled public String vmoa;//Volume / month on Adyen
        @AuraEnabled public String confidentialInformationId;
        @AuraEnabled public String currentMargin;//Volume / month on Adyen
        @AuraEnabled public String additionalMargin;
        @AuraEnabled public Decimal additionalMarginDecimal;
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
    
    //Use @AuraEnabled to enable client- and server-side access to the method
    @AuraEnabled
    public static Wrapper retrieveValues(Id recordId) {
        Wrapper w = new Wrapper();
        boolean error = false;
        Set<Id> recordIds = new Set<Id>();
        Set<Id> sowIds = new Set<Id>();
        AccountPlan__c ap = [SELECT Id, APConfidentialInformation__c FROM AccountPlan__c WHERE Id =: recordId ];
        w.confidentialInformationId = ap.APConfidentialInformation__c == null ? '' : ap.APConfidentialInformation__c;
        for (ShareOfWallet__c sow : [SELECT Id FROM ShareOfWallet__c WHERE AccountPlan__c =: recordId]){
            recordIds.add(sow.Id);
            sowIds.add(sow.Id);
        }
        recordIds.add(w.confidentialInformationId);
        List<UserRecordAccess> uraList = [SELECT RecordId, HasEditAccess, HasReadAccess FROM UserRecordAccess where UserId =: UserInfo.getUserId() and RecordId IN: recordIds];
        for (UserRecordAccess ura : uraList ) {
            if (!ura.HasReadAccess){
                w.addError('You do not have access to the Share of Wallet records and/or the AP Confidential Information record.');
                w.confidentialInformationId = '';
                return w;
            }
        }
        
        if (sowIds.size() == 0){
            w.count = 0;
            return w;
        }
        
        //Do the calculations
        AggregateResult[] aggregateResult = [SELECT Count(Id) cnt, FORMAT(SUM(CurrentAdyenMarginMonth__c)) currentMarginC, SUM(CurrentAdyenMarginMonth__c) currentMargin, FORMAT(SUM(VolumeMonthOnAdyen__c)) vmaC, SUM(VolumeMonthOnAdyen__c) vma, FORMAT(SUM(VolumeMonth__c)) vmC, SUM(VolumeMonth__c) vm 
                                             FROM ShareOfWallet__c
                                             WHERE AccountPlan__c =: recordId];
        if (aggregateResult != null && aggregateResult.size() > 0){
            if ((Integer) aggregateResult[0].get('cnt') == 0) {
                w.count = 0;
                return w;
            }
            w.count = (Integer) aggregateResult[0].get('cnt');
            Decimal vma = (Decimal) aggregateResult[0].get('vma');
            Decimal vm = (Decimal) aggregateResult[0].get('vm');
            Decimal currentMargin = (Decimal) aggregateResult[0].get('currentMargin');
            if (vm == null){
                w.addError('VolumeMonth__c is not populated on atleast one Share of Wallet record');
                error = true;
            } 
            else if( vm == 0 ){
                w.addError('VolumeMonth__c is zero on atleast one Share of Wallet record');
                error = true;
            }
            if (vma == null){
                w.addError('VolumeMonthOnAdyen__c is not populated on atleast one Share of Wallet record');
                error = true;
            }
            if (!error) {
                w.mvm = (String) aggregateResult[0].get('vmC');
                w.vmoa = (String) aggregateResult[0].get('vmaC');
                w.currentMargin = currentMargin == null ? '' : (String) aggregateResult[0].get('currentMarginC');
                w.value= vma / vm;
                w.value = (w.value * 100);
                w.value = w.value.setScale(0);
                
                
                if (currentMargin == 0  || currentMargin == null || vma == 0 || vm == 0){
                    w.additionalMargin = '';
                }
                else {
                    System.debug('CurrentMargin: ' + currentMargin);
                    System.debug('vma: ' + vma);
                    System.debug('vm: ' + vm);
                    w.additionalMarginDecimal = (currentMargin / (vma / vm) - currentMargin);
                    w.currencyIsoCode = UserInfo.getDefaultCurrency();
                    w.additionalMargin = getCents(w.additionalMarginDecimal);
                    w.additionalMargin = w.currentMargin.left(4) + w.additionalMargin; //This is a little bit of a trick
                }
            }
            
        }
        else {
            w.count = 0;
        }
        return w;
    }
    
    public static String getCents(Decimal x){
        String y = x.format();
        System.debug(y);
        String z = '.'; //Decimal seperator depends on locale
        integer trailingZeroes = 2;
        
        Decimal temp  = 2.01;
        if(temp.format().contains(',')) {
            z = ',';
        }
        if (y.contains(z)) {
            System.debug('Number Contains decimal point');
            trailingZeroes = 3 - (y.length() - y.indexOf(z));//zeroes to add
        }
        String returnValue = x.format();
        System.debug('Adding this many zeroes: ' + trailingZeroes);
        if (trailingZeroes == 2) {
            returnValue = returnValue + z;
        }
        for (Integer i = 0; i < trailingZeroes; i++){
            returnValue = returnValue + '0';
        }
        return returnValue;
        
        /*


String y = String.valueOf(x);
String z = '.';
Decimal temp  = 2.01;
if(temp.format().contains(',')) {
z = ',';
}
System.debug('Y : ' + y);
if (!y.contains(z)) {

System.debug('Y contains );
y = y.substring(0, y.indexOf(z));
if(x - Decimal.valueOf(y) == 0) {
return x.format() + z + '00';
}
}
return x.format();*/
    }
    
}