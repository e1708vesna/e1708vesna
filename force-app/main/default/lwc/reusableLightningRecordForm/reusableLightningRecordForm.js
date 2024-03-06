/*IMPORTS*/
//Bare Module Imports
import { LightningElement, api, track } from 'lwc';

// "@salesforce/*" imports
import getFields from '@salesforce/apex/ReusableLightningRecordFormController.getFields';
/*IMPORTS*/

export default class ReusableLightningRecordForm extends LightningElement {

        @api objectName;
        @api recordTypeId;
        @api title;
        @api columns = 1;
        @track fields;
        showToast;


        connectedCallback() {
            getFields({ objectAPIName: this.objectName, fieldSetName: 'CaseCallToAction' })
                        .then((result) => {
                            this.fields = result;
                            console.log(JSON.parse(JSON.stringify(result)));
                        })
                        .catch((error) => {
                            console.log(JSON.parse(JSON.stringify(error)));
                         });
                }

        handleSuccess(event) {
            let closeModalEvent = new CustomEvent('closemodal', {detail: event.detail.id});
            this.dispatchEvent(closeModalEvent);
        }

      }