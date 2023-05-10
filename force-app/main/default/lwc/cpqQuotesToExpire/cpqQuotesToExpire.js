import { LightningElement} from 'lwc';

import getQuotes from '@salesforce/apex/CPQQuotesToExpireRecords.retrieveQuotes1';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import USER_ID from '@salesforce/user/Id';

export default class cpqQuotesToExpire extends LightningElement {

    userId = USER_ID;
    quoteUrl;
	quotes;
	error;
    columns = [
        {
            label: 'Quote Number', fieldName: 'QuoteURL', type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                }
            }
        },
        /*{ label: 'Quote Number', fieldName: 'Name' },*/
        { label: 'Status', fieldName: 'SBQQ__Status__c' ,sortable: true},
        { label: 'Legal Doc Status', fieldName: 'qtc_Legal_Document_Status__c' },
        { label: 'Payments Application Status', fieldName: 'qtc_Status_of_all_Applications__c'},
        { label: 'Creation Date', fieldName: 'CreatedDate',type:"date", typeAttributes: {
            timeZone: 'America/New_York',
            //timeZoneName:'short',
            day: "numeric",
            month: "numeric",
            year: "numeric",
            hour:"2-digit", minute:"2-digit", hour12:"true"
        }},
        { label: 'Expires On ', fieldName: 'SBQQ__ExpirationDate__c',type:"date", typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"}}
    ];

    connectedCallback() {
  		this.loadQuotes({userID:this.userId});
	}
	loadQuotes(qdet) {
        //alert('Loading quotes...'+qdet);
		getQuotes(qdet)
			.then(result => {
				this.quotes = result.quotetList;
                if(this.quotes !=null && this.quotes.length>0){
                  this.showToast();
                    this.quotes.forEach(item => item['QuoteURL'] = result.quoteURL+'/' +item['Id']);
                    //alert(result.quoteURL);
                }
			})
			.catch(error => {
				this.error = error;
                console.error(error);
			});

            
	}

    showToast() {
        const event = new ShowToastEvent({
            variant: 'warning',
            title: 'Quotes To Expire Alert',
            message: 'Few of your quotes are expiring soon, please see the details on “Quotes Expiring Soon” section.',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }
}