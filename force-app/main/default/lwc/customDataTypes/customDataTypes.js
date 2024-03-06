import LightningDatatable from 'lightning/datatable';
import customRichText from './templates/customRichText';
import customDateTime from './templates/customDateTime'


export default class CustomDataTypes extends LightningDatatable {
    static customTypes = {
        customRichTextType: {
            template: customRichText,
            typeAttributes: ['richText']
        },
        customDateTimeType: {
            template: customDateTime,
            typeAttributes: ['dateTimeValue']
        }
        // Other Custom Types
    };
}