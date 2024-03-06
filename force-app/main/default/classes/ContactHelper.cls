/**
 * @description   : ContactHelper business logic for the trigger
 * @author (s)    : BRITE
 */
public without sharing class ContactHelper {

	/**
	 * If the ChannelPartner Account is filled in on a license than share the related end customer account record with 
	 * all channelPartner->Contacts->User (direct and indirect)
	 * Create Account share for channelPartner Accounts->Contact->User on Accounts with licenses with the channel partner
	 */
   	public static void setAccountSharing(List<Contact> newContactList, Map<Id,Contact> oldContactMap) {
   		// on change accountId on the Contact then update sharing
		Set<Id> contactIdSet = new Set<Id> ();   
		     
   		contact oldContact; 
   		for (Contact newContact : newContactList) {
   			oldContact = oldContactMap.get(newContact.Id);
   			if (newContact.AccountId != oldContact.AccountId) {
				contactIdSet.add(newContact.Id);
   			}
   		}
   		
		List<User> channelPartnerUsers = UserDao.getByRelConId(contactIdSet);
		if (!channelPartnerUsers.isEmpty()) {
			Map<Id, Id> channelPartnerUserPerContact = new Map<Id, Id> ();
			Map<Id, Set<Id>> channelPartnerUsersPerAccount;
			Map<Id, Set<Id>> channelPartnersPerEndCustomer;

			// map user list per channel partner (Account Id)
			for (User usr : channelPartnerUsers) {
				channelPartnerUserPerContact.put(usr.ContactId, usr.Id);
			}
	
			// map channel partuer user id per channel partner account Id (direct and indirect), and visa versa
			channelPartnerUsersPerAccount = AccountContactRelationHelper.getAccountContactRelations(channelPartnerUserPerContact);
			
			// map end customer accounts per channelpartner Account
			channelPartnersPerEndCustomer = LicenseHelper.getExpectedEndCustomerChannelPartnerRelations(channelPartnerUsersPerAccount.keySet());
	
			// retrieve current account shares
			List<AccountShare> accountShareList = AccountShareDao.getByAccountId(channelPartnersPerEndCustomer.keySet());
	
			// remove obsolete account shares and build up a map of account shares with end customer account-Channel partner user Id as key
			Map<String, AccountShare> accSharePerAccIdUsrId = AccountShareHelper.deleteAccountShares(accountShareList, channelPartnersPerEndCustomer, channelPartnerUsersPerAccount, channelPartnerUserPerContact);
	
			// add new account shares
			AccountShareHelper.insertAccountShares(channelPartnersPerEndCustomer, channelPartnerUsersPerAccount, accSharePeraccIdUsrId);
		}
	}
	   
}