import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getAvailableProducts from '@salesforce/apex/manageProductStockController.getAvailableProducts';
import updateProductStock from '@salesforce/apex/manageProductStockController.updateProductStock';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
const FIELDS = ['Account.EnergiebankVestiging__c'];

export default class AddProductReservation extends NavigationMixin(LightningElement) {

    @api recordId;
    vestiging;
    @track products;
    error;
    emptyProductList = false;
    noAccountId = false;


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Account',
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.vestiging = data.fields.EnergiebankVestiging__c.value;
            this.handleLoad();
        }
    }

    handleLoad() {
        if (this.recordId){
            getAvailableProducts({ accountId: this.recordId, vestiging: this.vestiging })
                .then(result => {
                    console.log("this.result");
                    console.log(this.result);
                    this.products = JSON.parse(result);
                    if (this.products.length === 0){
                        this.emptyProductList = true;
                    }
                })
                .catch(error => {
                    this.error = error;
                });
        }
        else {
            this.noAccountId = true;
        }
    }
    
    handleCancel(event) {      
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }

    handleSave(event) {
        updateProductStock({ stockJson: JSON.stringify(this.products), accountId: this.recordId })
        .then(result => {
            //Show Toast
            const evt = new ShowToastEvent({
                title: "Succes!",
                message: "Productvoorraad is succesvol opgeslagen",
                variant: "Success"
            });
            this.dispatchEvent(evt);
            this.navigateToRecordViewPage();
        })
        .catch(error => {
            this.error = error;
            console.log(error);
            const evt = new ShowToastEvent({
                title: "Er is iets fout gegaan: " + error.body.exceptionType,
                message: error.body.message,
                variant: "Error"
            });
            this.dispatchEvent(evt);
        });
    }

    handleValueChange(event) {
        for(let i=0; i<this.products.length; i++){
            if(this.products[i].id === event.target.dataset.item){
                this.products[i].quantity = event.target.value;
            }
            
        }
    }

    navigateToRecordViewPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }

}