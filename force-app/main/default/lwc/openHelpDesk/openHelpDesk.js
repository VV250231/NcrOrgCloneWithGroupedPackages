import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getHelpDeskCases from '@salesforce/apex/OpenHelpDeskandCasesHandler.getHelpDeskCases';

export default class OpenHelpDesk extends LightningElement {
    @api recordId;
    @track getHelpDeskCases;
    @wire(getHelpDeskCases,{accountID : '$recordId'}) wireHelpDeskCases({data,error}){
        if(data){ 
            this.getHelpDeskCases = data;
            window.console.log("== Get Help Desk Cases  ==",this.getHelpDeskCases);
        }
        if(error){
            console.log("== OpenHelpDeskCases==",error);
        }
    }
}