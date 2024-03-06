/**
 * @description   : LicenseHelper business logic for the trigger
 * @author (s)    : Brite
 */
public without sharing class LicenseHelper {
    // Help variable for testing date related functionality
    public static Boolean skipUpdateUACSummaryFields = false;
    
	/**
	 * Create Account share for channelPartner Accounts->Contact->User on end customer accounts
	 */
    public static void updateFieldsLicenseItem(List<License__c> newLicenseList, Map<Id, License__c> oldLicenseMap) {
        Set<Id> licenseIdSet = new Set<Id>();
        License__c licOld;
        for (License__c lic : newLicenseList) {
            licOld = oldLicenseMap.get(lic.Id);
            if (licOld != null && licOld.Currency__c != lic.Currency__c) {
                licenseIdSet.add(lic.Id);
            }
        }
        update LicenseDao.getLicenseItems(licenseIdSet);
    }

    /**
     * Recalculate the fields 'Upgrade Assurance Contract Value', 'NumOfActiveUAC', 'Number of Upgrade Assurance Contracts'
     * and 'Number of Open Upgrade Assurance Contracts'.
     */
    public static void updateUACSummaryFields(Set<Id> licenseIdSet) {
        if (skipUpdateUACSummaryFields || licenseIdSet == null || licenseIdSet.isEmpty()) {
            return;
        }
        updateLicenseTotals(LicenseDao.getByIdWithUACDetails(licenseIdSet));
    }

    /**
     * Recalculate the fields 'Upgrade Assurance Contract Value', 'NumOfActiveUAC', 'Number of Upgrade Assurance Contracts'
     * and 'Number of Open Upgrade Assurance Contracts'.
     * no update
     */
    public static void updateLicenseTotals(List<License__c> licenses) {
        List<License__c> updatedLicenses = new List<License__c> ();
        List<UpgradeAssuranceContract__c> uacList;
        for (License__c lic : licenses) {
            // calculate total billing amount of UAC iwth record type 'Activated Contract'
            Decimal billingAmount = 0;
            // count number of active upgrade assurance contracts
            Integer nbrActiveUACs = 0;
            // count number of upgrade assurance contracts with record type 'Activated Contract' (active or expired)
            Integer nbrActivatedUACs = 0;
            // count number of open (cloned or pending) upgrade assurance contracts
            Integer nbrOpenUACs = 0;
            // most recent activated contract
            Id lastActivatedContract;

            uacList = lic.UpgradeAssurances__r;
            String recordTypeDevName;
            for (UpgradeAssuranceContract__c uac : uacList) {
                recordTypeDevName = uac.RecordType.DeveloperName;
                if (recordTypeDevName == UpgradeAssuranceContractHelper.RT_DEV_NAME_ACTIVATED_CONTRACT) {
                    if (uac.CombinedBillingAmount__c != null) {
                        billingAmount += uac.CombinedBillingAmount__c;
                    }
                    nbrActivatedUACs += 1;
                    if (uac.Active__c) {
                        nbrActiveUACs += 1;
                    }            
                    if (uac.Stage__c == 'Order' && uac.StartDateLine__c <= Date.today()) {
                        //Take the first from the list that is within the date
                        if (lastActivatedContract == null) {
                            lastActivatedContract = uac.Id;
                        }
                    }
                } else if (recordTypeDevName == UpgradeAssuranceContractHelper.RT_DEV_NAME_PENDING_CONTRACT
                    || recordTypeDevName == UpgradeAssuranceContractHelper.RT_DEV_NAME_CLONED_CONTRACT) {
                    nbrOpenUACs += 1;
                }
            } 
            
            if (lic.TotalUACValue__c != billingAmount
                || lic.NumberActiveUACs__c != nbrActiveUACs
                || lic.NumberUACs__c != nbrActivatedUACs
                || lic.NumberOpenUACs__c != nbrOpenUACs
                || lic.LastActivatedUAC__c != lastActivatedContract) {
                
                updatedLicenses.add(new License__c (
                    Id = lic.Id,
                    TotalUACValue__c = billingAmount,
                    NumberActiveUACs__c = nbrActiveUACs,
                    NumberUACs__c = nbrActivatedUACs,
                    NumberOpenUACs__c = nbrOpenUACs,
                    LastActivatedUAC__c = lastActivatedContract));
            }
        }
        if (!updatedLicenses.isEmpty()) {
            SkipTrigger.LicenseSkip = true;
            update updatedLicenses;
            SkipTrigger.LicenseSkip = false;
        }
    }

    /**
	 * @description Based on existing License records, get all relations between end customer accounts and channel partner accounts. 
	 * 
	 * @param endCustomerAccountIds Set of account IDs of channel partners 
	 */
	public static Map<Id, Set<Id>> getExpectedEndCustomerChannelPartnerRelations(Set<Id> channelPartnerAccountIds) {
		Map<Id, Set<Id>> channelPartnersPerEndCustomer = new Map<Id, Set<Id>> ();

		List<License__c> licenseList = LicenseDao.getByChannelPartner(channelPartnerAccountIds);
		for (License__c lic : licenseList) {
			if (lic.ChannelPartner__c != null && lic.EndCustomer__c != null) {
				if (!channelPartnersPerEndCustomer.containsKey(lic.EndCustomer__c)) {
					channelPartnersPerEndCustomer.put(lic.EndCustomer__c, new Set<Id> ());
				}
				channelPartnersPerEndCustomer.get(lic.EndCustomer__c).add(lic.ChannelPartner__c);
			}
		}

		return channelPartnersPerEndCustomer;
	}

	/**
	 * @description For indicated channel partner users create account shares for these users.
	 *              Users can be linked directly or indirectly to a Channel Partner account. The user
	 *              should have visibility on the end customer account's for which one or more licenses exist.
	 * 
	 * @param licenseList List of channel partner users (user ID with their contact ID) for which account sharing 
	 * 				needs to be created. It will NOT verify if the sharing already exists
	 */
	public static void createAccountSharing(List<License__c> licenseList) {
		Map<Id, Id> channelPartnerUserPerContact = new Map<Id, Id> ();
		Map<Id, Set<Id>> channelPartnerUsersPerAccount;
		Map<Id, Set<Id>> channelPartnersPerEndCustomer = new Map<Id, Set<Id>> ();
		Set<Id> channelPartnerAccounts = new Set<Id> ();

		// collect channel partner and end customers
        for (License__c lic : licenseList) {
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

	/**
	 * @description Create/update Account share for channelPartner Accounts->Contact->User on end customer accounts
	 */
   	public static void recalculateAccountSharing(List<License__c> newLicenseList, Map<Id, License__c> oldLicenseMap) {
		Map<Id, Id> channelPartnerUserPerContact = new Map<Id, Id> ();
		Map<Id, Set<Id>> channelPartnerUsersPerAccount;
        Map<Id, Set<Id>> channelPartnersPerEndCustomer = new Map<Id, Set<Id>> ();
        Set<Id> channelPartnerAccounts = new Set<Id> ();
        Set<Id> endCustomerAccounts = new Set<Id> ();

        if (oldLicenseMap == null) {
            oldLicenseMap = new Map<Id, License__c> ();
        }

        // collect channel partner and end customers
        License__c oldLic;
        for (License__c newLic : newLicenseList) {
            oldLic = oldLicenseMap.get(newLic.Id);
            if (oldLic != null 
                && (newLic.ChannelPartner__c != oldLic.ChannelPartner__c || newLic.EndCustomer__c != oldLic.EndCustomer__c)) {

                if (oldLic.EndCustomer__c != null && oldLic.ChannelPartner__c != null) {
                    endCustomerAccounts.add(oldLic.EndCustomer__c);
                    channelPartnerAccounts.add(oldLic.ChannelPartner__c);
                }
                if (newLic.EndCustomer__c != null && newLic.ChannelPartner__c != null) {
                    endCustomerAccounts.add(newLic.EndCustomer__c);
                    channelPartnerAccounts.add(newLic.ChannelPartner__c);
                }
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
   		// map user list per channel partner (Account Id)
		for (User usr : channelPartnerUsers) {
			channelPartnerUserPerContact.put(usr.ContactId, usr.Id);
		}

		// map channel partner user id per channel partner account id (direct and indirect)
		channelPartnerUsersPerAccount = AccountContactRelationHelper.mapChannelPartnerUsersPerAccount(accountContactRelations, channelPartnerUserPerContact);

		// retrieve current account shares
		List<AccountShare> accountShareList = AccountShareDao.getByAccountId(endCustomerAccounts);

        // get all existing licenses of the end customers
        List<Account> accWithLicensesList = AccountDao.getByIdWithLicenses(endCustomerAccounts);
        // create a mapping between end customer account and a set of channel account Id's
        for (Account acc : accWithLicensesList) {
            channelPartnerAccounts = new Set<Id> ();
            for (License__c lic : acc.LicensesCustomer__r) {
                channelPartnerAccounts.add(lic.ChannelPartner__c);
            }
            channelPartnersPerEndCustomer.put(acc.Id, channelPartnerAccounts);
        }

		// remove obsolete account shares and build up a map of account shares with end customer account-Channel partner user Id as key
        Map<String, AccountShare> accSharePerAccIdUsrId = AccountShareHelper.deleteAccountShares(accountShareList, channelPartnersPerEndCustomer, channelPartnerUsersPerAccount, channelPartnerUserPerContact);

		// add new account shares
		AccountShareHelper.insertAccountShares(channelPartnersPerEndCustomer, channelPartnerUsersPerAccount, accSharePeraccIdUsrId);
   	} 

	/**
	 * @description Update Account share for channelPartner Accounts->Contact->User on end customer accounts upon delete of a license.
     * Runs after delete of a license.
	 */
   	public static void deleteAccountSharing(List<License__c> oldLicenseList) {
		Map<Id, Id> channelPartnerUserPerContact = new Map<Id, Id> ();
		Map<Id, Set<Id>> channelPartnerUsersPerAccount;
        Map<Id, Set<Id>> channelPartnersPerEndCustomer = new Map<Id, Set<Id>> ();
        Set<Id> channelPartnerAccounts = new Set<Id> (); // all channel partners related to the end customers
        Set<Id> endCustomerAccounts = new Set<Id> ();
        
		// collect channel partner and end customers
        for (License__c lic : oldLicenseList) {
            if (lic.EndCustomer__c != null && lic.ChannelPartner__c != null) {
                endCustomerAccounts.add(lic.EndCustomer__c);
                channelPartnerAccounts.add(lic.ChannelPartner__c); // channel partners from licenses that are deleted
            }
        }
        
        // retrieve current account shares
        List<AccountShare> accountShareList = AccountShareDao.getByAccountId(endCustomerAccounts);
        
        // get all existing licenses of the end customers
        List<Account> accWithLicensesList = AccountDao.getByIdWithLicenses(endCustomerAccounts);
        // create a mapping between end customer account and a set of channel account Id's
        Set<Id> tmpChannelPartners = new Set<Id> ();
        for (Account acc : accWithLicensesList) {
            tmpChannelPartners = new Set<Id> ();
            for (License__c lic : acc.LicensesCustomer__r) {
                tmpChannelPartners.add(lic.ChannelPartner__c);
                channelPartnerAccounts.add(lic.ChannelPartner__c); // channel partners from existing licenses
            }
            channelPartnersPerEndCustomer.put(acc.Id, tmpChannelPartners);
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
   		// map user list per channel partner (Account Id)
		for (User usr : channelPartnerUsers) {
			channelPartnerUserPerContact.put(usr.ContactId, usr.Id);
		}

		// map channel partner user id per channel partner account id (direct and indirect)
		channelPartnerUsersPerAccount = AccountContactRelationHelper.mapChannelPartnerUsersPerAccount(accountContactRelations, channelPartnerUserPerContact);

		// remove obsolete account shares and build up a map of account shares with end customer account-Channel partner user Id as key
        AccountShareHelper.deleteAccountShares(accountShareList, channelPartnersPerEndCustomer, channelPartnerUsersPerAccount, channelPartnerUserPerContact);
    }


//------------------------- Recalculation -------------------------------
    /**
     * @description Update Totaal Prices om changes in the LicenseItems
     * call from the License trigger before insert/update
     * @param newList
     */
    public static void updateTotalPrices (Map<Id,License__c> newLicMap) {
        List<LicenseItem__c> licItemList = LicenseDao.getLicenseItems (newLicMap.keySet ());
        List<LicenseItem__c> tmpLicItemList = new List<LicenseItem__c> ();
        Map<Id, List<LicenseItem__c>> licIdItemMap = new Map<Id, List<LicenseItem__c>> ();

        for (License__c lic : newLicMap.values()) {
            lic.LicenseValue__c = 0;
        }

        for (LicenseItem__c licItem : licItemList) {
            tmpLicItemList = licIdItemMap.get (licItem.License__c);
            if (tmpLicItemList == null) {
                tmpLicItemList = new List<LicenseItem__c> ();
            }
            tmpLicItemList.add (licItem);
            licIdItemMap.put (licItem.License__c, tmpLicItemList);
        }
        List<ExportFactor__c> efList = ExportFactorDao.getAll ();
        Map<String,ExportFactor__c> efMap = new Map<String,ExportFactor__c> ();
        
        for (ExportFactor__c ef : efList) {
            efMap.put (ef.Name, ef);
        }

    	List<MSRP__c> msrpList = MsrpDao.getByArticleNumberToday(efMap.keySet());
    	//Put the result in a article map per currency map with minimum order variants
    	Map<String,List<MSRP__c>> artNoMsrpTmpMap = new Map<String,List<MSRP__c>>();
    	Map<String,Map<String,List<MSRP__c>>> currArtNoMsrpMap = new Map<String,Map<String,List<MSRP__c>>>();
    	List<MSRP__c> msrpTmpList;
        String curr;
        String artNo;
    	for (MSRP__c msrp : msrpList) {
    		artNo = msrp.ArticleNumber__c;
    		curr = msrp.Currency__c;
    		if (curr == null || curr == '') {
    			curr = 'EUR';
    		}
    		artNoMsrpTmpMap = currArtNoMsrpMap.get(curr);
    		if (artNoMsrpTmpMap == null) {
    			artNoMsrpTmpMap = new Map<String,List<MSRP__c>>();
				msrpTmpList = null;
    		} else {
    			msrpTmpList = artNoMsrpTmpMap.get(artNo);
    		}
    		if (msrpTmpList == null) {
    			msrpTmpList = new List<MSRP__c>();
    		}
    		msrpTmpList.add (msrp);
    		artNoMsrpTmpMap.put (artNo,msrpTmpList);
    		currArtNoMsrpMap.put (curr, artNoMsrpTmpMap);
    	}

        License__c lic;
        for (String licId : licIdItemMap.keySet ()) {
            //get the License__c
            lic = newLicMap.get (licId);
            //get the article list for this currency
    		curr = lic.Currency__c;
    		if (curr == null || curr == '') {
    			curr = 'EUR';
    		}            
            artNoMsrpTmpMap = currArtNoMsrpMap.get(curr);
            calculatelicPrice (lic, licIdItemMap.get (licId), efList, efMap, artNoMsrpTmpMap, curr);
        }
    }

    private static void calculatelicPrice (License__c lic, List<LicenseItem__c> licIdItemList, 
            List<ExportFactor__c> efList, Map<String,ExportFactor__c> efMap, Map<String,List<MSRP__c>> artNoMsrpTmpMap, String curr) {
        //normal -> summary License Item: Total Price (TotalPrice__c)
		String errMsg = '';

        if (artNoMsrpTmpMap == null) {
            errMsg += 'No articles found for License: ' + lic.Id + ' in Msrp for Currency: ' + curr + '\n';
        } else {
            List<MSRP__c> msrpTmpList;
            Map<String,ExportFactorData> exportDataMap = new Map<String,ExportFactorData>();
            ExportFactorData exportFactorDataTmp;

            Decimal licenseValue = 0;
            Decimal licenseOrgValue = 0;

            List<LicenseItem__c> liciTmpList;
            Map<String, List<LicenseItem__c>> artNoLiciMap = new Map<String, List<LicenseItem__c>> ();

            //Calculate the correct quantity per export factor articles
            //If article not known in export factors table -> item->TotalPrice__c for de price!!
            ExportFactor__c ef;
            for (LicenseItem__c licIdItem : licIdItemList) {
                ef = efMap.get (licIdItem.ArtNo__c);
                licenseOrgValue += licIdItem.TotalPrice__c;
                if (ef == null) {
                    licenseValue += licIdItem.TotalPrice__c;
                } else {
                    //Make for the current ef lici a map to compare later
                    liciTmpList = artNoLiciMap.get (licIdItem.ArtNo__c);
                    if (liciTmpList == null) {
                        liciTmpList = new List<LicenseItem__c> ();
                    }
                    liciTmpList.add (licIdItem);
                    artNoLiciMap.put (licIdItem.ArtNo__c, liciTmpList);
                    //

                    //Save current selected quantities
                    msrpTmpList = artNoMsrpTmpMap.get (licIdItem.ArtNo__c);

                    exportFactorDataTmp = exportDataMap.get (ef.ExportCode__c);
                    if (exportFactorDataTmp == null) {
                        exportFactorDataTmp = new ExportFactorData (ef.ExportCode__c);
                    }
                    exportFactorDataTmp.quantity += (licIdItem.Quantity__c * ef.ExportFactor__c);
                    exportFactorDataTmp.restQuantity += (licIdItem.Quantity__c * ef.ExportFactor__c);
                    exportDataMap.put (ef.ExportCode__c, exportFactorDataTmp);
                }
            }

            //item->TotalPrice__c voor de price!!

            Decimal factor;
            LicenseItem__c li;
            for (ExportFactor__c eftmp : efList) {
                msrpTmpList = artNoMsrpTmpMap.get (eftmp.Name);
                if (msrpTmpList == null || msrpTmpList[0] == null || msrpTmpList[0].UnitPrice__c == null) {
                    errMsg += 'No article found for License: ' + lic.Id + ' in Msrp for Article Number ' + eftmp.Name + ' with Currency' + curr + '\n';
                } else {
                    if (msrpTmpList.size () != 1) {
                        errMsg += 'Multiple articles found for License: ' + lic.Id + ' in Msrp for Article Number ' + eftmp.Name + ' with Currency' + curr + '\n';
                    } 
                    exportFactorDataTmp = exportDataMap.get (eftmp.ExportCode__c);
                    if (exportFactorDataTmp == null) {
                        exportFactorDataTmp = new ExportFactorData (eftmp.ExportCode__c);
                    }
                    exportFactorDataTmp.restPrice = msrpTmpList[0].UnitPrice__c;
                    factor = (exportFactorDataTmp.restQuantity / eftmp.ExportFactor__c).round (System.RoundingMode.DOWN);
                    exportFactorDataTmp.price += (factor * exportFactorDataTmp.restPrice);
                    exportFactorDataTmp.restQuantity -= (eftmp.ExportFactor__c * factor);
                    exportDataMap.put (efTmp.ExportCode__c, exportFactorDataTmp);
                }
            }

            // Add rest price if rest quantity is not 0 and sum al prices
            Decimal efPriceTotal = 0;
            for (String key : exportDataMap.keySet()) {
                exportFactorDataTmp = exportDataMap.get (key);
                if (exportFactorDataTmp.restQuantity != 0) {
                    exportFactorDataTmp.price += exportFactorDataTmp.restPrice;
                }
                efPriceTotal += exportFactorDataTmp.price;
            }

            licenseValue += efPriceTotal;
            //End result
            lic.licenseValue__c = licenseValue;
            lic.licenseOrgValue__c = licenseOrgValue;
        }        
        if (errMsg != '') {
			CustomLog.create(CustomLog.WARNING, 'License Total Price Errors', errMsg, '');
        }

    }

    public class ExportFactorData {
        String exportCode;
        Decimal quantity;
        Decimal restQuantity;
        Decimal price;
        Decimal restPrice;

        public ExportFactorData(String exportCode) {
            this.exportCode = exportCode;
            this.quantity = 0;
            this.restQuantity = 0;
            this.price = 0;
            this.restPrice = 0;
        }
    }

//-----------------------------------------------------------------------
}