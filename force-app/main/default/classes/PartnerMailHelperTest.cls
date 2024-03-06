/**
 * @description   : PartnerMailHelper test class
 * @author (s)    : BRITE
 */
@isTest
public class PartnerMailHelperTest {
    
    @isTest
    public static void testEmail(){
        Account acc = TestUtil.createAccount('TestAccount', RecordTypeUtil.getRecordTypeIdByDevName('ChannelPartner', Schema.SObjectType.Account.getSobjectType()), true);
        Contact con = TestUtil.createContact ('FirstName', 'LastName', 'FirstNameLastName@example.com', acc.Id, true);
        List<Account> accList = [SELECT Id, (SELECT Id, Email FROM Contacts) FROM Account];
        PartnerMailHelper.sendBatchMail(accList, 'ContractRenewalReminder2', 'Test@test.com');
        PartnerMailHelper.sendBatchMail(accList, 'ContractRenewalReminder', 'Test@test.com');
        //No emails are send, so no assert possible
    }
}