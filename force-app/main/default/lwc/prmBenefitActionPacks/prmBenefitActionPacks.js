import {LightningElement, wire, track} from 'lwc';
import getChannelBenefitActionPackMap from '@salesforce/apex/PRM_BenefitActionPacksController.getChannelBenefitActionPackMap';

export default class PrmBenefitActionPacks extends LightningElement {
    @track salesAndMarketingList = [];
    @track servicesList = [];
    @track supportList = [];
    @track customerExperienceList =[];
    @wire(getChannelBenefitActionPackMap) wireBenefitActionPackMap({ data, error }) {
        if (data) { 
            for (let recordKey of Object.keys(data)) {
                if (recordKey === "Sales and Marketing") {
                    this.salesAndMarketingList = data[recordKey];
                }

                if (recordKey === "Services") {
                    this.servicesList = data[recordKey];
                }

                if (recordKey === "Support") {
                    this.supportList = data[recordKey];
                }

                if (recordKey === "Customer Experience") {
                    this.customerExperienceList = data[recordKey];
                }
            }
        }
        //Showing error on console.
        if(error){
            window.console.log("=== Error While loading Benefit Action Packs");
        }
    }
}