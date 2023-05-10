import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteD from '@salesforce/apex/CPQQuotesToExpireRecords.getQuote';
import { loadStyle } from 'lightning/platformResourceLoader';
//import CUSTOMCSS from '@salesforce/resourceUrl/cpq_custom_style';



export default class CpqQuoteExpireWarning extends LightningElement {

    quote;
    error;
    messageDataArray = [];

    @api recordId;

    //isCssLoaded = false;
    /*
    renderedCallback() {

        if (this.isCssLoaded) return
        this.isCssLoaded = true;
        loadStyle(this, CUSTOMCSS).then(() => {
            console.log('loaded');
        })
            .catch(error => {
                console.log('error to load');
            });
    }
    */

    connectedCallback() {
        this.getQuoteDetails();
 	}

    getQuoteDetails() {
     //alert('33-->'+this.recordId);
        //messageDataArray[0] = this.recordId;
		getQuoteD({qid:this.recordId})
			.then(result => {
				this.quote = result;
                this.messageDataArray[0]=new Date(result.SBQQ__ExpirationDate__c).toLocaleDateString('en-US');
                 //showWarning = ;
                if(result!=null) {                 
        		 this.showToast('Please note: This quote is set to expire on '+this.messageDataArray[0]+' date. If you require additional time to complete please work with your Sales Ops team.');
                }
                //   alert(this.messageDataArray[0]);
			})
			.catch(error => {
				this.error = error;
			});

            
	}

    showToast(message) {
        //alert(quote);
        const event = new ShowToastEvent({
            variant: 'warning',
            title: 'Quote To Expire Alert',
            //messageData: this.messageDataArray,
            message: message,
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }
}