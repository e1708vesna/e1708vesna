/**
 * @description   : License Item Update scheduler     
 * @author (s)    : Brite
 */
global class LicenseItemUpdateBtchSchd extends BtchSchdQueryLocator {    
    /**
     * Set the query for the batch process
     * Note: LIMIT statement is added automatically, so do not add it here!!
     */
    global override void setQuery() {
        String selectQuery = 
			'SELECT Id, Name, License__c, Quantity__c, Item__c, Currency__c, ArticleNumber__c';
        String fromWhereQuery =  
            ' FROM LicenseItem__c';
        String orderByQuery = 
            '';
                    
        //Note: LIMIT statement is added automatically, so do not add it here!!

        this.query = selectQuery + fromWhereQuery + orderByQuery;                        
        this.countQuery = 'SELECT count()' + fromWhereQuery;	//No orderBy!!
    }
    
    /**
     * Execute of de scheduling on the retrieved dataset
     */
    global override void execute (Database.BatchableContext bc, List<SObject> sobjectList) {
		List<LicenseItem__c> licenseItemList = (List<LicenseItem__c>)sobjectList;
    	try {    		
    		String errMsg = '';
	    	String suc6Msg = '';
	    	Integer errCnt = 0;
	    	Integer suc6Cnt = 0;
	    	Integer i = 0;
    	
    		if (!licenseItemList.isEmpty()) {
		    	Database.SaveResult[] srList = Database.update(licenseItemList, false);
		    	i = 0;
				for(Database.SaveResult sr : srList) {
				    if (sr.isSuccess()) {
				        // Operation was successful
						suc6Cnt++;
						suc6Msg += licenseItemList[i].Name + '|' + '\t'; 
				    }
				    else {
				    	errCnt++;
				        // Operation failed, so get all errors                
				        for(Database.Error err : sr.getErrors()) {
							errMsg += licenseItemList[i].Name + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\t';
				        }
				        errMsg += '\n';
				    }
				    i++;
				}
    		}
			if (suc6Cnt!=0) {
		        System.debug('Successfully updated ' + suc6Cnt + ' License Items');
				CustomLog.create(CustomLog.INFO, 'Successfully updated ' + suc6Cnt + ' License Items', suc6Msg, '');
	    	}
	    	if (errMsg!='') {
				System.debug(errMsg);
				CustomLog.create(CustomLog.ERROR, 'Failed updated ' + errCnt + ' License Items', errMsg, '');
	    	}
     	} catch (exception ex) {
    		System.debug('Saving License Items failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, 'Saving License Items failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
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
        	                               RescheduleDelayMinutes__c = 58, 
        	                               RescheduleDelayHours__c = 7, 
        	                               MaxProcessItems__c = 100000, 
                                           BatchSize__c = 200,
        	                               LastProcessedId__c = null, 
        	                               LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0), 
        	                               MoreHitsAvailableIndicator__c = false,
        	                               RetryDelayMinutes__c = 7,
										   FixedTime__c = true,
										   FixedDay__c = false,
										   FixedMonth__c = false,
										   ScheduleDateTime__c = DateTime.newInstance(2012, 1, 1, 6, 0, 0),
                                           Description__c = 'Update License Items',
                                           LinkedScheduler__c = '');
			insert ss;
		}   
		return ss;
	}
}