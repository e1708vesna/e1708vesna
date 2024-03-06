/**
 * @description   : AccountShare DAO test class
 * @author (s)    : BRITE
 */
@isTest
private class AccountShareDaoTest {

    static testMethod void deploymentTest() {
    	Account acc = new Account(Name = 'CompanyNameTestClass');
    	insert Acc;
    	Set<Id> accountIdSet = new Set<Id>();
    	accountIdSet.add(acc.Id);
        List<AccountShare> accountShareList = AccountShareDao.getByAccountId(accountIdSet);
        System.assertEquals(0,accountShareList.size(), 'No manual Account Share should be found' );
    }
}