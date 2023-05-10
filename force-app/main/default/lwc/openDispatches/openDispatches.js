import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getDispatch from '@salesforce/apex/OpenDispatchesHandler.getDispatch';
export default class OpenDispatches extends LightningElement {
    @api recordId;
    @track getDispatchList;
    
    connectedCallback(){
        getDispatch({accountID:this.recordId}).then(result=>{
            //window.console.log("==== Result ==== : ",result);
           
            /*for (let index = 0; index < result.length; index++) {
                const element = result[index];
                if(result[index].SLA_Category__c.includes('Open Call Within SLA')){

                    result[index].meetsSLA = 'Within SLA';
                }
                else{
                    result[index].meetsSLA = '';
                }
                if(result[index].SLA_Category__c.includes('Open Call Outside SLA')){

                    result[index].outsideSLA = 'Outside SLA';
                }
                else{
                    result[index].outsideSLA = '';
                }
                
            }
            window.console.log("==== Result ==== : ",result);*/
            this.getDispatchList = result;
 
        }).catch(error=>{
            
            window.console.log("==== Error ==== : ",error);
    
        });
    }
}