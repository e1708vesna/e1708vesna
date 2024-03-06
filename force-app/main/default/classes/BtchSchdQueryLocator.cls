/**
 * @description   : Default Scheduler to extend by any custom scheduler that uses the QueryLocater
 * @author (s)    : Brite
 */
global virtual class BtchSchdQueryLocator extends BtchSchd implements Database.Batchable<SObject>, Database.AllowsCallouts {	   
	/**
     * Scheduler method
     * @param sc SchedulableContext
     */
    global override void execute(SchedulableContext sc) {
        //System.debug('BtchSchdQueryLocator->execute Solo: ' + this.solo);
        SchedulerSettings__c ss = getSchedulerSettings();
		Type t = Type.forName(JOB_NAME_PREFIX);
		BtchSchdQueryLocator b = (BtchSchdQueryLocator)t.newInstance();
        b.solo = this.solo;
     	Database.executeBatch((Database.Batchable<SObject>)b, Integer.valueOf(ss.BatchSize__c));
  	}

    /**
     * Start of the scheduling process
     * @Param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext bc){
        Database.QueryLocator ql = null;
        try {
            ql = getDataSet();
        } catch(exception ex) {
            System.debug(JOB_NAME_PREFIX + '.getDataSet() failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, JOB_NAME_PREFIX + '.getDataSet() failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
        }
        finally {
            CustomLog.commitLog();
        }
        return ql;
    }

    /**
     * Retrieve dataset, needs to be overriden
     * @return List<SOBjects>
     */
    global virtual Database.QueryLocator getDataSet() {      
        Database.QueryLocator ql = null;
        SchedulerSettings__c ss = getSchedulerSettings();
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
}