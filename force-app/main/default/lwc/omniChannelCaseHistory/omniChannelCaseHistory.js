import { LightningElement, api, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

export default class OmniChannelCaseHistory extends LightningElement {
    error;
    records;
    @wire(getRelatedListRecords, {
        parentRecordId: '0017E00001KrW7vQAF',
        relatedListId: 'Contacts',
        fields: ['Contact.Id','Contact.Name']
    })listInfo({ error, data }) {
        if (data) {
            this.records = data.records;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }
}