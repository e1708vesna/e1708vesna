/**
 * @description   : Navision License Account retrieve scheduler     
 * @author (s)    : Brite
 */
global class NavisionLicenseAccountBtchSchd extends BtchSchdIterable {
    /**
     * Retrieve dataset
     * @return List<SOBjects>
     */
	global override List<SObject> getDataSet() {
		List<SObject> accountList = new List<Account>();
		try {
			SchedulerSettings__c ss = getSchedulerSettings();   		
			if (ss.LastProcessedDateTime__c == null) {
				ss.LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0);
			}
			accountList = new NavisionService().getAccountsFromLicenseHeader(ss);
			if (ss.MoreHitsAvailableIndicator__c == false) {
				ss.LastProcessedDateTime__c = startBatchDate;
			}
			upsert ss;
		} catch (exception ex) {
			this.inError = true;
    		System.debug(JOB_NAME_PREFIX + ' getDataSet failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, JOB_NAME_PREFIX + ' getDataSet failed: ' + ex.getCause(), ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
    	} finally {
			CustomLog.commitLog();
		}
        return accountList;         
	}
    
    /**
     * Execute of de scheduling on the retrieved dataset
     */
    global override void execute(Database.BatchableContext bc, List<SObject> sobjectList) {
		List<Account> accountList = (List<Account>)sobjectList;
    	try {
    		String errMsg = '';
	    	String suc6Msg = '';
	    	Integer errCnt = 0;
	    	Integer suc6Cnt = 0;
	    	Integer i = 0;

			/*
    		List<Account> parentAccountList = new List<Account>();
    		List<Account> childAccountList = new List<Account>();
    		for (Account acc : accountList) {
    			if (acc.ChannelPartner__r == null) {
    				parentAccountList.add (acc);
    			} else {
    				childAccountList.add (acc);
    			}
    		}
	
    		if (!parentAccountList.isEmpty()) {
    			//Upsert with external Id
				Schema.SObjectField f = Account.Fields.CustomerCode__c;			
		    	Database.UpsertResult[] urList = Database.upsert(parentAccountList, f, false);
		    	i = 0;
				for(Database.UpsertResult ur : urList) {
				    if (ur.isSuccess()) {
				        // Operation was successful
						suc6Cnt++;
						//accountList[i].NavisionExternalId__c + '|' +  //notfilled in if loaded from Licenses
						suc6Msg += parentAccountList[i].Name + '|' + '\t'; 
				    }
				    else {
				    	errCnt++;
				        // Operation failed, so get all errors                
				        for(Database.Error err : ur.getErrors()) {
							errMsg += parentAccountList[i].Name + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\t';
				        }
				        errMsg += '\n';
				    }
				    i++;
				}
    		}
    		
    		if (!childAccountList.isEmpty()) {
    			//Upsert with external Id
				Schema.SObjectField f = Account.Fields.CustomerCode__c;			
		    	Database.UpsertResult[] urList = Database.upsert(childAccountList, f, false);
		    	i = 0;
				for(Database.UpsertResult ur : urList) {
				    if (ur.isSuccess()) {
				        // Operation was successful
						suc6Cnt++;
						//accountList[i].NavisionExternalId__c + '|' +  //notfilled in if loaded from Licenses
						suc6Msg += childAccountList[i].Name + '|' + '\t'; 
				    }
				    else {
				    	errCnt++;
				        // Operation failed, so get all errors                
				        for(Database.Error err : ur.getErrors()) {
							errMsg += childAccountList[i].Name + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\t';
				        }
				        errMsg += '\n';
				    }
				    i++;
				}
    		}
			*/
			if (!accountList.isEmpty()) {
    			//Upsert with external Id
				Schema.SObjectField f = Account.Fields.CustomerCode__c;			
		    	Database.UpsertResult[] urList = Database.upsert(accountList, f, false);
		    	i = 0;
				for(Database.UpsertResult ur : urList) {
				    if (ur.isSuccess()) {
				        // Operation was successful
						suc6Cnt++;
						//accountList[i].NavisionExternalId__c + '|' +  //notfilled in if loaded from Licenses
						suc6Msg += accountList[i].Name + '|' + '\t'; 
				    }
				    else {
				    	errCnt++;
				        // Operation failed, so get all errors                
				        for(Database.Error err : ur.getErrors()) {
							errMsg += accountList[i].Name + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\t';
				        }
				        errMsg += '\n';
				    }
				    i++;
				}
    		}

			if (suc6Cnt!=0) {
		        System.debug('Successfully upserted ' + suc6Cnt + ' Accounts');
				CustomLog.create(CustomLog.INFO, 'Successfully upserted ' + suc6Cnt + ' Accounts', suc6Msg, '');
	    	}
	    	if (errMsg!='') {
				System.debug(errMsg);
				CustomLog.create(CustomLog.ERROR, 'Failed Upserting ' + errCnt + ' Accounts', errMsg, '');
	    	}
     	} catch (exception ex) {
    		System.debug('Saving Accounts failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, 'Saving Accounts failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
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
										   Description__c = 'Retrieve Navision Accounts from the Licenses',
                                           LinkedScheduler__c ='NavisionLicenseBtchSchd');
			insert ss;
		}
		return ss;
	}
}