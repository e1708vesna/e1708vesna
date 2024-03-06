/**
 * @Description Trigger framework based on framework written by Kevin O'Hara (https://github.com/kevinohara80/sfdc-trigger-framework)
 * @Author BRITE
 */
public virtual class TriggerHandler {

    private static final String RECORD_TYPE_ID = 'RecordTypeId';
    private static final String RECORD_ID = 'Id';

    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
  
    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    // record types to run the trigger for; if left empty, trigger will run for all record types
    public Set<Id> recordTypeIdSet;
  
    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;
  
    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }
    
    // constructor
    public TriggerHandler() {
        this.setTriggerContext();
    }
  
    /***************************************
     * public instance methods
     ***************************************/
  
    // main method that will be called during execution
    public void run() {
        if (!validateRun()) return;
  
        addToLoopCount();
  
        // dispatch to the correct handler method
        if (this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
        } else if (this.context == TriggerContext.BEFORE_UPDATE) {
            this.beforeUpdate();
        } else if (this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
        } else if (this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
        } else if (this.context == TriggerContext.AFTER_UPDATE) {
            this.afterUpdate();
        } else if (this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
        } else if (this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
        }
    }
  
    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }
  
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }
  
    /***************************************
     * public static methods
     ***************************************/
  
    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }
  
    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }
  
    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }
  
    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }
  
    /***************************************
     * private instancemethods
     ***************************************/
  
    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }
  
    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }
        
        if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
            (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
            (ctx != null && ctx == 'before update')){
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
            (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
            (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
            (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
            (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
            (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }
  
    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
            if (exceeded) {
                Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }
  
    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        if (!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        if (TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return false;
        }
        return true;
    }
  
    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
  
    /***************************************
     * context methods
     ***************************************/
  
    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert(){}
    @TestVisible
    protected virtual void beforeUpdate(){}
    @TestVisible
    protected virtual void beforeDelete(){}
    @TestVisible
    protected virtual void afterInsert(){}
    @TestVisible
    protected virtual void afterUpdate(){}
    @TestVisible
    protected virtual void afterDelete(){}
    @TestVisible
    protected virtual void afterUndelete(){}
  
    /***************************************
     * inner classes
     ***************************************/
  
    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;
  
        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }
  
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }
  
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }
  
        public Boolean exceeded() {
            if (this.max < 0) return false;
            if (this.count > this.max) {
                return true;
            }
            return false;
        }
  
        public Integer getMax() {
            return this.max;
        }
  
        public Integer getCount() {
            return this.count;
        }
  
        public void setMax(Integer max) {
            this.max = max;
        }
    }
  
    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }
  
    // exception class
    public class TriggerHandlerException extends Exception {}
  

    /***************************************
     * filter records based on record type
     ***************************************/
  
    public FilteredRecordSet filterRecords() {
        FilteredRecordSet filteredRecords;

        Boolean allowAllRecordTypes = (recordTypeIdSet == null || recordTypeIdSet.isEmpty());

        if (Trigger.isUpdate) {
            filteredRecords = filterRecordsOnUpdate(allowAllRecordTypes);
        } else if (Trigger.isInsert) {
            filteredRecords = filterRecordsOnInsert(allowAllRecordTypes);
        } else if (Trigger.isDelete) {
            filteredRecords = filterRecordsOnDelete(allowAllRecordTypes);
        } else if (Trigger.isUndelete) {
            filteredRecords = filterRecordsOnUndelete(allowAllRecordTypes);
        }

        return filteredRecords;
    }

    @testVisible
    private FilteredRecordSet filterRecordsOnUpdate(Boolean allowAllRecordTypes) {
        Id recordTypeId, recordId;
        FilteredRecordSet filteredRecords = new FilteredRecordSet();

        SObject newRecord;
        SObject oldRecord;
        for (Id key : Trigger.newMap.keySet()) {
            newRecord = Trigger.newMap.get(key);
            oldRecord = Trigger.oldMap.get(key);

            // only look at record of the updated record
            if (!allowAllRecordTypes) {
                recordTypeId = (Id) newRecord.get(RECORD_TYPE_ID);
            }

            if (allowAllRecordTypes || recordTypeIdSet.contains(recordTypeId)) {
                recordId = (Id) newRecord.get(RECORD_ID);
                filteredRecords.objectNewList.add(newRecord);
                filteredRecords.objectNewMap.put(recordId, newRecord);
                filteredRecords.objectOldList.add(oldRecord);
                filteredRecords.objectOldMap.put(recordId, oldRecord);
            }
        }

        return filteredRecords;
    }

    @testVisible
    private FilteredRecordSet filterRecordsOnInsert(Boolean allowAllRecordTypes) {
        Id recordTypeId;
        FilteredRecordSet filteredRecords = new FilteredRecordSet();

        for (SObject record : Trigger.new) {
            if (!allowAllRecordTypes) {
                recordTypeId = (Id) record.get(RECORD_TYPE_ID);
            }

            if (allowAllRecordTypes || recordTypeIdSet.contains(recordTypeId)) {
                filteredRecords.objectNewList.add(record);
            }
        }

        filteredRecords.objectNewMap = Trigger.newMap;
        filteredRecords.objectOldList = Trigger.old;
        filteredRecords.objectOldMap = Trigger.oldMap;

        return filteredRecords;
    }

    @testVisible
    private FilteredRecordSet filterRecordsOnDelete(Boolean allowAllRecordTypes) {
        Id recordTypeId;
        FilteredRecordSet filteredRecords = new FilteredRecordSet();

        for (SObject record : Trigger.old) {
            if (!allowAllRecordTypes) {
                recordTypeId = (Id) record.get(RECORD_TYPE_ID);
            }

            if (allowAllRecordTypes || recordTypeIdSet.contains(recordTypeId)) {
                filteredRecords.objectOldList.add(record);
                filteredRecords.objectOldMap.put((Id) record.get(RECORD_ID), record);
            }
        }

        filteredRecords.objectNewList = Trigger.new;
        filteredRecords.objectNewMap = Trigger.newMap;

        return filteredRecords;
    }

    @testVisible
    private FilteredRecordSet filterRecordsOnUndelete(Boolean allowAllRecordTypes) {
        Id recordTypeId;
        FilteredRecordSet filteredRecords = new FilteredRecordSet();

        for (SObject record : Trigger.new) {
            if (!allowAllRecordTypes) {
                recordTypeId = (Id) record.get(RECORD_TYPE_ID);
            }

            if (allowAllRecordTypes || recordTypeIdSet.contains(recordTypeId)) {
                filteredRecords.objectNewList.add(record);
                filteredRecords.objectNewMap.put((Id) record.get(RECORD_ID), record);
            }
        }

        filteredRecords.objectOldList = Trigger.old;
        filteredRecords.objectOldMap = Trigger.oldMap;

        return filteredRecords;
    }

    public class FilteredRecordSet {

        public List<SObject> objectNewList;
        public Map<Id, SObject> objectNewMap;
        public List<SObject> objectOldList;
        public Map<Id, SObject> objectOldMap;

        public FilteredRecordSet() {
            objectNewList = new List<SObject> ();
            objectNewMap = new Map<Id, SObject> ();
            objectOldList = new List<SObject> ();
            objectOldMap = new Map<Id, SObject> ();
        }
    }

}