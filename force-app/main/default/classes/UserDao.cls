/**
 * @description   : User DAO class for retrieving User data from the database.
 * @author (s)    : BRITE
 */
public class UserDao {
    /**
     * @description Return a list of Users that have the Account Id on the related Contact.
     * 	Filter on u.UserType = 'PowerCustomerSuccess' (power community user) 
     *
     * @param accIdSet Set of Account Ids that should match the related Contact Account Field.
     * @return Returns either an empty list or a List with the details of the User.
     */
    public static List<User> getByRelConAccId(Set<Id> accIdSet) {
		return [SELECT u.Name, u.LastName, u.IsActive, u.Id, u.FirstName, u.Contact.Name, u.Contact.FirstName, u.Contact.LastName, u.Contact.AccountId, u.ContactId 
		        FROM User u 
		        WHERE u.UserType = 'PowerCustomerSuccess' AND u.Contact.AccountId in :accIdSet AND IsActive = true];    	
    }
    
    /**
     * @description Return a list of Users that have the Contact Id from the list.
     * 	Filter on u.UserType = 'PowerCustomerSuccess' (power community user) 
     *
     * @param conIdSet Set of Contact Ids that should match the related Contact Field.
     * @return Returns either an empty list or a List with the details of the User.
     */
    public static List<User> getByRelConId(Set<Id> conIdSet) {
		return [SELECT u.Name, u.LastName, u.IsActive, u.Id, u.FirstName, u.UserType, u.CompanyName, u.AccountId, 
                  u.Contact.Name, u.Contact.FirstName, u.Contact.LastName, u.Contact.AccountId, u.ContactId 
		        FROM User u 
		        WHERE u.UserType = 'PowerCustomerSuccess' AND u.ContactId in :conIdSet AND IsActive = true];    	
    }

    /**
     * @description Return a list of Users that have the Account Id on the related Contact.
     * 	Filter on u.UserType = 'PowerCustomerSuccess' (power community user) 
     *
     * @param accIdSet Set of Account Ids that should match the related Contact Account Field.
     * @return Returns either an empty list or a List with the details of the User.
     */
    public static List<User> getByIdSet(Set<Id> usrIdSet) {
		return [SELECT u.Name, u.LastName, u.IsActive, u.Id, u.FirstName, u.UserType, u.CompanyName, u.AccountId,
            u.Contact.Name, u.Contact.FirstName, u.Contact.LastName, u.Contact.AccountId, u.ContactId 
		        FROM User u 
		        WHERE u.Id in: usrIdSet];    	
    }

}