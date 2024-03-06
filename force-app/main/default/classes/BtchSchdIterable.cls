/**
 * @description   : Default Scheduler to extend by any custom scheduler that uses the Iterable
 * @author (s)    : Brite
 */
global virtual class BtchSchdIterable extends BtchSchd implements Database.Batchable<SObject>, Database.AllowsCallouts {
	/**
     * Scheduler method
     * @param sc SchedulableContext
     */
    global override void execute(SchedulableContext sc) {
        //System.debug('BtchSchdIterable->execute Solo: ' + this.solo);
        SchedulerSettings__c ss = getSchedulerSettings();
		Type t = Type.forName(JOB_NAME_PREFIX);
		BtchSchdIterable b = (BtchSchdIterable)t.newInstance();
        b.solo = this.solo;
     	Database.executeBatch((Database.Batchable<SObject>)b, Integer.valueOf(ss.BatchSize__c));
  	}

    /**
     * Start of the scheduling process
     * @Param bc Database.BatchableContext
     * @return Iterable<SObject>
     */
    global virtual Iterable<SObject> start(Database.BatchableContext bc){
        List<SObject> sObjectList = new List<SObject>();
        try {
            sObjectList = getDataSet();
        } catch(exception ex) {
            System.debug(JOB_NAME_PREFIX + '.getDataSet() failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, JOB_NAME_PREFIX + '.getDataSet() failed at: ', ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
        }
        finally {
            CustomLog.commitLog();
        }
        return sObjectList;
    }
 
    /**
     * Retrieve dataset, needs to be overriden
     * @return List<SOBjects>
     */
    global virtual List<SObject> getDataSet() {        
        //system.debug('getDataSet query: ' + query);
        SchedulerSettings__c ss = getSchedulerSettings();
        String queryTmp = query + ' LIMIT ' + (Integer)ss.MaxProcessItems__c;
        List<SObject> sObjectList = Database.query(queryTmp);
        if (sObjectList.size() >= ss.MaxProcessItems__c) {
            ss.moreHitsAvailableIndicator__c = true;
        }
        else {
            ss.moreHitsAvailableIndicator__c = false;
        }
        ss.LastProcessedDateTime__c = startBatchDate;
        update ss;
        return sObjectList;
    }   
}