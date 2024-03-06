import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class LwcFlowButton extends LightningElement {

    @api targetLookup;
    @api contactNeeded;
    @api availableActions = [];

    renderedCallback(){
        const attributeChangeEvent = new FlowAttributeChangeEvent('contactNeeded', false);
        this.dispatchEvent(attributeChangeEvent);
        console.log('rendered '+this.contactNeeded);
    }

    handleClick(event) {
        // check if NEXT is allowed on this screen
        if (this.availableActions.find(action => action === 'NEXT')) {
            // set contactNeeded so we can load the proper screen in our Flow
            const attributeChangeEvent = new FlowAttributeChangeEvent('contactNeeded', true);
            this.dispatchEvent(attributeChangeEvent);
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

}