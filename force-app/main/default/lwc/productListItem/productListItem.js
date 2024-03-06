import { LightningElement, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

/** Product2 Schema. */
import PRODUCT_OBJECT from '@salesforce/schema/Product2';

/**
 * A presentation component to display a Product2 sObject. The provided
 * Product2 data must contain all fields used by this component.
 */
export default class ProductListItem extends NavigationMixin(LightningElement) {

    @api product;

    /** View Details Handler to navigates to the record page */
    handleViewDetailsClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.product.Id,
                objectApiName: PRODUCT_OBJECT.objectApiName,
                actionName: 'view'
            }
        });
    }
}
