//wire a property or a function to receive the data
import { LightningElement, wire } from 'lwc';

//wire adapter to get the object info
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

// Product2 Filter Schema
import CATEGORY_FIELD from '@salesforce/schema/Product2.Category__c';
import GENDER_FIELD from '@salesforce/schema/Product2.Gender__c';
import TYPE_FIELD from '@salesforce/schema/Product2.Type__c';

// Lightning Message Service and a message channel
import { publish, MessageContext } from 'lightning/messageService';
import PRODUCTS_FILTERED_MESSAGE from '@salesforce/messageChannel/ProductsFiltered__c';

const DELAY = 350;

/**
 * Displays a filter panel to search for Product2[].
 */
export default class Filter extends LightningElement {

    categoryField;
    genderField;
    typeField;

    // Exposing fields to make them available in the template
    @wire(getObjectInfo, { objectApiName: CATEGORY_FIELD })
    categoryInfo({ data, error }){
        if (data) this.categoryField = data.fields.Category__c.label;
    };

    @wire(getObjectInfo, { objectApiName: GENDER_FIELD })
    genderInfo({ data, error }) {
        if (data) this.genderField = data.fields.Gender__c.label;
    }

    @wire(getObjectInfo, { objectApiName: TYPE_FIELD })
    typeInfo({ data, error }) {
        if (data) this.typeField = data.fields.Type__c.label;
    }

    searchKey = '';
    maxPrice = 300;

    filters = {
        searchKey: '',
        maxPrice: 300
    }

    @wire(MessageContext) messageContext;

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: CATEGORY_FIELD
    }) 
    categories;   

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: GENDER_FIELD
    }) 
    genders;

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: TYPE_FIELD
    }) 
    types;

    handleSearchKeyChange(event) {
        this.filters.searchKey = event.target.value;
        this.delayedFireFilterChangeEvent()
    }

    handleMaxPriceChange(event) {
        const maxPrice = event.target.value;
        this.filters.maxPrice = maxPrice;
        this.delayedFireFilterChangeEvent();
    }

    handleCheckboxChange(event){  
        if(!this.filters.categories){
            // Lazy initialize filters with all values initially set
            this.filters.categories = this.categories.data.values.map(
                (item) => item.value
            );
            this.filters.genders = this.genders.data.values.map(
                (item) => item.value
            );
            this.filters.types = this.types.data.values.map(
                (item) => item.value
            );
        }
        const value = event.target.dataset.value;
        const filterArray = this.filters[event.target.dataset.filter];
        if (event.target.checked) {
            if (!filterArray.includes(value)) {
                filterArray.push(value);
            }
        } else {
            this.filters[event.target.dataset.filter] = filterArray.filter(
                (item) => item !== value
            );
        }
        // Published ProductsFiltered message
        publish(this.messageContext, PRODUCTS_FILTERED_MESSAGE, {
            filters: this.filters
        });
    }

    /** Debouncing this method: Do not actually fire the event as long as this function is
    * being called within a delay of DELAY. This is to avoid a very large number of Apex
    * method calls in components listening to this event.
    */
     delayedFireFilterChangeEvent() {
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            // Published ProductsFiltered message
            publish(this.messageContext, PRODUCTS_FILTERED_MESSAGE, {
                filters: this.filters
            });
        }, DELAY);
    }

}