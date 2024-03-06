/**
 * @description   : Schedule to deactivate users that did not log in for x period
 * @author (s)    : Brite
 */
global class UserDeactivationBtchSchd implements Database.Batchable<User>, BtchSchdImpl, Schedulable, Database.Stateful, Database.AllowsCallouts {
	
	private static final String JOB_NAME_PREFIX = 'UserDeactivationBtchSchd';
	Boolean solo = false;
	Boolean inError = false;
    @TestVisible private Integer inactiveDays = null;
    @TestVisible private Integer inactiveDaysAfterActivation = null;

	global UserDeactivationBtchSchd() {
	}

	global UserDeactivationBtchSchd(Boolean solo) {
		this.solo = solo;
	}

	//Scheduler method
  	global void execute(SchedulableContext sc) {
   		UserDeactivationBtchSchd p = new UserDeactivationBtchSchd(This.solo);
     	Database.executeBatch(p, 200);
  	}
	
    global Iterable<User> start(Database.BatchableContext bc){
        return getDataSet();
    }
 
	global List<User> getDataSet() {
		List<User> userList = new List<User>();
		try {
            UserSetting__mdt[] userSettingList = [SELECT InactiveDays__c, InactiveDaysAfterActivation__c FROM UserSetting__mdt where DeveloperName	= 'All' ];
            if (inactiveDays == null) {
                this.inactiveDays = Integer.valueOf(userSettingList[0].InactiveDays__c);
            }
            if (inactiveDaysAfterActivation == null){
                this.inactiveDaysAfterActivation = Integer.valueOf(userSettingList[0].InactiveDaysAfterActivation__c);
            }
	   		SchedulerSettings__c ss = getSchedulerSettings();   		
	        DateTime lastLoginDate = DateTime.now().addDays(-this.inactiveDays);
	        DateTime lastActivationDate = DateTime.now().addDays(-this.inactiveDaysAfterActivation);
            Integer maxItems = (Integer)ss.MaxProcessItems__c;
	        userList = [SELECT u.LastLoginDate, u.ContactId, u.IsActive, u.Id 
                        FROM User u 
                        WHERE u.IsActive = true AND u.ContactId != null AND (u.LastLoginDate < :lastLoginDate OR u.LastLoginDate = null) AND (u.LastActivationDate__c  < :lastActivationDate OR u.LastActivationDate__c = null) limit :maxItems];

    		ss.LastProcessedDateTime__c = DateTime.now();
			update ss;
     	} catch (exception ex) {
    		System.debug(JOB_NAME_PREFIX + ' getDataSet failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            //CustomLog.create(CustomLog.ERROR, JOB_NAME_PREFIX + ' getDataSet failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
    	} finally {
			//CustomLog.commitLog();
    	}
        return userList;        
	}
    
    global void execute(Database.BatchableContext bc, List<User> userList) {
    	try {            
    		String errMsg = '';
	    	String suc6Msg = '';
	    	Integer errCnt = 0;
	    	Integer suc6Cnt = 0;
	    	Integer i = 0;

			for (User usr : userList) {
				usr.IsActive = false;
			}

    		if (!userList.isEmpty()) {
		    	Database.SaveResult[] srList = Database.Update(userList, false);
		    	i = 0;
				for(Database.SaveResult sr : srList) {
				    if (sr.isSuccess()) {
				        // Operation was successful
						suc6Cnt++;
						suc6Msg += userList[i].Id + '|' + '\t'; 
				    }
				    else {
				    	errCnt++;
				        // Operation failed, so get all errors                
				        for(Database.Error err : sr.getErrors()) {
							errMsg += userList[i].Id + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\t';
				        }
				        errMsg += '\n';
				    }
				    i++;
				}
    		
				if (suc6Cnt!=0) {
					System.debug('Successfully updated ' + suc6Cnt + ' Users');
					//CustomLog.log(CustomLog.INFO, 'Successfully updated ' + suc6Cnt + ' Users', suc6Msg, '');
				}
				if (errMsg!='') {
					System.debug(errMsg);
					//CustomLog.log(CustomLog.ERROR, 'Failed updating ' + errCnt + ' Users', errMsg, '');
				}
			}
     	} catch (exception ex) {
    		System.debug('Updating Users failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            //CustomLog.log(CustomLog.ERROR, 'Updating Users failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
    	}
    }
    
    global void finish(Database.BatchableContext bc) {
		if (!this.solo) {
    		scheduleWakeup();
		}
		this.solo = false;
    }
    
    public void scheduleWakeup() {
    	scheduleWakeup(false);
    }

    public void scheduleStop() {
    	abortAlreadyScheduled();
    }

    public void scheduleSolo() {
		this.solo = true;
    	execute(null);
    }

    public void scheduleWakeup(Boolean direct) {
    	abortAlreadyScheduled();
   		SchedulerSettings__c ss = getSChedulerSettings(); 
    	if (ss.AutoReschedule__c || direct) {
			DateTime dateNow = DateTime.now();
			DateTime nextScheduleTime = dateNow;
			if (direct) {
				nextScheduleTime = nextScheduleTime.addSeconds(5);
			} else if (ss.MoreHitsAvailableIndicator__c) {
				if (this.inError) {
					nextScheduleTime = nextScheduleTime.addMinutes(Integer.valueOf(ss.RetryDelayMinutes__c));
					this.inError = false;
				}
				nextScheduleTime = nextScheduleTime.addSeconds(5);
			} else {
				if (ss.FixedTime__c && ss.ScheduleDateTime__c != null) {
					nextScheduleTime = nextScheduleTime.addDays(1);
					nextScheduleTime = DateTime.newInstance(nextScheduleTime.year(), nextScheduleTime.month(), nextScheduleTime.day(), 
							ss.ScheduleDateTime__c.hour(), ss.ScheduleDateTime__c.minute(), ss.ScheduleDateTime__c.second());
				} else {
					nextScheduleTime = nextScheduleTime.addHours(Integer.valueOf(ss.RepeatDelayHours__c));				
					nextScheduleTime = nextScheduleTime.addMinutes(Integer.valueOf(ss.RepeatDelayMinutes__c));				
				}
			}
			
			String year = string.valueof(nextScheduleTime.year());
			String month = string.valueof(nextScheduleTime.month());
			String day = string.valueof(nextScheduleTime.day());
			string hour = string.valueof(nextScheduleTime.hour());
			string minute = string.valueof(nextScheduleTime.minute());
			string second = string.valueof(nextScheduleTime.second());
			
			String cronvalue = '' + second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year; 
			string jobName = JOB_NAME_PREFIX + '_' + nextScheduleTime.format('yyyyMMddHHmm');
		
			//CustomLog.log(CustomLog.INFO, JOB_NAME_PREFIX + ' Reschedule' + nextScheduleTime, '', 'Current Time: ' + DateTime.now());
			try {
				UserDeactivationBtchSchd p = new UserDeactivationBtchSchd();
				system.schedule(jobName, cronvalue , p);
			} catch (Exception e) {
				system.debug(JOB_NAME_PREFIX + ' Failed scheduling reason: ' + e.getMessage()); //To bad
				//CustomLog.log(CustomLog.FATAL, JOB_NAME_PREFIX + ' Failed, reason: ' + e.getMessage(), 'Scheduled Time: ' + nextScheduleTime, 'Current Time: ' + DateTime.now());
			}
		} else {
			system.debug(JOB_NAME_PREFIX + ' No rescheduling!');
		}
	}
	
    private void abortAlreadyScheduled (){
    	Set<Id> cjdIdSet = new Set<Id>();
    	
    	List<CronJobDetail> cjdList = [Select c.Name, c.JobType, c.Id From CronJobDetail c where c.Name LIKE :(JOB_NAME_PREFIX+'_%')];
    	if (cjdList != null) {
    		for (CronJobDetail cjd : cjdList) {
    			cjdIdSet.add(cjd.Id);
    		}
    	}
    	
    	List<CronTrigger> ctList = [select Id, NextFireTime, CronJobDetailId from CronTrigger where CronJobDetailId in :cjdIdSet];
		if (ctList != null) {
    		for (CronTrigger ct : ctList) {
		    	system.abortJob(ct.Id);
    		}		
		}    	
    }
    
	private SchedulerSettings__c getSchedulerSettings() {
   		SchedulerSettings__c ss = SchedulerSettings__c.getValues(JOB_NAME_PREFIX);   		
		if (ss == null) {
        	ss = new SchedulerSettings__c( Name = JOB_NAME_PREFIX, 
        	                               AutoReschedule__c = true, 
        	                               RepeatDelayMinutes__c = 1, 
        	                               RepeatDelayHours__c = 1, 
        	                               MaxProcessItems__c = 10000, 
        	                               LastProcessedId__c = null, 
        	                               LastProcessedDateTime__c = DateTime.newInstance(2012, 1, 1, 12, 0, 0), 
        	                               MoreHitsAvailableIndicator__c = false,
        	                               RetryDelayMinutes__c = 10,
										   FixedTime__c = true,
										   ScheduleDateTime__c = DateTime.newInstance(2012, 1, 1, 21, 0, 0));
        	insert ss;
		}   
		return ss;
	}
	 
}