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

	public BatchSchedulerCtrl() {
	}

	public void init() {
		getSchedulerSettingsNames();
		getStatus();		
	}
	
	public List<SchedBatJob> getSbj() {
		return this.sbj;
	}
	
	public void getStatus() {
    	List<CronTrigger> ctList = getCronData(this.nameSet);
		Map<String,CronTrigger> nameCtMap = new Map<String,CronTrigger>();
		String[] ctNameArray;
		for (CronTrigger ct : ctList) {
			ctNameArray = ct.CronJobDetail.Name.split('_');
			nameCtMap.put(ctNameArray[0], ct);
		}		
		
		SchedulerSettings__c ss;
		CronTrigger ctTmp;
		sbj = new List<SchedBatJob>();
		for (String name : this.ssMap.keySet()) {
			ss = ssMap.get(name);
			ctTmp = nameCtMap.get(name);
			if (ctTmp==null) {
				sbj.add(new SchedBatJob (name, 'Unknown', '-', 
						ss.AutoReschedule__c ? 'Yes' : 'No', 
						ss.MoreHitsAvailableIndicator__c ? 'Yes' : 'No',
						formatDate(ss.LastProcessedDateTime__c),
						ss.LastProcessedId__c));
			} else {
				sbj.add(new SchedBatJob (name, ctTmp.State,
						formatDate(ctTmp.NextFireTime), 
						ss.AutoReschedule__c ? 'Yes' : 'No', 
						ss.MoreHitsAvailableIndicator__c ? 'Yes' : 'No',
						formatDate(ss.LastProcessedDateTime__c),
						ss.LastProcessedId__c));
			}
		}
	}

	public void scheduleWakeup () {
		//inputValue will be null if no rerender is used on the command button!
		//system.debug('inputValue: ' + this.inputValue);
		scheduleWakeup(this.inputValue);
	}

	private void scheduleWakeup (String className) {
		try {
			// Get the Type corresponding to the class name
	        Type t = Type.forName(className);
	        
	        // Instantiate the type.
	        // The type of the instantiated object 
	        //   is the interface.
	        BtchSchdImpl b = (BtchSchdImpl)t.newInstance();	
	        b.scheduleWakeup(true);
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
	        BtchSchdImpl b = (BtchSchdImpl)t.newInstance();	
	        b.scheduleStop();
		} catch (Exception ex) {
			system.debug('Calling schedulestop failed on: ' + ex.getMessage());
		}	
	}

	public void scheduleSolo () {
		scheduleSolo(this.inputValue);
	}

	private void scheduleSolo (String className) {
		try {
			// Get the Type corresponding to the class name
	        Type t = Type.forName(className);
	        
	        // Instantiate the type.
	        // The type of the instantiated object 
	        //   is the interface.
	        BtchSchdImpl b = (BtchSchdImpl)t.newInstance();	
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
    	return [Select c.State, c.StartTime, c.PreviousFireTime, c.NextFireTime, c.CronJobDetail.Name, c.CronJobDetailId From CronTrigger c where c.CronJobDetail.Name LIKE :jobNamePrefixSet limit 100];
	}
	
	private void getSchedulerSettingsNames() {
		this.ssMap = new Map<String,SchedulerSettings__c>();
		this.nameSet = new Set<String>();
		List<SchedulerSettings__c> ssList = SchedulerSettings__c.getall().values();
		for (SchedulerSettings__c ss : ssList) {
			this.nameSet.add(ss.Name+'_%');
			this.ssMap.put(ss.Name, ss);
		}
	}
			
	@TestVisible class SchedBatJob {
		public String name;
		public String state;
		public String nextRun;
		public String autoReschedule;
		public String MoreHitsAvailableIndicator;
		public String LastProcessedDateTime;
		public String LastProcessedId;
		public SchedBatJob (String name,
							String state,
							String nextRun,
							String autoReschedule,
							String MoreHitsAvailableIndicator,
							String LastProcessedDateTime, 
							String LastProcessedId) {
			this.name = name;
			this.state = state;
			this.nextRun = nextRun;
			this.autoReschedule = autoReschedule;
			this.MoreHitsAvailableIndicator = MoreHitsAvailableIndicator;
			this.LastProcessedDateTime = LastProcessedDateTime;
			this.LastProcessedId = LastProcessedId;
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
			return MoreHitsAvailableIndicator;
		}
		public String getLastProcessedDateTime () {
			return LastProcessedDateTime;
		}
		public String getLastProcessedId () {
			return LastProcessedId;
		}
	}
}