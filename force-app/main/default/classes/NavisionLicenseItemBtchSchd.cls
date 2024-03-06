/**
 * @description   : Navision License Item retrieve scheduler     
 * @author (s)    : Brite
 */
global class NavisionLicenseItemBtchSchd extends BtchSchdIterable {
    /**
     * Retrieve dataset
     * @return List<SOBjects>
     */
	global override List<SObject> getDataSet() {
		List<LicenseItem__c> licenseItemList = new List<LicenseItem__c>();
		try {
			SchedulerSettings__c ss = getSchedulerSettings();   		
			if (ss.LastProcessedDateTime__c == null) {
				ss.LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0);
			}
			licenseItemList = new NavisionService().getLicenseLines(ss);
			if (ss.MoreHitsAvailableIndicator__c == false) {
				ss.LastProcessedDateTime__c = startBatchDate;
			}
			upsert ss;
		} catch (exception ex) {
			this.inError = true;
    		System.debug(JOB_NAME_PREFIX + ' getDataSet failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, JOB_NAME_PREFIX + ' getDataSet failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
    	} finally {
			CustomLOg.commitLog();
		}
        return licenseItemList;         
	}
    
    /**
     * Execute of de scheduling on the retrieved dataset
     */
    global override void execute(Database.BatchableContext bc, List<SObject> sobjectList) {
		List<LicenseItem__c> licenseItemList = (List<LicenseItem__c>)sobjectList;
		String errMsg = '';
		String suc6Msg = '';
		Integer errCnt = 0;
		Integer suc6Cnt = 0;
		Integer i = 0;
    	
		List<LicenseItem__c> updLicenseItemList = new List<LicenseItem__c>();
		List<LicenseItem__c> remLicenseItemList = new List<LicenseItem__c>();
		Set<String> remLiSet = new Set<String>();

		for (LicenseItem__c li : licenseItemList) {
			if (li.Quantity__c == null) {
				remLiSet.add(li.NavisionExternalId__c);
			} else {
				updLicenseItemList.add(li);
			}
		}

    	try {
    		if (!updLicenseItemList.isEmpty()) {
    			//Upsert with external Id
				Schema.SObjectField f = LicenseItem__c.Fields.NavisionExternalId__c;			
		    	Database.UpsertResult[] urList = Database.upsert(updLicenseItemList, f, false);
		    	i = 0;
				for(Database.UpsertResult ur : urList) {
				    if (ur.isSuccess()) {
				        // Operation was successful
						suc6Cnt++;
						suc6Msg += updLicenseItemList[i].NavisionExternalId__c + '|' + updLicenseItemList[i].Name + '|' + '\t'; 
				    }
				    else {
				    	errCnt++;
				        // Operation failed, so get all errors                
				        for(Database.Error err : ur.getErrors()) {
							errMsg += updLicenseItemList[i].NavisionExternalId__c + '|' + updLicenseItemList[i].Name + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\t';
				        }
				        errMsg += '\n';
				    }
				    i++;
				}
    		}
			if (suc6Cnt!=0) {
		        System.debug('Successfully upserted ' + suc6Cnt + ' LicenceItems');
				CustomLog.create(CustomLog.INFO, 'Successfully upserted ' + suc6Cnt + ' LicenceItems', suc6Msg, '');
	    	}
	    	if (errMsg!='') {
				System.debug(errMsg);
				CustomLog.create(CustomLog.ERROR, 'Failed Upserting ' + errCnt + ' LicenceItems', errMsg, '');
	    	}

    		errMsg = '';
	    	suc6Msg = '';
	    	errCnt = 0;
	    	suc6Cnt = 0;
	    	i = 0;
    	
			if (!remLiSet.isEmpty()) {
         		remLicenseItemList = [SELECT Id, Name, NavisionExternalId__c FROM LicenseItem__c WHERE NavisionExternalId__c IN :remLiSet];				
			}
    		if (!remLicenseItemList.isEmpty()) {
		    	Database.DeleteResult[] drList = Database.delete(remLicenseItemList, false);
		    	i = 0;
				for(Database.DeleteResult dr : drList) {
				    if (dr.isSuccess()) {
				        // Operation was successful
						suc6Cnt++;
						suc6Msg += remLicenseItemList[i].NavisionExternalId__c + '|' + remLicenseItemList[i].Name + '|' + '\t'; 
				    }
				    else {
				    	errCnt++;
				        // Operation failed, so get all errors                
				        for(Database.Error err : dr.getErrors()) {
							errMsg += remLicenseItemList[i].NavisionExternalId__c + '|' + remLicenseItemList[i].Name + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\t';
				        }
				        errMsg += '\n';
				    }
				    i++;
				}
    		}
			if (suc6Cnt!=0) {
		        System.debug('Successfully deleted ' + suc6Cnt + ' LicenceItems');
				CustomLog.create(CustomLog.INFO, 'Successfully deleted ' + suc6Cnt + ' LicenceItems', suc6Msg, '');
	    	}
	    	if (errMsg!='') {
				System.debug(errMsg);
				CustomLog.create(CustomLog.ERROR, 'Failed Deleting ' + errCnt + ' LicenceItems', errMsg, '');
	    	}
     	} catch (exception ex) {
    		System.debug('Saving or Deleting LicenceItems failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, 'Deleting LicenceItems failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
    	} finally {
			CustomLog.commitLog();
		}
    }
    
	/**
     * Retrieve the settings for this scheduler or create the default
     * @return SchedulerSettings__c
     */    
	public override SchedulerSettings__c getSchedulerSettings() {
		SchedulerSettings__c ss = SchedulerSettings__c.getValues(JOB_NAME_PREFIX);   		
		if (ss == null) {
        	ss = new SchedulerSettings__c( Name = JOB_NAME_PREFIX, 
        	                               AutoReschedule__c = false, 
        	                               RescheduleDelayMinutes__c = 1, 
        	                               RescheduleDelayHours__c = 1, 
        	                               MaxProcessItems__c = 1000, 
                                           BatchSize__c = 200,
        	                               LastProcessedId__c = null, 
        	                               LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0), 
        	                               MoreHitsAvailableIndicator__c = false,
        	                               RetryDelayMinutes__c = 7,
										   FixedTime__c = true,
										   FixedDay__c = false,
										   FixedMonth__c = false,
										   ScheduleDateTime__c = DateTime.newInstance(2012, 1, 1, 6, 0, 0),
										   Description__c = 'Retrieve Navision License Items from the Licenses',
                                           LinkedScheduler__c = '');
			insert ss;
		}   
		return ss;
	}         
}