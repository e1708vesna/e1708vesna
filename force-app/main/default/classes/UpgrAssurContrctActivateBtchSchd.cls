/**
 * @description   : Class for the functionality Ugrade Assurance Contract activate
 *                  Run every 1 Januari
 *                  direct start is not smart for this process
 * @author (s)    : Brite
 */
    
global class UpgrAssurContrctActivateBtchSchd extends BtchSchdQueryLocator {
    /**
     * Set the query for the batch process
     * Note: LIMIT statement is added automatically, so do not add it here!!
     */
    global override void setQuery() {
        //Id rtIdPendingContract = RecordTypeUtil.getRecordTypeIdByDevName('Pending_Contract', UpgradeAssuranceContract__c.getSObjectType());
        Id rtIdClonedContract = RecordTypeUtil.getRecordTypeIdByDevName('Cloned_Contract', UpgradeAssuranceContract__c.getSObjectType());
        String selectQuery = 
            'SELECT u.YourReference__c, u.YourOrder__c, u.Version__c, u.UpgradeAssuranceValue__c, u.Status__c, u.StartDate__c, u.StartDateLine__c, u.Stage__c, u.SignedDate__c,' +
                ' u.SignedBy__c, u.RecordTypeId, u.PercentageDiscountDate__c, u.PartnerDiscountPercentage__c, u.OutstandingLineAmount__c, u.NavisionUaNumber__c, u.Name,' +
                ' u.LineAmount__c, u.LicenseeName__c, u.License__c, u.RecalculatedLicenseValue__c, u.IsDeleted, u.Invoice__c, u.Id, u.Handler__c, u.FlatFeeUa__c, u.Exception__c,' +
                ' u.EndDate__c, u.EndDateLine__c, u.EndCustomer__c, u.Email__c, u.DocumentType__c, u.Currency__c, u.ContractDuration__c, u.ChannelPartner__c,' +
                ' u.CalculationPercentage__c, u.CalculationMethod__c, u.Billing__c, u.BillingValueUa__c, u.Approved__c, u.RecalculatedAdjustedLicenseValue__c,' +
                ' u.AdditionalConditions__c, u.AdditionalConditionsReason__c, u.Active__c, u.AcceptTermsAndConditions__c'; 
                //',(SELECT Id, IsDeleted, Name, UpgradeAssuranceContract__c, AdjustedQuantity__c, AdjustedUnitPrice__c, AdjustmentReason__c, ArticleNumber__c, Currency__c, InitialQuantity__c, ItemDescription__c, LicenseItem__c, LineNumber__c, NavisionExternalId__c, PriceDate__c, Quantity__c, SQLTimeStamp__c, TotalPrice__c, UnitPrice__c, UpgradeAssuranceContractTypeVersion__c, VersionCode__c, AdjustedTotalPriceFormula__c FROM Upgrade_Assurance_Contract_Items__r) ' + 
        String fromWhereQuery =  
            ' FROM UpgradeAssuranceContract__c u WHERE RecordTypeId = \'' + rtIdClonedContract + '\' AND AdditionalConditions__c = false AND StartDateLine__c = THIS_YEAR ';
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
        List<UpgradeAssuranceContract__c> uacList = (List<UpgradeAssuranceContract__c>)sobjectList;
        Integer thisYear = Date.today().Year();
        Id rtIdActivatedContract = RecordTypeUtil.getRecordTypeIdByDevName ('Activated_Contract', UpgradeAssuranceContract__c.getSObjectType());
        
        List<UpgradeAssuranceContract__c> uacToActivateList = new List<UpgradeAssuranceContract__c>();
        
        for (UpgradeAssuranceContract__c uac : uacList) {
            uac.RecordTypeId = rtIdActivatedContract;
            uac.Stage__c = 'Order';
            uacToActivateList.add(uac);
            //Auto Approve
            uac.Approved__c = true;
        }
        
        try {
            String errMsg = '';
            String suc6Msg = '';
            Integer errCnt = 0;
            Integer suc6Cnt = 0;
            Integer i = 0;
        
            if (!uacToActivateList.isEmpty()) {
                Database.SaveResult[] srList = Database.update(uacToActivateList, false);
                i = 0;
                for(Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful
                        suc6Cnt++;
                        suc6Msg += uacToActivateList[i].Name + '|' + uacToActivateList[i].License__c + '\t'; 
                    }
                    else {
                        errCnt++;
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            errMsg += uacToActivateList[i].Name + '|' + uacToActivateList[i].License__c + '|' + err.getStatusCode() + ': ' + err.getMessage() + '\t';
                        }
                        errMsg += '\n';
                    }
                    i++;
                }
            }
            if (suc6Cnt!=0) {
                System.debug('Successfully activated ' + suc6Cnt + ' Upgrade Assurance Contracts');
                CustomLog.create(CustomLog.INFO, 'Successfully activated ' + suc6Cnt + ' Upgrade Assurance Contracts', suc6Msg, '');
            }
            if (errMsg!='') {
                System.debug(errMsg);
                CustomLog.create(CustomLog.ERROR, 'Failed activated ' + errCnt + ' Upgrade Assurance Contracts', errMsg, '');
            }
        } catch (exception ex) {
            System.debug('Activating Upgrade Assurance Contracts failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, 'Activating Upgrade Assurance Contracts failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
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
                                           MaxProcessItems__c = 1000000, 
                                           BatchSize__c = 200,
                                           LastProcessedId__c = null, 
                                           LastProcessedDateTime__c = DateTime.newInstance(1970, 1, 1, 12, 0, 0), 
                                           MoreHitsAvailableIndicator__c = false,
                                           RetryDelayMinutes__c = 7,
                                           FixedTime__c = true,
                                           FixedDay__c = true,
                                           FixedMonth__c = true,
                                           ScheduleDateTime__c = DateTime.newInstance(2012, 1, 1, 4, 0, 0),
										   Description__c = 'Activate UAC Contracts run every 1 Februari',
                                           LinkedScheduler__c ='');
			insert ss;
        }   
        return ss;
    }             
}