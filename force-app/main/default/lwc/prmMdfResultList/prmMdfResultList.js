import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LANG from "@salesforce/i18n/lang";

import getPartnerFundROIList from "@salesforce/apex/PRM_MdfResultList.getPartnerFundROIList";

export default class PrmMdfResultList extends LightningElement {
    @track partnerFundROIList = [];
    @track rowCount;
    @track showLoadingSpinner =true;

    connectedCallback(){
        getPartnerFundROIList().then(result=>{
            this.showLoadingSpinner = true;
            window.console.log("=== MDF Results ", result);
            var urlparamsList = this.getUrlVars(decodeURI(window.location.href));
            var urlString=''; 

            window.console.log("url Params List ",urlparamsList);

            for (const key in urlparamsList) {                 
                 if(key.includes('tabset')){                    
                    urlString = key+'vtab'+urlparamsList[key];
                 }
            }
            window.console.log("=== urlString ===",urlString);

            for (let index = 0; index < result.length; index++) {
                const element = result[index]; 
                result[index].pathUrl = './mdf-activity?id='+result[index].Fund_Request__c+'&tab='+urlString;
                result[index].pathId = './mdf-result?id='+result[index].Id;
            } 
            this.partnerFundROIList = result;
            window.console.log("=== MDF Results ", this.partnerFundROIList);
            this.rowCount = this.partnerFundROIList.length;
            
            this.error = undefined; 
            if (this.partnerFundROIList.length === 0 || this.partnerFundROIList.length === undefined) {
                this.dispatchEvent(
                new ShowToastEvent({
                    title: "Information",
                    message: "No Data Found !",
                    variant: "info"
                })
                );
            } 
            this.showLoadingSpinner = false;

        }).catch(error=>{
            this.showLoadingSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "Error while loading data.",
                  message: "Error :- " + this.error ,
                  variant: "error"
                })
              );
        });
    }

    getUrlVars(urlString) {
        var prams = {};
        if(urlString){
            let parts =urlString.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
                prams[key] = value;
            });
        }        
        return prams;
    }
}