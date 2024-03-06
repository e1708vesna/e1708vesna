@isTest
public class ApexSharingUtilsTest {
	@isTest
    private static void cleanseShares (){
        
        
        
        Id userId1 = '000000000000000001';
        Id userId2 = '000000000000000002';
        Id userId3 = '000000000000000003';
        Id userId4 = '000000000000000004';
        Id accountId = '000000000000000005';
        Map<Id, Map<Id, sObject>> existingShares= new Map<Id, Map<Id, sObject>>();
        Map<Id, Map<Id, sObject>> newShares= new Map<Id, Map<Id, sObject>>();
        List<sObject> upsertList = new List<sObject>();
        List<sObject> deleteList = new List<sObject>();
        
        
        ApexSharingUtils.cleanseShares(existingShares, newShares, upsertList, deleteList);
        System.assertEquals(0, upsertList.size(), 'Upsert List should be empty');
        System.assertEquals(0, deleteList.size(), 'delete List should be empty');
        
        
        
        //one in existing that is not in new
        //one in new that is not in existing
        //one in existing and new
        //one in existing and new that have different access rights
        Map<Id, sObject> existingShareMap = new Map<Id, sObject>();
        sObject existingShareRecord1 = createShareRecord('Read', accountId, 'Reason', userId1);
        existingShareMap.put(userId1, existingShareRecord1);
        sObject existingShareRecord3 = createShareRecord('Read', accountId, 'Reason', userId3);
        existingShareMap.put(userId3, existingShareRecord3);
        sObject existingShareRecord4 = createShareRecord('Read', accountId, 'Reason', userId4);
        existingShareMap.put(userId4, existingShareRecord4);
        existingShares.put(accountId, existingShareMap);
            
        Map<Id, sObject> newShareMap = new Map<Id, sObject>();
        sObject shareRecord2 = createShareRecord('Read', accountId, 'Reason', userId2);
        newShareMap.put(userId2, shareRecord2);
        sObject shareRecord3 = createShareRecord('Read', accountId, 'Reason', userId3);
        newShareMap.put(userId3, shareRecord3);
        sObject shareRecord4 = createShareRecord('Edit', accountId, 'Reason', userId4);
        newShareMap.put(userId4, shareRecord4);
        newShares.put(accountId, newShareMap);
        
        ApexSharingUtils.cleanseShares(existingShares, newShares, upsertList, deleteList);
        System.assertEquals(2, upsertList.size(), 'Upsert List should have one entry');
        System.assertEquals(1, deleteList.size(), 'delete List should have two entries');
    }
    
    private static sObject createShareRecord(String accessLevel, Id parentId, String rowCause, Id userOrGroupId){
        sObject record = Schema.getGlobalDescribe().get('AccountShare').newSObject();//Use account as an sObject because it exists in every salesforce org.
        record.put('AccountAccessLevel', accessLevel);
        record.put('AccountId', parentId);
        record.put('RowCause', rowCause);
        record.put('UserOrGroupId', userOrGroupId);
        return record;
    }
}