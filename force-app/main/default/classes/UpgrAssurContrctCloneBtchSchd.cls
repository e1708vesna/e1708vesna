/**
 * @description   : Class for the functionality Ugrade Assurance Contract clone
 *                  Run every 1 November
 *                  direct start is not smart for this process
 * @author (s)    : Brite
 */ 
global class UpgrAssurContrctCloneBtchSchd extends BtchSchdQueryLocator {
    /**
     * Retrieve dataset, needs to be overriden
     * @return List<SOBjects>
     */
    global override Database.QueryLocator getDataSet() {      
        Database.QueryLocator ql = null;
        SchedulerSettings__c ss = getSchedulerSettings();
        //modified-->

        // filter the existing cloned Upgrade Assurance Contract records    
        Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
        List<UpgradeAssuranceContract__c> uacExistList = [SELECT Id, License__c FROM UpgradeAssuranceContract__c WHERE RecordTypeId = :RtIdClonedContract AND StartDateLine__c = NEXT_YEAR];
        Set<Id> licenseIdSet = new Set<Id>();
        for (UpgradeAssuranceContract__c uac : uacExistList) {
            if (uac.License__c != null) {
                licenseIdSet.add(uac.License__c);
            }
        }
        //Main query
        Id rtIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
        String selectQuery = 
            'SELECT u.YourReference__c, u.YourOrder__c, u.Version__c, u.UpgradeAssuranceValue__c, u.Status__c, u.StartDate__c, u.StartDateLine__c, u.Stage__c, u.SignedDate__c,' +
                ' u.SignedBy__c, u.RecordTypeId, u.PercentageDiscountDate__c, u.PartnerDiscountPercentage__c, u.OutstandingLineAmount__c, u.NavisionUaNumber__c, u.Name,' + 
                ' u.LineAmount__c, u.LicenseeName__c, u.License__c, u.IsDeleted, u.Invoice__c, u.Id, u.Handler__c, u.FlatFeeUa__c, u.Exception__c, u.EndDate__c, u.EndDateLine__c,' +
                ' u.EndCustomer__c, u.Email__c, u.DocumentType__c, u.Currency__c, u.ContractDuration__c, u.ChannelPartner__c, u.CalculationPercentage__c, u.CalculationMethod__c,' +
                ' u.Billing__c, u.BillingValueUa__c, u.Approved__c, u.AdditionalConditions__c, u.BillingPercentage__c, u.AdditionalConditionsReason__c, u.Active__c,' +
                ' u.AcceptTermsAndConditions__c';
        String fromWhereQuery =  
            ' FROM UpgradeAssuranceContract__c u WHERE Active__c = true AND RecordTypeId = :rtIdActivatedContract  AND StartDateLine__c = THIS_YEAR AND License__c NOT IN :licenseIdSet';
        String orderByQuery = 
            '';
                    
        //Note: LIMIT statement is added automatically, so do not add it here!!

        this.query = selectQuery + fromWhereQuery + orderByQuery;                        
        this.countQuery = 'SELECT count()' + fromWhereQuery;	//No orderBy!!
        //modified<--
        String countQueryTmp = countQuery + ' LIMIT ' + (Integer)ss.MaxProcessItems__c;
        system.debug('getDataSet countQueryTmp: ' + countQueryTmp);
        Integer cnt = Database.countQuery(countQueryTmp);
        String queryTmp = query + ' LIMIT ' + (Integer)ss.MaxProcessItems__c;
        system.debug('getDataSet queryTmp: ' + queryTmp);
        ql = Database.getQueryLocator (queryTmp);
        if (cnt >= ss.MaxProcessItems__c) {
            ss.moreHitsAvailableIndicator__c = true;
        }
        else {
            ss.moreHitsAvailableIndicator__c = false;
        }
        ss.LastProcessedDateTime__c = startBatchDate;
        update ss;
        return ql;
    }	    
    
    /**
     * Execute of de scheduling on the retrieved dataset
     */
    global override void execute (Database.BatchableContext bc, List<SObject> sobjectList) {
        List<UpgradeAssuranceContract__c> uacList = (List<UpgradeAssuranceContract__c>)sobjectList;    
        UpgrAssurContrctCloneHelper.cloneUpgradeAssuranceContract (uacList);
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
                                           MaxProcessItems__c = 5000, 
                                           BatchSize__c = 200,
                                           LastProcessedId__c = null, 
                                           LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0), 
                                           MoreHitsAvailableIndicator__c = false,
                                           RetryDelayMinutes__c = 7,
                                           FixedTime__c = true,
                                           FixedDay__c = true,
                                           FixedMonth__c = true,
                                           ScheduleDateTime__c = DateTime.newInstance(2012, 11, 1, 4, 0, 0),
										   Description__c = 'Ugrade Assurance Contract clone run every 1 November',
                                           LinkedScheduler__c ='');
			insert ss;
        }   
        return ss;
    }
}