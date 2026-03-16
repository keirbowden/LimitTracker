import { LightningElement, api, wire } from 'lwc';
import getAssociatedRecords from '@salesforce/apex/AdditionalInformationController.getAssociatedRecords'

export default class AssociatedRecords extends LightningElement {
    @api recordId;

    @wire(getAssociatedRecords, {limitTrackerId: '$recordId'})
    records;
}