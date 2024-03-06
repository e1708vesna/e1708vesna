import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import HYPERCARE_FIELD from '@salesforce/schema/Case.HypercareMode__c';
import userHasSkill from '@salesforce/apex/CaseHyperCareNotificationCtrl.userHasSkill';
import hypercareAccountMessage from '@salesforce/label/c.HypercareAccountMessage';
import handoverMessage from '@salesforce/label/c.HypercareHandoverMessage';
export default class CaseHyperCareNotification extends LightningElement {

    @api recordId;
    requestedFields = [HYPERCARE_FIELD];
    HYPERCARE_SKILLNAME = 'Hypercare';

    hypercareMode = false;
    agentHasSkill = true;
    loading = true;

    label = {
        hypercareAccountMessage,
        handoverMessage,
    };
    @wire(getRecord, { recordId: '$recordId', fields: '$requestedFields' }) 
    initializeComponent({data, error}) {
        if (data) {
            this.hypercareMode = getFieldValue(data, HYPERCARE_FIELD);
            if (this.hypercareMode){
                userHasSkill({skillName: this.HYPERCARE_SKILLNAME})
                .then(result => {
                    this.agentHasSkill = result;
                    this.loading = false;
                })
                .catch(error => {
                    console.log(error);
                    this.loading = false;
                });
            }
        } else if (error) {
            this.loading = false;
            console.log(error);
        }
    };
    
    get notAgentHasSkill() {
        return !this.agentHasSkill;
    }
}