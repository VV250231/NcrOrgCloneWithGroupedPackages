import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationNextEvent, FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class SFGlobalSupportCase extends LightningElement {
    @api CaseRecord = {};
    @api caseReasonSelValue;
    @api reasonTypeSelValue;


    _caseRecord = {};
    showlookup = false;
    showlookup1 = false;
    showlookup2 = false;
		req;
    lkpobject;
    lkpLabel;
    lkpicon;
    lkpobject1;
    lkpLabel1;
    lkpicon1;
    lkpobject2;
    lkpLabel2;
    lkpicon2;
    sellkpRecord;
    sellkpRecord1;
    sellkpRecord2;
    strcasesub;
    strcasedesc;
    //fields = ["Name", "Industry"]; // ,"Email","Phone"
    displayFields = "";
    displayFields1 = "";// , Email, Phone
    displayFields2 = "";


    connectedCallback() {
        this.initLkp();
        this._caseRecord = Object.assign({}, this.CaseRecord);
    }


    handleNext(event) {

        let caseSub = this.template.querySelector('.gstxtsubject').value;
        let caseDesc = this.template.querySelector('.gstxtdesc').value;
        let isValidform = false;
        let errMsg = '';
        //this.CaseRecord.Subject = {...caseSub};
        //this.CaseRecord.Description = caseDesc;
        /*
       return { 
           isValid: false, 
           errorMessage: 'test msg' 
            }; */
        debugger;
        if (caseSub && caseDesc && this.caseReasonSelValue && this.reasonTypeSelValue
            && (this.showlookup == false || (this.showlookup == true && this.sellkpRecord))) {

            isValidform = true;
        } else {
            errMsg = 'Please enter all required fields';
        }

        if (isValidform) {
            this._caseRecord.Reason = this.caseReasonSelValue;
            this._caseRecord.Reason_Type__c = this.reasonTypeSelValue;
            //this._caseRecord.Related_Record__c = window.location.origin + '/' + this.sellkpRecord;
            this._caseRecord.Subject = caseSub;
            this._caseRecord.Description = caseDesc;
            this.CaseRecord = this._caseRecord;

            let reason = this.caseReasonSelValue;
            let reasonType = this.reasonTypeSelValue;

            if (reason == 'Account') {
                this._caseRecord.AccountId = this.sellkpRecord;
            } else if (reason == 'Lead') {
                this._caseRecord.LeadId__c = this.sellkpRecord;
            } else if (reason == 'Contact') {
                this._caseRecord.ContactId = this.sellkpRecord;
            } else if (reason == 'Opportunity') {
                this._caseRecord.Opportunity_Name__c = this.sellkpRecord;
            } else if (reason == 'CPQ') {
                if (reasonType == 'Document Generation/Signature' || reasonType == 'NCR Payments'
                    || reasonType == 'Ops- Contracting' || reasonType == 'Ops- Ordering' || reasonType == 'Pricing Approvals' || reasonType == 'Quote Configuration') {
                    this._caseRecord.cpq_Quote__c = this.sellkpRecord;
                }
                if (reasonType == 'Billing' || reasonType == 'Credit Application' || reasonType == 'Disputes' || reasonType == 'MyNCR AutoPay Setup') {
                    this._caseRecord.AccountId = this.sellkpRecord;
                    this._caseRecord.Opportunity_Name__c = this.sellkpRecord1;
                    this._caseRecord.cpq_Quote__c = this.sellkpRecord2;
                }
                if (reasonType == 'Opportunity') {
                    this._caseRecord.Opportunity_Name__c = this.sellkpRecord;
                    this._caseRecord.cpq_Quote__c = this.sellkpRecord2;
                }
                if (reasonType == 'Other') {
                    this._caseRecord.Opportunity_Name__c = this.sellkpRecord1;
                    this._caseRecord.cpq_Quote__c = this.sellkpRecord2;
                }
                if (reasonType == 'Reporting') {
                    this._caseRecord.Opportunity_Name__c = this.sellkpRecord1;
                    this._caseRecord.cpq_Quote__c = this.sellkpRecord2;
                }

                //this._caseRecord.cpq_Quote__c = this.sellkpRecord;        
            }

            //Object.assign(this.CaseRecord,  this._caseRecord);
            //this.CaseRecord = this._caseRecord;
            const attributeChangeEvent = new FlowAttributeChangeEvent(
                'CaseRecord',
                this._caseRecord
            );
            this.dispatchEvent(attributeChangeEvent);

            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);


            // navigate next
            //const nextNavigationEvent = new FlowNavigationNextEvent();       
            //this.dispatchEvent(nextNavigationEvent); 
        }
        else {
            const evt = new ShowToastEvent({
                title: 'Required field error',
                message: 'Please enter all required fields',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }


    handlePicklistChange(event) {
        console.log('controlling' + event.detail.pickListValue.controlling);
        console.log('dependent' + event.detail.pickListValue.dependent);

        if (event.detail && event.detail.pickListValue.controlling) {
            this.caseReasonSelValue = event.detail.pickListValue.controlling;
            this.reasonTypeSelValue = event.detail.pickListValue.dependent;
            this.initLkp();
        }

        if (event.detail && event.detail.pickListValue.dependent) {
            this.reasonTypeSelValue = event.detail.pickListValue.dependent;
        }
    }

    initLkp() {
        if (this.caseReasonSelValue) {
            let reason = this.caseReasonSelValue;
            let reasonType = this.reasonTypeSelValue;

            
            this.showlookup = false;
            this.showlookup1 = false;
            this.showlookup2 = false;
            this.lkpobject ='';
            this.lkpLabel ='';
            this.lkpicon ='';
            this.lkpobject1 ='';
            this.lkpLabel1='';
            this.lkpicon1 ='';
            this.lkpobject2='';
            this.lkpLabel2='';
            this.lkpicon2='';
            


            if (reason == 'Lead' || reason == 'Account' || reason == 'Contact' || reason == 'Opportunity') {
                this.lkpLabel = 'Select ' + this.caseReasonSelValue;
                this.lkpicon = 'standard:' + this.caseReasonSelValue.toLowerCase();
                this.showlookup = true;
                this.lkpobject = reason;
            } else if (reason == 'CPQ') {
                if (reasonType == 'Document Generation/Signature' || reasonType == 'NCR Payments'
                    || reasonType == 'Ops- Contracting' || reasonType == 'Ops- Ordering' || reasonType == 'Pricing Approvals' || reasonType == 'Quote Configuration') {
                    this.lkpLabel = 'Select Quote';
                    this.lkpicon = 'custom:custom93';
                    this.showlookup = true;
                    this.lkpobject = 'SBQQ__Quote__c';

                    this.showlookup1 = false;
                    this.showlookup2 = false;

                }
                else if (reasonType == 'Billing' || reasonType == 'Credit Application' || reasonType == 'Disputes' || reasonType == 'MyNCR AutoPay Setup') {
                    this.lkpLabel = 'Select Account';
                    this.lkpicon = 'custom:custom93';
                    this.showlookup = true;
                    this.lkpobject = 'Account';

                    this.lkpLabel1 = 'Select Opportunity';
                    this.lkpicon1 = 'custom:custom93';
                    this.showlookup1 = true;
                    this.lkpobject1 = 'Opportunity';
										//this.req = true;

                    this.lkpLabel2 = 'Select Quote';
                    this.lkpicon2 = 'custom:custom93';
                    this.showlookup2 = true;
                    this.lkpobject2 = 'SBQQ__Quote__c';
										//this.req = false;

                }

                else if (reasonType == 'Opportunity') {
                    this.lkpLabel = 'Select Opportunity';
                    this.lkpicon = 'custom:custom93';
                    this.showlookup = true;
                    this.lkpobject = 'Opportunity';

                    this.lkpLabel2 = 'Select Quote';
                    this.lkpicon2 = 'custom:custom93';
                    this.showlookup2 = true;
                    this.lkpobject2 = 'SBQQ__Quote__c';

                    this.showlookup1 = false;

                }

                else if (reasonType == 'Other') {
                    this.lkpLabel1 = 'Select Opportunity';
                    this.lkpicon1 = 'custom:custom93';
                    this.showlookup1 = true;
                    this.lkpobject1 = 'Opportunity';

                    this.lkpLabel2 = 'Select Quote';
                    this.lkpicon2 = 'custom:custom93';
                    this.showlookup2 = true;
                    this.lkpobject2 = 'SBQQ__Quote__c';

                    this.showlookup = false;

                }
                else if (reasonType == 'Reporting') {
                    this.lkpLabel1 = 'Select Opportunity';
                    this.lkpicon1 = 'custom:custom93';
                    this.showlookup1 = true;
                    this.lkpobject1 = 'Opportunity';

                    this.lkpLabel2 = 'Select Quote';
                    this.lkpicon2 = 'custom:custom93';
                    this.showlookup2 = true;
                    this.lkpobject2 = 'SBQQ__Quote__c';

                    this.showlookup = false;

                }
                /*this.lkpLabel = 'Select Quote' ;
                this.lkpicon = 'custom:custom93';  
                this.showlookup = true;
                this.lkpobject= 'SBQQ__Quote__c';*/
            } else {
                this.showlookup = false;
                this.showlookup1 = false;
                this.showlookup2 = false;
            }

            if (reason == 'Account') {
                this.displayFields = 'Name,RecordType.Name,Master_Customer_Number__c';
            } else if (reason == 'Lead') {
                this.displayFields = 'Name,Company';
            } else if (reason == 'Contact') {
                this.displayFields = "Name,Account.Name";
            } else if (reason == 'Opportunity') {
                this.displayFields = 'Name,Opportunity_Number__c';
            } else if (reason == 'CPQ') {
                if (reasonType == 'Document Generation/Signature' || reasonType == 'NCR Payments'
                    || reasonType == 'Ops- Contracting' || reasonType == 'Ops- Ordering' || reasonType == 'Pricing Approvals' || reasonType == 'Quote Configuration') {
                    this.displayFields = 'Name';
                }
                if (reasonType == 'Billing' || reasonType == 'Credit Application' || reasonType == 'Disputes' || reasonType == 'MyNCR AutoPay Setup') {
                    this.displayFields = 'Name,RecordType.Name,Master_Customer_Number__c';
                    this.displayFields1 = 'Name,Opportunity_Number__c';
                    this.displayFields2 = 'Name';
                }
                if (reasonType == 'Opportunity') {
                    this.displayFields = 'Name,Opportunity_Number__c';
                    this.displayFields2 = 'Name';
                }
                if (reasonType == 'Other') {
                    this.displayFields1 = 'Name,Opportunity_Number__c';
                    this.displayFields2 = 'Name';
                    
                }
                if (reasonType == 'Reporting') {
                    this.displayFields1 = 'Name,Opportunity_Number__c';
                    this.displayFields2 = 'Name';
                }
                //this.displayFields = 'Name';          
            }
        } else {
            this.showlookup = false;
            this.showlookup1 = false;
            this.showlookup2 = false;
        }
    }


    handleLookup(event) {
        //console.log( JSON.stringify ( event.detail) );
        var eventdetail = event.detail;

        if (eventdetail.data && eventdetail.data.record) {
            this.sellkpRecord = eventdetail.data.record.Id;
        } else {
            this.sellkpRecord = '';
        }
    }
    handleLookup1(event) {
        //console.log( JSON.stringify ( event.detail) );
        var eventdetail = event.detail;

        if (eventdetail.data && eventdetail.data.record) {
            this.sellkpRecord1 = eventdetail.data.record.Id;
        } else {
            this.sellkpRecord1 = '';
        }
    }
    handleLookup2(event) {
        //console.log( JSON.stringify ( event.detail) );
        var eventdetail = event.detail;

        if (eventdetail.data && eventdetail.data.record) {
            this.sellkpRecord2 = eventdetail.data.record.Id;
        } else {
            this.sellkpRecord2 = '';
        }
    }



}