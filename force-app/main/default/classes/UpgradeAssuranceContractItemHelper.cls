/**
 * @description   : UpgradeAssuranceContractItemHelper business logic for the trigger
 * @author (s)    : Brite
 */
public without sharing class UpgradeAssuranceContractItemHelper {
    
    private static Map<Id,Boolean> recalculateMap = new Map<Id,Boolean>(); //Used to pass the recalculate value between before and after trigger

    /**
     * @description check, store for the transaction, and reset the recalculatioon checkbox
     */
    public static void checkRecalculate(List<UpgradeAssuranceContract__c> newList, Map<Id, UpgradeAssuranceContract__c> oldMap) {
        if (oldMap != null || !oldMap.isEmpty()) {
            UpgradeAssuranceContract__c oldUac = null;
            for (UpgradeAssuranceContract__c newUac : newList) {
                oldUac = oldMap.get(newUac.Id);
                UpgradeAssuranceContractItemHelper.recalculateMap.put(newUac.Id,(newUac.Recalculate__c != oldUac.Recalculate__c));
                newUac.Recalculate__c = false;
            }
        }
    }

    /**
     * @description check if the record is locked or is temp unlocked
     */
    public static void checkLock(List<UpgradeAssuranceContract__c> newList, Map<Id, UpgradeAssuranceContract__c> oldMap) {
        if (oldMap != null || !oldMap.isEmpty()) {
            UpgradeAssuranceContract__c oldUac = null;
            for (UpgradeAssuranceContract__c uacNew : newList) {
                oldUac = oldMap.get(uacNew.Id);
                if (oldUac.Lock__c && oldUac.RequestUnlock__c == uacNew.RequestUnlock__c && !(oldUac.Invoice__c == null && oldUac.Invoice__c != uacNew.Invoice__c)) {
                    uacNew.addError(Label.RecordLocked);
                }
                uacNew.RequestUnlock__c = false;
            }
        }
    }

    /**
     * @description Set the name with the correct otrder number CUA-{00000}-{YYYY(StartDateLine__c)}
     */
    public static void setOrderNumberName(List<UpgradeAssuranceContract__c> newList) {
        Date sdyr;
        String licenseNumber;
        // get all Licenses
        Set<id> licenseIdSet = new Set<Id> ();
        for (UpgradeAssuranceContract__c uac : newList) {
            licenseIdSet.add(uac.License__c);
        }
        Map<Id,License__c> licenseMap = new Map<Id,License__c>(LicenseDao.getById(licenseIdSet));
        if (!licenseMap.isEmpty()) {
        
            for (UpgradeAssuranceContract__c uac : newList) {
                sdyr = uac.StartDateLine__c;
                if (sdyr == null) {
                    sdyr = Date.today();
                }
                licenseNumber = licenseMap.get(uac.license__c).Name;
                uac.Name = 'CUA-' + licenseNumber + '-' + sdyr.year();
            }
        }
    }

    /**
     * @description Create Upgrade Assurance Contract Item based on License Item record.
     */
    public static UpgradeAssuranceContractItem__c createUpgradeAssuranceContractItem(UpgradeAssuranceContract__c uac, LicenseItem__c licItem) {
        UpgradeAssuranceContractItem__c uacItem = new UpgradeAssuranceContractItem__c();
        copyLicenseItemData(uacItem, licItem);
        uacItem.UpgradeAssuranceContract__c = uac.Id;
        uacItem.PriceDate__c = uac.StartDateLine__c;
        
        return uacItem;
    }

    /**
     * @description Create a copy of all related license items into Upgrade Assurance Contract Items
     *              Runs after insert of a new Upgrade Assurance Contract
     * Only on Insert!
     */ 
    public static void cloneLicenseItems(List<UpgradeAssuranceContract__c> newList) {
        if (newList.isEmpty()) {
            return;
        }
        
        // get all License Items
        Set<id> licenseIdSet = new Set<Id> ();
        Set<id> parentUacIdSet = new Set<Id> ();
        for (UpgradeAssuranceContract__c uac : newList) {
            if (uac.License__c != null) {
                licenseIdSet.add(uac.License__c);
            }
            if (uac.ParentUAC__c != null) {
                parentUacIdSet.add(uac.ParentUAC__c);
            }
        }
        List<LicenseItem__c> licenseItemList = LicenseDao.getLicenseItems(licenseIdSet);
        
        Map<Id, List<LicenseItem__c>> licenseItemMap = new Map<Id, List<LicenseItem__c>> ();
        if (!licenseItemList.isEmpty()) {
            // convert list into a map with license ID as key
            licenseItemMap = convertLicenseItemListToMap(licenseItemList);
        }

        List<UpgradeAssuranceContractItem__c> uacItemList = UpgradeAssuranceContractItemDao.getContractItems(parentUacIdSet);
        Map<Id, List<UpgradeAssuranceContractItem__c>> uacItemByParentUacIdMap = new Map<Id, List<UpgradeAssuranceContractItem__c>> ();
        if (!uacItemList.isEmpty()) {
            // convert list into a map with license ID as key
            uacItemByParentUacIdMap = convertUacItemListToMap(uacItemList); //TODO this failes on the use of the parent Id
        }

        Set<Id> doneLicense = new Set<Id>();

        // clone license items to upgrade assucense contract items
        List<UpgradeAssuranceContractItem__c> newUACItemList = new List<UpgradeAssuranceContractItem__c> ();
        UpgradeAssuranceContractItem__c uacItem;
        Set<String> articleNumberSet = new Set<String> ();
        Date minStartDate = null;
        Map<Id,LicenseItem__c> licenseItemByIdMap;
        for (UpgradeAssuranceContract__c uac : newList) {
            licenseItemList = licenseItemMap.get(uac.License__c);
            licenseItemByIdMap = new Map<Id,LicenseItem__c>();
            if (licenseItemList != null) {
                licenseItemByIdMap = new Map<Id,LicenseItem__c>(licenseItemList);
            }
            uacItemList = uacItemByParentUacIdMap.get(uac.ParentUAC__c);
            doneLicense = new Set<Id>();
            if (uacItemList != null) {
                //This order in case there are more upgrade assurance contract items on the same license item
                LicenseItem__c li;
                
                for (UpgradeAssuranceContractItem__c uacTmpItem : uacItemList) {
                    if (uacTmpItem.LicenseItem__c != null) {
                        li = licenseItemByIdMap.get(uacTmpItem.LicenseItem__c);
                        if (li != null) {
                            uacItem = createUpgradeAssuranceContractItem(uac, li);
                            copyUacItemData(uacItem, uacTmpItem);
                            
                            newUACItemList.add(uacItem);
                            
                            // collect article number and minimal price date for MSRP retrieval later on 
                            articleNumberSet.add(uacItem.ArticleNumber__c);
                            if (minStartDate == null || minStartDate > uacItem.PriceDate__c) {
                                minStartDate = uacItem.PriceDate__c;
                            }
                
                            doneLicense.add(uacItem.LicenseItem__c);
                        }
                    }
                } 
                               
            }  
            //This order in case there are more upgrade assurance contract items on the same license item //check missing new licenses
            if (licenseItemList != null) {
                for (LicenseItem__c li : licenseItemList) {
                    if (doneLicense.contains(li.Id)) {
                        continue;   //skip the items already copied from parent contract.
                    }
                    uacItem = createUpgradeAssuranceContractItem(uac, li);
                    
                    newUACItemList.add(uacItem);
                    
                    // collect article number and minimal price date for MSRP retrieval later on 
                    articleNumberSet.add(uacItem.ArticleNumber__c);
                    if (minStartDate == null || minStartDate > uacItem.PriceDate__c) {
                        minStartDate = uacItem.PriceDate__c;
                    }
                }
            }
        }
        
        // get actual unit price
        updatePricesFromMsrp(newUACItemList, articleNumberSet, minStartDate);
        
        // save create UpgradeAssuranceContractItem records
        insert newUACItemList;
        
    }
    
    /**
     * @description If field 'Start Date Line' has been changed, and the contract is not activated yet, update unit prices on 
     *              related contract items.
     *              Runs after update of UpgradeAssuranceContract__c.
     */
    public static void recalculateContractItems(List<UpgradeAssuranceContract__c> newList, Map<Id, UpgradeAssuranceContract__c> newMap, Map<Id, UpgradeAssuranceContract__c> oldMap) {
        system.debug('*** start recalculateContractItems');
        if (oldMap == null || oldMap.isEmpty()) {
            return;
        }

	   	Id rtIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());

        // get all contracts for which the start date has been changed        
        UpgradeAssuranceContract__c oldContract;
        Set<Id> uacIdSet = new Set<Id> ();
        for (UpgradeAssuranceContract__c uac : newList) {
            oldContract = oldMap.get(uac.Id);
            if (oldContract != null && !uac.Active__c && (uac.StartDateLine__c != oldContract.StartDateLine__c || UpgradeAssuranceContractItemHelper.recalculateMap.get(uac.Id)) && uac.RecordTypeId != rtIdActivatedContract ) {
                //system.debug('*** upgradeAssuranceContract is not active');
                uacIdSet.add(uac.Id);
            }
        }
        
        //system.debug('*** UAC items: ' + [SELECT Id, ArticleNumber__c, PriceDate__c, UnitPrice__c FROM UpgradeAssuranceContractItem__c]);
            
        if (!uacIdSet.isEmpty()) {
            // update price date and unit price for the related contract items
            List<UpgradeAssuranceContractItem__c> uacItemList = UpgradeAssuranceContractItemDao.getContractItems(uacIdSet);
            if (!uacItemList.isEmpty()) {
                UpgradeAssuranceContract__c uaContract;
                // collect article numbers and min start date in order to retrieve correct prices
                Set<String> articleNumberSet = new Set<String> ();
                Date minStartDate = null;
                for (UpgradeAssuranceContractItem__c uacItem : uacItemList) {
                    uaContract = newMap.get(uacItem.UpgradeAssuranceContract__c);
                    uacItem.PriceDate__c = uaContract.StartDateLine__c;
                    if (uacItem.ArticleNumber__c != null) {
                        articleNumberSet.add(uacItem.ArticleNumber__c);
                        if (minStartDate == null || minStartDate > uacItem.PriceDate__c) {
                            minStartDate = uacItem.PriceDate__c;
                        }
                    }
                }
                
                // update prices
                updatePricesFromMsrp(uacItemList, articleNumberSet, minStartDate);
                
                // save changes
                update uacItemList;

                //system.debug('*** UAC items after update: ' + [SELECT Id, ArticleNumber__c, PriceDate__c, UnitPrice__c FROM UpgradeAssuranceContractItem__c]);
            }
        }
        system.debug('*** end recalculateContractItems');
    }
    
    /**
     * @description Sync LicenseItem records with UpgradeAssuranceContractItem records.
     *              Runs after insert/update/delete of a LicenseItem record
     *
     * @param newList List of new/updated LicenseItem records
     * @param oldMap Map of LicenseItem records with previous values, or deleted records
     */
    public static void syncUpgradeAssuranceContractItems (List<LicenseItem__c> newList, Map<Id, LicenseItem__c> oldMap) {
        /* Disabled synchronisation on request 20190924
        system.debug('*** start syncUpgradeAssuranceContractItems');
        if (newList == null && oldMap == null) {
            return;
        }
        
        if (oldMap == null || oldMap.isEmpty()) {
            // new License items

            // get UpgradeAssuranceContract details
            Set<Id> licenseIdSet = new Set<Id> ();
            for (LicenseItem__c licItem : newList) {
                licenseIdSet.add(licItem.License__c);
            }
            List<UpgradeAssuranceContract__c> uaContractList = UpgradeAssuranceContractDao.getByLicenseId(licenseIdSet);
            Map<Id, UpgradeAssuranceContract__c> uaContractMap = new Map<Id, UpgradeAssuranceContract__c> ();
            for (UpgradeAssuranceContract__c uac : uaContractList) {
                uaContractMap.put(uac.License__c, uac);
            }
            
            Set<String> articleNumberSet = new Set<String> ();
            Date minStartDate = null;
            
            // create Upgrade Assurance Contract Items
            List<UpgradeAssuranceContractItem__c> uacItemList = new List<UpgradeAssuranceContractItem__c> ();
            UpgradeAssuranceContract__c uac;
            for (LicenseItem__c licItem : newList) {
                uac = uaContractMap.get(licItem.License__c);
                if (uac != null) {
                    // only create UAC item if there is an UpgadeAssuranceContract linked to a License record 
	                uacItemList.add(createUpgradeAssuranceContractItem(uac, licItem));
	                
	                articleNumberSet.add(licItem.ArtNo__c);
                    if (minStartDate == null || minStartDate > licItem.PriceDate__c) {
                        minStartDate = licItem.PriceDate__c;
                    }
                }
            }
            
            // update prices
            updatePricesFromMsrp(uacItemList, articleNumberSet, minStartDate);
            
            // create UpgradeAssuranceContractItem records
            insert uacItemList;
        } else {
            // updated License items
            
            Set<String> articleNumberSet = new Set<String> ();
            Date minStartDate = null;

            // get license Item id's of items that has interesting changes
            Set<Id> licItemIdSet = new Set<Id> ();
            LicenseItem__c oldLicItem;
            for (LicenseItem__c licItem : newList) {
                oldLicItem = oldMap.get(licItem.Id);
                if (oldLicItem != null &&
                    (licItem.InitialQuantity__c != oldLicItem.InitialQuantity__c
                    //|| licItem.ItemDescription__c != oldLicItem.ItemDescription__c // formula field
                    || licItem.LineNumber__c != oldLicItem.LineNumber__c
                    || licItem.NavisionExternalId__c != oldLicItem.NavisionExternalId__c
                    //|| licItem.Name != oldLicItem.Name // name field on UAC item is an autonumber field 
                    || licItem.Item__c != oldLicItem.Item__c
                    || licItem.LicenseTypeVersion__c != oldLicItem.LicenseTypeVersion__c
                    || licItem.VersionCode__c != oldLicItem.VersionCode__c)) {
                    
                    licItemIdSet.add(licItem.Id);
                }
                if (oldLicItem != null &&
                    (licItem.Currency__c != oldLicItem.Currency__c
                    || licItem.Quantity__c != oldLicItem.Quantity__c
                    || licItem.ArtNo__c != oldLicItem.ArtNo__c)) {
                    
                    licItemIdSet.add(licItem.Id);
                    articleNumberSet.add(licItem.ArtNo__c);
                    if (minStartDate == null || minStartDate > licItem.PriceDate__c) {
                        minStartDate = licItem.PriceDate__c;
                    }
                }
            }
            // get all linked Upgrade Assurance Contract Item records
            List<UpgradeAssuranceContractItem__c> uacItemList = UpgradeAssuranceContractItemDao.getByLicenseItems(licItemIdSet);
            // convert list into a map
            Map<Id, UpgradeAssuranceContractItem__c> licItemToUacItemMap = new Map<Id, UpgradeAssuranceContractItem__c> ();
            for (UpgradeAssuranceContractItem__c uacItem : uacItemList) {
                licItemToUacItemMap.put(uacItem.LicenseItem__c, uacItem);
            }
            // if something has changed, update related Upgrade Assurance Contract Item records
            UpgradeAssuranceContractItem__c uaci;
            for (LicenseItem__c licItem : newList) {
                uaci = licItemToUacItemMap.get(licItem.Id);
                if (uaci != null) {
                    copyLicenseItemData(uaci, licItem);
                }
            }
            // if quantity has changed, update unit price via MSRP table
            updatePricesFromMsrp(uacItemList, articleNumberSet, minStartDate);
            
            if (!uacItemList.isEmpty()) {
                update uacItemList;
            }
        }
        */
    }
    
    /**
     * @description Sync LicenseItem records with UpgradeAssuranceContractItem records.
     *              Runs before delete of a LicenseItem record
     *
     * @param oldMap Map of deleted LicenseItem records
     */
    public static void syncUpgradeAssuranceContractItemsDelete (Map<Id, LicenseItem__c> oldMap) {
        /* Disabled synchronisation on request 20190924
        if (oldMap != null && !oldMap.isEmpty()) {
            // delete UpgradeAssuranceContractItems that are related to the LicenseItems
            UpgradeAssuranceContractItemDao.deleteByLicenseItems(oldMap.keySet());
        } 
        */
    }
    
   /**
     * @description Update prices on the UpgradeAssuranceContractItem by prices from MSRP table.
     *
     * @param uacItemList List of UpgradeAssuranceContractItem records that needs to be updated
     * @param articleNumberSet Set of articleNumbers that needs to be retrieved from teh MSRP table
     * @param minStartDate Date as of which the prices needs to be retrieved
     */
    private static void updatePricesFromMsrp(List<UpgradeAssuranceContractItem__c> uacItemList, Set<String> articleNumberSet, Date minStartDate) {
        // retrieve unit prices for the article numbers from MSRP table
        List<MSRP__c> msrpList = MsrpDao.getByArticleNumberAndMinStartDate(articleNumberSet, minStartDate);
        // convert list into a map with article number as key
        Map<String, List<MSRP__c>> msrpMap = convertMSRPListToMap(msrpList);
        for (UpgradeAssuranceContractItem__c uacItem : uacItemList) {
            msrpList = msrpMap.get(uacItem.ArticleNumber__c);
            if (msrpList != null && !msrpList.isEmpty()) {
                for (MSRP__c msrp : msrpList) {
                    if (uacItem.Currency__c == msrp.Currency__c 
                        && (uacItem.Quantity__c >= msrp.MinimumQuantity__c || msrp.MinimumQuantity__c == null)
                        && uacItem.PriceDate__c >= msrp.StartDate__c
                        && (msrp.EndDate__c == null || uacItem.PriceDate__c <= msrp.EndDate__c)) {
                        
                        system.debug('*** update unit price and time stamp');
                        uacItem.UnitPrice__c = msrp.UnitPrice__c;
                        uacItem.SQLTimeStamp__c = msrp.SQLTimeStamp__c;
                        break;
                    }
                }
            }
        }
    }
    
    /**
    * @description Convert a list of LicenseItem__c into a map with License ID as key and a list of licenseItem__c records as value.
    *              It groups the license items on license ID.
    *              Returns an empty map if the input list is null or empty.
    */ 
    private static Map<Id, List<LicenseItem__c>> convertLicenseItemListToMap(List<LicenseItem__c> licenseItemList) {
        Map<Id, List<LicenseItem__c>> licenseItemMap = new Map<Id, List<LicenseItem__c>> ();
        if (licenseItemList != null && !licenseItemList.isEmpty()) {
            List<LicenseItem__c> tmpItemList;
            for (LicenseItem__c li : licenseItemList) {
                tmpItemList = licenseItemMap.get(li.License__c);
                if (tmpItemList == null) {
                    // item from a new license
                    tmpItemList = new List<LicenseItem__c> {li};
                    licenseItemMap.put(li.License__c, tmpItemList);
                } else {
                    // item from an already known license
                    tmpItemList.add(li);
                }
            }
        }
        
        return licenseItemMap;
    }
    
    /**
    * @description Convert a list of UpgradeAssuranceContractItem__c into a map with UpgradeAssuranceContract__c->ID as key and a list of UpgradeAssuranceContractItem__c records as value.
    *              It groups the Upgrade Assurance Contract items on Upgrade Assurance Contract ID.
    *              Returns an empty map if the input list is null or empty.
    */ 
    private static Map<Id, List<UpgradeAssuranceContractItem__c>> convertUacItemListToMap(List<UpgradeAssuranceContractItem__c> uacItemList) {
        Map<Id, List<UpgradeAssuranceContractItem__c>> uacItemMap = new Map<Id, List<UpgradeAssuranceContractItem__c>> ();
        if (uacItemList != null && !uacItemList.isEmpty()) {
            List<UpgradeAssuranceContractItem__c> tmpItemList;
            for (UpgradeAssuranceContractItem__c uaci : uacItemList) {
                tmpItemList = uacItemMap.get(uaci.UpgradeAssuranceContract__c);
                if (tmpItemList == null) {
                    // item from a new license
                    tmpItemList = new List<UpgradeAssuranceContractItem__c> {uaci};
                    uacItemMap.put(uaci.UpgradeAssuranceContract__c, tmpItemList);
                } else {
                    // item from an already known license
                    tmpItemList.add(uaci);
                }
            }
        }
        
        return uacItemMap;
    }

    /**
    * @description Convert a list of MSRP__c into a map with article number as key and a list of MSRP__c records as value.
    *              It groups the msrp records on article numbers.
    *              Returns an empty map if the input list is null or empty.
    */ 
    private static Map<String, List<MSRP__c>> convertMSRPListToMap(List<MSRP__c> msrpList) {
        Map<String, List<MSRP__c>> msrpMap = new Map<String, List<MSRP__c>> ();
        if (msrpList != null && !msrpList.isEmpty()) {
            List<MSRP__c> tmpMsrpList;
            for (MSRP__c msrp : msrpList) {
                tmpMsrpList = msrpMap.get(msrp.ArticleNumber__c);
                if (tmpMsrpList == null) {
                    // new article number
                    tmpMsrpList = new List<MSRP__c> {msrp};
                    msrpMap.put(msrp.ArticleNumber__c, tmpMsrpList);
                } else {
                    // article number already known
                    tmpMsrpList.add(msrp);
                }
            }
        }
        
        return msrpMap;
    }    
    
    /**
     * @description Copy LicenseItem data to UpgradeAssuranceContractItem record.
     */
    private static void copyLicenseItemData(UpgradeAssuranceContractItem__c uacItem, LicenseItem__c licItem) {
        uacItem.LicenseItem__c = licItem.Id;
        uacItem.ArticleNumber__c = licItem.ArtNo__c;
        uacItem.Currency__c = licItem.Currency__c;
        uacItem.InitialQuantity__c = licItem.InitialQuantity__c;
        uacItem.ItemDescription__c = licItem.ItemDescription__c;
        uacItem.LineNumber__c = licItem.LineNumber__c;
        uacItem.NavisionExternalId__c = licItem.NavisionExternalId__c;
        uacItem.Quantity__c = licItem.Quantity__c;
        //uacItem.Name = licItem.Name;
        uacItem.UpgradeAssuranceContractTypeVersion__c = licItem.LicenseTypeVersion__c;
        uacItem.VersionCode__c = licItem.VersionCode__c;
    }

    /**
     * @description Copy Upgrade Assurance Contract Item data to a new UpgradeAssuranceContractItem record.
     */
    private static void copyUacItemData(UpgradeAssuranceContractItem__c uacItem, UpgradeAssuranceContractItem__c parentUacItem) {
        uacItem.AdjustedQuantity__c = parentUacItem.AdjustedQuantity__c;
        uacItem.AdjustedUnitPrice__c = parentUacItem.AdjustedUnitPrice__c;
        uacItem.AdjustmentReason__c = parentUacItem.AdjustmentReason__c;
    }

    /**
     * @description force update on all parent UpgradeAssuranceContract__c records to calculate the correct prices. After trigger
     */ 
    public static void updatePrices (List<UpgradeAssuranceContractItem__c> upgradeAssuranceContractItemList) {
        Set<Id> idSet = new Set<Id>();
        for (UpgradeAssuranceContractItem__c uaci : upgradeAssuranceContractItemList) {
            idSet.add (uaci.UpgradeAssuranceContract__c);
        }

        List<UpgradeAssuranceContract__c> uacList = UpgradeAssuranceContractDao.getById(idSet);
        for (UpgradeAssuranceContract__c uac : uacList) {
            uac.RequestUnlock__c = !uac.RequestUnlock__c;
        }
        update uacList;
    }

}