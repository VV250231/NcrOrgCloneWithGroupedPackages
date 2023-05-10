import { LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LANG from "@salesforce/i18n/lang";
import getPartnerFundROI from "@salesforce/apex/PRM_MdfRoiController.getPartnerFundROI";

export default class PrmMdfResult extends NavigationMixin (LightningElement) {
    @track partnerFundROI;
    @track showLoadingSpinner = true; 
    connectedCallback(){
        let param = this.getUrlVars(decodeURI(window.location.href)); 
        this.showLoadingSpinner = true;
        if(param['id']){
            getPartnerFundROI({
                partnerFundRoiId: param['id']
            })
            .then(result => {
                if (result) {
                this.partnerFundROI = result; 
                this.partnerFundROI.CreatedDate = new Intl.DateTimeFormat(LANG).format(new Date(result.CreatedDate)); 
                }
                this.error = undefined;
                this.showLoadingSpinner = false;
            }).catch(error => {
                this.error = error;
                this.mdfDetail = undefined;
                this.showLoadingSpinner = false;
                this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error while loading data",
                    message: "Error :- " + this.error.body.message,
                    variant: "error"
                })
                );
                this.showLoadingSpinner = false;
            });
        }
        this.showLoadingSpinner = false;

    }

    backToListView() {  
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:  window.location.origin+'/PartnerCentral/s/partner-claim?tabset-6ee1a=ff462'
            }
        },
          false
        );
        this.showLoadingSpinner = false;
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