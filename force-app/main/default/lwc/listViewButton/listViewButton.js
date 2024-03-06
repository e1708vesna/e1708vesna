import {LightningElement} from 'lwc';

export default class ListViewButton extends LightningElement {

	close(){
		setTimeout(
			function() {
				window.history.back();
			},
			1000
		);
	}
}