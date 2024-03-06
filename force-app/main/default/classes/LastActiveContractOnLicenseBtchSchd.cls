/**
 * @description   : Rollup Last Activated UAC on the License
 * @author (s)    : Brite
 */
global class LastActiveContractOnLicenseBtchSchd extends BtchSchdQueryLocator {    
    /**
     * Set the query for the batch process
     * Note: LIMIT statement is added automatically, so do not add it here!!
     */
    global override void setQuery() {
        String selectQuery = 
			'SELECT Id, TotalUACValue__c, NumberUACs__c, NumberActiveUACs__c, NumberOpenUACs__c, LastActivatedUAC__c,' +
                ' (SELECT Id, Active__c, CombinedBillingAmount__c, StartDate__c, StartDateLine__c, EndDate__c, Stage__c, RecordType.DeveloperName' + 
                ' FROM UpgradeAssurances__r ORDER BY StartDateLine__c DESC)';         
        String fromWhereQuery =  
            ' FROM License__c';
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
        LicenseHelper.updateLicenseTotals((List<License__c>)sobjectList);
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
        	                               MaxProcessItems__c = 1000000, 
                                           BatchSize__c = 200,
        	                               LastProcessedId__c = null, 
        	                               LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0), 
        	                               MoreHitsAvailableIndicator__c = false,
        	                               RetryDelayMinutes__c = 7,
										   FixedTime__c = true,
										   FixedDay__c = false,
										   FixedMonth__c = false,
										   ScheduleDateTime__c = DateTime.newInstance(2012, 1, 1, 1, 30, 0),
                                           Description__c = 'Set last activated UAC on the Licenses affected by the current date',
                                           LinkedScheduler__c = '');
			insert ss;
		}   
		return ss;
	}
}