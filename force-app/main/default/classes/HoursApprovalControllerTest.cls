@isTest
public with sharing class HoursApprovalControllerTest {

    @testSetup
    static void makeData(){

        Integer thisYear = Date.today().Year();

        List<Account> accList = new List<Account> {
            new Account (Name = 'AccountTest'),
            new Account (Name = 'AccountTest1'),
            new Account (Name = 'AccountTest2')
            };
        insert accList; 

        List<Bezoek__c> bezoekList = new List<Bezoek__c> {
            new Bezoek__c (Name = 'BezoekTest', Datum__c = Date.newInstance(thisYear,4,12), Account__c = accList[0].Id),
            new Bezoek__c (Name = 'BezoekTest1', Datum__c = Date.newInstance(thisYear,4,27), Account__c = accList[1].Id),
            new Bezoek__c (Name = 'BezoekTest2', Datum__c = Date.newInstance(thisYear,5,5), Account__c = accList[2].Id)
            };
        insert bezoekList;
        
        List<Urenregistratie__c> urenRegistratieList = new List<Urenregistratie__c>{
            new Urenregistratie__c (Datum__c = bezoekList[0].Datum__c.date(), Uren__c = 3.50, Huishouden__c = accList[0].Id, Bezoek__c = bezoekList[0].Id, Akkoord__c = false, Opmerkingen__c = 'test'),
            new Urenregistratie__c (Datum__c = bezoekList[1].Datum__c.date(), Uren__c = 5.20, Huishouden__c = accList[1].Id, Bezoek__c = bezoekList[1].Id, Akkoord__c = false, Opmerkingen__c = 'test1'),
            new Urenregistratie__c (Datum__c = bezoekList[2].Datum__c.date(), Uren__c = 1.30, Huishouden__c = accList[2].Id, Bezoek__c = bezoekList[2].Id, Akkoord__c = false, Opmerkingen__c = 'test2')
            };
        insert urenRegistratieList;  
    }

   
    @isTest
    static void updateUrenregistratieTest() {

        String remarkTest = 'test remark';

        List<Urenregistratie__c> editedListTest = [SELECT Name, Akkoord__c, Opmerkingen__c FROM Urenregistratie__c WHERE Akkoord__c = false];
        System.assertEquals(3, editedListTest.size());
        List<Urenregistratie__c> selectedListTest = new List<Urenregistratie__c>();
        for(Urenregistratie__c editedItem : editedListTest){
            selectedListTest.add(new Urenregistratie__c(
                Id = editedItem.Id
            ));
            editedItem.Opmerkingen__c = remarkTest;
        }
        HoursApprovalController.UrenApprovalRequest uareq = new HoursApprovalController.UrenApprovalRequest();
        uareq.editedList = editedListTest;
        uareq.selectedList = selectedListTest;

        HoursApprovalController.updateUrenregistratie(new List<HoursApprovalController.UrenApprovalRequest>{uareq});  

        List<Urenregistratie__c> urenRegistratieList = [SELECT Name, Akkoord__c, Opmerkingen__c 
                                                        FROM Urenregistratie__c
                                                        WHERE Id IN :editedListTest];
        
        System.assertEquals(3, urenRegistratieList.size(), 'urenRegistratie List' + urenRegistratieList);

        for(Urenregistratie__c urItem : urenRegistratieList){
            System.assertEquals(true, urItem.Akkoord__c);
            System.assertEquals(remarkTest, urItem.Opmerkingen__c);
        }
    }

}