/* eslint-disable no-alert */
/* eslint-disable guard-for-in */
/* eslint-disable vars-on-top */
/* eslint-disable eqeqeq */
/* eslint-disable no-console */
import { LightningElement, wire, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRevenueList from "@salesforce/apex/PRM_RevenueDataController.getRevenueList";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import YEAR_FIELD from "@salesforce/schema/Partner_Revenue__c.Year__c";
import getPartnerRevenueByYear from "@salesforce/apex/PRM_RevenueDataController.getPartnerRevenueByYear";

import Funds_Claimed_YTD from "@salesforce/schema/Account.Funds_Claimed_YTD__c";
import ROI_on_MDF_Activities from "@salesforce/schema/Account.ROI_on_MDF_Activities__c";
import Funds_Requested_YTD from "@salesforce/schema/Account.Funds_Requested_YTD__c";

export default class CPPData extends LightningElement { 
  @api recordId;
  @track revenueList;
  @track currentYear = new Date().getFullYear();
  @track showMdfData = true;
  @track hasRendered = false;
  @track spinner = false;
  @track year = new Date().getFullYear().toString();
  @track revenueDatafields = [
    "Direct_Revenue__c",
    "Indirect_Revenue__c",
    "Hardware__c",
    "Software__c",
    "Professional_Services__c",
    "Recurring_SW__c",
    "Recurring_PS__c",
    "TS__c",
    "Hosted__c",
    "SaaS__c",
    "POSaaS__c",
    "Revenue_to_Target__c",
    "Total_Services_Revenue__c",
    "Total_Solution_Revenue__c",
    "Total_Subscription_Revenue__c",
    "Total_Revenue__c",
    "First_Half__c",
    "Second_Half__c",
    "Year__c",
    "Partner_Account__c",
    "Min_Total_Revenue_to_Platinum__c",
    "Min_total_revenue_for_next_tier__c",
    //New fields added - EBA_SF-1518
    "Quota__c",
    "Order_YTD__c",
    "Traditional_Sites__c",
    "Subscription_Sites__c"

  ];
  @track netNewCustomerDataFields = [
    "Solution_from_Net_New_Customers__c",
    "Subscription_from_Net_New_Customers__c",
    "Net_New_Customer_Revenue__c",
    "Percent_of_Total_Rev_Net_New_Cust__c"
  ];
  @wire(getPicklistValues, {
    fieldApiName: YEAR_FIELD,
    recordTypeId: "012000000000000AAA"
  })
  yearPickList;
  
  mdfDatafields = [
    Funds_Claimed_YTD,
    Funds_Requested_YTD,
    ROI_on_MDF_Activities
  ];

  //Picklist and DataTable Links Events
  handleEvents(event) {
    this.spinner = true;
    if (event.detail.value != undefined) {
      this.year = event.detail.value;
    } else if (event.target.textContent != undefined) {
      this.year = event.target.textContent;
    }
    this.hasRendered = false;

    if (event.detail.value == this.currentYear || event.target.textContent == this.currentYear) {
      this.showMdfData = true;
    } else {
      this.showMdfData = false;
    }
  }

  renderedCallback() {
    if (!this.hasRendered) {
      this.spinner = true;
      this.partnerRevenueByYear(this.year);
      this.handleTableData();
      this.hasRendered = true;
    }
  }
  //Revenues Data Table
  handleTableData() {
    let accountId = this.recordId;
    getRevenueList({ accountId })
      .then(result => {
        var myMap = new Map();
        var dataList = [];
        myMap = result;
        for (var recKey of Object.keys(myMap).sort()) {
          dataList.push(myMap[recKey]);
        }
        this.revenueList = dataList.reverse();
        this.spinner = false;
        this.error = undefined;
      })
      .catch(error => {
        this.revenueList = undefined;
        this.spinner = false;
        this.error = error;
      });
  }
  //Partner Revenue record according to selected year
  @track revenueRecordId;
  partnerRevenueByYear(currentYear) {
    getPartnerRevenueByYear({
      "accountId": this.recordId,
      "year": currentYear
    })
      .then(result => {
        if (result.Id) {
          this.revenueRecordId = result.Id;
          this.spinner = false;
        }
      }).catch(error => {
        this.revenueRecordId = undefined;
        this.spinner = false;
        window.console.log("==== Partner Revenue By Year Error ==== :( ", error);
      });
  }
  //Create and Update Success Events
  handleSuccess(event) {
    this.recordId = "";
    const evt = new ShowToastEvent({
      title: "Success",
      message: "",
      variant: "success"
    });
    this.year = event.detail.fields.Year__c.value;
    this.recordId = event.detail.fields.Partner_Account__c.value;
    this.hasRendered = false;
    this.dispatchEvent(evt);
    this.closeModal();
  }
  //Handling Error
  handleError(event) {
    const evt = new ShowToastEvent({
      title: "Error",
      message: event.detail.detail,
      variant: "error"
    });
    this.dispatchEvent(evt);
  }
  // Poppup Modal for New Button and Edit Button
  @track modalStatus = false;
  @track currentRevenueRecordId = this.revenueRecordId;
  openModal(event) {
    if (event.target.label == "New") {
      this.currentRevenueRecordId = "";
    } else if (event.target.label == "Edit") {
      this.currentRevenueRecordId = this.revenueRecordId;
    }    
    this.modalStatus = true;
  }
  // Close Modal for New Button and Edit Button
  closeModal() {
    if (this.revenueRecordId) {
      this.currentRevenueRecordId = this.revenueRecordId;
    }
    this.modalStatus = false;
  }
}