//Bare Module Imports
import { api, wire } from 'lwc';

// "lightning/*" imports
import LightningModal from 'lightning/modal';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

// "@salesforce/*" imports
import CASE_OBJECT from '@salesforce/schema/Case';
//import CaseCreationFailureMessage from '@salesforce/label/c.CaseCreationFailureMessage';
//import EmptyStateHeading from '@salesforce/label/c.EmptyStateErrorHeading1';
//import CaseCreationSuccessMessage from '@salesforce/label/c.CaseCreationSuccessMessage';

export default class ReusableModal extends LightningModal {

    /*label = {
                CaseCreationFailureMessage,
                EmptyStateHeading,
                CaseCreationSuccessMessage
            };*/
    @api objectName = 'Case';
    @api fieldSetName = 'CaseCallToAction';
    supportCaseRecordTypeId;
    showToast;

    get inputVariables() {
            return [
                {
                    name: 'varIsManualSupportCase',
                    type: 'Boolean',
                    value: true
                }
            ];
        }

    connectedCallback() {
        console.log('label' + this.label.CaseCreationSuccessMessage);
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
          wiredObject(result) {
              if (result.data) {
                  this.objectInfo = result.data;
                  const recordTypes = this.objectInfo.recordTypeInfos;
                  this.supportCaseRecordTypeId = Object.keys(recordTypes).find(recordTypeId => recordTypes[recordTypeId].name === 'Support');
              }
              else if (result.error) {
                  //TBD - Use Error Logging to log the error
                  //this.error = result.error;
                  this.showEmptyState = true;
              }
    }

    handleClose(event) {
        this.showToast = true;
        this.close(event.detail);
    }
}