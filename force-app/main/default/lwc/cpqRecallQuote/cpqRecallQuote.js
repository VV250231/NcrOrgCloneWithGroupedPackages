import { LightningElement, track, api, wire } from 'lwc';
import recallApproval from '@salesforce/apex/QuoteExtController.recallApproval';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class CpqRecallQuote extends LightningElement {
    
    @api recordId;
    @api isLoaded = false;
    @track error;
    @api showMessage = false;
    showCancelBtn = true;
    showOkBtn = true;
    showCloseBtn = false;
    pressedCancelBtn = false;
    @api isConfirmed = false;

    connectedCallback() {this.isLoaded = true;}

    handleRecall(event) {
        this.isLoaded = false;
        this.showMessage = false;
        this.error='';
        this.showCancelBtn = false;
        this.showOkBtn = false;
        this.isConfirmed = true;
        console.log(this.recordId);
        recallApproval({quoteId: this.recordId})
            .then(result => {
                console.log(result);
                this.showMessage = result;  
                // If there is no need to show message than directly close the window
                if (!this.showMessage) {
                    this.dispatchEvent(new CustomEvent('closeBox'));
                }            
                this.isLoaded = true;
                this.showCloseBtn = true;
                //getRecordNotifyChange([{recordId: this.recordId}]);
            })
            .catch(error => {
                this.error = 'Unknown error';
                if (Array.isArray(error.body)) {
                    this.error = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.error = error.body.message;
                }
                console.log(error);
                this.isLoaded = true;
                this.showCloseBtn = true;
            });
    }

    handleCancel(event) {
        this.dispatchEvent(new CustomEvent('closeBox'));
    }

    handleClose(event) {
        this.dispatchEvent(new CustomEvent('closeBox'));
    }
    
}