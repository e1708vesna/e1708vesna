//Onetime use only.
public class OpportunitySnapshotBtch implements Database.Batchable<sObject>{
    
    public final Boolean fieldHistory;
    public final String fieldName;
    public final Schema.SObjectField fieldSnapshotObject;
    public final System.Type fieldSnapshotObjectType;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime currentDate = DateTime.now();
        Date dateTill = Date.Today().addMonths(-18);
        String query = 'SELECT Id, CreatedDate, ' + fieldName + ', OwnerId, OpportunitySource__c, CurrencyIsoCode, Sales_channel__c, Account.SubIndustry__c, Account.BillingCountry, AccountId, Account.Industry, Account.OwnerId, Account.RecordType.DeveloperName, Account.Account_Status__c, Account.Company_Segment__c, Account.BusinessModelBasedOnAdyenData__c, (SELECT NewValue, OldValue, CreatedDate FROM Histories WHERE Field = \'' + fieldName + '\' AND CreatedDate <= :currentDate AND CreatedDate >= :dateTill ORDER BY CreatedDate DESC) FROM Opportunity';
        //query += ' WHERE Id = \'0063W000008WKeHQAW\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Schema.DisplayType dType = fieldSnapshotObject.getDescribe().getType();
        System.Type typee = System.Type.forName(dType.name());
        Date currentDate = Date.Today();
        Date dateTillOriginal = Date.Today().addMonths(-18);
        Date dateTill = Date.Today().addMonths(-18);
        Integer dayOfMonth = 1;
        List<Snapshot__c> snapShotList = new List<SnapShot__c>();
        for(Opportunity opp : (List<Opportunity>) scope){
            dateTill = dateTillOriginal;
            if (opp.CreatedDate > dateTill){
                dateTill = Date.newInstance(opp.CreatedDate.year(), opp.CreatedDate.month(), opp.CreatedDate.day());
            }
            Map<Date, String> snapshotByDate = new Map<Date, String>();
            DateTime nextSnapshotDate;
            if (currentDate.day() > dayOfMonth){
                nextSnapshotDate = currentDate.addMonths(-1);
            }
            nextSnapshotDate = Date.newInstance(currentDate.year(), currentDate.month(), dayOfMonth);
            List<OpportunityFieldHistory> historyList = opp.Histories;
            object currentValue = opp.get(fieldName); //determin the currentValue
            for (OpportunityFieldHistory historyRecord : historyList){
                if (historyRecord.CreatedDate > nextSnapshotDate){ //nextSnapshotDate has not passed yet, update the currentValue
                    currentValue = historyRecord.oldValue;
                }
                else {//has passed: Create the snapshot(s)
                    while(historyRecord.CreatedDate < nextSnapshotDate) {
                        SnapShot__c s = initSnapshotRecord(opp, nextSnapshotDate);
                        if (currentValue != null || (fieldSnapshotObjectType == String.Class && !String.isEmpty((String) currentValue))) {
                            if (fieldSnapshotObjectType == String.Class) {
                                s.put('' + fieldSnapshotObject, currentValue);
                                if ('StageName'.equalsIgnoreCase(fieldName)){
                                    s.put('Probability__c', getProbability((String)currentValue));
                                }
                            }
                            else {
                                try {
                                    if (fieldSnapshotObjectType == Date.Class){
                                        s.put('' + fieldSnapshotObject, Date.valueOf(String.valueOf(currentValue)));
                                    }
                                    else {
                                        s.put('' + fieldSnapshotObject, Json.deserialize(String.valueOf(currentValue), fieldSnapshotObjectType));
                                    }
                                }
                                Catch (Exception e){
                                    System.debug(currentValue);
                                    throw e;
                                }
                            }
                        }
                        snapShotList.add(s);
                        //snapshotByDate.put(nextSnapshotDate.date(), currentValue);
                        nextSnapshotDate = nextSnapshotDate.addMonths(-1);
                    }
                    currentValue = historyRecord.oldValue;
                }
            }
            while(dateTill < nextSnapshotDate) { //No more history changes, so create snapshots till dateTill
                SnapShot__c s = initSnapshotRecord(opp, nextSnapshotDate);
                if (currentValue != null || (fieldSnapshotObjectType == String.Class && !String.isEmpty((String) currentValue)))  {
                    if (fieldSnapshotObjectType == String.Class) {
                        s.put('' + fieldSnapshotObject, currentValue);
                        if ('StageName'.equalsIgnoreCase(fieldName)){
                            s.put('Probability__c', getProbability((String)currentValue));
                        }
                    }
                    else {
                        try {
                            if (fieldSnapshotObjectType == Date.Class){
                                s.put('' + fieldSnapshotObject, Date.valueOf(String.valueOf(currentValue)));
                            }
                            else {
                                s.put('' + fieldSnapshotObject, Json.deserialize(String.valueOf(currentValue), fieldSnapshotObjectType));
                            }
                        }
                        Catch (Exception e){
                            System.debug(currentValue);
                            throw e;
                        }
                    }
                }
                snapShotList.add(s);
                nextSnapshotDate = nextSnapshotDate.addMonths(-1);
            }
        }
        upsert snapShotList UniqueKey__c;
        
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
    private String getTwoDigit(Integer i){
        if (i < 10){
            return '0' + String.valueOf(i);
        }
        return String.valueOf(i);
    }
    
    private SnapShot__c initSnapshotRecord(Opportunity opp, DateTime snapshotDate){
        SnapShot__c s = new SnapShot__c();
        s.SnapshotDate__c = date.newinstance(snapshotDate.year(), snapshotDate.month(), snapshotDate.day());
        s.UniqueKey__c = getTwoDigit(snapshotDate.month()) + String.valueOf(snapshotDate.year()) + '-' + opp.Id;
        if (s.UniqueKey__c == '052022-0060q00000jej9rqab'){
            System.debug('snapshotDate in init method: ' + snapshotDate);
        }
        s.Opportunity__c = opp.Id;
        s.OpportunityOwner__c = opp.OwnerId;
        s.OpportunitySource__c = opp.OpportunitySource__c;
        s.SalesChannel__c = opp.Sales_channel__c;
        s.Account__c = opp.AccountId;
        s.AccountOwner__c = ((String) opp.Account.OwnerId).startsWith('005') ? opp.Account.OwnerId : null;
        s.AccountRecordType__c = opp.Account.RecordType.DeveloperName;
        s.AccountStatus__c = opp.Account.Account_Status__c;
        s.AddressableCompanySegment__c = opp.Account.Company_Segment__c;
        s.BusinessModelBasedOnAdyenData__c = opp.Account.BusinessModelBasedOnAdyenData__c;
        s.Industry__c = opp.Account.Industry;
        s.SubIndustry__c = opp.Account.SubIndustry__c;
        s.Country__c = opp.Account.BillingCountry;
        s.CurrencyIsoCode = opp.CurrencyIsoCode;
        return s;
    }
    
    private static decimal getProbability(String stageName){
        if (stageName == 'SCOTSMAN'){
            return 10;
        }
        else if (stageName == 'Proposal/RFP Sent'){
            return 30;
        }
        else if (stageName == 'Negotiation'){
            return 50;
        }
        else if (stageName == 'Commitment'){
            return 70;
        }
        else if (stageName == 'Contract signed'){
            return 90;
        }
        else if (stageName == 'Transacting'){
            return 100;
        }
        else if (stageName == 'Closed Lost'){
            return 0;
        }
        return null;
    }
    
    
}