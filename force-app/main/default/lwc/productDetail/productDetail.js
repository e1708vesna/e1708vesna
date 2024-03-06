import { LightningElement, wire } from 'lwc';

// Lightning Message Service and a message channel
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext } from 'lightning/messageService';
import PRODUCT_SELECTED_DETAIL_MESSAGE from '@salesforce/messageChannel/ProductSelected__c';

// Utils to extract field values
import { getFieldValue } from 'lightning/uiRecordApi';

// Product__c Schema
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import NAME_FIELD from '@salesforce/schema/Product2.Name';
import PICTURE_URL_FIELD from '@salesforce/schema/Product2.DisplayURL';
import CATEGORY_FIELD from '@salesforce/schema/Product2.Category__c';
import GENDER_FIELD from '@salesforce/schema/Product2.Gender__c';
import TYPE_FIELD from '@salesforce/schema/Product2.Type__c';
import MSRP_FIELD from '@salesforce/schema/Product2.MSRP__c';

/**
 * Component to display details of a Product2.
 */
export default class ProductCard extends NavigationMixin(LightningElement) {

    // Exposing fields to make them available in the template
    categoryField = CATEGORY_FIELD;
    genderField = GENDER_FIELD;
    typeField = TYPE_FIELD;
    msrpField = MSRP_FIELD;

    // Id of Product__c to display
    recordId;

    // Product fields displayed with specific format
    productName;
    productPictureUrl;

    /** Load context for Lightning Messaging Service */
    @wire(MessageContext) messageContext;

    /** Subscription for ProductSelected Lightning message */
    productSelectionSubscriptionDetail;

    connectedCallback() {
        this.productSelectionSubscriptionDetail = subscribe(
            this.messageContext,
            PRODUCT_SELECTED_DETAIL_MESSAGE,
            (message) => this.handleProductSelected(message.productId)
        );
    }

    handleRecordLoaded(event) {
        const { records } = event.detail;
        const recordData = records[this.recordId];
        this.productName = getFieldValue(recordData, NAME_FIELD);
        this.productPictureUrl = getFieldValue(recordData, PICTURE_URL_FIELD);
    }

    /**
     * Handler for when a product is selected. When `this.recordId` changes, the
     * lightning-record-view-form component will detect the change and provision new data.
     */
    handleProductSelected(productId) {
        this.recordId = productId;
    }

    /** 1. In order to use the navigation we need to import navigate library
     *  2. Make the library available for this file exporting it (extends Navigation Mixin(LightningElement))
     *  3. Use navigation method 
     */
    handleNavigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: PRODUCT_OBJECT.objectApiName,
                actionName: 'view'
            }
        });
    }
}
