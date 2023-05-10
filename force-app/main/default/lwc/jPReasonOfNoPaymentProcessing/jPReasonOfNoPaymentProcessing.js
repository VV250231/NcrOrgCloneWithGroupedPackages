import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import rsnRequireOrNot from '@salesforce/apex/JPReasonOfNoPaymentProcessingCtrl.reasonRequireOrNot';
import contractDateAvailable from '@salesforce/apex/JPReasonOfNoPaymentProcessingCtrl.isContractDateAvl';
import NO_HWSWProd_REASON_FIELD from '@salesforce/schema/Opportunity.You_have_not_selected_any_TS_HWM_or_SW__c';
import Payment_REASON_FIELD from '@salesforce/schema/Opportunity.Reasons_for_no_Payment_Processing__c';
import Contract_Date_FIELD from '@salesforce/schema/Opportunity.Payments_Contract_End_Date__c';
import REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';

export default class JPReasonOfNoPaymentProcessing extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track showComp = false;
    @track showModel = false;
    @track contractDateAvl = false;
    @track isModalLoaded = false;
    @track fields=[];
    cfields=[];
    @track fieldss =[];
    @track showContrctDate = false;
    @track cntrctfields = [];
    @track errorMsg;
    @track showhelpText = false;
    @track helptext='';
    
    handleSubmit(event){
        this.isModalLoaded = true;
        event.preventDefault();       // stop the form from submitting
        const efields = event.detail.fields;
        const fieldsStr = JSON.stringify(efields);        
        if ((fieldsStr.indexOf('Existing Contract (WP/NMS)') > -1 ||fieldsStr.indexOf('Existing Contract (Other)') > -1)) {
            this.showModel=true;  
            this.cfields.push(Contract_Date_FIELD);
            this.fieldss=efields;
            }
            else{
                    console.log('++++'+JSON.stringify(efields));         
                    this.template.querySelector('lightning-record-form').submit(efields);    
                }
        this.isModalLoaded = false;
        }

     handleContractSubmit(event){  
        this.isModalLoaded = true;
        event.preventDefault();
        const efields = event.detail.fields;
       
        console.log('Ajay++++'+JSON.stringify(efields));   
        console.log('____'+JSON.stringify(this.fieldss)); 
        if(efields.Payments_Contract_End_Date__c!= null || efields.Payments_Contract_End_Date__c != undefined){this.fieldss.Payments_Contract_End_Date__c=efields.Payments_Contract_End_Date__c;
            console.log('____'+JSON.stringify(this.fieldss)); 
            this.template.querySelector('lightning-record-form').submit(this.fieldss);
        }  
        else{
            console.log('In contract date null');
            this.errorMsg='Contract End Date can not be blank';
            const event = new ShowToastEvent({
                title: 'Error!!',
                message: 'Contract End Date can not be blank',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }
            
        
        this.showModel= false;   
        this.isModalLoaded = false;
     }
     closeModal(event){
        this.isModalLoaded = true;
         console.log('+++++'+JSON.stringify(event.detail.value));
         contractDateAvailable({
            oppId: this.recordId
        })
        .then(result => {
            if(!result){
                this.template.querySelector('lightning-record-form').submit(this.fieldss); 
            }
            this.isModalLoaded = false;
            this.showModel=false;
        });
        
        
     }
    connectedCallback() {
        rsnRequireOrNot({
            oppId: this.recordId
            })
            .then(result => {
                if(result.noHWMSWMProdsReasonReq){
                    this.showComp=true;
                    this.fields.push(NO_HWSWProd_REASON_FIELD);
                }
                if(result.noPymtProdsReasonReq){
                    this.showComp=true;
                    this.fields.push(Payment_REASON_FIELD);
                 }

            }).catch((error) => {
                console.log('Error Occured : ' + JSON.stringify(error));
            });
            contractDateAvailable({
                oppId: this.recordId
            })
            .then(result => {
                console.log('resuttt____'+result);
                if(!result){
                    this.cntrctfields.push(Contract_Date_FIELD);
                    this.showContrctDate = true;
                    this.showhelpText=true;
                    this.helptext='Please indicate customer existing Payment contact end date';                    
                    
                }
                console.log('______this.fields'+JSON.stringify(this.fields));
            });
}
handleCheckboxChange(event){
console.log('++'+event.target.dataset.value);
console.log(event.target.checked);

}
}