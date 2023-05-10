import { LightningElement, api, wire} from 'lwc';
import { NavigationMixin} from 'lightning/navigation';
import getQuoteLine from '@salesforce/apex/PaymentTeamOverrideController.getQuoteLine';
import commitQuoteLine from '@salesforce/apex/PaymentTeamOverrideController.commitQuoteLine';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class PaymentTeamOverride extends NavigationMixin(LightningElement) {
    _recordId;
    revenuePerTransactionId;
    revenuePerTransactionValue;
    isLoading = false;


    @api set recordId( value ){
        this._recordId = value;
        getQuoteLine( {quoteId: this.recordId})
            .then(result=>{
                this.revenuePerTransactionId = result.Id;
                this.revenuePerTransactionValue = result.SBQQ__ListPrice__c;
    
            });
    }
    get recordId(){
        return this._recordId;
    }

    handleListPriceBlur( event ){
        this.revenuePerTransactionValue = event.target.value;
    }

    handleSave(event){
      
        if( !this.revenuePerTransactionValue ){
            this.showToast("Warning", "Revenue Per Transaction requires a value to save", "warning");
        } else {
            this.isLoading = true;
            commitQuoteLine({ 
                quoteId : this.recordId,
                quoteLineId : this.revenuePerTransactionId,
                listPriceValue : this.revenuePerTransactionValue
            })
            .then( returnData =>{
                if(returnData === 'SUCCESS'){
                    let link = `/apex/sbqq__sb?scontrolCaching=1&id=${this.recordId}#quote/le?qId=${this.recordId}`;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: link
                        }
                    });
                }
                else {
                    this.showToast("Error!", 'An error has occured while communicating with the server', "error" );
                }
            })
            .catch( error=> {
                this.showToast("An error has occured while communicating to the server", error.body.message, "error" );
            });
        }
    }
    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    showToast(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}