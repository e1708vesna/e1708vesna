import { LightningElement, api, wire } from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';
import getSimilarProducts from '@salesforce/apex/ProductCtrl.getSimilarProducts';
import PRODUCT_FAMILY_FIELD from '@salesforce/schema/Product2.Category__c';

const fields = [PRODUCT_FAMILY_FIELD];

export default class SimilarProducts extends LightningElement {
    @api recordId;
    @api familyId;

    // Track changes to the Category__c field that could be made in other components.
    // If Category__c is updated in another component, getSimilarProducts
    // is automatically re-invoked with the new this.familyId parameter
    @wire(getRecord, { recordId: '$recordId', fields })
    product

    @wire(getSimilarProducts, {
        productId: '$recordId',
        familyId: '$product.data.fields.Category__c.value'
    })
    similarProducts;

    get errors() {
        const errors = [this.product.error, this.similarProducts.error].filter(
            (error) => error
        );
        return errors.length ? errors : undefined;
    }
}