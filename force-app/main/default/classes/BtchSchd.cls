/**
 * @description   : Default Scheduler methods to extend by any custom scheduler
 * @author (s)    : Brite
 */
global virtual class BtchSchd implements BtchSchdInf, Schedulable, Database.Stateful {
	@TestVisible 
	protected String JOB_NAME_PREFIX = '';  //Needs to be overwriten by the class constructor that extends this class
	@TestVisible 
	protected Boolean solo = false;
	protected DateTime startBatchDate = DateTime.now();
	@TestVisible 
	protected Boolean inError = false;
	@TestVisible 
    protected String query = '';
	@TestVisible 
    protected String countQuery = '';

    /**
     * Default constructor
     */
	global BtchSchd() {
        //Retrieve the name of this class
        this.JOB_NAME_PREFIX = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
        setQuery();
    }
	
    /**
     * Constructor to start this scheduler ones without calling a possible linked scheduler
     */
	global BtchSchd(Boolean solo) {
		this();
		this.solo = solo;
	}

    /**
     * Set the query for the batch process
     * Note: LIMIT statement is added automatically, so do not add it here!!
     */
    global virtual void setQuery() {
        String selectQuery = 'SELECT Id';
        String fromWhereQuery =  
                    ' FROM User';
        String orderByQuery = 
                    ' ORDER BY Id ASC';
                    
        //Note: LIMIT statement is added automatically, so do not add it here!!
        this.query = selectQuery + fromWhereQuery + orderByQuery;                        
        this.countQuery = 'SELECT count()' + fromWhereQuery;	//No orderBy!!
    }

	/**
     * Scheduler method
     * @param sc SchedulableContext
     */
    global virtual void execute(SchedulableContext sc) {
  	}
	
    /**
     * Execute of de scheduling on the retrieved dataset, needs to be overriden
     */
    global virtual void execute(Database.BatchableContext bc, List<SObject> sobjectList) {
    }
    
    /**
     * Last method of the scheduling process. Used to reschedule en start another scheduler
     */
    global virtual void finish(Database.BatchableContext bc) {
        try {
            if (!this.solo) {
                SchedulerSettings__c ss = getSchedulerSettings();
                if (!ss.moreHitsAvailableIndicator__c) {
                    scheduleWakeup(ss.LinkedScheduler__c, true);
                }
                scheduleWakeup(false);
            }
            this.solo = false;
        } finally {
            CustomLog.commitLog();
        }
    }

    /**
     * Wakeup another scheduler (Linked)
     * @param className String Name of the batchscheduler class that implements BtchSchdInf 
     * @param direct Boolean true if it needs to run directly
     */
	@TestVisible 
	protected void scheduleWakeup (String className, Boolean direct) {
		if (String.isNotBlank(className)) {
			try {
				// Get the Type corresponding to the class name
				Type t = Type.forName(className);
				
				// Instantiate the type.
				// The type of the instantiated object 
				//   is the interface.
				BtchSchdInf b = (BtchSchdInf)t.newInstance();	
				b.scheduleWakeup(direct);
			} catch (Exception ex) {
				System.debug(JOB_NAME_PREFIX + ' Calling scheduleWakeup failed on: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
				CustomLog.create(CustomLog.ERROR, JOB_NAME_PREFIX + ' Calling scheduleWakeup failed on: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
			}	
		}
	}
    
    /**
     * Abort al versions of this scheduler
     */
    public void scheduleStop() {
    	abortAlreadyScheduled(true);
    }

    /**
     * Schedule this proces ones without any possible linked scheduler
     */
    public virtual void scheduleSolo() {
		this.solo = true;
    	execute(null);
    }
    
    /**
     * Restart scheduler with posibility to start the scheduling direct
     * @param direct Boolean true to start direct
     */
    public void scheduleWakeup(Boolean direct) {
        SchedulerSettings__c ss = getSchedulerSettings();
    	if (abortAlreadyScheduled (false)) {
			Boolean autoReschedule = true;
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
                autoReschedule = ss.AutoReschedule__c;
                if ((ss.FixedTime__c || ss.FixedDay__c || ss.FixedMonth__c) && ss.ScheduleDateTime__c != null) {
                    if (ss.FixedMonth__c) {
                        nextScheduleTime = DateTime.newInstance(nextScheduleTime.year(), ss.ScheduleDateTime__c.month(), ss.ScheduleDateTime__c.day(), 
                                ss.ScheduleDateTime__c.hour(), ss.ScheduleDateTime__c.minute(), ss.ScheduleDateTime__c.second());
                        if (datenow > nextScheduleTime) {		
                            nextScheduleTime = nextScheduleTime.addYears(1);
                        }
                    } else if (ss.FixedDay__c) {
                        nextScheduleTime = DateTime.newInstance(nextScheduleTime.year(), nextScheduleTime.month(), ss.ScheduleDateTime__c.day(), 
                                ss.ScheduleDateTime__c.hour(), ss.ScheduleDateTime__c.minute(), ss.ScheduleDateTime__c.second());
                        if (datenow > nextScheduleTime) {		
                            nextScheduleTime = nextScheduleTime.addMonths(1);
                        }
                    } else {
                        nextScheduleTime = DateTime.newInstance(nextScheduleTime.year(), nextScheduleTime.month(), nextScheduleTime.day(), 
                                ss.ScheduleDateTime__c.hour(), ss.ScheduleDateTime__c.minute(), ss.ScheduleDateTime__c.second());
                        if (datenow > nextScheduleTime) {		
                            nextScheduleTime = nextScheduleTime.addDays(1);
                        }
                    }
                } else {
                    nextScheduleTime = nextScheduleTime.addHours(Integer.valueOf(ss.RescheduleDelayHours__c));				
                    nextScheduleTime = nextScheduleTime.addMinutes(Integer.valueOf(ss.RescheduleDelayMinutes__c));				
                }	
            }
            
            if (autoReschedule) {
                String year = string.valueof(nextScheduleTime.year());
                String month = string.valueof(nextScheduleTime.month());
                String day = string.valueof(nextScheduleTime.day());
                string hour = string.valueof(nextScheduleTime.hour());
                string minute = string.valueof(nextScheduleTime.minute());
                string second = string.valueof(nextScheduleTime.second());
                
                String cronvalue = '' + second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year; 
                string jobName = JOB_NAME_PREFIX;   // + '_' + nextScheduleTime.format('yyyyMMddHHmm'); //Keep the same name to be sure only one scheduler runs
            
                //CustomLog.log(CustomLog.INFO, JOB_NAME_PREFIX + ' Reschedule' + nextScheduleTime, 'Current Time: ' + DateTime.now(), '');
                try {
                    // Get the Type corresponding to the class name
                    Type t = Type.forName(JOB_NAME_PREFIX);	        
                    // Instantiate the type.
                    // The type of the instantiated object 
                    //   is the interface.
                    Schedulable p = (Schedulable)t.newInstance();	

                    system.schedule(jobName, cronvalue , p);
                } catch (Exception e) {
                    system.debug(JOB_NAME_PREFIX + ' Failed scheduling reason: ' + e.getMessage()); //To bad
                    CustomLog.create(CustomLog.FATAL, JOB_NAME_PREFIX + ' Failed, reason: ' + e.getMessage(), 'Scheduled Time: ' + nextScheduleTime, 'Current Time: ' + DateTime.now());
                }
            } else {
                system.debug(JOB_NAME_PREFIX + ' No rescheduling!');
            }
		} else {
            ss.moreHitsAvailableIndicator__c = true;
            update ss;
        }
	}
	
	/**
	 * Abort scheduler but not if state is ACQUIRED' or 'EXECUTING or NextTimeFire within 2 minutes
	 * Forced to stop if forceStop is true
	 * @param forceStop Boolean true to abort unconditional
	 * @Return true if aborted and a new reschedule is needed
	**/
    private Boolean abortAlreadyScheduled (Boolean forceStop){
		Boolean reschedule = true;
    	Set<Id> cjdIdSet = new Set<Id>();
		for (CronJobDetail cjd : [Select c.Name, c.JobType, c.Id From CronJobDetail c where c.Name LIKE :(JOB_NAME_PREFIX+'%')]) {
			cjdIdSet.add(cjd.Id);
		}
		
        DateTime dateNow = DateTime.now();
		for (CronTrigger ct : [select Id, state, NextFireTime, CronJobDetailId from CronTrigger where CronJobDetailId in :cjdIdSet]) {
			try {
				if (!forceStop && (ct.state == 'ACQUIRED' || ct.state == 'EXECUTING' || (ct.NextFireTime > dateNow && ct.NextFireTime < dateNow.addMinutes(2)))) {
					reschedule = false;
				} else {
					system.abortJob(ct.Id);
				}
			} catch (Exception e) {
				system.debug(JOB_NAME_PREFIX + ' abort failed aborting job: ' + e.getMessage()); //To bad
				CustomLog.create(CustomLog.FATAL, JOB_NAME_PREFIX + ' abort job Failed ', e.getMessage() + ' | ' + e.getLineNumber(), e.getStackTraceString());
			}		
		}
		return reschedule;
    }
    
    /**
     * Retrieve the settings for this scheduler or create the default
     * @return SchedulerSettings__c
     */
	public virtual SchedulerSettings__c getSchedulerSettings() {
   		SchedulerSettings__c ss = SchedulerSettings__c.getValues(JOB_NAME_PREFIX);   		
		if (ss == null) {
        	ss = new SchedulerSettings__c( Name = JOB_NAME_PREFIX, 
        	                               AutoReschedule__c = true, 
        	                               RescheduleDelayMinutes__c = 30, 
        	                               RescheduleDelayHours__c = 1, 
        	                               MaxProcessItems__c = 100, 
                                           BatchSize__c = 200,
        	                               LastProcessedId__c = null, 
        	                               LastProcessedDateTime__c = DateTime.newInstance(2012, 1, 1, 3, 0, 0), 
        	                               MoreHitsAvailableIndicator__c = false,
        	                               RetryDelayMinutes__c = 10,
										   FixedTime__c = false,
										   FixedDay__c = false,
										   FixedMonth__c = false,
										   ScheduleDateTime__c = DateTime.newInstance(2012, 1, 1, 3, 0, 0),
                                           Description__c = ' - ',
                                           LinkedScheduler__c = '');
        	insert ss;
		}   
		return ss;
	}	 
}