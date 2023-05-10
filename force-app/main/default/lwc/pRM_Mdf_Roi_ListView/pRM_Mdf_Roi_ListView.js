import { LightningElement, track, wire } from "lwc";

import getFundClaimMap from "@salesforce/apex/PRM_MdfRoiController.getFundClaimMap";

import { NavigationMixin } from "lightning/navigation";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import LANG from "@salesforce/i18n/lang";

import mdfDetailRecord from "@salesforce/apex/PRM_MdfRoiController.mdfDetailRecord";
import savePartnerFundROI from "@salesforce/apex/PRM_MdfRoiController.savePartnerFundROI";
import roiSubmitForApproval from "@salesforce/apex/PRM_MdfRoiController.roiSubmitForApproval";
import deleteFundROIWithID from "@salesforce/apex/PRM_MdfRoiController.deleteFundROIWithID";
import deleteFundROIList from "@salesforce/apex/PRM_MdfRoiController.deleteFundROIList";

export default class PRM_Mdf_Roi_ListView extends NavigationMixin(
  LightningElement
) {
  @track fundClaimList = [];
  @track mdfDetail = undefined;
  @track isButtonShow = false;
  @track headTitle = "MDF Claims";
  @track rowCount;
  @track isListView = true;
  @track isDetailView = false;
  @track isButtonShow = false;
  @track isMDFResultsPopUpOpen = false;
  @track tempRowCount = undefined;
  @track currentFundRequestId = undefined;
  @track fileName = "";
  @track currentRevenueEarned;
  @track partnerFundRoiID;
  @track showLoadingSpinner = true;
  @track issubmitButton = true;
  @track commentstext;
  @track validFileExtension = [
    ".plain",
    ".jpeg",
    ".jpg",
    ".png ",
    ".doc",
    ".docx",
    ".html",
    ".odt",
    ".pdf",
    ".xlsx",
    ".xls",
    ".ods",
    ".ppt",
    ".pptx",
    ".txt",
    ".key",
    ".xlr",
    ".wpd",
    ".wps",
    ".wks",
    ".txt",
    ".rtf",
    ".zip",
    ".msg",
    ".one",
    ".csv"
  ];
  @track isCurrent = true;
  @track isSubmitApproval = false;
  @track isFileUpload = false;
  @track isPrevious = true;

  isPreviousValue = "IS-CURRENT";
  currentREVN = "";
  commenttxt = "";

  attachedFile = [];
  error = "";
  tempFundClaimMap = [];
  file;

  connectedCallback() {
    deleteFundROIList()
      .then(result => {
        window.console.log("=== Data Deleted ===");
      })
      .catch(error => {
        window.console.log("=== Error While Deleting Data ===", error);
      });
  }

  @wire(getFundClaimMap)
  wiredContacts({ error, data }) {
    if (data) {
      this.tempFundClaimMap = data;
      this.fundClaimList = Object.values(data);
      this.rowCount = this.fundClaimList.length;
      this.tempRowCount = this.rowCount;
      this.error = undefined;
      this.showLoadingSpinner = false;
      if (
        this.fundClaimList.length === 0 ||
        this.fundClaimList.length === undefined
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
      this.error = error;
      this.fundClaimList = undefined;
      this.showLoadingSpinner = false;

      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error while saving Data",
          message: " Error :- " + this.error.body.message,
          variant: "error"
        })
      );
    }
  }

  navigateToFundRequest(event) {
    var mdfId = event.currentTarget.dataset.record;
    this.showLoadingSpinner = true;
    mdfDetailRecord({
      fundRequestId: mdfId
    })
      .then(result => {
        if (result) {
          this.mdfDetail = result;
          this.isListView = false;
          this.isDetailView = true;
          this.headTitle = "MDF activity";
          this.isButtonShow = true;
          this.rowCount = undefined;
          this.currentFundRequestId = mdfId;
          this.mdfDetail.fundRequest.Request_Submission_Date__c = new Intl.DateTimeFormat(
            LANG
          ).format(new Date(result.fundRequest.Request_Submission_Date__c));
          this.mdfDetail.fundClaim.Claim_Submission_Date__c = new Intl.DateTimeFormat(
            LANG
          ).format(new Date(result.fundClaim.Claim_Submission_Date__c));
          window.console.log("New DAta ", new Intl.DateTimeFormat(LANG));
          if (this.isPreviousValue === "IS-CURRENT") {
            this.isPrevious = false;
          }
        }
        this.error = undefined;
        this.showLoadingSpinner = false;
      })
      .catch(error => {
        this.error = error;
        this.mdfDetail = undefined;
        this.showLoadingSpinner = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error while Loading Data",
            message: "Error :- " + this.error.body.message,
            variant: "error"
          })
        );
      });
  }

  backToListView() {
    this.showLoadingSpinner = true;
    this.isListView = true;
    this.headTitle = "MDF Claims";
    this.isDetailView = false;
    this.isButtonShow = false;
    this.rowCount = this.tempRowCount;
    this.showLoadingSpinner = false;
    this.isCurrent = true;
    this.isSubmitApproval = false;
    this.isFileUpload = false;
  }

  onSubmitMDFResults(event) {
    this.isMDFResultsPopUpOpen = true;
    this.fileName = "";
    this.commentstext = "";
    this.template.querySelector(
      '[data-id^="currentRevenueAttachment"]'
    ).files = null;
    this.isCurrent = true;
    this.isSubmitApproval = false;
    this.isFileUpload = false;
  }

  onSubmitMDFPopUpClose() {
    this.showLoadingSpinner = true;
    this.isMDFResultsPopUpOpen = false;
    this.fileName = "";
    this.commentstext = "";
    this.showLoadingSpinner = false;
    this.isCurrent = true;
    this.isSubmitApproval = false;
    this.isFileUpload = false;
    if (
      this.partnerFundRoiID !== null &&
      this.partnerFundRoiID !== "" &&
      this.partnerFundRoiID !== undefined
    ) {
      deleteFundROIWithID({
        fundId: this.partnerFundRoiID
      })
        .then(result => {
          window.console.log("=== Data Delete ===");
          this.partnerFundRoiID = null;
          this.isPreviousValue = "IS-CURRENT";
          this.isPrevious = false;
          this.showLoadingSpinner = false;
        })
        .catch(error => {
          window.console.log("=== Data Delete error ===", error);
          this.showLoadingSpinner = false;
        });
    } else {
      this.showLoadingSpinner = false;
    }
  }

  nextRequest() {
    let revenueEarned = this.template.querySelector(
      '[data-id^="currentRevenueearn"]'
    );
    let tempId;
    if (this.partnerFundRoiID !== undefined && this.partnerFundRoiID != null) {
      tempId = this.partnerFundRoiID;
    } else {
      tempId = "null";
    }
    let matchNumber = /^\d*\.?\d*$/; //'([0-9]*\.[0-9]*)|([0-9]*)';

    if (revenueEarned.value !== "" && revenueEarned.value !== undefined) {
      if (revenueEarned.value.match(matchNumber) && revenueEarned.value > 0) {
        this.showLoadingSpinner = true;
        savePartnerFundROI({
          fundRequest: this.currentFundRequestId,
          fundClaim: this.tempFundClaimMap[this.currentFundRequestId].Id,
          currentRevenueEarned: revenueEarned.value,
          partnerFundROIId: tempId
        })
          .then(result => {
            this.partnerFundRoiID = result.Id;
            this.error = undefined;
            this.isCurrent = false;
            this.isFileUpload = true;
            this.currentREVN = revenueEarned.value;
            this.isPreviousValue = "IS-FILE-UP-LOAD";
            this.isPrevious = true;
            this.showLoadingSpinner = false;
          })
          .catch(error => {
            this.showLoadingSpinner = false;
            this.isCurrent = true;
            this.isFileUpload = false;
            window.console.log("Error ", error);
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error While Saving the record.",
                message: " Error :- " + error.body.message + ".\n Try again.",
                variant: "error"
              })
            );
          });
      } else {
        if (!revenueEarned.value.match(matchNumber)) {
          revenueEarned.setCustomValidity("Please enter Number.");
        } else {
          revenueEarned.setCustomValidity("Value must be greater than zero.");
        }
        revenueEarned.reportValidity();
        this.showLoadingSpinner = false;
      }
    } else {
      if (revenueEarned.value === "" || revenueEarned.value === undefined) {
        revenueEarned.setCustomValidity("Please enter current revenue earned.");
        revenueEarned.reportValidity();
      }
      this.showLoadingSpinner = false;
    }
  }

  submitRoiRequest(event) {
    this.commentstext = this.template.querySelector(
      '[data-id^="comments"]'
    ).value;
    this.showLoadingSpinner = true;
    roiSubmitForApproval({
      idParent: this.partnerFundRoiID,
      comment: this.commentstext
    })
      .then(result => {
        this.partnerFundRoiID = "null";
        this.currentRevenueEarned = "";
        this.commentstext = "";
        this.showLoadingSpinner = false;
        this.isMDFResultsPopUpOpen = false;
        this.isCurrent = true;
        this.isSubmitApproval = false;
        this.isFileUpload = false;
        this.showLoadingSpinner = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success!!",
            message: "Record Submitted successfully.",
            variant: "success"
          })
        );
      })
      .catch(error => {
        this.showLoadingSpinner = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error ",
            message: "Error :- " + error.body.message,
            variant: "error"
          })
        );
      });
    this.showLoadingSpinner = false;
  }
  handleUploadFinished(event) {
    this.isSubmitApproval = true;
    this.isCurrent = false;
    this.isFileUpload = false;
  }
}