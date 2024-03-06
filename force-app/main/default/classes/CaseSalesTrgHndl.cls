/**
 * @description Class to handle Sales cloud cases: filter cases based on record type, and start run the methods
 *              for sales cloud cases
 * @author BRITE
 */
public without sharing class CaseSalesTrgHndl extends CaseTrgHndl {

    public CaseSalesTrgHndl() {
        recordTypeIdSet = new Set<Id> {
            // case record types
        };

        filterCaseRecords();
    }

    public override void beforeInsert() {
        // call method in case helper class
    }

}