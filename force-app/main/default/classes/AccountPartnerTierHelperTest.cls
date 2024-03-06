@isTest
public class AccountPartnerTierHelperTest {

    /*
     * New Account under parentId
     * Change top parent tier
     * Change tier child 
     * Reparent child to other Account Hierarchy
     * Delete top tier account
     * */
    
    
    @testSetup static void testSetup(){
        Map<String, Account> accMap = new Map<String, Account>();
        accMap.put('H1A1', TestUtil.createAccount('H1A1', false, False));
        accMap.put('H1A2', TestUtil.createAccount('H1A2', false, False));
        accMap.put('H1A3', TestUtil.createAccount('H1A3', false, False));
        accMap.put('H2A1', TestUtil.createAccount('H2A1', false, False));
        accMap.get('H2A1').Tier__c = 'Tier 1';
        accMap.get('H1A1').Tier__c = 'Tier 2';
        insert accMap.values();
        TestUtil.createPartnerType(accMap.values(), true);
        accMap.get('H1A2').parentId = accMap.get('H1A1').Id;
        accMap.get('H1A3').parentId = accMap.get('H1A2').Id;
        update accMap.values();
    }
    
    
    @isTest
    private static void newAccountExistingHierarchy(){ //Can't be a partner when inserting a new account, only when inserting a new Partner Type
        Map<String, Account> accMap = queryAccountMap();
        System.assertEquals('Tier 2', accMap.get('H1A3').Tier__c);
        Account testAccount = TestUtil.createAccount('H1A4', false, false);
        testAccount.ParentId = accMap.get('H1A3').Id;
        Test.startTest();
        insert testAccount;
        TestUtil.createPartnerType(testAccount, true);
        Test.stopTest();
        accMap = queryAccountMap();
        System.assertEquals('Tier 2', accMap.get('H1A4').Tier__c);
    }
    
    @isTest
    private static void changeTopParentTier(){
        Map<String, Account> accMap = queryAccountMap();
        System.assertEquals('Tier 2', accMap.get('H1A1').Tier__c);
        System.assertEquals('Tier 2', accMap.get('H1A2').Tier__c);
        System.assertEquals('Tier 2', accMap.get('H1A3').Tier__c);
        
        accMap.get('H1A1').Tier__c = 'Tier 3';
        
        Test.startTest();
        update accMap.get('H1A1');
        Test.stopTest();
        accMap = queryAccountMap();
        System.assertEquals('Tier 3', accMap.get('H1A1').Tier__c);
        System.assertEquals('Tier 3', accMap.get('H1A2').Tier__c);
        System.assertEquals('Tier 3', accMap.get('H1A3').Tier__c);
    }
    
    @isTest
    private static void changechildTier(){
        Map<String, Account> accMap = queryAccountMap();
        System.assertEquals('Tier 2', accMap.get('H1A1').Tier__c);
        System.assertEquals('Tier 2', accMap.get('H1A2').Tier__c);
        System.assertEquals('Tier 2', accMap.get('H1A3').Tier__c);
        
        accMap.get('H1A2').Tier__c = 'Tier 3';
        String errorMessage = '';
        Test.startTest();
        try {
            update accMap.get('H1A2');
        }
        Catch (Exception e){
            errorMessage = e.getMessage();
        }
        Test.stopTest();
        System.debug(errorMessage);
        System.assert(errorMessage.contains(AccountPartnerTierHelper.VALIDATION_MESSAGE), 'Expected a validation error');
        
    }
    
    @isTest
    private static void reparentMidChild(){
        Map<String, Account> accMap = queryAccountMap();
        System.assertEquals('Tier 2', accMap.get('H1A1').Tier__c);
        System.assertEquals('Tier 2', accMap.get('H1A2').Tier__c);
        System.assertEquals('Tier 2', accMap.get('H1A3').Tier__c);
        System.assertEquals('Tier 1', accMap.get('H2A1').Tier__c);
        
        Test.startTest();
        accMap.get('H1A2').ParentId = accMap.get('H2A1').Id;
        update accMap.get('H1A2');
        Test.stopTest();
        
        accMap = queryAccountMap();
        
        System.assertEquals('Tier 1', accMap.get('H1A2').Tier__c);
        System.assertEquals('Tier 1', accMap.get('H1A3').Tier__c);
        System.assertEquals('Tier 1', accMap.get('H2A1').Tier__c);
        System.assertEquals('Tier 2', accMap.get('H1A1').Tier__c);
        
    }
    
    @isTest
    private static void deleteTopTierAccount(){
        Map<String, Account> accMap = queryAccountMap();
        System.assertEquals('Tier 2', accMap.get('H1A1').Tier__c);
        System.assertEquals('Tier 2', accMap.get('H1A2').Tier__c);
        System.assertEquals('Tier 2', accMap.get('H1A3').Tier__c);
        
        Test.startTest();
        delete accMap.get('H1A1');
        Test.stopTest();
        
        accMap = queryAccountMap();
        
        System.assertEquals('Tier 2', accMap.get('H1A2').Tier__c);
        System.assertEquals('Tier 2', accMap.get('H1A3').Tier__c);
        
    }
    
    private static Map<String, Account> queryAccountMap(){
        Map<String, Account> accMap = new Map<String, Account>();
        for (Account acc : [SELECT ID, Name, ParentId, Tier__c FROM Account]){
            accMap.put(acc.Name, acc);
        }
        return accMap;
    }
    
}