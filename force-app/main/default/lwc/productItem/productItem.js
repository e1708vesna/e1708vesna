import { LightningElement, api, wire } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import PRODUCT_ADDED_MESSAGE from '@salesforce/messageChannel/ProductAdded__c'; 

import PRODUCT_OBJECT from '@salesforce/schema/Product2';
/**
 * A presentation component to display a Product2 sObject. The provided
 * Product2 data must contain all fields used by this component.
 */

export default class ProductItem extends NavigationMixin(LightningElement) {

    _product;

    /** Product2 to display. */
    @api
    /** We pass the product's data from the controller to LWC. */
    get product(){
        return this._product;
    }
    /** We pass the product's data from the LWC to the controller. */
    set product(value){
        this._product = value;
        this.pictureUrl = value.DisplayUrl;
        this.name = value.Name;
        this.msrp = value.MSRP__c
    }

    @wire(MessageContext) messageContext;

    productDetails(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.product.Id,
                objectApiName: PRODUCT_OBJECT.objectApiName,
                actionName: 'view'
            }
        });
    }

    addToCart() { 
        publish(this.messageContext, PRODUCT_ADDED_MESSAGE, {
            product: this.product
        });
    }
   
}