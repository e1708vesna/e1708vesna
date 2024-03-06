/**
 * @description   : Class for the functionality Send Email to partners Ugrade Assurance Contract activate
 *                  Run every 1 Oktober
 *                  direct start is not smart for this process
 * @author (s)    : Brite
 */    
global class PartnerMailBtchSchd extends BtchSchdQueryLocator {    
    private static final String EMAIL_TEMPLATE_NAME = 'ContractRenewalReminder';  
        
    /**
     * Set the query for the batch process
     * Note: LIMIT statement is added automatically, so do not add it here!!
     */
    global override void setQuery() {
        startBatchDate = DateTime.now();
        String recordTypeDeveloperName = 'Cloned_Contract';
        Integer thisYear = Date.today().Year();
        String selectQuery = 
            'SELECT Id,' +
                ' (SELECT Id, Name, License__c, EndDate__c, Active__c FROM UpgradeAssuranceContractsChannelPartner__r' + 
                    ' WHERE Active__c = true AND (EndDate__c = null OR CALENDAR_YEAR(EndDate__c) > ' + thisYear + ')),' +
            	' (SELECT Id, LastName, FirstName, Salutation, Name, Email FROM Contacts)';
        String fromWhereQuery =  
            ' FROM Account' + 
            ' WHERE ChannelPartner__c = null AND ID IN' +
                ' (SELECT ChannelPartner__c FROM UpgradeAssuranceContract__c WHERE Active__c = true AND (EndDate__c = null OR CALENDAR_YEAR(EndDate__c) > ' + thisYear + '))';
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
        PartnerMailHelper.sendBatchMail((List<Account>)sobjectList, EMAIL_TEMPLATE_NAME, null);
    }
   
    /**
     * Retrieve the settings for this scheduler or create the default
     * @return SchedulerSettings__c
     */    
    public override SchedulerSettings__c getSchedulerSettings() {
        //Note max 1000 emails at ones so this is 5 x Acoount x contacts at Account = expected less than 200Contacts/Account
        SchedulerSettings__c ss = SchedulerSettings__c.getValues(JOB_NAME_PREFIX);          
        if (ss == null) {
            ss = new SchedulerSettings__c( Name = JOB_NAME_PREFIX, 
                                           AutoReschedule__c = true, 
                                           RescheduleDelayMinutes__c = 1, 
                                           RescheduleDelayHours__c = 1, 
                                           MaxProcessItems__c = 5000, 
                                           BatchSize__c = 5,
                                           LastProcessedId__c = null, 
                                           LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0), 
                                           MoreHitsAvailableIndicator__c = false,
                                           RetryDelayMinutes__c = 7,
                                           FixedTime__c = true,
                                           FixedDay__c = true,
                                           FixedMonth__c = true,
                                           ScheduleDateTime__c = DateTime.newInstance(2012, 10, 1, 9, 0, 0),
                                           Description__c = 'Send Email to partners for Ugrade Assurance Contract activate. Run every 1 Oktober',
                                           LinkedScheduler__c = '');
            insert ss;
        }   
        return ss;
    }             
}