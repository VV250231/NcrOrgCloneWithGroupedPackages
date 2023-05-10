import { LightningElement, api, wire, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getRevenueByCategory from '@salesforce/apex/APL_HierarchyRevenueDisplayController.getRevenueByCategory';

export default class AplRevenueHierarchyDataDisplay extends LightningElement {
    @api recordId;
    @track RevenueByCategory;
    
    /*
    connectedCallback(){
            getRevenueByCategory({accountID:this.recordId}).then(result=>{        
            this.RevenueByCategory = result;
            window.console.log("aa" , result);
        }).catch(error=>{        
            window.console.log("==== Error ==== : ",error);
        });
    }*/

    @wire(getRevenueByCategory,{accountID : '$recordId'}) wireRevenueByCategory({data,error}) {
        if(data){
            this.RevenueByCategory = data;
            window.console.log("aa" , data);
        }
        
        if(error){
            window.console.log("==== Error ==== : ",error);
        }
    }
}