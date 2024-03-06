import { LightningElement, api, wire, track } from 'lwc';

import { subscribe, MessageContext } from 'lightning/messageService';
import PRODUCT_ADDED_MESSAGE from '@salesforce/messageChannel/ProductAdded__c';

import getProducts from '@salesforce/apex/ProductCtrl.getProducts';

export default class Cart extends LightningElement {

    recordArray = [];
    temp = [];

    @api total = 0;

    @wire(MessageContext) messageContext;

    pageNumber = 1;
    filters = null;

    @wire(getProducts, { filters: '$filters', pageNumber: '$pageNumber' })
    products;

    productSelectionSubscriptionCart;

    connectedCallback() {
        if(sessionStorage.getItem('productArray')){
            this.recordArray = JSON.parse(sessionStorage.getItem('productArray'));
            this.recordArray.forEach((record => {
                this.total += parseInt(record.MSRP__c);
            }
            ));
        }
        this.productSelectionSubscriptionCart = subscribe(
            this.messageContext,
            PRODUCT_ADDED_MESSAGE,
            (message) => this.addToCart(message.product)
        );
    }

    addToCart(product) {
        const placeholder = this.template.querySelector('c-placeholder');
        if(placeholder != null){
            if(!(placeholder.hasAttribute('style'))){
                placeholder.style.display = 'none';
            }
        }

        if(this.recordArray){
            if (this.recordArray.find(x => x.Id === product.Id) === undefined && this.temp.find(x => x.Id === product.Id) === undefined){
                this.temp.push(product);
                this.total += parseInt(product.MSRP__c);
            }
        }
        else{
            if (this.temp.find(x => x.Id === product.Id) === undefined){
                this.temp.push(product);
                this.total += parseInt(product.MSRP__c);
            }
        }
       
        
        sessionStorage.setItem('productArray', JSON.stringify(this.temp.concat(this.recordArray)));

        let items = this.temp;
        const html = items
        .map(
            (item) => `
            <div lwc:dom="manual" id=${item.Id} class="tile-body" style="display:flex; width:100%;">
                <img src=${item.DisplayUrl} style="width:100px; padding:5px; vertical-align:middle;" alt="Product picture"/>
                <div style="padding-left:15px;">
                    <p id="item-name" style="font-size:17px; margin-bottom:1px">${item.Name}</p>
                    <p style="font-size:17px; font-wight:700; margin-bottom:1px">$${item.MSRP__c}</p>
                    <div style="display:flex">
                        <p style="margin-right:13px; font-size:17px; margin-bottom:1px;">Quantity</p>
                        <input class="tile-q-input" style="width:53px; margin-right:5px; border: 1px solid #c9c9c9; border-radius: 4px; padding-left:12px" type="number" min="1" value="1"></input>
                        <button class="tile-delete-btn" id="${item.Id}" style="border:1px solid #c9c9c9; border-radius:4px; background-color:white; padding:6px 18px; color:#0076d3">Delete</button>
                    </div>
                </div>
            </div>
        `
        )
        .join("");
            
        const dynamicallyLoaded = this.template.querySelector(".dynamicallyLoaded");
        dynamicallyLoaded.innerHTML = html;

        // const quantityInputs = this.template.querySelectorAll('.tile-body .tile-q-input');
        const btns = this.template.querySelectorAll('.tile-body .tile-delete-btn');
        // window.console.log('btns', btns);
        

        // quantityInputs.forEach((quantityInput) => {
        //     quantityInput.addEventListener('change', this.handleQuantityChange);
        // });

        
        btns.forEach((btn) => {
            // const btnId = btn.getAttribute('id');
            btn.addEventListener('click', this.handleDeleteClick)
        });
    }

    handleDeleteClick(event){

        const {id} = event.target;
        const item = window.document.getElementById(id);
        item.style.display = 'none';
        if(sessionStorage.getItem('productArray')){
            this.temp = JSON.parse(sessionStorage.getItem('productArray'));
        }

        this.temp.forEach((record => {
            if(record.Id == id){
                sessionStorage.removeItem(JSON.stringify(record.Id));
                //window.console.log('total', window.document.getElementsByClassName('.total'));
                // this.total -= parseInt(item.MSRP__c);
            }
        }));

    };

    // handleQuantityChange(event){
    //     const quantityInputValues = this.template.querySelectorAll('.tile-body .tile-q-input').getAttribute('value');
    //     quantityInputValues.forEach((quantityInputValue) => {
    //         window.console.log('quantityInput', quantityInputValue);
    //     });
    // }
    
}

{/* <button class="tile-submit" style="margin-right:5px; border:1px solid #c9c9c9; border-radius:4px; background-color:white; padding:6px 18px;
                    }" id="${item.Id}"><label style="color:#0076d3;">Submit</label></button> */}

                    // <button class="tile-delete-btn" id="${item.Id}" style="border:1px solid #c9c9c9; border-radius:4px; background-color:white; padding:6px 18px;"><label class="tile-delete-label" style="color:#0076d3;">Delete</label></button>