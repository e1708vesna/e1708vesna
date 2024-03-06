/**
 * @description   : AccountHelper business logic for the trigger
 * @author (s)    : BRITE
 */
public without sharing class AccountHelper {

	public static final String RT_DEV_NAME_CHANNEL_PARTNER = 'ChannelPartner';
	public static final String RT_DEV_NAME_END_CUSTOMER = 'EndCustomer';

	/**
	 * @description When account changes owner, all manual sharings will be deleted by Salesforce. Recreate them again.
	 * 
	 * @param updatedAccounts List of accounts that have been changed
	 * @param oldAccounts Map of accounts with previous values
	 */
	public static void createAccountSharing(List<Account> updatedAccounts, Map<Id, Account> oldAccounts) {
		Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName(RT_DEV_NAME_END_CUSTOMER, Account.getSObjectType());

		Account oldAccount;
		Set<Id> endCustomerAccounts = new Set<Id> ();
		for (Account newAccount : updatedAccounts) {
			// collect all accounts of which the owner has been changed on end customer accounts
			oldAccount = oldAccounts.get(newAccount.Id);
			if (newAccount.RecordTypeId == recIdEndCustomer && newAccount.OwnerId != oldAccount.OwnerId) {
				endCustomerAccounts.add(newAccount.Id);
			}
		}

		if (!endCustomerAccounts.isEmpty()) {
			// manual sharings need to be recreated for channel partner users

			// get all licenses for the end customers
			List<License__c> licenses = LicenseDao.getByEndCustomer(endCustomerAccounts);
			// collect channel partner by end customers
			Map<Id, Set<Id>> channelPartnersPerEndCustomer = new Map<Id, Set<Id>> ();
			Set<Id> channelPartnerAccounts = new Set<Id> ();
			for (License__c lic : licenses) {
				if (lic.EndCustomer__c != null && lic.ChannelPartner__c != null) {
					if (!channelPartnersPerEndCustomer.containsKey(lic.EndCustomer__c)) {
						channelPartnersPerEndCustomer.put(lic.EndCustomer__c, new Set<Id> ());
					}
					channelPartnersPerEndCustomer.get(lic.EndCustomer__c).add(lic.ChannelPartner__c);
					channelPartnerAccounts.add(lic.ChannelPartner__c);
				}
			}
	
			// get channel partner account-contact relations
			List<AccountContactRelation> accountContactRelations = AccountContactRelationDao.getByAccountId(channelPartnerAccounts);

			// get all related contacts
			Set<Id> contactIds = new Set<Id> ();
			for (AccountContactRelation rel : accountContactRelations) {
				contactIds.add(rel.ContactId);
			}

			// get all user records of the channel partner contacts
			List<User> channelPartnerUsers = UserDao.getByRelConId(contactIds);

			if (!channelPartnerUsers.isEmpty()) {
				Map<Id, Id> channelPartnerUserPerContact = new Map<Id, Id> ();
				Map<Id, Set<Id>> channelPartnerUsersPerAccount;

				// map user list per channel partner (Account Id)
				for (User usr : channelPartnerUsers) {
					channelPartnerUserPerContact.put(usr.ContactId, usr.Id);
				}
		
				// map channel partner user id per channel partner account id (direct and indirect)
				channelPartnerUsersPerAccount = AccountContactRelationHelper.mapChannelPartnerUsersPerAccount(accountContactRelations, channelPartnerUserPerContact);
		
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

}