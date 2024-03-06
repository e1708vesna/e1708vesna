/**
 * @description   : AccountShare business logic for the trigger
 * @author (s)    : Brite
 */
public without sharing class AccountShareHelper {

    private static final String ACCOUNT_ACCESS_LEVEL = 'Edit';
    private static final String OPPORTUNITY_ACCESS_LEVEL = 'Read';
    private static final String CASE_ACCESS_LEVEL = 'Read';

    /**
     * @description Create account share record
     *
     * @accId Account ID
     * @usrId User ID
     */
    public static AccountShare createAccountShare (Id accId, Id usrId) {
        return new AccountShare (
                        AccountId = accId,
                        UserOrGroupId = usrId,
                        AccountAccessLevel = ACCOUNT_ACCESS_LEVEL,
                        //ContactAccessLevel = 'Edit',
                        OpportunityAccessLevel = OPPORTUNITY_ACCESS_LEVEL,
                        CaseAccessLevel = CASE_ACCESS_LEVEL,
                        RowCause = 'Manual');
    }

    /**
     * @description Save new account share
     */
    public static void insertAccountShares (List<AccountShare> accountShareToInsert) {
   		Integer i = 0;
   		Integer suc6Cnt = 0;
   		Integer errCnt = 0;
   		String suc6Msg = '';
   		String errMsg = '';

		if (accountShareToInsert != null && !accountShareToInsert.isEmpty()) {
	    	Database.SaveResult[] srList = Database.insert(accountShareToInsert, false);
			for(Database.SaveResult sr : srList) {
			    if (sr.isSuccess()) {
			        // Operation was successful
					suc6Cnt++;
					suc6Msg += 'Id: ' + accountShareToInsert[i].Id + '\n'; 
			    }
			    else {
			    	errCnt++;
			        // Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
						errMsg += 'Id: ' + accountShareToInsert[i].Id + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
			        }
			        errMsg += '\n';
			    }
			    i++;
			}
		} 
		if (suc6Cnt!=0) {
	        System.debug('Successfully inserted ' + suc6Cnt + ' AccountShare(s)');
			CustomLog.log(CustomLog.INFO, 'Successfully inserted ' + suc6Cnt + ' AccountShare(s)', suc6Msg, '');
    	}
    	if (errCnt!=0) {
			System.debug(errMsg);
			CustomLog.log(CustomLog.ERROR, 'Failed to inserted ' + errCnt + ' AccountShare(s)', errMsg, '');
    	}        
	}
	
	/**
	 * @description Create and insert new account shares.
	 * 
	 * @param channelPartnersPerEndCustomer Map between end customer account (key) and channel partner accounts (values)
	 * 					that should have visibility to the end customer account 
	 * @param channelPartnerUsersPerAccount Map between channel partner acount (key) and their directly or indirectly
	 *                  related channel partner users (values)
	 * @param accSharePeraccIdUsrId Existing account sharing rule with <accountId>_<UserOrGroupId> as key
	 */
	public static void insertAccountShares(Map<Id, Set<Id>> channelPartnersPerEndCustomer, 
										   Map<Id, Set<Id>> channelPartnerUsersPerAccount, 
										   Map<String, AccountShare> accSharePeraccIdUsrId) {

		List<AccountShare> accountShareToInsert = new List<AccountShare>();
		Set<Id> channelPartnerAccounts;
		Set<Id> channelPartnerUsers;

		Set<Id> endCustomerAccounts = channelPartnersPerEndCustomer.keySet();
		for (Id endCustomerAcc : endCustomerAccounts) {
			channelPartnerAccounts = channelPartnersPerEndCustomer.get(endCustomerAcc);
			for (Id cpAcc : channelPartnerAccounts) {
				channelPartnerUsers = channelPartnerUsersPerAccount.get(cpAcc);
				if (channelPartnerUsers != null) {
					// if there are channel partner users for that account
					for (Id cpUser : channelPartnerUsers) {
						// if not already exists, create a new account share
						if (!accSharePeraccIdUsrId.containsKey(endCustomerAcc + '_' + cpUser)) {
							accountShareToInsert.add(createAccountShare(endCustomerAcc, cpUser));
						}
					}
				}
			}
		}
        insertAccountShares(accountShareToInsert);
	}

    /**
     * @description Delete existing account shares
     */
    public static void deleteAccountShares (List<AccountShare> accountShareToDelete) {
   		Integer i = 0;
   		Integer suc6Cnt = 0;
   		Integer errCnt = 0;
   		String suc6Msg = '';
   		String errMsg = '';

		if (accountShareToDelete != null && !accountShareToDelete.isEmpty()) {
	    	Database.DeleteResult[] drList = Database.delete(accountShareToDelete, false);
			for(Database.DeleteResult dr : drList) {
			    if (dr.isSuccess()) {
			        // Operation was successful
					suc6Cnt++;
					suc6Msg += 'Id: ' + accountShareToDelete[i].Id + '\n'; 
			    }
			    else {
			    	errCnt++;
			        // Operation failed, so get all errors                
			        for(Database.Error err : dr.getErrors()) {
						errMsg += 'Id: ' + accountShareToDelete[i].Id + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
			        }
			        errMsg += '\n';
			    }
			    i++;
			}
		} 
		if (suc6Cnt!=0) {
	        System.debug('Successfully deleted ' + suc6Cnt + ' AccountShare(s)');
			CustomLog.log(CustomLog.INFO, 'Successfully deleted ' + suc6Cnt + ' AccountShare(s)', suc6Msg, '');
    	}
    	if (errCnt!=0) {
			System.debug(errMsg);
			CustomLog.log(CustomLog.ERROR, 'Failed to deleted ' + errCnt + ' AccountShare(s)', errMsg, '');
    	}        
	}

    /**
     * @description Delete existing account shares. Returns map of account shares that weren't deleted.
	 * 
	 * @param accountShareList Current list of accountShare records that needs to be verified for deletion
	 * @param channelPartnersPerEndCustomer Mapping between end customer account ID (key) and channel partner account ID (value) that still need to exist
	 * @param channelPartnerUsersPerAccount Mapping between channel partner account ID (key) and channel partner users IDs (value)
	 * @param channelPartnerUserPerContact Mapping between channel partner contact ID (key) and channel partner user ID (value)
     */
	public static Map<String, AccountShare> deleteAccountShares(List<AccountShare> accountShareList, 
																Map<Id, Set<Id>> channelPartnersPerEndCustomer, 
																Map<Id, Set<Id>> channelPartnerUsersPerAccount, 
																Map<Id, Id> channelPartnerUserPerContact) {
		List<Id> channelPartnerUserIdSet = channelPartnerUserPerContact.values();

		List<AccountShare> accountShareToDelete = new List<AccountShare>();   
		Map<String, AccountShare> accSharePeraccIdUsrId = new Map<String, AccountShare> ();
		Set<Id> channelPartnerAccounts;
		Set<Id> channelPartnerUsers;
		Boolean keepSharing;
		for (AccountShare accShare : accountShareList) {
			// verify if account is shared with a channel partner user
			if (channelPartnerUserIdSet.contains(accShare.UserOrGroupId)) {
				channelPartnerAccounts = channelPartnersPerEndCustomer.get(accShare.AccountId);
				if (channelPartnerAccounts == null) {
					// sharing between channel partner and end customer can be removed
					accountShareToDelete.add(accShare);
				} else {
					keepSharing = false;
					for (Id cpAcc :  channelPartnerAccounts) {
						channelPartnerUsers = channelPartnerUsersPerAccount.get(cpAcc);
						if (channelPartnerUsers != null) {
							for (Id cpUser : channelPartnerUsers) {
								if (cpUser == accShare.UserOrGroupId) {
									keepSharing = true;
									accSharePeraccIdUsrId.put((accShare.AccountId + '_' + accShare.UserOrGroupId), accShare);
									break;
								}
							}
						}

						if (keepSharing) {
							// break of the search if the correct share is found
							break;
						}
					}

					if (!keepSharing) {
						// finished search, but combination end-customer account with channel partner user is not needed
						accountShareToDelete.add(accShare);
					}
				}
			}
        }
		deleteAccountShares(accountShareToDelete);

		return accSharePeraccIdUsrId;
	}

}