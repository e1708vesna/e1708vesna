/**
 * @description   : Controller class for the BatchScheduler page
 * @author (s)    : Brite
 **/
public with sharing class BatchSchedulerCtrl {
	private final String DATETIMEFORMATSAP = 'yyyy-MM-dd  HH:mm:ss';
	private Map<String,SchedulerSettings__c> ssMap;
	private Set<String> nameSet = new Set<String>();	    
	public List<SchedBatJob> sbj = new List<SchedBatJob>();
	public String inputValue {get;set;}
	public Boolean buttonLock {get;set;}
	public Boolean buttonWaitUnlock = false;

	public BatchSchedulerCtrl() {
		this.buttonLock = false;
	}

	public void init() {
		getSchedulerSettingsNames();
		getStatus();		
	}
	
	public List<SchedBatJob> getSbj() {
		return this.sbj;
	}
	
	public void getStatus() {
		if (buttonWaitUnlock) {
			buttonWaitUnlock = false;
		} else {
			buttonLock = false;
		}

    	List<CronTrigger> ctList = getCronData(this.nameSet);
		List<AsyncApexJob> aajList = getApexJobData(this.ssMap.keySet());		
		Map<String,CronTrigger> nameCtMap = new Map<String,CronTrigger>();
		Map<String,List<AsyncApexJob>> nameAajMap = new Map<String,List<AsyncApexJob>>();
		String[] ctNameArray;
		for (CronTrigger ct : ctList) {
			//ctNameArray = ct.CronJobDetail.Name.split('_');
			//nameCtMap.put(ctNameArray[0], ct);
			nameCtMap.put(ct.CronJobDetail.Name, ct);
		}		
		List<AsyncApexJob> aajTmpList;
		for (AsyncApexJob aaj : aajList) {
			aajTmpList = nameAajMap.get(aaj.ApexClass.Name);
			if (aajTmpList == null) {
				aajTmpList = new List<AsyncApexJob>();
			}
			aajTmpList.add(aaj);			
			nameAajMap.put(aaj.ApexClass.Name, aajTmpList);
		}		
		
		SchedulerSettings__c ss;
		CronTrigger ctTmp;
		AsyncApexJob aajTmp;
		String nextfire;
		String state;
		String jobStatus;
		sbj = new List<SchedBatJob>();
		for (String name : this.ssMap.keySet()) {
			ss = ssMap.get(name);
			ctTmp = nameCtMap.get(name);
			if (ctTmp==null) {
				state = 'Unknown';
				nextfire = '-';
			} else {
				state = ctTmp.State;
				nextfire = formatDate(ctTmp.NextFireTime);
			}
			aajTmpList = nameAajMap.get(name);
			if (aajTmpList != null && aajTmpList.size() >= 1 && aajTmpList[0] != null) {
				jobStatus = aajTmpList[0].Status;
			} else {
				jobStatus = 'Unknown';
			}
			sbj.add(new SchedBatJob (name, state,
					nextfire, 
					ss.AutoReschedule__c ? 'Yes' : 'No', 
					ss.MoreHitsAvailableIndicator__c ? 'Yes' : 'No',
					formatDate(ss.LastProcessedDateTime__c),
					ss.LastProcessedId__c,
					ss.Description__c,
					ss.LinkedScheduler__c,
					jobStatus));
		}
	}

	public void scheduleWakeup () {
		buttonLock = true;
		buttonWaitUnlock = true;
		//inputValue will be null if no rerender is used on the command button!
		//system.debug('inputValue: ' + this.inputValue);
		scheduleWakeup(this.inputValue, false);
	}

	public void scheduleWakeupDirect () {
		buttonLock = true;
		buttonWaitUnlock = true;
		//inputValue will be null if no rerender is used on the command button!
		//system.debug('inputValue: ' + this.inputValue);
		scheduleWakeup(this.inputValue, true);
	}

	private void scheduleWakeup (String className, Boolean direct) {
		try {
			// Get the Type corresponding to the class name
	        Type t = Type.forName(className);
	        
	        // Instantiate the type.
	        // The type of the instantiated object 
	        //   is the interface.
	        BtchSchdInf b = (BtchSchdInf)t.newInstance();	
	        b.scheduleWakeup(direct);
		} catch (Exception ex) {
			system.debug('Calling scheduleWakeup failed on: ' + ex.getMessage());
		}	
	}

	public void scheduleStop () {
		scheduleStop(this.inputValue);
	}

	private void scheduleStop (String className) {
		try {
			// Get the Type corresponding to the class name
	        Type t = Type.forName(className);
	        
	        // Instantiate the type.
	        // The type of the instantiated object 
	        //   is the interface.
	        BtchSchdInf b = (BtchSchdInf)t.newInstance();	
	        b.scheduleStop();
		} catch (Exception ex) {
			system.debug('Calling schedulestop failed on: ' + ex.getMessage());
		}	
	}

	public void scheduleSolo () {
		buttonLock = true;
		buttonWaitUnlock = true;
		scheduleSolo(this.inputValue);
	}

	private void scheduleSolo (String className) {
		try {
			// Get the Type corresponding to the class name
	        Type t = Type.forName(className);
	        
	        // Instantiate the type.
	        // The type of the instantiated object 
	        //   is the interface.
	        BtchSchdInf b = (BtchSchdInf)t.newInstance();	
	        b.scheduleSolo();
		} catch (Exception ex) {
			system.debug('Calling schedulestop failed on: ' + ex.getMessage());
		}	
	}

	private String formatDate(DateTime dt) {
		String ret = 'unknown';
    	try {
    		ret = dt.format(DATETIMEFORMATSAP);
    	} catch(Exception e) {
    	}
    	return ret;
	}
	
	private List<CronTrigger> getCronData(Set<String> jobNamePrefixSet) {
    	return [SELECT c.State, c.StartTime, c.PreviousFireTime, c.NextFireTime, c.CronJobDetail.Name, c.CronJobDetailId 
				FROM CronTrigger c 
				WHERE c.CronJobDetail.Name LIKE :jobNamePrefixSet LIMIT 100];
	}
	
	private List<AsyncApexJob> getApexJobData(Set<String> jobNamePrefixSet) {
		return [SELECT Status, NumberOfErrors, ApexClass.Name, CreatedDate, ExtendedStatus, JobItemsProcessed, JobType, MethodName, ParentJobId 
				FROM AsyncApexJob 
				WHERE ApexClass.Name IN :jobNamePrefixSet
				ORDER BY CreatedDate DESC LIMIT 100];
	}

	private void getSchedulerSettingsNames() {
		this.ssMap = new Map<String,SchedulerSettings__c>();
		this.nameSet = new Set<String>();
		List<SchedulerSettings__c> ssList = SchedulerSettings__c.getall().values();
		for (SchedulerSettings__c ss : ssList) {
			this.nameSet.add(ss.Name+'%');
			this.ssMap.put(ss.Name, ss);
		}
	}
			
	@TestVisible class SchedBatJob {
		public String name;
		public String state;
		public String nextRun;
		public String autoReschedule;
		public String moreHitsAvailableIndicator;
		public String lastProcessedDateTime;
		public String lastProcessedId;
		public String description;
		public String linkedScheduler;
		public String jobStatus;

		public SchedBatJob (String name,
							String state,
							String nextRun,
							String autoReschedule,
							String moreHitsAvailableIndicator,
							String lastProcessedDateTime, 
							String lastProcessedId,
							String description,
							String linkedScheduler,
							String jobStatus) {
			this.name = name;
			this.state = state;
			this.nextRun = nextRun;
			this.autoReschedule = autoReschedule;
			this.moreHitsAvailableIndicator = moreHitsAvailableIndicator;
			this.lastProcessedDateTime = lastProcessedDateTime;
			this.lastProcessedId = lastProcessedId;
			this.description = description;
			this.linkedScheduler = linkedScheduler;
			this.jobStatus = jobStatus;
		}
		public String getName () {
			return name;
		}
		public String getState () {
			return state;
		}
		public String getNextRun () {
			return nextRun;
		}
		public String getAutoReschedule () {
			return autoReschedule;
		}
		public String getMoreHitsAvailableIndicator () {
			return moreHitsAvailableIndicator;
		}
		public String getLastProcessedDateTime () {
			return lastProcessedDateTime;
		}
		public String getLastProcessedId () {
			return lastProcessedId;
		}
		public String getDescription () {
			return description;
		}
		public String getLinkedScheduler () {
			return linkedScheduler;
		}
		public String getJobStatus () {
			return jobStatus;
		}
	}
}