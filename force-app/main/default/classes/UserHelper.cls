/**
 * @description   : UserHelper business logic for the trigger
 * @author (s)    : BRITE
 */
public without sharing class UserHelper {
	/**
	 * Create Account share for all accounts that has license items related to the partner account (User->Contact->Account).
	 */
   	public static void setAccountSharing(List<User> newUserList) {
		Set<Id> userIdSet = new Set<Id>();
   		for (User usr : newUserList) {
			userIdSet.add(usr.Id);
		}
		setAccountSharingFuture(userIdSet);
	}

	@future
	private static void setAccountSharingFuture(Set<Id> userIdSet) {
		List<User> newUserList = UserDao.getByIdSet(userIdSet);

		List<User> channelPartnerUsers = new List<User> ();
		for (User usr : newUserList) {
			if (usr.UserType == 'PowerCustomerSuccess' && usr.AccountId != null) {
				channelPartnerUsers.add(usr);
			}
		}

		if (!channelPartnerUsers.isEmpty()) {
			Map<Id, Id> channelPartnerUserPerContact = new Map<Id, Id> ();
			Map<Id, Set<Id>> channelPartnerUsersPerAccount;
			Map<Id, Set<Id>> channelPartnersPerEndCustomer;
	
			   // map user list per channel partner (Account Id)
			for (User usr : channelPartnerUsers) {
				channelPartnerUserPerContact.put(usr.ContactId, usr.Id);
			}
	
			// map channel partuer user id per channel partner account Id (direct and indirect)
			channelPartnerUsersPerAccount = AccountContactRelationHelper.getAccountContactRelations(channelPartnerUserPerContact);
			   
			// map end customer accounts per channelpartner Account
			channelPartnersPerEndCustomer = LicenseHelper.getExpectedEndCustomerChannelPartnerRelations(channelPartnerUsersPerAccount.keySet());
	
			// add new account shares
			AccountShareHelper.insertAccountShares(channelPartnersPerEndCustomer, channelPartnerUsersPerAccount, new Map<String, AccountShare> ());
		}
   	}    

}