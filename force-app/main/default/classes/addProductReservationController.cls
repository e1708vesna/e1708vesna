public with sharing class addProductReservationController {

    public class DraftReservation {
        public String name;
        public String id;
        public Decimal inventory;
        public Integer quantity;
        public String description;
        public String image;
    }

    @AuraEnabled
    public static String getAvailableProducts(String accountId, String vestiging) {
        //first check if there are any existing Product Reservations on the Account
        Id vestigingId = [Select Id, ParentId From Account Where Id =: accountId LIMIT 1]?.ParentId;
        Set<Id> existingProductIds = new Set<Id>();
        for (ProductReservering__c pr : [SELECT Id, Product__c 
                                        FROM ProductReservering__c 
                                        WHERE Account__c = :accountId]) {
            existingProductIds.add(pr.Product__c);
        }

        System.debug(existingProductIds);
        List<DraftReservation> draftsToReturn = new List<DraftReservation>();
        for (Product__c p : [SELECT Id, Name,Omschrijving__c,Afbeelding__c, (SELECT Id, Aantal__c FROM ProductVoorraden__r WHERE Vestiging__c = :vestigingId)
                            FROM Product__c
                            WHERE Id NOT IN :existingProductIds]) {
        //needs to be expanded when other branches start working with products  
        System.debug(JSON.serialize(p));
        if (p.ProductVoorraden__r != null && p.ProductVoorraden__r.size() > 0 && p.ProductVoorraden__r[0].Aantal__c > 0) {
                DraftReservation dr = new DraftReservation();
                dr.id           = p.Id;
                dr.name         = p.Name;
                dr.inventory    = p.ProductVoorraden__r[0].Aantal__c;
                dr.quantity     = 0;
                dr.description    = p.Omschrijving__c;
                dr.image    = p.Afbeelding__c;

                draftsToReturn.add(dr);     
            }                     
        }
        system.debug(JSON.serialize(draftsToReturn));
        return JSON.serialize(draftsToReturn);
        
    }

    @AuraEnabled
    public static void createReservations(String reservationsJSON, String accountId) {
        List<DraftReservation> reservationList = (List<DraftReservation>) JSON.deserialize(reservationsJSON, List<DraftReservation>.class);
        List<ProductReservering__c> reservationsToInsert = new List<ProductReservering__c>();
        
        for (DraftReservation dr : reservationList) {
            if (dr.quantity != 0) {
                ProductReservering__c pr = new ProductReservering__c();
                pr.Product__c = dr.id;   
                pr.Account__c = accountId;
                pr.Aantal__c = dr.quantity;
                reservationsToInsert.add(pr);   
            }   
        }

        if (reservationsToInsert.size() > 0) {
            insert reservationsToInsert;
        }
        //return reservationsToInsert;
    }

}