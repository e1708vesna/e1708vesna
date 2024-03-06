import { LightningElement, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

export default class image extends NavigationMixin(LightningElement) {

    @api imageUrl = '';

}