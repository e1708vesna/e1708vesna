/**
 * @description Test class to verify the correctness of the methods in the class UserDao.
 * @author BRITE
 */
@isTest
private class UserDaoTest {

    @isTest
    public static void testGetCurrentUserDetails() {
        User usr = UserDao.getCurrentUserDetails();
        system.assertEquals(UserInfo.getUserId(), usr.Id, 'User ID');
    }
    
    @isTest
    public static void testGetDetails() {
        List<User> usrList = UserDao.getDetails(new Set<Id> {UserInfo.getUserId()});
        
        system.assertNotEquals(null, usrList, 'Result list is empty');
        system.assertEquals(1, usrList.size(), 'Number of users returned');
    }

    @isTest
    public static void testGetInactiveUsers() {
        Set<Id> userIdSet = UserDao.getInactiveUsers();
        
        system.assertNotEquals(null, userIdSet, 'Result list is empty');
        system.assert(!userIdSet.contains(UserInfo.getUserId()), 'Current user cannot be inactive');
    }  
    
}