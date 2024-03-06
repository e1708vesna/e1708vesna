import { LightningElement, api, wire } from 'lwc';

/**Importing messageService library with publish, subscribe and messageContext methods */
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import PRODUCTS_FILTERED_MESSAGE from '@salesforce/messageChannel/ProductsFiltered__c';
import PRODUCTS_MESSAGE from '@salesforce/messageChannel/Products__c';

// getProducts() method in ProductController Apex class
import getProducts from '@salesforce/apex/ProductCtrl.getProducts';

/**
 * Container component that loads and displays a list of Product2 records.
 */
export default class ProductList extends LightningElement {

    /**
     * Whether to display the search bar.
     * TODO - normalize value because it may come as a boolean, string or otherwise.
     */
    @api searchBarIsVisible = false;

    /**
     * Whether the product tiles are draggable.
     * TODO - normalize value because it may come as a boolean, string or otherwise.
     */
    @api tilesAreDraggable = false;

    /** Current page in the product list. */
    pageNumber = 1;

    /** The number of items on a page. */
    pageSize;

    /** The total number of items matching the selection. */
    totalItemCount = 0;

    /** JSON.stringified version of filters to pass to apex */
    filters = {};

    /** Load context for Lightning Messaging Service */
    @wire(MessageContext) messageContext;

    /** Subscription for ProductsFiltered Lightning message */
    productFilterSubscription;

     /**
     * Load the list of available products.
     */
    @wire(getProducts, { filters: '$filters', pageNumber: '$pageNumber' })
    products;

    connectedCallback() {
      // Subscribe to ProductsFiltered message
      this.productFilterSubscription = subscribe(
          this.messageContext,
          PRODUCTS_FILTERED_MESSAGE,
          (message) => this.handleFilterChange(message)
      );
    }

    handleSearchKeyChange(event) {
      this.filters = {
          searchKey: event.target.value.toLowerCase()
      };
      this.pageNumber = 1;
    }

    handleFilterChange(message) {
      this.filters = { ...message.filters };
      this.pageNumber = 1;
    }

    handlePreviousPage() {
      this.pageNumber = this.pageNumber - 1;
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
    }

}