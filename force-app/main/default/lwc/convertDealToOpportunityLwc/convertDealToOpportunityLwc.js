import { LightningElement, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import getRecordTypeList from '@salesforce/apex/convertSBRtoOpportunityCon.getRecordTypeList';

export default class ConvertDealToOpportunityLwc extends LightningElement {
    @track options = [];
    @track value = '';
    @track selectedRecType = '';
    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT}) objectInfo;
    @wire(getRecordTypeList) wireRecordTypes;

    handleCancel(event) {
        const closebox = new CustomEvent('closeModal');
        this.dispatchEvent(closebox);
    }

    handleNext (event) {
        //Create a custom event that bubbles.
        let radiobuttons = this.template.querySelectorAll('input[name="oppRecordType"]:checked');
        if(radiobuttons.length > 0) {
            const selectEvent = new CustomEvent('recordtypeselect',{detail: {recordTypeId: radiobuttons[0].value}});
            this.dispatchEvent(selectEvent);
        }
    }
}