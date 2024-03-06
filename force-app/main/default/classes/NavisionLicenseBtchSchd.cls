/**
 * @description   : Navision License retrieve scheduler     
 * @author (s)    : Brite
 */
global class NavisionLicenseBtchSchd extends BtchSchdIterable {
    /**
     * Retrieve dataset
     * @return List<SOBjects>
     */
	global override List<SObject> getDataSet() {
		List<SObject> licenseList = new List<SObject>();
		try {
			SchedulerSettings__c ss = getSchedulerSettings();   		
			if (ss.LastProcessedDateTime__c == null) {
				ss.LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0);
			}
			licenseList = new NavisionService().getLicenseHeader(ss);
			if (ss.MoreHitsAvailableIndicator__c == false) {
				ss.LastProcessedDateTime__c = startBatchDate;
			}
			upsert ss;
		} catch (exception ex) {
			this.inError = true;
    		System.debug(JOB_NAME_PREFIX + ' getDataSet failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.log(CustomLog.ERROR, JOB_NAME_PREFIX + ' getDataSet failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
    	} finally {
			CustomLog.commitLog();
    	}
        return licenseList;         
	}
    
    /**
     * Execute of de scheduling on the retrieved dataset
     */
    global override void execute(Database.BatchableContext bc, List<SObject> sobjectList) {
		List<License__c> licenseList = (List<License__c>)sobjectList;
    	try {
    		String errMsg = '';
	    	String suc6Msg = '';
	    	Integer errCnt = 0;
	    	Integer suc6Cnt = 0;
	    	Integer i = 0;
    		List<License__c> licenseUpsertList = new List<License__c>();
    		List<License__c> licenseRemoveList = new List<License__c>();
			Set<String> idSet = new Set<String>();

			for (License__c lic : licenseList) {
				if (lic.MarkForDelete__c) {
					idSet.add(lic.NavisionExternalId__c);
				} else {
					licenseUpsertList.add(lic);
				}
			}

    		if (!licenseUpsertList.isEmpty()) {
    			//Upsert with external Id
				Schema.SObjectField f = License__c.Fields.NavisionExternalId__c;			
		    	Database.UpsertResult[] urList = Database.upsert(licenseUpsertList, f, false);
		    	i = 0;
				for(Database.UpsertResult ur : urList) {
				    if (ur.isSuccess()) {
				        // Operation was successful
						suc6Cnt++;
						suc6Msg += licenseUpsertList[i].Name + '|' + '\t'; 
				    }
				    else {
				    	errCnt++;
				        // Operation failed, so get all errors                
				        for(Database.Error err : ur.getErrors()) {
							errMsg += licenseUpsertList[i].Name + '|' + licenseUpsertList[i].ChannelPartner__r.CustomerCode__c + licenseUpsertList[i].EndCustomer__r.CustomerCode__c + err.getStatusCode() + ': ' + err.getMessage() + '\t';
				        }
				        errMsg += '\n';
				    }
				    i++;
				}
    		}
			if (suc6Cnt!=0) {
		        System.debug('Successfully upserted ' + suc6Cnt + ' Licences');
				CustomLog.create(CustomLog.INFO, 'Successfully upserted ' + suc6Cnt + ' Licences', suc6Msg, '');
	    	}
	    	if (errMsg!='') {
				System.debug(errMsg);
				CustomLog.create(CustomLog.ERROR, 'Failed Upserting ' + errCnt + ' Licences', errMsg, '');
	    	}

			licenseRemoveList = [SELECT Id, Name, Status__c, ChannelPartner__r.CustomerCode__c, EndCustomer__r.CustomerCode__c FROM License__c WHERE NavisionExternalId__c IN :idSet];
    		errMsg = '';
	    	suc6Msg = '';
	    	errCnt = 0;
	    	suc6Cnt = 0;
	    	i = 0;
    		if (!licenseRemoveList.isEmpty()) {
		    	Database.DeleteResult[] drList = Database.delete(licenseRemoveList, false);
		    	i = 0;
				for(Database.DeleteResult dr : drList) {
				    if (dr.isSuccess()) {
				        // Operation was successful
						suc6Cnt++;
						suc6Msg += licenseRemoveList[i].Name + '|' + '\t'; 
				    }
				    else {
				    	errCnt++;
				        // Operation failed, so get all errors                
				        for(Database.Error err : dr.getErrors()) {
							errMsg += licenseRemoveList[i].Name + '|' + licenseRemoveList[i].ChannelPartner__r.CustomerCode__c + licenseRemoveList[i].EndCustomer__r.CustomerCode__c + err.getStatusCode() + ': ' + err.getMessage() + '\t';
				        }
				        errMsg += '\n';
				    }
				    i++;
				}
    		}
			if (suc6Cnt!=0) {
		        System.debug('Successfully deleted ' + suc6Cnt + ' Licences');
				CustomLog.create(CustomLog.INFO, 'Successfully deleted ' + suc6Cnt + ' Licences', suc6Msg, '');
	    	}
	    	if (errMsg!='') {
				System.debug(errMsg);
				CustomLog.create(CustomLog.ERROR, 'Failed deleting' + errCnt + ' Licences', errMsg, '');
	    	}
			
     	} catch (exception ex) {
    		System.debug('Saving/Deleting licences failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, 'Saving/Deleting licences failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
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
        	                               AutoReschedule__c = true, 
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
										   ScheduleDateTime__c = DateTime.newInstance(2012, 1, 1, 5, 0, 0),
										   Description__c = 'Retrieve Navision Licenses from the Licenses',
                                           LinkedScheduler__c ='NavisionLicenseItemBtchSchd');
			insert ss;
		}   
		return ss;
	}      
}