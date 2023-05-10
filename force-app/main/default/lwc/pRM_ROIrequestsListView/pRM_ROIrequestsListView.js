import { LightningElement, track, wire } from "lwc";

import { NavigationMixin } from "lightning/navigation";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LANG from "@salesforce/i18n/lang";

import getPartnerFundROIList from "@salesforce/apex/PRM_MdfRoiController.getPartnerFundROIList";
import getPartnerFundROI from "@salesforce/apex/PRM_MdfRoiController.getPartnerFundROI";

export default class PRM_ROIrequestsListView extends NavigationMixin(
  LightningElement
) {
  @track partnerFundROIList = [];
  @track isButtonShow = false;
  @track headTitle = "MDF Results";
  @track rowCount;
  @track isListView = true;
  @track isDetailView = false;
  @track isButtonShow = false;
  @track isMDFResultsPopUpOpen = false;
  @track tempRowCount = undefined;
  @track partnerFundROI;
  @track showLoadingSpinner = true;

  attachedFile = [];
  error = "";
  tempFundClaimMap = [];

  @wire(getPartnerFundROIList)
  wiredFundRequest({ error, data }) {
    if (data) {
      window.console.log("=== MDF Results ", data);
      this.partnerFundROIList = data;
      this.rowCount = this.partnerFundROIList.length;
      this.tempRowCount = this.rowCount;
      this.error = undefined;
      this.showLoadingSpinner = false;
      if (
        this.partnerFundROIList.length === 0 ||
        this.partnerFundROIList.length === undefined
      ) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Information",
            message: "No Data Found !",
            variant: "info"
          })
        );
      }
    } else if (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error while loading data.",
          message: "Error :- " + this.error.body.message,
          variant: "error"
        })
      );
    }
    this.showLoadingSpinner = false;
  }

  navigateToFundROI(event) {
    this.showLoadingSpinner = true;
    let currentRequestRoiId = event.currentTarget.dataset.record;
    getPartnerFundROI({
      partnerFundRoiId: currentRequestRoiId
    })
      .then(result => {
        if (result) {
          this.partnerFundROI = result;
          this.isListView = false;
          this.isDetailView = true;
          this.headTitle = "MDF Result";
          this.isButtonShow = true;
          this.rowCount = undefined;
          this.partnerFundROI.CreatedDate = new Intl.DateTimeFormat(
            LANG
          ).format(new Date(result.CreatedDate));

          this.showLoadingSpinner = false;
        }
        this.error = undefined;
      })
      .catch(error => {
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
      });
  }

  backToListView() {
    this.showLoadingSpinner = true;
    this.isListView = true;
    this.headTitle = "MDF Results";
    this.isDetailView = false;
    this.isButtonShow = false;
    this.rowCount = this.tempRowCount;
    this.showLoadingSpinner = false;
  }
}