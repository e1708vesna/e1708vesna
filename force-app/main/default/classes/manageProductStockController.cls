public with sharing class manageProductStockController {

    public class Draft{
        public String name;
        public String id;
        public Decimal inventory;
        public Decimal quantity;
    }

    @AuraEnabled
    public static String getAvailableProducts(String accountId) {
        //first check if there are any existing Product Reservations on the Account
        List<Draft> draftsToReturn = new List<Draft>();
        for (Product__c p : [SELECT Id, Name, (SELECT Id, Aantal__c FROM ProductVoorraden__r WHERE Vestiging__c = :accountId)
                            FROM Product__c
                            ]) {
        //needs to be expanded when other branches start working with products  
        Draft dr = new Draft();
            dr.id           = p.Id;
            dr.name         = p.Name;
            dr.inventory    = null;
            dr.quantity     = 0;
                if (p.ProductVoorraden__r != null && p.ProductVoorraden__r.size() > 0 && p.ProductVoorraden__r[0].Aantal__c > 0) {
                    dr.inventory    = p.ProductVoorraden__r[0].Aantal__c;
                    dr.quantity    = p.ProductVoorraden__r[0].Aantal__c;
                }
            

            draftsToReturn.add(dr);     
                                 
        }
        system.debug(JSON.serialize(draftsToReturn));
        return JSON.serialize(draftsToReturn);
        
    }

    @AuraEnabled
    public static void updateProductStock(String stockJson, String accountId) {
        System.debug(stockJson);
        List<Draft> reservationList = (List<Draft>) JSON.deserialize(stockJson, List<Draft>.class);
        List<ProductVoorraad__c> voorraadToUpsert = new List<ProductVoorraad__c>();
        
        for (Draft dr : reservationList) {
            if (dr.quantity != null) {
                ProductVoorraad__c pv = new ProductVoorraad__c();
                pv.UniqueKey__c = accountId + dr.id;
                pv.Product__c = dr.id;   
                pv.Vestiging__c = accountId;
                pv.Aantal__c = dr.quantity;
                voorraadToUpsert.add(pv);   
            }   
        }

        if (voorraadToUpsert.size() > 0) {
            upsert voorraadToUpsert UniqueKey__c;
        }
    }

}