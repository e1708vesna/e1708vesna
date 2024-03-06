/**
 * @description	  : Test class to verify the correctness of the methods in the class RecordTypeUtil.
 * @author (s)    : BRITE
 */
 @isTest
 private class RecordTypeUtilTest {
    
    @isTest
    public static void testGetRecordTypeIdByDevName() {
        // case 1: empty record type dev name
        Id recordTypeId = RecordTypeUtil.getRecordTypeIdByDevName(null, Account.getSObjectType());
        System.assert(recordTypeId == null, 'Case 1a: RecordType dev name is null; expected null, actual: ' + recordTypeId);
        recordTypeId = RecordTypeUtil.getRecordTypeIdByDevName('', Account.getSObjectType());
        System.assert(recordTypeId == null, 'Case 1b: RecordType dev name is empty string; expected null, actual: ' + recordTypeId);
        
        // case 2: unknown record type dev name
        recordTypeId = RecordTypeUtil.getRecordTypeIdByDevName('myRecordType', Account.getSObjectType());
        System.assert(recordTypeId == null, 'Case 2: RecordType dev name is unknown; expected null, actual: ' + recordTypeId);

        // case 3: valid record type dev name
        recordTypeId = RecordTypeUtil.getRecordTypeIdByDevName('ChannelPartner', Account.getSObjectType());
        System.assert(recordTypeId != null, 'Case 3: RecordType dev name, but RecordType not found');
    }   
    
}