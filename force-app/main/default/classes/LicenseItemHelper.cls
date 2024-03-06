/**
 * @description   : UpgradeAssuranceContractHelper business logic for the trigger
 * @author (s)    : Brite
 */
public without sharing class LicenseItemHelper {
    
    /**
     * @description Update the price in the License Item depended on the Article number, Currency and Date
     *
     * @param newList List of new/updated LicenseItem records
     * @param oldMap Map of LicenseItem records with previous values, or deleted records
     */
    public static void updateArticlePrice (List<LicenseItem__c> newList, Map<Id, LicenseItem__c> oldMap) {
    	Set<Id> licIdSet = new Set<Id>();
    	Set<Id> idSet = new Set<Id>();
    	Set<String> artNumSet = new Set<String>();
    	String errMsg = '';
    	
    	for (LicenseItem__c licItem : newList) {
    		artNumSet.add(licItem.ArtNo__c);
			licIdSet.add(licItem.License__c);
    	}
    	
		//get currency From the License
    	Map<Id,License__c> licenseMap = new Map<Id, License__c>(LicenseDao.getLicenseById(licIdSet));

    	List<MSRP__c> msrpList = MsrpDao.getByArticleNumberToday(artNumSet);
    	
    	//Put the result in a article map per currency map with minimum order variants
    	Map<String,Map<String,List<MSRP__c>>> artNoMsrpMap = new Map<String,Map<String,List<MSRP__c>>>();
    	Map<String,List<MSRP__c>> artNoCurMsrpTmpMap;
    	List<MSRP__c> msrpTmpList;
    	String artNo;
    	String curr;
    	for (MSRP__c msrp : msrpList) {
    		artNo = msrp.ArticleNumber__c;
    		curr = msrp.Currency__c;
    		if (curr == null || curr == '') {
    			curr = 'EUR';
    		}
    		artNoCurMsrpTmpMap = artNoMsrpMap.get(artNo);
    		if (artNoCurMsrpTmpMap == null) {
    			artNoCurMsrpTmpMap = new Map<String,List<MSRP__c>>();
					msrpTmpList = null;
    		} else {
    			msrpTmpList = artNoCurMsrpTmpMap.get(curr);
    		}
    		if (msrpTmpList == null) {
    			msrpTmpList = msrpTmpList = new List<MSRP__c>(); 
    		}
    		msrpTmpList.add(msrp);
    		artNoCurMsrpTmpMap.put(curr,msrpTmpList);
    		artNoMsrpMap.put(artNo, artNoCurMsrpTmpMap);
    	}
    	
    	Boolean notFound;
    	Decimal quantity;
		License__c lic;
    	for (LicenseItem__c licItem : newList) {
    		notFound = true;
			artno = licItem.ArtNo__c;
    		quantity = licItem.Quantity__c;
			lic = licenseMap.get(licItem.License__c);
			if (lic != null) {
				curr = lic.Currency__c;
			}
    		if (curr == null || curr == '') {
    			curr = 'EUR';
    		}
			licItem.Currency__c = curr;
    		artNoCurMsrpTmpMap = artNoMsrpMap.get(artNo);
    		if (artNoCurMsrpTmpMap != null) {
    			msrpTmpList = artNoCurMsrpTmpMap.get(curr);
    			if (msrpTmpList != null) {
    				for (MSRP__c msrp : msrpTmpList) {
						if (artNo != msrp.ArticleNumber__c) {
  	  						errMsg += 'article mismatch msrp artno: ' + msrp.ArticleNumber__c + ' artNo: ' + artNo +'|Currency' + curr + '|Quantity' + quantity + '\n';
						}
    					if (msrp.MinimumQuantity__c <= quantity) {
    						licItem.Item__c = msrp.Id;
    						notFound = false;
    						break;
    					}
    				}
					if (notFound) {
						licItem.Item__c = null;
						errMsg += 'price not found for artNo: ' + artNo +'|Currency' + curr + '|Quantity' + quantity + '\n';
					}
    			}
    		}    			
    	}
		if (errMsg != '') {
			CustomLog.log(CustomLog.WARNING, 'updateArticlePrice failed at ', 
					errMsg, null);
		}
    }

    /**
     * @description force update on all parent License__c records to calculate the correct prices. After trigger
     */ 
    public static void updatePrices (List<LicenseItem__c> licenseItemList) {
        List<License__c> licList = new List<License__c> ();
        Set<Id> idSet = new Set<Id>();
        for (LicenseItem__c lici : licenseItemList) {
            idSet.add (lici.license__c);
        }
        for (Id licId : idSet) {
            licList.add (new License__c(Id = licId));
        }
        update licList;
    }

}