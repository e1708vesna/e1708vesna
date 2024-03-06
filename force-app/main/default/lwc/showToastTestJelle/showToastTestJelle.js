import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class ShowToastTestJelle extends NavigationMixin( LightningElement) {
    // initialize component
    connectedCallback() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '500RR000001LeOTYA0' ,
                actionName: 'view',
            },
        }).then( url =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'To got to the Case: {0}',
                    messageData: [{
                        url,
                        label: 'click here'
                    },]
                })
            );
        })
    }
}