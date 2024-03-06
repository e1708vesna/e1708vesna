import { LightningElement,api } from 'lwc';

export default class ButtonAddProductReservation extends LightningElement {

    @api recordId;
    @api inCommunity = false;
    buttonPressed = false;

    openModal(e){
        this.buttonPressed = true;
    }

    closeModal(e){
        this.buttonPressed = false;
    }
}