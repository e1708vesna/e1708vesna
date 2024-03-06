public class PartnerEcommerceLghtCtrl {
    
    public class wrapperClass {
        @AuraEnabled public List<partnerData> partnerData;
        @AuraEnabled public List<String> partnersNotFound;
        @AuraEnabled public List<String> partnersExisting;
        public void addPartnerData(List<partnerData> partnerData, Set<String> partnersNotFound, Set<String> partnersExisting){
            this.partnerData = partnerData.clone();
            this.partnersNotFound = new List<String>();
            this.partnersNotFound.addAll(partnersNotFound);
            this.partnersExisting = new List<String>();
            this.partnersExisting.addAll(partnersExisting);
        }
        
    }
    
    public class partnerData {
        @AuraEnabled public String partnerName;
        @AuraEnabled public String url;
        @AuraEnabled public String accountId;
        @AuraEnabled public String accountName;
        @AuraEnabled public Boolean platform;
        @AuraEnabled public Boolean ecom;
        @AuraEnabled public Boolean pos;
        
        partnerData(String partnerName, Id accountId, String accountName, Boolean platformPartner, Boolean ecom, Boolean pos) {
            this.partnerName = partnerName;
            this.accountId = accountId;
            this.accountName = accountName;
            this.url = '/' + accountId;
            this.platform = platformPartner;
            this.ecom = ecom;
            this.pos = pos;
        }
    }
    
    @auraEnabled
    public static wrapperClass getEcommercePartnerss(String recordId){
        Map<String, EcomAccountMapping__c> mappingInsertMap = new Map<String, EcomAccountMapping__c>();
        Map<String, PartnerData> partnerMap = new Map<String, PartnerData>();
        Set<String> notFoundList = new Set<String>();
        Set<String> existingList = new Set<String>();
        wrapperClass wc = new wrapperClass();
        
        //Grab partner String and all Lead Partners
        Lead leadRecord = [Select Id, ECOMMERCE_PLATFORM__c, POS_Software__c, CbEcommercePlatform__c, (Select Id, Partner__c, Platform__c FROM Lead_Partners__r WHERE Platform__c = true) FROM Lead WHERE Id =: recordId LIMIT 1];
        
        retrievePartners(wc, leadRecord, partnerMap, notFoundList, existingList, mappingInsertMap);
        wc.addPartnerData(partnerMap.values(), notFoundList, existingList);
        insert mappingInsertMap.values();
        System.debug(Json.serializePretty(wc));
        return wc;
    }
    
    public static void retrievePartners(wrapperClass wc, Lead ld, Map<String, PartnerData> partnerMap, Set<String> notFoundList, Set<String> existingList, Map<String, EcomAccountMapping__c> mappingInsertMap){
        Set<String> exisitingPartners = new Set<String>();
        for (LeadPartner__c lp : ld.Lead_Partners__r){
            exisitingPartners.add(lp.Partner__c);
        }
        
        //Get a list of partners from the ecomm field, Clearbit and PoS field
        //Gather the partner information within in the partner fields on lead
        Set<String> fieldNames = new Set<String>{'ECOMMERCE_PLATFORM__c', 'POS_Software__c', 'CbEcommercePlatform__c'};
        Set<String> partners = new Set<String>();
        Set<String> ecomPartners = extractPartnersFromString(ld.ECOMMERCE_PLATFORM__c);
        Set<String> posPartners = extractPartnersFromString(ld.POS_Software__c);
        Set<String> cbPartners = extractPartnersFromString(ld.CbEcommercePlatform__c);
        partners.addAll(ecomPartners);
        partners.addAll(posPartners);
        partners.addAll(cbPartners);
        
        System.debug(JSON.serializePretty(partners));
        //Query the mapping from custom setting
        List<EcomAccountMapping__c> partnerMappingList = [Select Name, PartnerName__c, AccountId__c FROM EcomAccountMapping__c WHERE Name in: partners];
        Map<String, EcomAccountMapping__c> accountByEcom = new Map<String, EcomAccountMapping__c>();
        Set<String> accountIds = new Set<String>();
        for (EcomAccountMapping__c mapping : partnerMappingList){
            if (!mapping.AccountId__c.equalsIgnoreCase('TBD') && !mapping.AccountId__c.equalsIgnoreCase('N/A')){
                accountIds.add(mapping.AccountId__c);
            }
            accountByEcom.put(mapping.PartnerName__c.toLowerCase(), mapping);
        }
        Map<Id, Account> accountMap = new Map<Id,Account>([Select Id, Name, Platform__c FROM Account Where Id in: accountIds]);
        
        //Go through all partners and put them in the appropriate list.
        for (String partner : partners){
            if (accountByEcom.containsKey(partner.toLowerCase())){
                
                String accountId = accountByEcom.get(partner.toLowerCase()).AccountId__c;
                if (exisitingPartners.contains(accountId)){ //Is this already a lead partner?
                    existingList.add(partner);
                }
                else if(!accountId.equalsIgnoreCase('N/A') && !accountId.equalsIgnoreCase('TBD')){
                    boolean ecom = ecomPartners.contains(partner) || cbPartners.contains(partner);
                    boolean pos = posPartners.contains(partner);
                    if (!partnerMap.containsKey(accountId)) {
                    	partnerMap.put(accountId, new partnerData(partner, accountId, accountMap.get(accountId).Name, accountMap.get(accountId).Platform__c, ecom, pos));
                    }
                    else {
                        partnerMap.get(accountId).partnerName +=', ' + partner;
                        if (ecom && !partnerMap.get(accountId).ecom){
                            partnerMap.get(accountId).ecom = true;
                        }
                        if (pos && !partnerMap.get(accountId).pos){
                            partnerMap.get(accountId).pos = true;
                        }
                    }
                }
                else {
                    notFoundList.add(partner);
                }
            }
            else {
                notFoundList.add(partner);
                mappingInsertMap.put(partner, new EcomAccountMapping__c(Name = partner.left(35), PartnerName__c = partner, AccountId__c = 'TBD'));                
            }
        }
    }
    
    @auraEnabled
    public static void insertPartners(String recordId, List<Map<String, Object>> accList){
        List<LeadPartner__c> upsertList = new List<LeadPartner__c>();
        //First check if these partners already exist
        
        Map<Id, LeadPartner__c> existingPartnerMap = new Map<Id, LeadPartner__c>();
        for (LeadPartner__c p : [Select Id, Lead__c, Partner__c, Platform__c FROM LeadPartner__c WHERE Lead__c =: recordId]) {
            existingPartnerMap.put(p.Partner__c, p);
        }
        for (Map<String, Object> account : accList){
            String accountId = (String)account.get('accountId');
            if (existingPartnerMap.containsKey(accountId)){
                LeadPartner__c p = existingPartnerMap.get(accountId);
                if (!p.Platform__c) {
                    p.Platform__c = true;
                    upsertList.add(p);
                }
            }
            else {
                upsertList.add(new LeadPartner__c(Lead__c = recordId, Platform__c = true, Partner__c = accountId));
            }
        }
        try {
            upsert upsertList;
        }
        catch (Exception e){
            throw new AuraHandledException('Something went wrong: '
            + e.getMessage());    
        }
    }
    
    private static Set<String> extractPartnersFromString(String str){
        Set<String> partnerSet = new Set<String>();
        if (!String.isBlank(str)){
            //Get a list of partners from the ecomm field
            List<String> partnersUnTrimmed = str.split(';');
            for (String partner : partnersUnTrimmed){
                String partnerTrimmed = partner.trim();
                if (!String.isBlank(partnerTrimmed)){
                    partnerSet.add(partnerTrimmed);
                }
            }
        }
        return partnerSet;
    }
    
}