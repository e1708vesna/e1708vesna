import { LightningElement, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

export default class NavMenuVesnaTest extends NavigationMixin(LightningElement) {
    
    @api title = '';
    @api description = '';
    
    get menuItemValues(){
        return [{label :'Create A Case',
        value : 'Create A Case'},
        {label :'All Active Cases',
        value : 'All Active Cases'},
        {label :'Statistics & Performance',
        value : 'Statistics & Performance'},
        {label :'Adyen Help',
        value : 'Adyen Help'}]
    }

}