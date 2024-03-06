@isTest
public class RelationshipMergeUtilityTest {

    
    @isTest
    private static void mergeAccounts(){
        //Insert test data
        Account partnerAcc = TestUtil.createAccount('PartnerAccount', false, false);
        Account masterAcc = TestUtil.createAccount('Master', true, false);
        Account slaveAcc = TestUtil.createAccount('Slave', true, false);
        List<Account> accList = new List<Account>();
        accList.add(masterAcc);
        accList.add(slaveAcc);
        accList.add(partnerAcc);
        insert accList;
        PartnerType__c pt = new PartnerType__c(Account__c = partnerAcc.Id, Type__c = 'Value Added Service (VAS)', SubType__c = 'Order Management Systems (OMS)');
        PartnerType__c pt2 = new PartnerType__c(Account__c = partnerAcc.Id, Type__c = 'Value Added Service (VAS)', SubType__c = 'Loyalty');
        List<PartnerType__c> partnerTypeList = new List<PartnerType__c>();
        partnerTypeList.add(pt);
        partnerTypeList.add(pt2);
        insert partnerTypeList;
        
        List<Relationship__c> relationShips = new List<Relationship__c>();
        relationShips.add(new Relationship__c(Account__c = slaveAcc.Id, PartnerType__c = pt.Id));
        relationShips.add(new Relationship__c(Account__c = masterAcc.Id, PartnerType__c = pt.Id));
        relationShips.add(new Relationship__c(Account__c = slaveAcc.Id, PartnerType__c = pt2.Id));
        insert relationShips;
        
        //Merge master and slave accounts
        merge masterAcc slaveAcc;
        
        List<Relationship__c> resultingRelationships = [SELECT Id,
                                                        Account__c,
                                                        Lead__c,
                                                        Opportunity__c,
														PartnerType__c
                                                        FROM Relationship__c
                                                        WHERE Account__c = :slaveAcc.Id OR Account__c = :masterAcc.Id];
        
        System.assertEquals(2, resultingRelationships.size(), 'Expected 2 Relationships.');
        Integer pt1Count = 0;
        Integer pt2Count = 0;
        for (Relationship__c rShip : resultingRelationships){
            system.assertEquals(masterAcc.Id, rShip.Account__c);
            if (rShip.PartnerType__c == pt.Id){
                pt1Count++;
            }
            else if (rShip.PartnerType__c == pt2.Id){
                pt2Count++;
            }
            else {
                System.assert(False); //Should not occur.
            }
        }
        System.assertEquals(1, pt1Count);
        System.assertEquals(1, pt2Count);
    }
    
    @isTest
    private static void mergeLeads(){
        //Insert test data
        Account partnerAcc = TestUtil.createAccount('PartnerAccount', false, false);
        insert partnerAcc;
        List<PartnerType__c> partnerTypeList = new List<PartnerType__c>();
        PartnerType__c pt = new PartnerType__c(Account__c = partnerAcc.Id, Type__c = 'Value Added Service (VAS)', SubType__c = 'Order Management Systems (OMS)');
        PartnerType__c pt2 = new PartnerType__c(Account__c = partnerAcc.Id, Type__c = 'Value Added Service (VAS)', SubType__c = 'Loyalty');
        partnerTypeList.add(pt);
        partnerTypeList.add(pt2);
        insert partnerTypeList;
        List<Lead> ldList = new List<Lead>();
        Lead masterLd = TestUtil.createLead('PartnerLeadMaster', Constants.RT_ID_LEAD_INBOUND2, false);
        Lead slaveLd = TestUtil.createLead('PartnerLeadSlave', Constants.RT_ID_LEAD_INBOUND2, false);
        ldList.add(masterLd);
        ldList.add(slaveLd);
        insert ldList;
        List<Relationship__c> relationShips = new List<Relationship__c>();
        relationShips.add(new Relationship__c(Lead__c = slaveLd.Id, PartnerType__c = pt.Id));
        relationShips.add(new Relationship__c(Lead__c = masterLd.Id, PartnerType__c = pt.Id));
        relationShips.add(new Relationship__c(Lead__c = slaveLd.Id, PartnerType__c = pt2.Id));
        insert relationShips;
        
        //Merge master and slave accounts
        merge masterLd slaveLd;
        
        List<Relationship__c> resultingRelationships = [SELECT Id,
                                                        Account__c,
                                                        Lead__c,
                                                        Opportunity__c,
														PartnerType__c
                                                        FROM Relationship__c
                                                        WHERE Lead__c = :slaveLd.Id OR Lead__c = :masterLd.Id];
        
        System.assertEquals(2, resultingRelationships.size(), 'Expected 2 Relationships.');
        Integer pt1Count = 0;
        Integer pt2Count = 0;
        for (Relationship__c rShip : resultingRelationships){
            system.assertEquals(masterLd.Id, rShip.Lead__c);
            if (rShip.PartnerType__c == pt.Id){
                pt1Count++;
            }
            else if (rShip.PartnerType__c == pt2.Id){
                pt2Count++;
            }
            else {
                System.assert(False); //Should not occur.
            }
        }
        System.assertEquals(1, pt1Count);
        System.assertEquals(1, pt2Count);
    }
}