/**
 * @description   : Navision MSRP retrieve scheduler     
 * @author (s)    : Brite
 */
global class NavisionMsrpBtchSchd extends BtchSchdIterable {
	global override List<SObject> getDataSet() {
		List<MSRP__c> msrpList = new List<MSRP__c>();
		try {
			SchedulerSettings__c ss = getSchedulerSettings();   		
			if (ss.LastProcessedDateTime__c == null) {
				ss.LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0);
			}
			msrpList = new NavisionService().getMsrp(ss);
			if (ss.MoreHitsAvailableIndicator__c == false) {
				ss.LastProcessedDateTime__c = startBatchDate;
			}
			upsert ss;
		} catch (exception ex) {
			this.inError = true;
    		System.debug(JOB_NAME_PREFIX + ' getDataSet failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, JOB_NAME_PREFIX + ' getDataSet failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());    	
    	} finally {
			CustomLog.commitLog();
		}
        return msrpList;         
	}
    
    /**
     * Execute of de scheduling on the retrieved dataset
     */
    global override void execute(Database.BatchableContext bc, List<SObject> sobjectList) {
		List<msrp__c> msrpList = (List<msrp__c>)sobjectList;
    	try {
    		String errMsg = '';
	    	String suc6Msg = '';
	    	Integer errCnt = 0;
	    	Integer suc6Cnt = 0;
	    	Integer i = 0;
    	
    		if (!msrpList.isEmpty()) {
    			//Upsert with external Id
				Schema.SObjectField f = MSRP__c.Fields.NavisionMsrpNumber__c;			
		    	Database.UpsertResult[] urList = Database.upsert(msrpList, f, false);
		    	i = 0;
				for(Database.UpsertResult ur : urList) {
				    if (ur.isSuccess()) {
				        // Operation was successful
						suc6Cnt++;
						suc6Msg += msrpList[i].NavisionMsrpNumber__c + '\t'; 
				    }
				    else {
				    	errCnt++;
				        // Operation failed, so get all errors                
				        for(Database.Error err : ur.getErrors()) {
							errMsg += msrpList[i].NavisionMsrpNumber__c + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\t';
				        }
				        errMsg += '\n';
				    }
				    i++;
				}
    		}
			if (suc6Cnt!=0) {
		        System.debug('Successfully upserted ' + suc6Cnt + ' msrp');
				CustomLog.create(CustomLog.INFO, 'Successfully upserted ' + suc6Cnt + ' msrp', suc6Msg, '');
	    	}
	    	if (errMsg!='') {
				System.debug(errMsg);
				CustomLog.create(CustomLog.ERROR, 'Failed Upserting ' + errCnt + ' msrp', errMsg, '');
	    	}
     	} catch (exception ex) {
    		System.debug('Saving licences failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, 'Saving licences failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
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
										   ScheduleDateTime__c = DateTime.newInstance(2012, 1, 1, 4, 0, 0),
										   Description__c = 'Retrieve Navision MRSP',
                                           LinkedScheduler__c ='');
			insert ss;
		}   
		return ss;
	}         
}