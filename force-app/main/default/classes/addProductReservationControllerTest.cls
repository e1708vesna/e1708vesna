@isTest
public class addProductReservationControllerTest {

    @TestSetup static void makeData() {
        //create Energiebank Account
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Test Vestiging';
        acc.RecordTypeId = recordTypeId;
        insert acc;

        //create Household Account
        Account acc2 = new Account();
        acc2.Name = 'Test Household';
        acc2.ParentId = acc.Id;
        insert acc2;

        //create 2 Products with Stock
        Product__c prod = new Product__c();
        prod.Name = 'Test Product';
        insert prod;

        Productvoorraad__c stock = new Productvoorraad__c();
        stock.Vestiging__c = acc.Id;
        stock.Product__c = prod.Id;
        stock.Aantal__c = 10;
        insert stock;

        Product__c prod2 = new Product__c();
        prod2.Name = 'Test Product 2';
        insert prod2;

        Productvoorraad__c stock2 = new Productvoorraad__c();
        stock2.Vestiging__c = acc.Id;
        stock2.Product__c = prod2.Id;
        stock2.Aantal__c = 20;
        insert stock2;

        //create Product Reservation
        ProductReservering__c reservation = new ProductReservering__c();
        reservation.Account__c = acc2.Id;
        reservation.Aantal__c = 2;
        reservation.Product__c = prod.Id;
        insert reservation;
    }
    
    @isTest static void testGetAvailableProducts() {
        //get Account Id and call method, check if we get a response.
        Id accId = [SELECT Id FROM Account WHERE Name = 'Test Household' LIMIT 1].Id;

        Test.startTest();
        String returnedJSON = addProductReservationController.getAvailableProducts(accId, 'Test Vestiging');
        Test.stopTest();

        System.assertNotEquals(null, returnedJSON);
    }

    @isTest static void testCreateReservations() {
        //create a sample JSON object and call our method.
        Product__c testProd = [SELECT Id, Name FROM Product__c WHERE Name = 'Test Product 2'];
        Id accId = [SELECT Id FROM Account WHERE Name = 'Test Household' LIMIT 1].Id;

        List<addProductReservationController.DraftReservation> reservationList = new List<addProductReservationController.DraftReservation>();
        addProductReservationController.DraftReservation instance = new addProductReservationController.DraftReservation(); 
        instance.id = testProd.Id;
        instance.name = testProd.Name;
        instance.inventory = 20;
        instance.quantity = 2;
        reservationList.add(instance);
        String myJSON = JSON.serialize(reservationList);

        Test.startTest();
        addProductReservationController.createReservations(myJSON, String.valueOf(accId));
        Test.stopTest();

        //get newly created reservation.
        ProductReservering__c pr = [SELECT Id FROM ProductReservering__c WHERE Product__c = :testProd.Id];

        //if we got anything back it means our method created a reservation correctly.
        System.assertNotEquals(null, pr);
    }

}