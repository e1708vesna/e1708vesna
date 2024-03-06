import { LightningElement, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

export default class sectionCard extends NavigationMixin(LightningElement) {

    @api title = '';
    @api description = '';
    @api imageUrl = '';
    @api pageReference = '';

    handleClick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: this.pageReference
            }
        });
    }

}