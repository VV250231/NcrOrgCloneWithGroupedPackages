import { LightningElement, api, wire, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getRevenueByCategory from '@salesforce/apex/APL_RevenueDisplayController.getRevenueByCategory';

export default class AplRevenueDataDisplay extends LightningElement {
    @api recordId;
    @track RevenueByCategory;
    
    connectedCallback(){
            getRevenueByCategory({accID:this.recordId}).then(result=>{        
            this.RevenueByCategory = result;
            window.console.log("aa" , result);
        }).catch(error=>{        
            window.console.log("==== Error ==== : ",error);
        });
    }
}