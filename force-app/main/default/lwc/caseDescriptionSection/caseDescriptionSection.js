import { LightningElement, api } from 'lwc';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';

export default class RecordFormExample extends LightningElement {
    // Expose a field to make it available in the template
    fields = [DESCRIPTION_FIELD];

    // Flexipage provides recordId and objectApiName
    @api recordId;
    @api objectApiName;
}