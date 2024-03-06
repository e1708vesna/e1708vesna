/**
 * @description   : AccountContactRelationHelper business logic for the trigger
 * @author (s)    : Brite
 */
public class AccountContactRelationHelper {

	/**
	 * @description Retrieve account-contact relations for indicated contacts. Return a mapping
	 *              between channel partner account id (key) and a list of channel partner contact Ids.
	 */
	public static Map<Id, Set<Id>> getAccountContactRelations(Map<Id, Id> channelPartnerUserPerContact) {
		List<AccountContactRelation> accountContactRelations = AccountContactRelationDao.getByContactId(channelPartnerUserPerContact.keySet());

		return mapChannelPartnerUsersPerAccount(accountContactRelations, channelPartnerUserPerContact);
	}

	/**
	 * @description Convert account-contact relations from list to a mapping 
	 *              between channel partner account id (key) and a list of channel partner contact Ids.
	 */	
	public static Map<Id, Set<Id>> mapChannelPartnerUsersPerAccount(List<AccountContactRelation> accountContactRelations, 
																	  Map<Id, Id> channelPartnerUserPerContact) {
		Map<Id, Set<Id>> channelPartnerUsersPerAccount = new Map<Id, Set<Id>> ();

		Id userId;
		for (AccountContactRelation rel : accountContactRelations) {
			// verify if relation is between account a channel partner contact
			if (channelPartnerUserPerContact.containsKey(rel.ContactId)) {
				userId = channelPartnerUserPerContact.get(rel.ContactId);

				if (!channelPartnerUsersPerAccount.containsKey(rel.AccountId)) {
					channelPartnerUsersPerAccount.put(rel.AccountId, new Set<Id> ());
				}
				channelPartnerUsersPerAccount.get(rel.AccountId).add(userId);
			}
		}

		return channelPartnerUsersPerAccount;																															
    }
    
    /**
     * @description Create new account sharings for channel partner user are linked (indirectly) to a new channel partner account
     */
    public static void createAccountSharing(List<AccountContactRelation> newRelations) {
        // get all related contacts
		Set<Id> contactIds = new Set<Id> ();
		for (AccountContactRelation rel : newRelations) {
            contactIds.add(rel.ContactId);
        }
        
		// get all user records of the channel partner contacts
        List<User> channelPartnerUsers = UserDao.getByRelConId(contactIds);
        if (!channelPartnerUsers.isEmpty()) {
            // map user list per channel partner (Account Id)
            Map<Id, Id> channelPartnerUserPerContact = new Map<Id, Id> ();
            for (User usr : channelPartnerUsers) {
                channelPartnerUserPerContact.put(usr.ContactId, usr.Id);
            }

            // map channel partner user id per channel partner account id (indirect)
            Map<Id, Set<Id>> channelPartnerUsersPerAccount = AccountContactRelationHelper.mapChannelPartnerUsersPerAccount(newRelations, channelPartnerUserPerContact);

			// map end customer accounts per channelpartner Account
			Map<Id, Set<Id>> channelPartnersPerEndCustomer = LicenseHelper.getExpectedEndCustomerChannelPartnerRelations(channelPartnerUsersPerAccount.keySet());
            // if there are licenses for these end customers, continue
            if (!channelPartnersPerEndCustomer.isEmpty()) {
                // retrieve current account shares
                List<AccountShare> accountShareList = AccountShareDao.getByAccountId(channelPartnersPerEndCustomer.keySet());
                Map<String, AccountShare> accSharePeraccIdUsrId = new Map<String, AccountShare> ();
                for (AccountShare accShare : accountShareList) {
                    accSharePeraccIdUsrId.put((accShare.AccountId + '_' + accShare.UserOrGroupId), accShare);
                }

                // add new account shares
                AccountShareHelper.insertAccountShares(channelPartnersPerEndCustomer, channelPartnerUsersPerAccount, accSharePeraccIdUsrId);
            }
        }
    }

    /**
     * @description Delete obsolete account sharings for channel partner users who are no longer linked to a specific channel partner account
     */
    public static void deleteAccountSharing(List<AccountContactRelation> oldRelations) {
        // get all related contacts
        Set<Id> contactIds = new Set<Id> ();
        Set<Id> indirectAccountIds = new Set<Id> ();
		for (AccountContactRelation rel : oldRelations) {
            contactIds.add(rel.ContactId);
            indirectAccountIds.add(rel.AccountId);
        }
        
		// get all user records of the channel partner contacts
        List<User> channelPartnerUsers = UserDao.getByRelConId(contactIds);
        if (!channelPartnerUsers.isEmpty()) {
            // map user list per channel partner (Account Id)
            Map<Id, Id> channelPartnerUserPerContact = new Map<Id, Id> ();
            for (User usr : channelPartnerUsers) {
                channelPartnerUserPerContact.put(usr.ContactId, usr.Id);
            }

            // map channel partner user id per channel partner account id (direct and indirect) (delete indirect relation excluded)
            List<AccountContactRelation> accountContactRelations = AccountContactRelationDao.getByContactId(contactIds);
            Map<Id, Set<Id>> channelPartnerUsersPerAccount = AccountContactRelationHelper.mapChannelPartnerUsersPerAccount(accountContactRelations, channelPartnerUserPerContact);

            // map end customer accounts per channelpartner Account (retrieve existing and deleted relations)
            Set<Id> channelPartnerAccounts = new Set<Id> (channelPartnerUsersPerAccount.keySet());
            channelPartnerAccounts.addAll(indirectAccountIds);
			Map<Id, Set<Id>> channelPartnersPerEndCustomer = LicenseHelper.getExpectedEndCustomerChannelPartnerRelations(channelPartnerAccounts);

            // retrieve current account shares
            List<AccountShare> accountShareList = AccountShareDao.getByAccountId(channelPartnersPerEndCustomer.keySet());
            Map<String, AccountShare> accSharePeraccIdUsrId = new Map<String, AccountShare> ();
            for (AccountShare accShare : accountShareList) {
                accSharePeraccIdUsrId.put((accShare.AccountId + '_' + accShare.UserOrGroupId), accShare);
            }

            // remove obsolete account shares and build up a map of account shares with end customer account-Channel partner user Id as key
            AccountShareHelper.deleteAccountShares(accountShareList, channelPartnersPerEndCustomer, channelPartnerUsersPerAccount, channelPartnerUserPerContact);
        }
    }

}