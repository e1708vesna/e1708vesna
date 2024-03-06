/**
 * @description   : Controller class for the SyncWithNavision Lightning page
 * @author (s)    : Brite
 **/
public with sharing class SyncWithNavisionLghtCtrl {
    private static final String JOB_NAME_PREFIX_ACCOUNT = 'NavisionLicenseAccountBtchSchd';
    private static final String JOB_NAME_PREFIX_LICENSE = 'NavisionLicenseBtchSchd';
    private static final String JOB_NAME_PREFIX_LICENSEITEM = 'NavisionLicenseItemBtchSchd';
	private static final String DATETIMEFORMAT = 'yyyy-MM-dd  HH:mm:ss';

    @AuraEnabled
    public static void syncWithNavision () {
		try {
			// Get the Type corresponding to the class name
	        Type t = Type.forName(JOB_NAME_PREFIX_ACCOUNT);
	        
	        // Instantiate the type.
	        // The type of the instantiated object 
	        //   is the interface.
	        BtchSchdInf b = (BtchSchdInf)t.newInstance();	
	        b.scheduleWakeup(true);
		} catch (Exception ex) {
			system.debug('Calling scheduleWakeup failed on: ' + ex.getMessage());
        }	
    }

    @AuraEnabled
	public static List<SchedBatJob> getStatus() {
		Map<String,SchedulerSettings__c> ssMap = new Map<String,SchedulerSettings__c>();
		Set<String> nameSet = new Set<String>();
		List<SchedulerSettings__c> ssList = SchedulerSettings__c.getall().values();
		for (SchedulerSettings__c ss : ssList) {
            if (ss.Name == JOB_NAME_PREFIX_ACCOUNT ||
                    ss.Name == JOB_NAME_PREFIX_LICENSE ||
                    ss.Name == JOB_NAME_PREFIX_LICENSEITEM ) {
			    nameSet.add(ss.Name+'_%');
                ssMap.put(ss.Name, ss);
            }
		}

    	List<CronTrigger> ctList = getCronData(nameSet);
		Map<String,CronTrigger> nameCtMap = new Map<String,CronTrigger>();
		String[] ctNameArray;
		for (CronTrigger ct : ctList) {
			ctNameArray = ct.CronJobDetail.Name.split('_');
			nameCtMap.put(ctNameArray[0], ct);
		}		
		
		SchedulerSettings__c ss;
		CronTrigger ctTmp;
		List<SchedBatJob> sbj = new List<SchedBatJob>();
		for (String name : ssMap.keySet()) {
			ss = ssMap.get(name);
			ctTmp = nameCtMap.get(name);
			if (ctTmp==null) {
				sbj.add(new SchedBatJob (getCustomName(name), '-', '-', 
						ss.AutoReschedule__c ? 'Yes' : 'No', 
						ss.MoreHitsAvailableIndicator__c ? 'Yes' : 'No',
						formatDate(ss.LastProcessedDateTime__c),
						ss.LastProcessedId__c));
			} else {
				sbj.add(new SchedBatJob (getCustomName(name), ctTmp.State,
						formatDate(ctTmp.NextFireTime), 
						ss.AutoReschedule__c ? 'Yes' : 'No', 
						ss.MoreHitsAvailableIndicator__c ? 'Yes' : 'No',
						formatDate(ss.LastProcessedDateTime__c),
						ss.LastProcessedId__c));
			}
        }
        return sbj;
	}

    private static String getCustomName(String schedulerName) {
        if (schedulerName == JOB_NAME_PREFIX_ACCOUNT) {
            return 'Accounts';
        } else if (schedulerName == JOB_NAME_PREFIX_LICENSE) {
            return 'Licenses';
        } else if (schedulerName == JOB_NAME_PREFIX_LICENSEITEM) {
            return 'License Items';
        }
        return schedulerName;
    }

	private static String formatDate(DateTime dt) {
		String ret = 'unknown';
    	try {
    		ret = dt.format(DATETIMEFORMAT);
    	} catch(Exception e) {
    	}
    	return ret;
	}

    private static List<CronTrigger> getCronData(Set<String> jobNamePrefixSet) {
    	return [Select c.State, c.StartTime, c.PreviousFireTime, c.NextFireTime, c.CronJobDetail.Name, c.CronJobDetailId From CronTrigger c where c.CronJobDetail.Name LIKE :jobNamePrefixSet limit 100];
	}

    public class SchedBatJob {
		@AuraEnabled public String name;
		@AuraEnabled public String state;
		@AuraEnabled public String nextRun;
		@AuraEnabled public String autoReschedule;
		@AuraEnabled public String MoreHitsAvailableIndicator;
		@AuraEnabled public String LastProcessedDateTime;
		@AuraEnabled public String LastProcessedId;
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
        /*
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
        */
	}

}