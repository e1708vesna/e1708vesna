/**
 * @description   : UpgradeAssuranceContractHelper business logic for the trigger
 * @author (s)    : Brite
 */
public without sharing class UpgradeAssuranceContractHelper {
    
    public static final String RT_DEV_NAME_PENDING_CONTRACT = 'Pending_Contract';
    public static final String RT_DEV_NAME_CLONED_CONTRACT = 'Cloned_Contract';
    public static final String RT_DEV_NAME_ACTIVATED_CONTRACT = 'Activated_Contract';

    /**
     * @description Update upgrade assurance contract summary fields on license after insert/update/delete
     * of an upgrade assurance contract.
     */
    public static void updateUACSummaryFieldsOnLicenses(List<UpgradeAssuranceContract__c> newUACList, Map<Id, UpgradeAssuranceContract__c> oldUACMap) {
        Set<Id> licenseIdSet = new Set<Id> ();

        Id rtActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName(RT_DEV_NAME_ACTIVATED_CONTRACT, UpgradeAssuranceContract__c.getSObjectType());
        if (newUACList == null || newUACList.isEmpty()) {
            // delete of UACs
            for (UpgradeAssuranceContract__c uac : oldUACMap.values()) {
                licenseIdSet.add(uac.License__c);
            }
        } else if (oldUACMap == null || oldUACMap.isEmpty()) {
            // insert of UACs
            for (UpgradeAssuranceContract__c uac : newUACList) {
                licenseIdSet.add(uac.License__c);
            }
        } else {
            // update of UACs
            UpgradeAssuranceContract__c oldUAC;
            for (UpgradeAssuranceContract__c uac : newUACList) {
                oldUAC = oldUACMap.get(uac.Id);
                if (oldUAC != null  
                    && (oldUAC.RecordTypeId != uac.RecordTypeId
                        || oldUAC.CombinedBillingAmount__c != uac.CombinedBillingAmount__c
                        || oldUAC.Active__c != isActive(uac))) {
                    licenseIdSet.add(uac.License__c);
                }
            }
        }

        if (!licenseIdSet.isEmpty()) {
            LicenseHelper.updateUACSummaryFields(licenseIdSet);
        }
    }

    /**
     * @description Update Totaal Prices om changes in the UpgradeAssuranceItems
     * call from the UpgradeAssuranceContract trigger before insert/update
     * @param newList
     */
    public static void updateTotalPrices (Map<Id,UpgradeAssuranceContract__c> newUacMap) {
        List<UpgradeAssuranceContractItem__c> uacItemList = UpgradeAssuranceContractItemDao.getContractItems (newUacMap.keySet ());
        List<UpgradeAssuranceContractItem__c> tmpUacItemList = new List<UpgradeAssuranceContractItem__c> ();
        Map<Id, List<UpgradeAssuranceContractItem__c>> uacIdItemMap = new Map<Id, List<UpgradeAssuranceContractItem__c>> ();

        for (UpgradeAssuranceContract__c uac : newUacMap.values()) {
            uac.RecalculatedAdjustedLicenseValue__c = 0;
            uac.RecalculatedLicenseValue__c = 0;
        }

        for (UpgradeAssuranceContractItem__c uacItem : uacItemList) {
            tmpUacItemList = uacIdItemMap.get (uacItem.UpgradeAssuranceContract__c);
            if (tmpUacItemList == null) {
                tmpUacItemList = new List<UpgradeAssuranceContractItem__c> ();
            }
            //artNoSet.add(uacItem.ArticleNumber__c);
            tmpUacItemList.add (uacItem);
            uacIdItemMap.put (uacItem.UpgradeAssuranceContract__c, tmpUacItemList);
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

        UpgradeAssuranceContract__c uac;
        for (String uacId : uacIdItemMap.keySet ()) {
            //get the UpgradeAssuranceContract__c
            uac = newUacMap.get (uacId);
            //get the article list for this currency
    		curr = uac.Currency__c;
    		if (curr == null || curr == '') {
    			curr = 'EUR';
    		}            
            artNoMsrpTmpMap = currArtNoMsrpMap.get(curr);
            calculateUacPrice (uac, uacIdItemMap.get (uacId), efList, efMap, artNoMsrpTmpMap, curr);
        }
    }

    /**
     * @description Calculate the years between the current and the last Upgrade Assurance Contract
     * call from the UpgradeAssuranceContract trigger before insert/update
     * @param newUacList
     */
    public static void calculateIntermediateYears (List<UpgradeAssuranceContract__c> newUacList) {
        Set<Id> licenseIdSet = new Set<Id>();
        Map<Id, Date> licenseToEndDateMap = new Map<Id, Date>();
        Integer currentYear;
        Integer oldYear;

        for (UpgradeAssuranceContract__c uac : newUacList) {
            if (uac.License__c != null) { 
            	licenseIdSet.add(uac.License__c);
            }
        }
        
        List<AggregateResult> maxYearList = UpgradeAssuranceContractDao.getLatestActivatedByLicenseId(licenseIdSet);
        for (AggregateResult ar : maxYearList) {
            licenseToEndDateMap.put((Id)ar.get('license__c'), (Date)ar.get('maxEndDate'));
        }
        for (UpgradeAssuranceContract__c uac : newUacList){
            if (uac.License__c != null && licenseToEndDateMap.containsKey(uac.License__c)) { 
                if (uac.EndDateLine__c != null) {
                    currentYear = uac.EndDateLine__c.year();
                }
                else {
                    currentyear = Date.today().year();
                }
                oldYear = licenseToEndDateMap.get(uac.License__c).year();
                if (currentYear - oldYear - 1 >= 0){
                	uac.IntermediateYears__c = currentYear - oldYear - 1;
                }
            }
        }
    }
    
    /**
     * @description Create the Upgrade Assurance Contracts for the years between the current and the last Upgrade Assurance Contract
     * call from the UpgradeAssuranceContract trigger after update
     * @param newUacList
     */
    public static void createIntermediateContracts (List<UpgradeAssuranceContract__c> newUacList, Map<Id, UpgradeAssuranceContract__c> oldUacMap) {
        List<UpgradeAssuranceContract__c> uacToProcessList = new List<UpgradeAssuranceContract__c>();
        for (UpgradeAssuranceContract__c uac : newUacList) {
            //if (uac.Approved__c && !(oldUacMap.get(uac.id).Approved__c) && uac.IntermediateYears__c != null && uac.IntermediateYears__c > 0) {
            if (uac.Approved__c && uac.Stage__c == 'Calculation' && oldUacMap.get(uac.id).Stage__c != 'Calculation' && 
                    uac.IntermediateYears__c != null && uac.IntermediateYears__c > 0) {
                uacToProcessList.add(uac);
            }
        }
        
        List<UpgradeAssuranceContract__c> contractsWithIntermediateYearsList = new List<UpgradeAssuranceContract__c>();
        List<UpgradeAssuranceContract__c> contractsToInsertList = new List<UpgradeAssuranceContract__c>();
        Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
        UpgradeAssuranceContract__c tempUac;
        for (UpgradeAssuranceContract__c uac : uacToProcessList) {
            System.debug('Contract does have intermediate years!');
            for (integer i = 1; i <= uac.IntermediateYears__c; i++) {
                
                System.debug('i: ' + i);
                tempUac = uac.clone(false, false, false, false);
                
                tempUac.StartDateLine__c = Date.newInstance((uac.StartDate__c.year()-i), 1, 1);
                tempUac.StartDate__c = Date.newInstance((uac.StartDate__c.year()-i), 1, 1);
                tempUac.EndDate__c = Date.newInstance((uac.StartDate__c.year()-i), 12, 31);
                tempUac.ParentUAC__c = uac.Id;
                tempUac.Id = null;
                tempUac.stage__c = 'Calculation';
                tempUac.RecordTypeId = rtIdClonedContract;
                tempUac.Approved__c = true;
                tempUac.invoice__c = null;
                tempUac.IntermediateYears__c = null;
                
                contractsToInsertList.add(tempUac);
            }
        }
        insert contractsToInsertList;
    }
    
    
    private static void calculateUacPrice (UpgradeAssuranceContract__c uac, List<UpgradeAssuranceContractItem__c> uacIdItemList, 
            List<ExportFactor__c> efList, Map<String,ExportFactor__c> efMap, Map<String,List<MSRP__c>> artNoMsrpTmpMap, String curr) {
        //normal -> summary Upgrade Assurance Contract Item: Adjusted Total Price (AdjustedTotalPriceFormula__c)
		String errMsg = '';

        if (artNoMsrpTmpMap == null) {
            errMsg += 'No articles found in Msrp for Currency: ' + curr + '\n';
        } else {
            List<MSRP__c> msrpTmpList;
            Map<String,ExportFactorData> exportDataMap = new Map<String,ExportFactorData>();
            ExportFactorData exportFactorDataTmp;

            //Decimal adjustedLicenseValue = 0; //done by role up, needed for the trigger
            //Decimal licenseValue = 0;         //done by role up, needed for the trigger
            Decimal recalculatedAdjustedLicenseValue = 0;
            Decimal recalculatedLicenseValue = 0;

            List<UpgradeAssuranceContractItem__c> uaciToUpsertList = new List<UpgradeAssuranceContractItem__c>();
            List<UpgradeAssuranceContractItem__c> uaciToDeleteList = new List<UpgradeAssuranceContractItem__c>();
            List<UpgradeAssuranceContractItem__c> uaciTmpList;
            Map<String, List<UpgradeAssuranceContractItem__c>> artNoUaciMap = new Map<String, List<UpgradeAssuranceContractItem__c>> ();

            //Calculate the correct quantity per export factor articles
            //If article not known in export factors table -> item->AdjustedTotalPriceFormula__c for de price!!
            ExportFactor__c ef;
            for (UpgradeAssuranceContractItem__c uacIdItem : uacIdItemList) {
                ef = efMap.get (uacIdItem.ArticleNumber__c);
                if (ef == null) {
                    recalculatedAdjustedLicenseValue += uacIdItem.AdjustedTotalPriceFormula__c;
                    recalculatedLicenseValue += uacIdItem.TotalPrice__c;
                } else {
                    //Make for the current ef uaci a map to compare later
                    uaciTmpList = artNoUaciMap.get (uacIdItem.ArticleNumber__c);
                    if (uaciTmpList == null) {
                        uaciTmpList = new List<UpgradeAssuranceContractItem__c> ();
                    }
                    uaciTmpList.add (uacIdItem);
                    artNoUaciMap.put (uacIdItem.ArticleNumber__c, uaciTmpList);
                    //

                    //Save current selected quantities
                    msrpTmpList = artNoMsrpTmpMap.get (uacIdItem.ArticleNumber__c);

                    exportFactorDataTmp = exportDataMap.get (ef.ExportCode__c);
                    if (exportFactorDataTmp == null) {
                        exportFactorDataTmp = new ExportFactorData (ef.ExportCode__c);
                    }
                    exportFactorDataTmp.quantity += (uacIdItem.Quantity__c * ef.ExportFactor__c);
                    exportFactorDataTmp.restQuantity += (uacIdItem.Quantity__c * ef.ExportFactor__c);
                    exportDataMap.put (ef.ExportCode__c, exportFactorDataTmp);
                }
            }

            //item->AdjustedTotalPriceFormula__c voor de price!!

            Decimal factor;
            LicenseItem__c li;
            for (ExportFactor__c eftmp : efList) {
                msrpTmpList = artNoMsrpTmpMap.get (eftmp.Name);
                if (msrpTmpList == null || msrpTmpList[0] == null || msrpTmpList[0].UnitPrice__c == null) {
                    errMsg += 'No article found in Msrp for Article Number ' + eftmp.Name + ' with Currency' + curr + '\n';
                } else {
                    if (msrpTmpList.size () != 1) {
                        errMsg += 'Multiple articles found in Msrp for Article Number ' + eftmp.Name + ' with Currency' + curr + '\n';
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

                    uaciTmpList = artNoUaciMap.get (eftmp.Name);
                    if ((uaciTmpList == null || uaciTmpList.size () != 1) && factor != 0) {
                        // insert current
                        uaciToUpsertList.add (new UpgradeAssuranceContractItem__c (
                                                UpgradeAssuranceContract__c = uac.Id,
                                                Quantity__c = factor,
                                                PriceDate__c = uac.StartDateLine__c,                   
                                                InitialQuantity__c = factor,
                                                ArticleNumber__c = eftmp.Name,
                                                Currency__c = uac.Currency__c,
                                                ItemDescription__c = msrpTmpList[0].Description__c,
                                                UnitPrice__c = msrpTmpList[0].UnitPrice__c
                        ));
                    }
                    if (uaciTmpList != null && (uaciTmpList.size () != 1 || factor == 0)) {
                        // delete current
                        uaciToDeleteList.addAll (uaciTmpList);
                    } 
                    if (uaciTmpList != null && uaciTmpList.size () == 1 && factor != 0) {
                        // update current 
                        if (uaciTmpList[0].Quantity__c != factor) {
                            uaciTmpList[0].Quantity__c = factor;
                            uaciToUpsertList.add (uaciTmpList[0]);
                        }
                    }
                }
            }
            SkipTrigger.UpgradeAssuranceContractItemSkip = true;
            SkipTrigger.UpgradeAssuranceContractSkip = true;
            delete uaciToDeleteList;
            upsert uaciToUpsertList;
            SkipTrigger.UpgradeAssuranceContractSkip = false;
            SkipTrigger.UpgradeAssuranceContractItemSkip = false;

            // Add rest price if rest quantity is not 0 and sum al prices
            Decimal efPriceTotal = 0;
            for (String key : exportDataMap.keySet()) {
                exportFactorDataTmp = exportDataMap.get (key);
                if (exportFactorDataTmp.restQuantity != 0) {
                    exportFactorDataTmp.price += exportFactorDataTmp.restPrice;
                }
                efPriceTotal += exportFactorDataTmp.price;
            }

            recalculatedAdjustedLicenseValue += efPriceTotal;
            recalculatedLicenseValue += efPriceTotal;
            //End result
            uac.RecalculatedAdjustedLicenseValue__c = recalculatedAdjustedLicenseValue;
            uac.RecalculatedLicenseValue__c = recalculatedLicenseValue;
        }
        if (errMsg != '') {
			CustomLog.log(CustomLog.WARNING, 'Upgrade Assurance Contract Total Price Errors', errMsg, '');
        }

    }

    /**
     * @description Verify if upgrade assurance contract is active; same als formula field Active__c.
     */
    private static Boolean isActive(UpgradeAssuranceContract__c uac) {
        Date dateToday = Date.today();

        return uac.RecordTypeId == RecordTypeUtil.getRecordTypeIdByDevName(RT_DEV_NAME_ACTIVATED_CONTRACT, UpgradeAssuranceContract__c.getSObjectType())
            && uac.StartDateLine__c <= dateToday
            && uac.EndDateLine__c >= dateToday;
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

}