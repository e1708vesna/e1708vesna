/**
 * @description   : Navision interface
 * @author (s)    : Brite
 */
public without sharing class NavisionService {
    /**
     * @description get all new records
     * @param Key String with the last retrieved key from which new records will be retrieved
     */
    public List<Account> getAccountsFromLicenseHeader(SchedulerSettings__c ss) {
    	List<Account> accountList = new List<Account>();
    	MsDynNedapLicenseHeader msDynLicHead = new MsDynNedapLicenseHeader(); 
    	MsDynNedapLicenseHeader.NedapLicenseHeader_Port licHeadPort = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
    	
    	List<MsDynNedapLicenseHeader.NedapLicenseHeader_Filter> filterList = new List<MsDynNedapLicenseHeader.NedapLicenseHeader_Filter>();
		/* DvtH Now all data is retrieved every time the sync is done with Navision
    	MsDynNedapLicenseHeader.NedapLicenseHeader_Filter filter1 = new MsDynNedapLicenseHeader.NedapLicenseHeader_Filter();
    	filter1.Field = 'SQLTimeStamp';
    	if (ss.LastProcessedId__c==null) {
    		ss.LastProcessedId__c = '0';
    	}
    	filter1.Criteria = '>' + ss.LastProcessedId__c;
    	filterList.add(filter1);
		*/
    	String bookmarkKey = ss.MoreHitsAvailableKey__c;
    	
    	MsDynNedapLicenseHeader.NedapLicenseHeader_List licHeadList = licHeadPort.ReadMultiple(filterList, bookmarkKey, Integer.valueOf(ss.MaxProcessItems__c));
    	
    	if (licHeadList!=null && licHeadList.NedapLicenseHeader != null) {
    		accountList = mapLicenseHeaderToSfAccount(licHeadList.NedapLicenseHeader, ss);
    	} else {
			ss.MoreHitsAvailableIndicator__c = false;
			ss.MoreHitsAvailableKey__c = null;
			/* DvtH Now all data is retrieved every time the sync is done with Navision
			ss.LastProcessedId__c = ss.LastProcessedTmpId__c;
			ss.LastProcessedTmpId__c = null;
			*/
    	}
    	return accountList;
    }
    
    /**
     * @description get all new records
     * @param Key String with the last retrieved key from which new records will be retrieved
     */
    public List<License__c> getLicenseHeader(SchedulerSettings__c ss) {
    	system.debug('DvtH_getLicenseHeader');
    	List<License__c> licenseList = new List<License__c>();
    	MsDynNedapLicenseHeader msDynLicHead = new MsDynNedapLicenseHeader(); 
    	MsDynNedapLicenseHeader.NedapLicenseHeader_Port licHeadPort = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
    	
    	List<MsDynNedapLicenseHeader.NedapLicenseHeader_Filter> filterList = new List<MsDynNedapLicenseHeader.NedapLicenseHeader_Filter>();
		/* DvtH Now all data is retrieved every time the sync is done with Navision
    	MsDynNedapLicenseHeader.NedapLicenseHeader_Filter filter1 = new MsDynNedapLicenseHeader.NedapLicenseHeader_Filter();
    	filter1.Field = 'SQLTimeStamp';
    	if (ss.LastProcessedId__c==null) {
    		ss.LastProcessedId__c = '0';
    	}
    	filter1.Criteria = '>' + ss.LastProcessedId__c;
    	filterList.add(filter1);
		*/
    	String bookmarkKey = ss.MoreHitsAvailableKey__c;
    	
    	MsDynNedapLicenseHeader.NedapLicenseHeader_List licHeadList = licHeadPort.ReadMultiple(filterList, bookmarkKey, Integer.valueOf(ss.MaxProcessItems__c));
    	if (licHeadList!=null && licHeadList.NedapLicenseHeader != null) {
	    	licenseList = mapLicenseHeaderToSfLicense(licHeadList.NedapLicenseHeader, ss);
    	} else {
			ss.MoreHitsAvailableIndicator__c = false;
			ss.MoreHitsAvailableKey__c = null;
			/* DvtH Now all data is retrieved every time the sync is done with Navision
			ss.LastProcessedId__c = ss.LastProcessedTmpId__c;
			ss.LastProcessedTmpId__c = null;
			*/
    	}
    	return licenseList;
    }
    
    /**
     * @description get all new records
     * @param Key String with the last retrieved key from which new records will be retrieved
     */
    public List<LicenseItem__c> getLicenseLines(SchedulerSettings__c ss) {
    	system.debug('DvtH_getLicenseLines');
    	List<LicenseItem__c> licenseItemList = new List<LicenseItem__c>();
    	MsDynNedapLicenseLines msDynLicLine = new MsDynNedapLicenseLines(); 
    	MsDynNedapLicenseLines.NedapLicenseLines_Port licLinePort = new MsDynNedapLicenseLines.NedapLicenseLines_Port();
    	
    	List<MsDynNedapLicenseLines.NedapLicenseLines_Filter> filterList = new List<MsDynNedapLicenseLines.NedapLicenseLines_Filter>();
		/* DvtH Now all data is retrieved every time the sync is done with Navision
    	MsDynNedapLicenseLines.NedapLicenseLines_Filter filter1 = new MsDynNedapLicenseLines.NedapLicenseLines_Filter();
    	filter1.Field = 'SQLTimeStamp';
    	if (ss.LastProcessedId__c==null) {
    		ss.LastProcessedId__c = '0';
    	}
    	filter1.Criteria = '>' + ss.LastProcessedId__c;
    	filterList.add(filter1);
		*/
    	String bookmarkKey = ss.MoreHitsAvailableKey__c;
    	
    	MsDynNedapLicenseLines.NedapLicenseLines_List licLineList = licLinePort.ReadMultiple(filterList, bookmarkKey, Integer.valueOf(ss.MaxProcessItems__c));
    	if (licLineList!=null && licLineList.NedapLicenseLines != null) {
	    	licenseItemList = mapLicenseLinesToSfLicenseItems(licLineList.NedapLicenseLines, ss);
    	} else {
			ss.MoreHitsAvailableIndicator__c = false;
			ss.MoreHitsAvailableKey__c = null;
			/* DvtH Now all data is retrieved every time the sync is done with Navision
			ss.LastProcessedId__c = ss.LastProcessedTmpId__c;
			ss.LastProcessedTmpId__c = null;
			*/
    	}
    	return licenseItemList;
    }
    

    /**
     * @description get all new records
     * @param Key String with the last retrieved key from which new records will be retrieved
     */
    public List<MSRP__c> getMsrp(SchedulerSettings__c ss) {
    	system.debug('DvtH_getMsrp');
    	List<MSRP__c> msrpList = null;
    	
    	MsDynNedapMsrp msDynMsrp = new MsDynNedapMsrp(); 
    	MsDynNedapMsrp.NedapMSRP_Port msrpPort = new MsDynNedapMsrp.NedapMSRP_Port();
    	
    	List<MsDynNedapMsrp.NedapMSRP_Filter> filterList = new List<MsDynNedapMsrp.NedapMSRP_Filter>();
			/* DvtH Now all data is retrieved every time the sync is done with Navision
    	MsDynNedapMsrp.NedapMSRP_Filter filter1 = new MsDynNedapMsrp.NedapMSRP_Filter();
    	filter1.Field = 'SQLTimeStamp';
    	if (ss.LastProcessedId__c==null) {
    		ss.LastProcessedId__c = '0';
    	}
    	filter1.Criteria = '>' + ss.LastProcessedId__c;
    	filterList.add(filter1);
		*/
    	String bookmarkKey = ss.MoreHitsAvailableKey__c;
    	
    	MsDynNedapMsrp.NedapMSRP_List nedapMsrpList = msrpPort.ReadMultiple(filterList, bookmarkKey, Integer.valueOf(ss.MaxProcessItems__c));
    	if (nedapMsrpList!=null && nedapMsrpList.NedapMSRP != null) {
	    	msrpList = mapMsrpToSf(nedapMsrpList.NedapMSRP, ss);
    	} else {
			ss.MoreHitsAvailableIndicator__c = false;
			ss.MoreHitsAvailableKey__c = null;
			/* DvtH Now all data is retrieved every time the sync is done with Navision
			ss.LastProcessedId__c = ss.LastProcessedTmpId__c;
			ss.LastProcessedTmpId__c = null;
			*/
    	}
    	return msrpList;
    }
    
    /* PRIVATE METHODS */
    
    /**
     * Map Navision License Header fields to the SF License__c object
     *
     */
    private List<Account> mapLicenseHeaderToSfAccount(List<MsDynNedapLicenseHeader.NedapLicenseHeader> licHeadList, SchedulerSettings__c ss) {
        List<Account> accountList = new List<Account>();
        Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName('ChannelPartner', Account.getSObjectType());
        Id recIdEndCustomer = RecordTypeUtil.getRecordTypeIdByDevName('EndCustomer', Account.getSObjectType());
        Set<String> CustomerCodeSet = new Set<String>();

        system.debug('mapLicenseHeaderToSfAccount starts');
        Account accTmp;   
        String custCode;     
        String endUserCode;
             
        for (MsDynNedapLicenseHeader.NedapLicenseHeader nlh : licHeadList) {
			/* DvtH Now all data is retrieved every time the sync is done with Navision
            if (ss.LastProcessedTmpId__c == null || Long.valueOf(ss.LastProcessedTmpId__c) < nlh.SQLTimeStamp) {
                ss.LastProcessedTmpId__c = String.valueOf(nlh.SQLTimeStamp);
			}            
			*/
            ss.MoreHitsAvailableKey__c = nlh.Key;
            
            custCode = nlh.Customer_No;
			if (nlh.Customer_Name == null) {
				nlh.Customer_Name = 'Unknown';
			}
            if (nlh.Customer_Name != null && custCode != null) {
            	custCode = custCode.toUpperCase();
	            if (!CustomerCodeSet.contains(custCode)) {
	            	CustomerCodeSet.add(custCode);
	                accountList.add( new Account(Name = nlh.Customer_Name, CustomerCode__c = custCode, RecordTypeId = recIdChannelPartner));	//SQLTimeStamp__c = nlh.SQLTimeStamp
	            }
            }           
            endUserCode = nlh.Enduser_code;
			if (nlh.Enduser_name == null) {
				nlh.Enduser_name = 'Unknown';
			}
            if (nlh.Enduser_name != null && endUserCode != null) {
            	endUserCode = endUserCode.toUpperCase();
	            if (!CustomerCodeSet.contains(endUserCode)) {
	            	CustomerCodeSet.add(endUserCode);
	            	accTmp = new Account(Name = nlh.Enduser_name, CustomerCode__c = endUserCode, RecordTypeId = recIdEndCustomer);	//SQLTimeStamp__c = nlh.SQLTimeStamp
		            //if (nlh.Customer_Name != null && custCode != null) {
					//	accTmp.ChannelPartner__r = new Account(CustomerCode__c = custCode);
		            //}
    	            accountList.add (accTmp); 
            	}
            }
        }
        
    	if (licHeadList!=null && licHeadList.size() == Integer.valueOf(ss.MaxProcessItems__c)) {
			ss.MoreHitsAvailableIndicator__c = true;
    	} else {
			ss.MoreHitsAvailableIndicator__c = false;
			ss.MoreHitsAvailableKey__c = null;
			/* DvtH Now all data is retrieved every time the sync is done with Navision
			ss.LastProcessedId__c = ss.LastProcessedTmpId__c;
			ss.LastProcessedTmpId__c = null;
			*/
    	}    	
        
        return accountList;
    }
    
    /**
     * Map Navision License Header fields to the SF License__c object
     *
     */
    private List<License__c> mapLicenseHeaderToSfLicense(List<MsDynNedapLicenseHeader.NedapLicenseHeader> licHeadList, SchedulerSettings__c ss) {
        List<License__c> licenceList = new List<License__c>();
        License__c lic = new License__c();
        
        system.debug('mapLicenseHeaderToSfLicense starts');
        DateTime refDateTime = DateTime.newInstance(1970, 1, 1, 12, 0, 0);
        String custCode;     
        String endUserCode;     
		String errMsg = '';
		//Added CurrencyCode on 8 august 2019
    	String curr;
		//

        for (MsDynNedapLicenseHeader.NedapLicenseHeader nlh : licHeadList) {
			/* DvtH Now all data is retrieved every time the sync is done with Navision
            if (ss.LastProcessedTmpId__c == null || Long.valueOf(ss.LastProcessedTmpId__c) < nlh.SQLTimeStamp) {
                ss.LastProcessedTmpId__c = String.valueOf(nlh.SQLTimeStamp);
            }          
			*/
            ss.MoreHitsAvailableKey__c = nlh.Key;
            
			//Only license numers that starts with a 1 or 9
			if (nlh.No != null && (nlh.No.startsWith('1') || nlh.No.startsWith('9')) &&
				nlh.Keytype == 'AEOS') {
 
				lic = new License__c();
			
				lic.NavisionExternalId__c = nlh.No;			//nlh.Key;
				//lic.SQLTimeStamp__c = nlh.SQLTimeStamp;
				lic.Name = nlh.No;

				//Use External Id
				endUserCode = nlh.Enduser_code;
				if (endUserCode != null && endUserCode != '') {
					endUserCode = endUserCode.toUpperCase();
					lic.EndCustomer__r = new Account(CustomerCode__c = endUserCode);
				} else {
					errMsg += nlh.No+'->Missing Enduser_code\n';
				}
				//nlh.Enduser_name; //End User
				
				lic.ExtraInfo__c = nlh.Extra_info;
				lic.IpAddress1__c = nlh.IP_Address_1;
				lic.ExtraLicenseKey__c = nlh.Extra_License_Key;
				
				//Use External Id
				custCode = nlh.Customer_No;
				if (custCode != null && custCode != '') {
					custCode = custCode.toUpperCase();
					lic.ChannelPartner__r = new Account(CustomerCode__c = custCode);
				} else {
					errMsg += nlh.No+'->Missing Customer_No\n';
				}
				//nlh.Customer_Name;    //Channel Partner
				
				if (refDateTime < nlh.Validity_start_date ) {
					lic.ValidityDateStart__c = nlh.Validity_start_date; //Date
				//} else {
				//	errMsg += nlh.No+'->Invalid ValidityDateStart: ' + nlh.Validity_start_date+'\n';
				}
				lic.ValidityPeriodDays__c = nlh.Validity_Period_days; //Integer to Number
				if (refDateTime < nlh.Validity_end_date ) {
					lic.ValidityDateEnd__c = nlh.Validity_end_date; //Date
				//} else {
				//	errMsg += nlh.No+'->Invalid ValidityDateEnd: ' + nlh.Validity_end_date+'\n';
				} 
				lic.RenewalPeriod__c = ''+ nlh.Renewal_Period; //Integer to Picklist!
				lic.LicenseeName__c = nlh.Licensee_name;
				//lic.UpgradeAssuranceContract__c = (nlh.Upgrade_assurance != null && nlh.Upgrade_assurance) ? 'Ja' : 'Nee';	//formula field!
				lic.Version__c = nlh.Version_Code;
				lic.VersionDescription__c = nlh.Version_Code_Description;
				lic.KeyType__c = nlh.Keytype;
				//lic.LicenseTypeVersion__c = nlh.License_type_version; //convert _x0031_ to 1
				if ('_x0031_'.equalsIgnoreCase(nlh.License_type_version)) {
					lic.LicenseTypeVersion__c = '1';
				} else if ('_x0032_'.equalsIgnoreCase(nlh.License_type_version)) {
					lic.LicenseTypeVersion__c = '2';
				} else if ('_x0033_'.equalsIgnoreCase(nlh.License_type_version)) {
					lic.LicenseTypeVersion__c = '3';
				} else if ('_blank_'.equalsIgnoreCase(nlh.License_type_version)) {
					lic.LicenseTypeVersion__c = '';
				} else {
					lic.LicenseTypeVersion__c = nlh.License_type_version;
				}
				lic.LicenseTypeCode__c = nlh.License_Type_Code;
				lic.LicenseType__c = nlh.License_Type;
				lic.SystemkeyProvider__c = nlh.Systemkey_Provider;
				lic.Status__c = nlh.Status;
				if ('Gearchiveerd'.equalsIgnoreCase(nlh.Status)) {		
					// || 'Geblokkeerd'.equalsIgnoreCase(nlh.Status)) {
					lic.MarkForDelete__c = true;
				}
				//Added CurrencyCode on 8 august 2019
	    		curr = nlh.CurrencyCode;	
				if (curr == null || curr == '') {
					curr = 'EUR';
				}
				lic.Currency__c = curr;
				//if (custCode == '29561' | endUserCode == '29561' ) {
				//	errMsg += 'endUserCode: ' + endUserCode + 'Custcode: ' + custCode + ' |Curr: ' + nlh.CurrencyCode + '->' + curr + '\n';
				//}
				//

				licenceList.add(lic);           				
			}
        }
        if (errMsg != '') {
			CustomLog.log(CustomLog.WARNING, 'Licence Errors', errMsg, '');
        }
        
    	if (licHeadList!=null && licHeadList.size() == Integer.valueOf(ss.MaxProcessItems__c)) {
			ss.MoreHitsAvailableIndicator__c = true;
    	} else {
			ss.MoreHitsAvailableIndicator__c = false;
			ss.MoreHitsAvailableKey__c = null;
			/* DvtH Now all data is retrieved every time the sync is done with Navision
			ss.LastProcessedId__c = ss.LastProcessedTmpId__c;
			ss.LastProcessedTmpId__c = null;
			*/
    	}    	
        
        return licenceList;
    }
    
    /**
     * Map Navision License Header fields to the SF License__c object
     *
     */
    private List<LicenseItem__c> mapLicenseLinesToSfLicenseItems(List<MsDynNedapLicenseLines.NedapLicenseLines> licLineList, SchedulerSettings__c ss) {
    	List<LicenseItem__c> licenceItemList = new List<LicenseItem__c>();
    	LicenseItem__c li = new LicenseItem__c();
		License__c lic;
		String errMsg = '';
    	
   		system.debug('mapLicenseHeaderToSfLicense starts');
    	String artNo;
    	String curr;

    	Boolean notFound;
    	Decimal quantity;
    	for (MsDynNedapLicenseLines.NedapLicenseLines nll : licLineList) {
			/* DvtH Now all data is retrieved every time the sync is done with Navision
            if (ss.LastProcessedTmpId__c == null || Long.valueOf(ss.LastProcessedTmpId__c) < nll.SQLTimeStamp) {
                ss.LastProcessedTmpId__c = String.valueOf(nll.SQLTimeStamp);
			}            
			*/
            ss.MoreHitsAvailableKey__c = nll.Key;

			//Do not store licence lines with quantity is 0
    		notFound = true;
    		artNo = nll.Item_No;
    		quantity = nll.Quantity;
			//Currency done in the LicenseItemHelper

    		li = new LicenseItem__c();
			li.ArtNo__c = artNo;
	        li.NavisionExternalId__c = nll.License_No + '_' + String.valueOf(nll.Line_No);	//nll.Key;	        

			if (Quantity == null || Quantity == 0 || nll.Version_Supported == false) {
				errMsg += 'Licence Item will be deleted. NavisionExternalId:' + li.NavisionExternalId__c + '|ArtNo: ' + artNo +'|Currency' + curr + '|Quantity' + quantity + 'Version_supported' + nll.Version_Supported + '\n';
				li.Quantity__c = null;
			} else {				
				errMsg += 'NavisionExternalId:' + li.NavisionExternalId__c + 'Version_supported' + nll.Version_Supported + '\n';
				/* DvtH Now all data is retrieved every time the sync is done with Navision
				if (ss.LastProcessedTmpId__c == null || Long.valueOf(ss.LastProcessedTmpId__c) < nll.SQLTimeStamp) {
					ss.LastProcessedTmpId__c = String.valueOf(nll.SQLTimeStamp);
				}   
				*/
				ss.MoreHitsAvailableKey__c = nll.Key;
				
				//li.SQLTimeStamp__c = nll.SQLTimeStamp;
				li.Name = String.valueOf(nll.Line_No);			
				li.Quantity__c = nll.Quantity;
				li.VersionCode__c = nll.Version_Code;
				li.LicenseTypeVersion__c = nll.License_type_version;
				
				//Use External Id License
				lic = new License__c(Name = nll.License_No);
				li.License__r = lic;				
			}
    		licenceItemList.add(li);	        
    	}
    	
        if (errMsg != '') {
			CustomLog.log(CustomLog.ERROR, 'Licence Item Errors', errMsg, '');
        }
        
    	if (licLineList!=null && licLineList.size() == Integer.valueOf(ss.MaxProcessItems__c)) {
			ss.MoreHitsAvailableIndicator__c = true;
    	} else {
			ss.MoreHitsAvailableIndicator__c = false;
			ss.MoreHitsAvailableKey__c = null;
			/* DvtH Now all data is retrieved every time the sync is done with Navision
			ss.LastProcessedId__c = ss.LastProcessedTmpId__c;
			ss.LastProcessedTmpId__c = null;
			*/
    	}    	
    	return licenceItemList;
    }

    /**
     * Map Navision MSRP fields to the SF MSRP__c object
     *
     */
    private List<MSRP__c> mapMsrpToSf(List<MsDynNedapMsrp.NedapMSRP> nedapMsrpList, SchedulerSettings__c ss) {
        List<MSRP__c> msrpList = new List<MSRP__c>();
        MSRP__c msrp = new MSRP__c();
        
        system.debug('mapMsrpToSf starts');
        DateTime refDateTime = DateTime.newInstance(1970, 1, 1, 12, 0, 0);
                
        for (MsDynNedapMsrp.NedapMSRP nedapMsrp : nedapMsrpList) {
			/* DvtH Now all data is retrieved every time the sync is done with Navision
            if (ss.LastProcessedTmpId__c == null || Long.valueOf(ss.LastProcessedTmpId__c) < nedapMsrp.SQLTimeStamp) {
                ss.LastProcessedTmpId__c = String.valueOf(nedapMsrp.SQLTimeStamp);
			}
			*/
            //CustomLog.log(CustomLog.INFO, 'Received Navision Msrp', '' + nedapMsrp, null);
              
            ss.MoreHitsAvailableKey__c = nedapMsrp.Key;
            
            msrp = new MSRP__c();
            //msrp.SQLTimeStamp__c = nedapMsrp.SQLTimeStamp;
            msrp.ArticleNumber__c = nedapMsrp.Item_No;
                        
            if (refDateTime < nedapMsrp.Starting_Date ) {
           		msrp.StartDate__c = nedapMsrp.Starting_Date; //Date
            } else {
				CustomLog.create(CustomLog.WARNING, 'Invalid Starting_Date: ' + nedapMsrp.Starting_Date, '', '');
            }
            if (refDateTime < nedapMsrp.Ending_Date ) {
	            msrp.EndDate__c = nedapMsrp.Ending_Date; //Date
            } else {
				CustomLog.create(CustomLog.WARNING, 'Invalid Ending_Date: ' + nedapMsrp.Ending_Date, '', '');
            }
            
            msrp.MinimumQuantity__c = nedapMsrp.Minimum_Quantity;
            msrp.Description__c = nedapMsrp.Description;
            msrp.Description2__c = nedapMsrp.Description_2;
            msrp.UnitPrice__c = nedapMsrp.Unit_Price;
			if (nedapMsrp.Currency_Code == null || nedapMsrp.Currency_Code == '') {
				msrp.Currency__c = 'EUR';
			} else {
	            msrp.Currency__c = nedapMsrp.Currency_Code;				
			}            
			
            msrp.NavisionMsrpNumber__c = nedapMsrp.Item_No + '_' + msrp.Currency__c + '_' + msrp.StartDate__c + '_' + msrp.MinimumQuantity__c;
            //msrp.NavisionMsrpNumber__c = nedapMsrp.Key;
            
            msrpList.add(msrp);           
        }
        
    	if (nedapMsrpList!=null && nedapMsrpList.size() == Integer.valueOf(ss.MaxProcessItems__c)) {
			ss.MoreHitsAvailableIndicator__c = true;
    	} else {
			ss.MoreHitsAvailableIndicator__c = false;
			ss.MoreHitsAvailableKey__c = null;
			/* DvtH Now all data is retrieved every time the sync is done with Navision
			ss.LastProcessedId__c = ss.LastProcessedTmpId__c;
			ss.LastProcessedTmpId__c = null;
			*/
    	}    	        
        return msrpList;
    }    
}