// Bare module imports
import { LightningElement, api, track } from 'lwc';

// "@salesforce/*" imports
import fetchChatterPosts from '@salesforce/apex/ChatterPostFeedDisplayCtrl.fetchChatterPosts';
import ChatterFeedNoPostsFoundHeading from '@salesforce/label/c.ChatterFeedNoPostsFoundHeading';
import ChatterFeedNoPostsFoundMessage from '@salesforce/label/c.ChatterFeedNoPostsFoundMessage';

// "c/*" imports
import { reduceErrors } from 'c/utils';

export default class ChatterPostFeedDisplay extends LightningElement {

    //column definition for data table
    columns = [
           {
             label: 'Message',
             type: 'customRichTextType',
             wrapText: true,
             sortable: false,
             typeAttributes: {
                  richText: { fieldName: 'body' }
                }
            },
            {
              label: 'Posted Date',
              type: 'customDateTimeType',
              typeAttributes: {
                    dateTimeValue: { fieldName: 'createdDate' }
             }
           },
           {
             label: 'Created By',
             fieldName: 'createdByUser',
             sortable: false
           }
        ];

    //organizing all custom labels into one variable
    label = {
              ChatterFeedNoPostsFoundHeading,
              ChatterFeedNoPostsFoundMessage
            }

    @api recordId; //case record id
    @track data; //FeedItem data fetched from apex controller
    error = ''; //error message
    loadSpinner = false; //spinner toggle

    get cardTitle() {
        let count = this.data ? this.data.length : 0;
        return `Posts (${count})`;
    }

     connectedCallback() {
        this.loadSpinner = true;
        fetchChatterPosts({ recordId : this.recordId })
        .then(
            result => {
                console.log(JSON.parse(JSON.stringify(result)));
                this.data = result;
                this.loadSpinner = false;
            }
        ).catch(
            error => {
                this.loadSpinner = false;
                this.error = reduceErrors(error);
             }
        );
    }
}