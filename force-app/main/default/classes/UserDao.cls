/**
 * @description User DAO class for retrieving user data from the database.
 * @author BRITE
 */
public class UserDao {

    /**
     * @description Get details of the current running user
     */
    public static User getCurrentUserDetails() {
        return [SELECT Id, UserRole.Name 
                FROM User
                WHERE Id = :UserInfo.getUserId()];
    }
    
    /**
     * @description Get details of the given users
     */
    public static List<User> getDetails(Set<Id> usrIdSet) {
        return [SELECT Id, ProfileId, Profile.Name, UserType, IsActive, ContactId, AccountId, Account.OwnerId
                FROM User
                WHERE Id IN :usrIdSet];
    } 

    /**
     * @description Get details of the given users
     * @param accountIdSet Set<Id> 
     * @return List<User>
     */
    public static List<User> getDetailsByAccountId(Set<Id> accountIdSet) {
        return [SELECT Id, ProfileId, Profile.Name, UserType, IsActive, ContactId, AccountId, Account.OwnerId 
                FROM User
                WHERE AccountId IN :accountIdSet];
    } 

    /**
     * @description Get inactive user Ids in a set
     */
    public static Set<Id> getInactiveUsers() {
        Set<Id> inactiveUserIdSet = new Set<Id>();
        List<User> userList =  [SELECT Id 
                                FROM User
                                WHERE IsActive = false];
        for (User usr : userList) {
            inactiveUserIdSet.add(usr.Id);
        }
        return inactiveUserIdSet;
    } 

}