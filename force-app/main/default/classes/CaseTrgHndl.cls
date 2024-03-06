/**
 * @description General case trigger handler that triggers the filtering on record types and populates the old and new case lists and maps.
 */
public virtual class CaseTrgHndl extends TriggerHandler {

    protected List<Case> newCases;
    protected Map<Id, Case> newCaseMap;
    protected List<Case> oldCases;
    protected Map<Id, Case> oldCaseMap;

    protected void filterCaseRecords() {
        TriggerHandler.FilteredRecordSet filteredRecords = filterRecords();
        this.newCases = (List<Case>) filteredRecords.objectNewList;
        this.newCaseMap = filteredRecords.objectNewMap == null || filteredRecords.objectNewMap.isEmpty() ? new Map<Id, Case> () : new Map<Id, Case> (newCases);
        this.oldCases = (List<Case>) filteredRecords.objectOldList;
        this.oldCaseMap = filteredRecords.objectOldMap == null || filteredRecords.objectOldMap.isEmpty() ? new Map<Id, Case> () : new Map<Id, Case> (oldCases);
    }

}