import { LightningElement, wire, track, api } from "lwc"; //Named import
import getAccountDetails from "@salesforce/apex/UpdateYTDFromRequest.SendCurrentPartnerAccount";
import getAveragePartnerUse from "@salesforce/apex/UpdateYTDFromRequest.AveragePartnerUse";

export default class Prm_MarketDevFund extends LightningElement {
  @api acId; // Getting Set from Parent Component.
  @track FundClaimYTD;
  @track FundRequestedYTD;
  @track ROIonMdfActivities;
  @track AveragePartUse;
  @track PartnerLevel;
  @track showErrorAVGuse = true;
  placeAppender(value) {
    return Math.abs(value) > 999 && Math.abs(value) < 1000000
      ? Math.sign(value) * (Math.abs(value) / 1000).toFixed(1) + "k"
      : Math.abs(value) >= 1000000
      ? Math.sign(value) * (Math.abs(value) / 1000000).toFixed(1) + "M"
      : Math.sign(value) * Math.abs(value);
  }
  @wire(getAccountDetails, { accId: "$acId" }) accdata({ data }) {
    if (data) {
      if (data.Funds_Claimed_YTD__c) {
        this.FundClaimYTD = this.placeAppender(data.Funds_Claimed_YTD__c);
      } else {
        this.FundClaimYTD = 0;
      }
      if (data.Funds_Requested_YTD__c) {
        this.FundRequestedYTD = this.placeAppender(data.Funds_Requested_YTD__c);
      } else {
        this.FundRequestedYTD = 0;
      }
      if (data.ROI_on_MDF_Activities__c) {
        this.FundRequestedYTD = this.placeAppender(
          data.ROI_on_MDF_Activities__c
        );
      } else {
        this.ROIonMdfActivities = 0;
      }
      //this.ROIonMdfActivities = data.ROI_on_MDF_Activities__c;
      this.PartnerLevel = data.Partner_Program_Level__c.toUpperCase();
    }
  }
  @wire(getAveragePartnerUse, { accId: "$acId" }) averagePartnerUse({
    data,
    error
  }) {
    if (data) {
      this.AveragePartUse = this.placeAppender(data);
      //this.PartnerLevel = data.PartnerLevel.toUpperCase();
    } else if (error) {
      this.showErrorAVGuse = false;
    }
  }
}