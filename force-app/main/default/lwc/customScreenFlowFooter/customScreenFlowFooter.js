import { LightningElement, api } from 'lwc';
import { FlowNavigationBackEvent , FlowNavigationFinishEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';

export default class CustomScreenFlowFooter extends NavigationMixin(LightningElement) {
    @api availableActions = [];

    showNextButton = false;
    showFinishButton = false;

    connectedCallback() {
        if (this.availableActions.find((action) => action === 'NEXT')) {
            this.showNextButton = true;
        }
        if (this.availableActions.find((action) => action === 'FINISH')) {
            this.showFinishButton = true;
        }
    }    

    handleCancel(event) {
        this.navigateToObjectHome();
    }

    handleNext(event) {
        if (this.availableActions.find((action) => action === 'NEXT')) {
            // navigate to the next screen
            const navigationEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigationEvent);
        }
    }

    handleFinish() {
        if (this.availableActions.find((action) => action === 'FINISH')) {
            // navigate to the next screen
            const navigationEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigationEvent);
        }
    }

    navigateToObjectHome() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'home'
            }
        });
    }
}