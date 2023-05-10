import { LightningElement, track, wire } from "lwc";
import mdfDetailRecord from "@salesforce/apex/PRM_MdfRoiController.mdfDetailRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LANG from "@salesforce/i18n/lang";
import savePartnerFundROI from "@salesforce/apex/PRM_MdfRoiController.savePartnerFundROI";
import roiSubmitForApproval from "@salesforce/apex/PRM_MdfRoiController.roiSubmitForApproval";
import deleteFundROIWithID from "@salesforce/apex/PRM_MdfRoiController.deleteFundROIWithID";
import deleteFundROIList from "@salesforce/apex/PRM_MdfRoiController.deleteFundROIList";
import { NavigationMixin } from 'lightning/navigation';


export default class PrmPartnerMdfActivity extends NavigationMixin (LightningElement) {
    @track mdfDetail = undefined;
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
  tempFundClaimList = [];
  file;

    connectedCallback(){  
        let prama = this.getUrlVars(decodeURI(window.location.href)); 
        if(prama['id']){
            mdfDetailRecord({
                fundRequestId: prama['id']
              })
            .then(result => {
              this.showLoadingSpinner = true;
                if (result) {
                this.mdfDetail = result; 
                this.currentFundRequestId = prama['id'];
                
                this.mdfDetail.fundRequest.Request_Submission_Date__c = new Intl.DateTimeFormat(
                    LANG
                ).format(new Date(result.fundRequest.Request_Submission_Date__c));

                if(this.mdfDetail.fundClaim.Claim_Submission_Date__c){
                    this.mdfDetail.fundClaim.Claim_Submission_Date__c = new Intl.DateTimeFormat(
                        LANG
                    ).format(new Date(result.fundClaim.Claim_Submission_Date__c));
                } 
                
                if (this.isPreviousValue === "IS-CURRENT") {
                    this.isPrevious = false;
                }
                }
                this.error = undefined; 
                this.showLoadingSpinner = false; 
            })
            .catch(error => {
                this.showLoadingSpinner = false;
                this.error = error;
                this.mdfDetail = undefined; 
                this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error while Loading Data",
                    message: "Error :- " + this.error,
                    variant: "error"
                })
                );
            });
        }
        this.showLoadingSpinner = false;
    }

    backToListView() {  
      this.showLoadingSpinner = true;
        this.isCurrent = true;
        this.isSubmitApproval = false;
        this.isFileUpload = false;
        var pram = this.getUrlVars(decodeURI(window.location.href));
        var pram1 =  decodeURI(window.location.href);
        console.log("URL : ",pram1);
        if(pram['tab']){
          window.console.log("=== Parma  ===",pram['tab'].replace('vtab','='));
          this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: window.location.origin+'/PartnerCentral/s/partner-claim?'+pram['tab'].replace('vtab','=')
            }
          },
          false 
          );
        }else{

          this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: window.location.origin+'/PartnerCentral/s/partner-claim'
            }
          },
          false 
          );
          
        } 
        this.showLoadingSpinner = false;
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
        this.showLoadingSpinner = false;
    }

    onSubmitMDFPopUpClose() { 
        this.isMDFResultsPopUpOpen = false;
        this.fileName = "";
        this.commentstext = "";      
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
              this.showLoadingSpinner = true;
              this.partnerFundRoiID = null;
              this.isPreviousValue = "IS-CURRENT";
              this.isPrevious = false;
              this.showLoadingSpinner = false;
               
            })
            .catch(error => {
              this.showLoadingSpinner = false;
               
            });
        } else {
           
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
            savePartnerFundROI({
              fundRequest: this.currentFundRequestId,
              fundClaim: this.mdfDetail.fundClaim.Id,
              currentRevenueEarned: revenueEarned.value,
              partnerFundROIId: tempId
            })
              .then(result => { 
                this.showLoadingSpinner = true;
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
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Error While Saving the record.",
                    message: " Error :- " + error.body.message + ".\n Try again.",
                    variant: "error"
                  })
                );
              });
          } else {
            this.showLoadingSpinner = false;
            if (!revenueEarned.value.match(matchNumber)) {
              revenueEarned.setCustomValidity("Please enter Number.");
            } else {
              revenueEarned.setCustomValidity("Value must be greater than zero.");
            }
            revenueEarned.reportValidity();
         
          }
        } else {
          this.showLoadingSpinner = false;
          if (revenueEarned.value === "" || revenueEarned.value === undefined) {
            revenueEarned.setCustomValidity("Please enter current revenue earned.");
            revenueEarned.reportValidity();
          }
        
        }
        this.showLoadingSpinner = false;
      }

      submitRoiRequest(event) {
        this.commentstext = this.template.querySelector(
          '[data-id^="comments"]'
        ).value;
         
        roiSubmitForApproval({
          idParent: this.partnerFundRoiID,
          comment: this.commentstext
        })
          .then(result => {
            this.showLoadingSpinner = true;
            this.partnerFundRoiID = "null";
            this.currentRevenueEarned = "";
            this.commentstext = ""; 
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
            
            if(result){ 
              this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url:  window.location.origin+'/PartnerCentral/s/mdf-result?id='+result
                }
            },
            false 
          );
            } 
            
          })
          .catch(error => { 
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error ",
                message: "Error :- " + error.body.message,
                variant: "error"
              })
            );
          }); 
      }

      handleUploadFinished(event) {
        this.isSubmitApproval = true;
        this.isCurrent = false;
        this.isFileUpload = false;
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