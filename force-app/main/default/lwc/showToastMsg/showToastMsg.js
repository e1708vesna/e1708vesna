import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ShowToastMsg extends LightningElement {
    
    @api title;
    @api message;
    @api variant;
    @api mode;
    @api linkURL;
    @api linkText;
    @api linkLabel;
    @track messageData;

    // initialize component
    connectedCallback() {
        const event = new ShowToastEvent({
            title: this.title,
            message: this.message,
            variant: this.variant,
            mode: this.mode,
            messageData: this.processMessageData()
        });
        this.dispatchEvent(event);
    }

    /**
       * Checks the params for displaying links on the toast
       * and dynamically forms the parameter to be passed
       *
       * @return {object to be passed to toast event}
       */
    processMessageData() {
        if(this.linkURL && this.linkText) {
            this.messageData = [
                this.linkLabel,
                {
                    url: this.linkURL,
                    label: this.linkText
                }
            ];
        }
        return this.messageData;
    }
}