import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const fields = [
    'Limit_Tracker_Snapshot__c.Additional_Information__c'
];

export default class AdditionalInfoRichText extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    snapshot;

    get addInfo() {
        console.log('Snapshot = ' + JSON.stringify(this.snapshot, null, 4));
        return this.snapshot.data && this.snapshot.data.fields.Additional_Information__c.value;
    }
}