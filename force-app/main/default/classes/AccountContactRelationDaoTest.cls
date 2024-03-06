/**
 * @description   : Account-Contact relation DAO test class
 * @author (s)    : BRITE
 */
@isTest
private class AccountContactRelationDaoTest {

    static testMethod void getByContactIdTest() {
        Id channelPartnerAccRecTypeId = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
        Account channelAcc1 = TestUtil.createAccount('Channel partner account 1', channelPartnerAccRecTypeId, false);
        Account channelAcc2 = TestUtil.createAccount('Channel partner account 2', channelPartnerAccRecTypeId, false);
        insert new List<Account> {channelAcc1, channelAcc2};

        Contact channelPartnerCon = TestUtil.createContact('Fred', 'Channel Partner', 'fred@unittest.nl.fake', channelAcc1.Id, true);
        AccountContactRelation relation = TestUtil.createIndirectAccountContactRelation(channelAcc2.Id, channelPartnerCon.Id, true);

        List<AccountContactRelation> resultList = AccountContactRelationDao.getByContactId(new Set<Id> {channelPartnerCon.Id});
        System.assertNotEquals(null, resultList, 'No account-contact relations found');
        System.assertEquals(2, resultList.size(), 'Two account-contact relations should be there (one indirect and one direct)');
    }

    static testMethod void getByAccountIdTest() {
        Id channelPartnerAccRecTypeId = RecordTypeUtil.getRecordTypeIdByDevName(AccountHelper.RT_DEV_NAME_CHANNEL_PARTNER, Account.getSObjectType());
        Account channelAcc1 = TestUtil.createAccount('Channel partner account 1', channelPartnerAccRecTypeId, false);
        Account channelAcc2 = TestUtil.createAccount('Channel partner account 2', channelPartnerAccRecTypeId, false);
        insert new List<Account> {channelAcc1, channelAcc2};

        Contact channelPartnerCon = TestUtil.createContact('Fred', 'Channel Partner', 'fred@unittest.nl.fake', channelAcc1.Id, true);
        AccountContactRelation relation = TestUtil.createIndirectAccountContactRelation(channelAcc2.Id, channelPartnerCon.Id, true);

        List<AccountContactRelation> resultList = AccountContactRelationDao.getByAccountId(new Set<Id> {channelAcc1.Id});
        System.assertEquals(1, resultList.size(), 'Two account-contact relations should be there (one direct)');
        resultList = AccountContactRelationDao.getByAccountId(new Set<Id> {channelAcc2.Id});
        System.assertEquals(1, resultList.size(), 'Two account-contact relations should be there (one indirect)');
    }

}