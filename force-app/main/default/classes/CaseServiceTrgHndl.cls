/**
 * @description Class to handle Service cloud cases: filter cases based on record type, and start run the methods
 *              for service cloud cases
 */
public without sharing class CaseServiceTrgHndl extends CaseTrgHndl {

    public CaseServiceTrgHndl() {
        recordTypeIdSet = new Set<Id> {
            Constants.RT_ID_CASE_SERVICECASE,
            Constants.RT_ID_CASE_INTERNALCASE
        };

        filterCaseRecords();
    }

    public override void beforeInsert() {
        CaseServiceHlpr.assignOwner(newCases);
    }

    public override void beforeUpdate() {
        CaseServiceHlpr.routeUnclassifiedCases(newCases, oldCaseMap);
        CaseServiceHlpr.validateMergeAction(newCases, oldCaseMap);
        CaseServiceHlpr.createFeedItemBeforeUpdate(newCases, oldCaseMap);
    }

}