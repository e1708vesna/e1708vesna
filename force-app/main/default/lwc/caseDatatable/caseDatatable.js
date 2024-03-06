import { LightningElement, wire, api } from "lwc";
import { refreshApex } from "@salesforce/apex";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SUBJECT_FIELD from "@salesforce/schema/Case.Subject";
import CASE_NUMBER_FIELD from "@salesforce/schema/Case.CaseNumber";
import TYPE_FIELD from "@salesforce/schema/Case.Type";
import ID_FIELD from "@salesforce/schema/Case.Id";

const COLS = [
  {
    label: "CASE_NUMBER_FIELD.fieldName",
    fieldName: CASE_NUMBER_FIELD.fieldApiName,
    editable: false,
  },
  {
    label: "SUBJECT_FIELD.fieldName",
    fieldName: SUBJECT_FIELD.fieldApiName,
    editable: false,
  },
  {
    label: "TYPE_FIELD.fieldName",
    fieldName: TYPE_FIELD.fieldApiName,
    editable: true,
  },
];
export default class CaseDatatable extends LightningElement {
  columns = COLS;
  draftValues = [];

  @api cases;

    connectedCallback() {
        console.log('Input Cases:');
    console.log(JSON.stringify(this.cases));
    }

  async handleSave(event) {
    // Convert datatable draft values into record objects
    const records = event.detail.draftValues.slice().map((draftValue) => {
      const fields = Object.assign({}, draftValue);
      return { fields };
    });

    // Clear all datatable draft values
    this.draftValues = [];

    try {
      // Update all records in parallel thanks to the UI API
      const recordUpdatePromises = records.map((record) => updateRecord(record));
      await Promise.all(recordUpdatePromises);

      // Report success with a toast
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Contacts updated",
          variant: "success",
        }),
      );

      // Display fresh data in the datatable
      await refreshApex(this.contacts);
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error updating or reloading contacts",
          message: error.body.message,
          variant: "error",
        }),
      );
    }
  }
}