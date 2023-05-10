import { LightningElement, track, wire } from "lwc";
import getPartnerClaimList from "@salesforce/apex/PRM_PartnerClaimsList.getPartnerClaimList";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class PrmPartnerClaimsListView extends LightningElement {
    @track rowCount = 0; 
    @track fundClaimList;
    @track showLoadingSpinner =true;
    connectedCallback(){       
        getPartnerClaimList().then(result => {
            this.showLoadingSpinner = true;
            if(result){     
                for (let index = 0; index < result.length; index++) {
                    const element = result[index]; 
                    result[index].pathUrl = './mdf-activity?id='+result[index].Fund_Request__c;                      
                } 
                this.fundClaimList = result;  
                this.rowCount = this.fundClaimList.length; 
                this.showLoadingSpinner = false;
                if (this.partnerFundROIList.length === 0 || this.partnerFundROIList.length === undefined) {
                    this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Information",
                        message: "No Data Found !",
                        variant: "info"
                    })
                );
                }
            }
        }).catch(error => {

            this.showLoadingSpinner = false;
        });
        this.showLoadingSpinner = false;
    }
}