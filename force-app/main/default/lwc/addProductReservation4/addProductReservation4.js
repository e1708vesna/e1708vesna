import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getAvailableProducts from '@salesforce/apex/addProductReservationController.getAvailableProducts';
import createReservations from '@salesforce/apex/addProductReservationController.createReservations';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Account.EnergiebankVestiging__c'];

export default class AddProductReservation extends NavigationMixin(LightningElement) {

    @api recordId;
    vestiging;
    @track products;
    error;
    saveButtonDisabled = true;
    emptyProductList = false;
    noAccountId = false;

    @api buttonPressed =false;
    saveExecuted = false;

    openModal(e){
        this.buttonPressed = true;
    }

    connectedcallback(){
        console.log('chris: starting lwc');
    }


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            console.log('chris: wire error');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Account',
                    variant: 'error',
                }),
            );
        } else if (data) {
            console.log('chris: wire load');
            this.vestiging = data.fields.EnergiebankVestiging__c.value;
            this.handleLoad();
        }
    }

    handleLoad() {
        console.log('chris: handle load');
        if(this.recordId) {
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
        this.buttonPressed = false;
        return false;
    }

    handleSave(event) {
        createReservations({ reservationsJSON: JSON.stringify(this.products), accountId: this.recordId })
        .then(result => {
            //Show Toast
            
            const evt = new ShowToastEvent({
                title: "Succes!",
                message: "Producten zijn succesvol gereserveerd",
                variant: "Success"
            });
            this.dispatchEvent(evt);
            this.saveExecuted = true;
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
            this.buttonPressed = false;
        });
    }

    handleValueChange(event) {
        var buttonDisabled = true;
        for(let i=0; i<this.products.length; i++){
            if(this.products[i].id === event.target.dataset.item){
                this.products[i].quantity = event.target.value;
            }
            if (this.products[i].quantity > 0){
                buttonDisabled = false;
            }
        }
        this.saveButtonDisabled = buttonDisabled;

        console.log(JSON.stringify(this.products));
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