/**
 * @description   : User DAO test class
 * @author (s)    : BRITE
 */
@isTest
private class UserDaoTest {
    static testMethod void deploymentTest() {
    	Set<Id> accIdSet = new Set<Id>();
    	List<User> usrList = UserDao.getByRelConAccId(accIdSet);
        System.assertEquals(0,usrList.size(), 'No community users found');
        
    	usrList = UserDao.getByRelConId(accIdSet);
        System.assertEquals(0,usrList.size(), 'No community users found');
    }    
}