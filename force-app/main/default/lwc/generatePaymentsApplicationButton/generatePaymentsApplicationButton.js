/* eslint-disable no-alert */
/* eslint-disable no-console */
import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import {
    getRecord,
    getFieldValue,
    updateRecord
} from 'lightning/uiRecordApi';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import oppRecord from '@salesforce/apex/GeneratePaymentsApplicationController.getOpportunity';
//import isPricingFilled from '@salesforce/apex/GeneratePaymentsApplicationController.isPricingFilled';
//import approvePricing from '@salesforce/apex/GeneratePaymentsApplicationController.ShowApprovePricing';
import executeButtonsStatusCalculation from '@salesforce/apex/GeneratePaymentsApplicationController.executeButtonsStatusCalculation';
import getRelatedTask from '@salesforce/apex/GeneratePaymentsApplicationController.getRelatedTask';
import updateOpp from '@salesforce/apex/GeneratePaymentsApplicationController.updatePricingApprove';
import updateOppReject from '@salesforce/apex/GeneratePaymentsApplicationController.updatePricingReject';
import updateOppWithdraw from '@salesforce/apex/GeneratePaymentsApplicationController.updatePricingWithdraw';
import updateOppMoreInfo from '@salesforce/apex/GeneratePaymentsApplicationController.updateMoreInfo';
import requestRateReview from '@salesforce/apex/GeneratePaymentsApplicationController.requestRateReviewUpdate';
import statusMoreInfoProvided from '@salesforce/apex/GeneratePaymentsApplicationController.updateMoreInfoProvided';
import getOppRecord from '@salesforce/apex/GeneratePaymentsApplicationController.getOppRecord';
import getRelatedTaskStatus from '@salesforce/apex/GeneratePaymentsApplicationController.getRelatedTaskStatus';
import billingAccList from '@salesforce/apex/GeneratePaymentsApplicationController.getBillingSites';
import totalBillingAcnts from '@salesforce/apex/GeneratePaymentsApplicationController.getTotalBillingSites';
import billingSearchList from '@salesforce/apex/GeneratePaymentsApplicationController.getSearchBillingList';
import RequestPaymentsReviewForOpp from '@salesforce/apex/GeneratePaymentsApplicationController.AssignTasktoQueue';
import SendApplication from '@salesforce/apex/GeneratePaymentsApplicationController.sendApplication';
import switchLabel from '@salesforce/label/c.PayProsSwitch';
import withdrawnApplication from '@salesforce/apex/GeneratePaymentsApplicationController.withdrawnApplication';
import getRelatedContact from '@salesforce/apex/GeneratePaymentsApplicationController.GetAllACHContacts';
import savePaymntAssignee from '@salesforce/apex/GeneratePaymentsApplicationController.SavePaymtAsigneOnOpp';
import NAME_FIELD from '@salesforce/schema/Opportunity.POS__c';
/* import POS_FIELD from '@salesforce/schema/Opportunity.POS__c';
import CON_FIELD from '@salesforce/schema/Opportunity.Contacts__c';
import EMAIL_FIELD from '@salesforce/schema/Opportunity.Contacts__r.Email';
import PHONE_FIELD from '@salesforce/schema/Opportunity.Contacts__r.Phone';
import CHANNEL_FIELD from '@salesforce/schema/Opportunity.Channel_Office__c';
import AGENT_FIELD from '@salesforce/schema/Opportunity.Channel_Office__r.Payments_Agent_ID__c';
//
import MORE_INFO_CMNTS from '@salesforce/schema/Opportunity.Pricing_More_Info_Reason__c';
import PRICING_COMMENTS from '@salesforce/schema/Opportunity.Pricing_Team_Comments__c';
import RATE_REVIEW_COMMENTS from '@salesforce/schema/Opportunity.Pricing_Rate_Review_Comments__c';
import REJECT_COMMENTS from '@salesforce/schema/Opportunity.Pricing_Reject_Reason_Comments__c'; */
//const VALIDATE_FIELDS = [POS_FIELD, CON_FIELD, EMAIL_FIELD,PHONE_FIELD,CHANNEL_FIELD,AGENT_FIELD];
const VALIDATE_FIELDS = [NAME_FIELD];
/* const MORE_INFO_FIELDS =[MORE_INFO_CMNTS,PRICING_COMMENTS];
const RATE_FIELDS =[RATE_REVIEW_COMMENTS];
const REJECT_FIELDS =[REJECT_COMMENTS]; */
export default class GeneratePaymentsApplicationButton extends LightningElement { 
    @api recordId;
    @track oppObj;
    @track showComp = false;
    @track showPricingApprove = false;
    @track accId = '';
    @track closeDate = '';	
	@track isOlderCloseDate = false;
    @track searchKey = '';
    @track showModel = false;
    @track showPrincingBtn = false;
    @track enableSendAppbtn = false;
    @track enableWithAppbtn1 = false;
    @track enableReqPricingbtn = false; 
    @track billingAccounts = [];
    @track searchedBillingAccount = [];
    @track totalSites = 0;
    @track isSiteSearched = false;
    @track totalSeachedSite = 0;
    @track selectedSites = [];
    @track isLoaded = false;
    @track isModalLoaded = false;
    @track pricingApprover;
    @track showRecomendation = false;
    @track resp = '';
    @track disGnrtebtnMsg = 'Identifying Generate Payments Status.....';
    //only populated when fields missing so no condition required
    @track disRequestbtnMsg = '';
    @track approvErrorMsg = '';
    @track approveError = false;
    @track approveSuggestion = false;  
    @track isShowMsg = false;
    @track isShowDisableMsg = false;
    @track showAppoveButton = false;
    @track add = false;
    @track showReviewPage = false;
    @track AddedSiteNo =0;
    @track addedSites = [];
    @track addedNewSites = [];
    @track totalAvlSites =0;
    @track showRateReviewbtn = false;
    @track showWithdrawalbtn = false;
    @track showMoreInfoProvidedbtn = false;
    @track withdrawalConfirmation = false;
    @track disableRateReviewbtn = false;
    @track showMoreInfoRequestbtn = false;
    @track disableMoreInfoRequestbtn = false;
    @track captureMoreInfoDetail = false;

    @track isModalOpen = false;  // eba-sf-2024
    @api msgVal = '';      // eba-sf-2024
     label = {switchLabel};    
     @track swt;  // eba-sf-2024

    @track captureRejectComments = false;
    @track captureRateReviewComments = false;
    @track showMoreInfoProvided = false;
    @track opp;
    //@track showPricingFillMessage = false;
    @track ConArray = [];
    @track toggleSpinner=false;
    @track pmntAsine='';
    @track selectedContact='';
    @track ToggleContactDetail=false;
    @wire(billingAccList, {
        accId: '$accId'
    }) billingAccountRecords;
    @wire(totalBillingAcnts, {
        accId: '$accId'
    }) AvlSites;
    //@wire(billingSearchList, { accntId: '$accId',searchKey: '$searchKey'}) billingAccountRecords;
    @wire(getRecord, {
        recordId: '$recordId',
        fields: VALIDATE_FIELDS
    })
    wiredRecord({
        error,
        data
    }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.disGnrtebtnMsg = 'Error: Fetching Information. Contact Salesforce Admin.' + message;
            this.enableSendAppbtn = false;
            this.enableWithAppbtn1 = false;
        } else if (data) {
            if (this.showComp == true) {
                this.opp = data;
                this.executeBtnCalculation();
            }
        }
    }
    connectedCallback() {
        

        if(switchLabel == 'True'){
            this.swt = true; 
        }
        else if(switchLabel == 'False'){
            this.swt = false; 

        }


        oppRecord({
                oppId: this.recordId
            })
            .then(result => {
                console.log('OppData Using Connected CallBack!!!@@@@ : ' + JSON.stringify(result));
                this.accId = result.Opportunity.AccountId;
                this.closeDate=result.Opportunity.CloseDate;	
               // alert(this.closeDate);
                //this.oppObj = result;
                if (result !== null) {
                    this.showComp = true;
                }
                console.log('----->' + result.Opportunity.NCR_Payments_Application_Status__c);
                if ((result.Opportunity.Payments_Application_Status__c === 'Approve' || result.Opportunity.Payments_Application_Status__c === 'Withdrawn') && (typeof(result.Opportunity.NCR_Payments_Application_Status__c) === 'undefined' || result.Opportunity.NCR_Payments_Application_Status__c === 'Withdrawn')) {
                    this.showPrincingBtn = true;
                }
            })
            .catch((error) => {
                console.log('Error Occured : ' + JSON.stringify(error));
            });
        // if open tasks
        getRelatedTask({
                oppId: this.recordId
            })
            .then(result => {
                this.showPricingApprove = (result.length > 0 ? true : false);
            })
            .catch((error) => {
                console.log('Error Occured : ' + JSON.stringify(error));
            });
        this.executeBtnCalculation();
         
        
    }
    handlePaymentApplication() {
        var today =new Date();	
    var monthDigit = today.getMonth() + 1;	
    if (monthDigit <= 9) {	
        monthDigit = '0' + monthDigit;	
    }	
    //var todayDate= today.getFullYear() + "-" + monthDigit + "-" + today.getDate();	
    //var todayDate= monthDigit + "-" + today.getDate() + "-" + today.getFullYear();	
    //this.isOlderCloseDate = this.closeDate < todayDate ? true : false;
    var todayDate= new Date(today.getFullYear() + "-" + monthDigit + "-" + today.getDate());
    var cd=new Date(this.closeDate);
    
    this.isOlderCloseDate = cd < todayDate ? true : false;
        if(this.isOlderCloseDate){	
        this.showModel = false;           	
                            const event = new ShowToastEvent({	
                                "title": "Error!",	
                                "message": "Book Date must not be in the past. Please select an appropriate date..",	
                                "variant": 'error',	
                            });	
                            this.dispatchEvent(event);	
                        } 	
    else{	
    this.showModel = true;	
    this.isSiteSearched = false;	
    this.billingAccounts = JSON.parse(JSON.stringify(this.billingAccountRecords.data));	
    this.totalAvlSites=this.AvlSites.data;	
    this.totalSites = this.billingAccountRecords.data.length;	
    this.sVal = '';	
    this.getContactAndRelatedContact();	
    }                    	
    
    }


    handleMsgChange(event){
        this.msgVal = event.target.value;
    }


    /* eba-sf2024 - Capture Withdrawing Payments Application Info */
    handleWithPayApp(event) {
       /* var today =new Date();	
    var monthDigit = today.getMonth() + 1;	
    if (monthDigit <= 9) {	
        monthDigit = '0' + monthDigit;	
    }	
    //var todayDate= today.getFullYear() + "-" + monthDigit + "-" + today.getDate();	
    //var todayDate= monthDigit + "-" + today.getDate() + "-" + today.getFullYear();	
    //this.isOlderCloseDate = this.closeDate < todayDate ? true : false;
    var todayDate= new Date(today.getFullYear() + "-" + monthDigit + "-" + today.getDate());
    var cd=new Date(this.closeDate);
    
    this.isOlderCloseDate = cd < todayDate ? true : false;
        if(this.isOlderCloseDate){	
        this.showModel = false;           	
                            const event = new ShowToastEvent({	
                                "title": "Error!",	
                                "message": "Book Date must not be in the past. Please select an appropriate date..",	
                                "variant": 'error',	
                            });	
                            this.dispatchEvent(event);	
                        } */	
    //else{	
    //this.showModel = true;
    this.isModalLoaded = true;
    //this.isModalOpen = false;   
    //this.msgValue='testing';
    //console.log('msg added for withdrawing payments appliaction:'+msgValue);
    /*this.isSiteSearched = false;	
    this.billingAccounts = JSON.parse(JSON.stringify(this.billingAccountRecords.data));	
    this.totalAvlSites=this.AvlSites.data;	
    this.totalSites = this.billingAccountRecords.data.length;	
    this.sVal = '';	
    this.getContactAndRelatedContact();	*/
    //} 


    //var siteSelected=false;
    //console.log('added sites before sending:'+JSON.stringify(this.addedSites));
    
    withdrawnApplication({
            oppId: this.recordId,
            //billingAccs: JSON.stringify(this.addedNewSites),
            msg : this.msgVal
        }).then(result => {
            //console.log('result.opp.Payments_Application_Status__c' + result.opp.Payments_Application_Status__c + 'response' + result.res + 'result.opp.NCR_Payments_Application_Status__c:' + result.opp.NCR_Payments_Application_Status__c);
            if (result.res != '') {
                var res = result.res.toUpperCase();
                this.showModel = false;
                this.isModalOpen = false;
                this.isModalLoaded = false;
                if (res.indexOf('PARTIAL') > -1) {
                    this.enableSendAppbtn = false;
                    this.enableWithAppbtn1 = false;
                    this.enableReqPricingbtn = false;
                    const evt = new ShowToastEvent({
                        title: 'Partially Successful.',
                        message: res,
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                }
                else  if (res.indexOf('FAIL') > -1) {
                    const evt = new ShowToastEvent({
                        title: 'Payments Withdrwan Failed.',
                        message: res,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
               
                } else {
                    this.enableSendAppbtn = true;
                    this.enableWithAppbtn1 = false;
                    this.enableReqPricingbtn = false;
                    const evt = new ShowToastEvent({
                        title: 'Payments Application Withdrawn.',
                        message: result.res,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                this.executeBtnCalculation();
                
            }
            console.log('Response is ' + JSON.stringify(result));
        })
        .catch((error) => {
            console.log('Error Occured in send response : ' + JSON.stringify(error));
        });

    
    }

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    





    executeBtnCalculation() {
        executeButtonsStatusCalculation({
                oppId: this.recordId
            })
            .then(result => {
                
                this.oppObj = result;
                this.showAppoveButton = result.enableAppoveButton;
                this.enableSendAppbtn = result.enableGenerateButton;
                this.enableWithAppbtn1 = result.enableWithdrawnButton;
                this.enableReqPricingbtn = result.enableReqPricingButton;
                this.pricingApprover = result.opp.Pricing_Approver_Name__c;
                this.disGnrtebtnMsg = result.DissableReason;
                this.disRequestbtnMsg = result.DissableReviewReason;
                this.approvErrorMsg = result.approverMessage;
                if (this.pricingApprover == null) {
                    this.showRecomendation = true;
                } else {
                    this.showRecomendation = false;
                }
                if (this.approvErrorMsg == '' || this.approvErrorMsg == null) {
                    this.approveError = false;
                    this.approveSuggestion = false;
                } else {
                    this.approveSuggestion = true;
                    this.approveError = true;
                }              
                if(result.opp.Pricing_Review_Request_Status__c!=null && result.opp.Pricing_Review_Request_Status__c!='Approve' && result.opp.Pricing_Review_Request_Status__c!='Reject' && result.opp.Pricing_Review_Request_Status__c!='Withdrawn'){
                    this.showWithdrawalbtn=true; 
                }else{
                    this.showWithdrawalbtn=false;  
                }
                if(result.opp.Pricing_Review_Request_Status__c!=null && (result.opp.Pricing_Review_Request_Status__c=='Approve' || result.opp.Pricing_Review_Request_Status__c=='Rate Review Request') ){
                    this.showRateReviewbtn=true; 
                }else{
                    this.showRateReviewbtn=false;  
                } 
                console.log('here');               
                if((result.opp.Pricing_Review_Request_Status__c!=null && result.opp.Pricing_Review_Request_Status__c=='Rate Review Request') || (this.disGnrtebtnMsg!=null && this.disGnrtebtnMsg.toLocaleLowerCase().indexOf('site(s)')>0)){
                    this.disableRateReviewbtn=true; 
                }else{
                    this.disableRateReviewbtn=false;  
                }
                console.log('here');               
                if(result.opp.Pricing_Review_Request_Status__c!=null && result.opp.Pricing_Review_Request_Status__c=='More Information Requested'){
                    this.showMoreInfoProvidedbtn=true; 
                }else{
                    this.showMoreInfoProvidedbtn=false;  
                }
                console.log('here');               
                if(result.opp.Pricing_Review_Request_Status__c!=null  && result.opp.Pricing_Review_Request_Status__c!='Approve' && result.opp.Pricing_Review_Request_Status__c!='Reject' && result.opp.Pricing_Review_Request_Status__c!='Withdrawn'){
                    this.showMoreInfoRequestbtn=true; 
                }else{
                    this.showMoreInfoRequestbtn=false; 
                }
                if(result.opp.Pricing_Review_Request_Status__c=='More Information Requested'){
                    this.disableMoreInfoRequestbtn=true; 
                }else{
                    this.disableMoreInfoRequestbtn=false; 
                }
                if(result.opp.Pricing_Review_Request_Status__c!=null && result.opp.Pricing_Review_Request_Status__c=='More Information Requested'){
                    this.showMoreInfoProvided=true; 
                }else{
                    this.showMoreInfoProvided=false; 
                }
                console.log('heref');
                console.log(this.enableReqPricingbtn+'@@'+this.showAppoveButton + 'msg1:' + this.disGnrtebtnMsg+'rate reviw'+this.showRateReviewbtn+' Withdrw'+ this.showWithdrawalbtn);
            
                /******* Added By Vivek Kumar Start Here ***********/ 
                /*isPricingFilled({
                    oppId: this.recordId
                })
                .then(result => {
                console.log('result : '+result);
                console.log('result : '+JSON.stringify(result));
                this.enableReqPricingbtn = result;
                this.showPricingFillMessage = (result == false ? true : false);
                })
                .catch((error) => {
                console.log('Error Occured : ' + JSON.stringify(error));
                });*/
                /******* Added By Vivek Kumar End Here ***********/
               
            })
            .catch((error) => {
                console.log('Error Occured : ' + JSON.stringify(error));
            });
    }
    closeModel() {
        this.showModel = false;
        this.addedNewSites=[];
        this.addedSites=[];
        this.totalSelectedSites=0;
    }
    handleReview(){
        if(this.pmntAsine != ''){
            this.showReviewPage = true;
           
            console.log('totalSelectedSites##@@ = '+this.totalSelectedSites);
            console.log('addedSites##@@ = '+JSON.stringify(this.addedSites));
            console.log('addedNewSites##@@ = '+JSON.stringify(this.addedNewSites));
            console.log('In Handle Review'+this.showReviewPage+'show modal is :'+this.showModel);
        }
        else{
            const showError = new ShowToastEvent({
                title: 'Error',
                message: 'please select Payment Assignee',
                variant: 'warning',
            });
            this.dispatchEvent(showError);
        }
    }
    handlePrevious(){
        this.showReviewPage = false;
        this.pmntAsine='';
    }
    updateSeachKey(event) {
        this.sVal = event.target.value;
        console.log('updatedKey'+this.sVal);
        // if search input value is not blank then call apex method, else display error msg 
        if (this.sVal !== undefined) {
            billingSearchList({
                searchKey: this.sVal,
                accntId: this.accId
            }).then(result => {
                console.log('result of search key'+JSON.stringify(result));
               // this.searchedBillingAccount=JSON.parse(JSON.stringify(result.billingSite));
                this.totalSeachedSite = result.length;
                this.searchedBillingAccount= JSON.parse(JSON.stringify(result));
                console.log('_____'+JSON.stringify(this.addedSites));
                this.searchedBillingAccount.forEach(site => {
                    if (this.addedNewSites.length!==0) {
                        this.addedNewSites.forEach(addedSite => {
                    var stName = addedSite.billingSite.Name;
                    console.log('stName is '+stName);
                    if (stName == site.billingSite.Name) {
                        console.log('selected site is :' + JSON.stringify(site));
                        site.isAdded = !site.isAdded;
                       // this.searchedBillingAccount[indx] = site;
                        console.log('added Sites'+JSON.stringify(this.addedSites))  ;
                       // console.log('After selection is :' + JSON.stringify(site));
                        //this.searchedBillingAccount[indx].isAdded = !this.searchedBillingAccount[indx].isAdded;
                    }
                });
                }
                });
            
                if (this.totalSeachedSite > 0) {
                    this.isSiteSearched = true;
                }
            });
           
        }
    }
    handleSendApplication() {
        var siteSelected=false;
        console.log('added sites before sending:'+JSON.stringify(this.addedSites));
        this.addedSites.forEach(site => {
            
            
            if (site.isAdded  == true) {
                siteSelected=true;
            }
        });
        if(siteSelected){
            this.isModalLoaded = true;
        SendApplication({
                oppId: this.recordId,
                billingAccs: JSON.stringify(this.addedNewSites)
            }).then(result => {
                console.log('result.opp.Payments_Application_Status__c' + result.opp.Payments_Application_Status__c + 'response' + result.res + 'result.opp.NCR_Payments_Application_Status__c:' + result.opp.NCR_Payments_Application_Status__c);
                if (result.res != '') {
                    var res = result.res.toUpperCase();
                    this.showModel = false;
                    this.isModalLoaded = false;
                    if (res.indexOf('PARTIAL') > -1) {
                        this.enableSendAppbtn = false;
                        this.enableWithAppbtn1 = false;
                        this.enableReqPricingbtn = false;
                        const evt = new ShowToastEvent({
                            title: 'Partially Successful.',
                            message: res,
                            variant: 'warning',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(evt);
                    }
                    else  if (res.indexOf('FAIL') > -1) {
                        const evt = new ShowToastEvent({
                            title: 'Payments Application Failed.',
                            message: res,
                            variant: 'error',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(evt);
                   
                    } else {
                        this.enableSendAppbtn = false;
                        this.enableWithAppbtn1 = true;
                        this.enableReqPricingbtn = false;
                        const evt = new ShowToastEvent({
                            title: 'Payments Application Successfully Sent.',
                            message: result.res,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                    }
                    this.executeBtnCalculation();
                    
                }
                console.log('Response is ' + JSON.stringify(result));
            })
            .catch((error) => {
                console.log('Error Occured in send response : ' + JSON.stringify(error));
            });
        }else{
            const evt = new ShowToastEvent({
                title: 'No Site Selected.',
                message: 'You have not selected any billing site to Send Application.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        
    }
    addSites(event) {
        this.enableSendButton=true;
        var indx = event.target.name;
        console.log('in add site' + indx);
        //  console.log('Is site Searched'+this.isSiteSearched+' data is'+JSON.stringify(this.searchedBillingAccount));
        if (this.isSiteSearched && !this.showReviewPage)   {
            var selectedSiteName = this.searchedBillingAccount[indx].billingSite.Name;
            var selectedSiteId = this.searchedBillingAccount[indx].billingSite.Id;
            this.searchedBillingAccount.forEach(site => {
                var stName = site.billingSite.Name;
                var stId = site.billingSite.Id;
                if (stId == selectedSiteId) {
                    site.isAdded= !site.isAdded;
                }  
                //console.log('site ____ line 325'+JSON.stringify(site));
                //console.log('Sitess_____line 326'+JSON.stringify(this.searchedBillingAccount));
                this.add = false;
                console.log('selected Site Name' + selectedSiteName +'and stName is '+stName);
                this.addedSites = [];
                this.addedSites = this.addedNewSites;
               console.log('addedSites 326 line'+JSON.stringify(this.addedSites));
                this.addedSites.forEach(addedSite => {
                    if((addedSite.billingSite.Id == selectedSiteId) ){
                       // addedSite.isAdded=!addedSite.isAdded;
                        this.add=true;
                        console.log('in site se arched this.add is'+this.add+'++++'+addedSite.isAdded);
                    }   
                });
                console.log('addedSites 335 line'+JSON.stringify(this.addedSites));
                if (stId == selectedSiteId) {   
                    console.log('selected site is :' + JSON.stringify(site));
                    //site.isAdded = !site.isAdded;
                    //console.log('SIte after isAddedChange'+JSON.stringify(site));
                    this.searchedBillingAccount[indx] = site;
                   // console.log('this.add line 335'+this.add);
                    if(!this.add && this.searchedBillingAccount[indx].isAdded){
                        //console.log('____________here');
                        this.addedSites.push(this.searchedBillingAccount[indx]);
                        }
                    if(!this.searchedBillingAccount[indx].isAdded){
                        console.log('____________here22'+selectedSiteName);
                        console.log('____________here2222'+JSON.stringify(this.addedSites));
                            this.addedSites.forEach(addedSite => {
                                console.log('addedSite.billingSite.name:'+addedSite.billingSite.Name)
                                if(addedSite.billingSite.Id == selectedSiteId){
                                   if(addedSite.isAdded) {
                                       console.log('_____here222'+JSON.stringify(addedSite));
                                    addedSite.isAdded=!addedSite.isAdded;
                                   }
                                }
                            });
                            }
                   // this.addedSites.push(this.searchedBillingAccount[indx]);
                   // console.log('added Sites in isSiteSearched '+JSON.stringify(this.addedSites));
                   // console.log('After selection is :' + JSON.stringify(site));
                    //this.searchedBillingAccount[indx].isAdded = !this.searchedBillingAccount[indx].isAdded;
                }
            });
            console.log('___________line no 462___'+JSON.stringify(this.addedSites));
            this.addedNewSites=[];
            this.addedSites.forEach(addedSite => {
                //this.AddedSiteNo+=this.AddedSiteNo;
                if(addedSite.isAdded){
                    
                    this.addedNewSites.push(addedSite);
                }
            });
            this.totalSelectedSites=this.addedNewSites.length;
            console.log('billing accounts after selection' + JSON.stringify(this.billingAccounts));
            console.log('Searched billing accounts after selection' + JSON.stringify(this.searchedBillingAccount));
            console.log('Added New Sites after selection ' + JSON.stringify(this.addedNewSites));
        } if(!this.isSiteSearched && !this.showReviewPage) {
            this.billingAccounts[indx].isAdded = !this.billingAccounts[indx].isAdded;
            var selectedSiteName = this.billingAccounts[indx].billingSite.Name;
            var selectedSiteId = this.billingAccounts[indx].billingSite.Id;
            this.billingAccounts.forEach(site => {
                var stName = site.billingSite.Name;
                var stId = site.billingSite.Id;
               console.log('485 -- selected Site Id is ' + selectedSiteId +' and stId in isNotSiteSearched is '+stId);
                console.log('486 -- selected Site Name is ' + selectedSiteName +' and stName in isNotSiteSearched is '+stName);
                if (stId == selectedSiteId) {
                    console.log('488 -- selected site is :' + JSON.stringify(site));
                   // site.isAdded = !site.isAdded;
                    this.billingAccounts[indx] = site;
                    this.add = false;
                    console.log('492 -- before iterate = '+this.add);
                    this.addedSites.forEach(addedSite => {
                        console.log('494 -- @@@@@addedSite2 '+addedSite.billingSite.Id+'!!!!!'+selectedSiteId);
                        console.log('495 -- @@@@@addedSite2 '+addedSite.billingSite.Name+'!!!!!'+selectedSiteName);
                        if(addedSite.billingSite.Id == selectedSiteId){
                            this.add=true;
                            console.log('498 -- In innotSearched = '+this.add);
                        }
                    });
                    console.log('501 -- this.add = '+this.add+', select site is added : '+this.billingAccounts[indx].isAdded) ;
                    if(!this.add && this.billingAccounts[indx].isAdded){
                       console.log('503 -- this.billingAccounts[indx] = '+JSON.stringify(this.billingAccounts[indx]));
                       this.addedSites.push(this.billingAccounts[indx]);
                    }
                    console.log('506 -- added Sites in isNotSiteSearched = '+JSON.stringify(this.addedSites));
                   // console.log('After selection is :' + JSON.stringify(site));
                    //this.searchedBillingAccount[indx].isAdded = !this.searchedBillingAccount[indx].isAdded;
                }
            });
            this.addedNewSites=[];
            this.addedSites.forEach(addedSite => {
                //this.AddedSiteNo+=this.AddedSiteNo;
                console.log('514 -- addedSite *&*& = '+JSON.stringify(addedSite));
                if(addedSite.isAdded){
                    console.log('516 -- addedSite added ##*&*&## = '+JSON.stringify(addedSite));
                    this.addedNewSites.push(addedSite);
                }
            });
            this.totalSelectedSites=this.addedNewSites.length;
            console.log('521 -- billing accounts = ' + JSON.stringify(this.billingAccounts));
        }
        if(this.showReviewPage){
            this.addedSites=[];
            console.log('++++this.addedSites'+JSON.stringify(this.addedSites));
            this.addedSites=this.addedNewSites;
            console.log('++++this.addedSites2s'+JSON.stringify(this.addedSites));
            var selectedSiteName = this.addedNewSites[indx].billingSite.Name;
            var selectedSiteId = this.addedNewSites[indx].billingSite.Id;
            this.addedSites.forEach(addedSite => {
                //this.AddedSiteNo+=this.AddedSiteNo;
                if( selectedSiteId == addedSite.billingSite.Id){
                    
                    addedSite.isAdded = !addedSite.isAdded;
                }
            });
            console.log('+++Nmae added'+selectedSiteName);
            console.log('++++this.addedSites3s'+JSON.stringify(this.addedSites));
            this.addedNewSites=[];
            this.addedSites.forEach(addedSite => {
                //this.AddedSiteNo+=this.AddedSiteNo;
                if(addedSite.isAdded){
                    
                    this.addedNewSites.push(addedSite);
                }
            });
            this.searchedBillingAccount.forEach(site => {
                if (this.addedNewSites.length!==0) {
                if (selectedSiteId == site.billingSite.Id) {
                    console.log('selected site is :' + JSON.stringify(site));
                    if(site.isAdded){
                        site.isAdded = !site.isAdded;
                    }
                    console.log('selected site after chnage  :' + JSON.stringify(site));
                    
                                   }
        }
        console.log('++++this.searched site Sitess'+JSON.stringify(this.searchedBillingAccount));
    });
    this.totalSelectedSites=this.addedNewSites.length;
            
        }
    }
    approvePricing() {
        this.isLoaded = true;
        updateOpp({
                oppId: this.recordId
            })
            .then(result => {
                this.oppObj = result.opp;
                this.approvErrorMsg = result.errorMsg;
                if (this.approvErrorMsg == null) {
                    this.approveError = false;
                    this.approveSuggestion = false;
                    if (result.opp.Pricing_Approver_Name__c !== null) {
                        this.showApproverName = true;
                        this.pricingApprover = result.opp.Pricing_Approver_Name__c;
                    }
                    this.executeBtnCalculation();
                    eval("$A.get('e.force:refreshView').fire();");
                    this.showPricingApprove = false;                  
                    
                } else {
                    this.approveError = true;
                    this.approveSuggestion = false;
                const showError = new ShowToastEvent({
                    title: 'Error, Information Incomplete >>',
                    message: this.approvErrorMsg,
                    variant: 'error',
                });
                this.dispatchEvent(showError);
                }
                this.isLoaded = false;
            })
            .catch((error) => {
                this.isLoaded = false;
                this.error = JSON.stringify(error);
                console.log('error ' + JSON.stringify(error));
                const showError = new ShowToastEvent({
                    title: 'Error Occured >>',
                    message: this.error.body,
                    variant: 'error',
                });
                this.dispatchEvent(showError);
            });
    }
    
    requestWithdrawalConfirmation() {
        this.withdrawalConfirmation=true;
    }
    requestWithdrawalCancel() {
        this.withdrawalConfirmation=false;
    }
    requestWithdrawal() {
        this.isLoaded = true;
        this.withdrawalConfirmation=false;
        updateOppWithdraw({
                oppId: this.recordId
            })
            .then(result => {
                console.log('01');
                this.oppObj = result.opp;
                console.log('001');
                this.approvErrorMsg = result.errorMsg;
                console.log('1');
                if (this.approvErrorMsg == null) {  
                    console.log('2');
                    const evt = new ShowToastEvent({
                        
                        title: 'Success!!',
                        message: 'Pricing Review Request successfully Withdrwan.',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.executeBtnCalculation();
                    this.dispatchEvent(evt);
                    eval("$A.get('e.force:refreshView').fire();");                
                    this.isLoaded = false;
                } else {
                    console.log('3');
                    const evt = new ShowToastEvent({
                        title: 'Failed to withdraw request.',
                        message: approvErrorMsg,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);   
                }
            })
            .catch((error) => {
                this.isLoaded = false;
                this.error = JSON.stringify(error);
                console.log('error ' + JSON.stringify(error));
                const showError = new ShowToastEvent({
                    title: 'Error Occured >>',
                    message: this.error.body,
                    variant: 'error',
                });
                this.dispatchEvent(showError);
                
            });
    }
    requestPricingReview(){
        this.reason='Pricing Request';
        this.requestReview();
    }
    /*requestInfoReview(){
        this.reason='info provided';
        console.log('____requestInfoReview___'+this.reason);
        this.requestReview();  
    }*/
    requestReview() {
        this.isLoaded = true;
        this.enableReqPricingbtn=false;
        RequestPaymentsReviewForOpp({
                OpportunityId: this.recordId,
                reason:this.reason
            }).then(response => {
                if (response) {
                    //this.createdAccountId = response.Id;
                    console.log('>>>>>>>>>' + JSON.stringify(response));
                    if (response !== null) {
                        this.showPricingApprove = true;
                        const showSuccess = new ShowToastEvent({
                            title: 'Success!!',
                            message: 'A request to review the pricing has been sent to the pricing team.',
                            variant: 'Success',
                        });
                        this.dispatchEvent(showSuccess);
                        this.executeBtnCalculation();
                        eval("$A.get('e.force:refreshView').fire();");
                        this.isLoaded = false;
                    }
                    this.error = undefined;
                } else {
                    this.error = 'You dont have permission to raise this Request.';
                    const showError = new ShowToastEvent({
                        title: 'Error!!',
                        message: this.error,
                        variant: 'error',
                    });
                    this.dispatchEvent(showError);
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                this.isLoaded = false;
                this.error = JSON.stringify(error);
                console.log('error ' + JSON.stringify(error));
                const showError = new ShowToastEvent({
                    title: 'Error >>',
                    message: this.error.body,
                    variant: 'error',
                });
                this.dispatchEvent(showError);
            });
    }
    captureMoreInfoDetailFn() {
        console.log('capture');
        this.captureMoreInfoDetail=true;
    }
    requestMoreInfoCancel() {
        this.captureMoreInfoDetail=false;
    }
    
    requestMoreInfo(event) {
        //handle submission
    }
    handleMoreInfo() {
        this.isLoaded = true;
        this.captureMoreInfoDetail=false;
        updateOppMoreInfo({
                OpportunityId: this.recordId               
            }).then(response => {
                if (response) {                    
                    if (response !== null) {
                        const showSuccess = new ShowToastEvent({
                            title: 'Success!!',
                            message: 'Successfully Requested More Information .',
                            variant: 'Success',
                        });
                        this.dispatchEvent(showSuccess); 
                        this.executeBtnCalculation();
                        eval("$A.get('e.force:refreshView').fire();");
                        this.isLoaded = false;
                    }
                    this.error = undefined;
                } else {
                    this.error = 'You dont have permission to raise this Request.';
                    const showError = new ShowToastEvent({
                        title: 'Error!!',
                        message: this.error,
                        variant: 'error',
                    });
                    this.dispatchEvent(showError);
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                this.isLoaded = false;
                this.error = JSON.stringify(error);
                console.log('error ' + JSON.stringify(error));
                const showError = new ShowToastEvent({
                    title: 'Error >>',
                    message: this.error.body,
                    variant: 'error',
                });
                this.dispatchEvent(showError);
            });
    }
    captureRejectDetailFn() {
        console.log('capture');
        this.captureRejectComments=true;
    }
    requestRejectCancel() {
        this.captureRejectComments=false;
    }
    requestReject(event) {
        //handle rejection
    }
    handleReject() {
        this.isLoaded = true;
        this.captureRejectComments=false;
        updateOppReject({
            oppId: this.recordId               
            }).then(response => {
                if (response) {                    
                    if (response !== null) {
                        const showSuccess = new ShowToastEvent({
                            title: 'Success!!',
                            message: 'Successfully Updated the status to Reject .',
                            variant: 'Success',
                        });
                        this.dispatchEvent(showSuccess); 
                        this.executeBtnCalculation();
                        this.showPricingApprove = false; 
                        eval("$A.get('e.force:refreshView').fire();");
                        this.isLoaded = false;
                    }
                    this.error = undefined;
                } else {
                    this.error = 'You dont have permission to raise this Request.';
                    const showError = new ShowToastEvent({
                        title: 'Error!!',
                        message: this.error,
                        variant: 'error',
                    });
                    this.dispatchEvent(showError);
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                this.isLoaded = false;
                this.error = JSON.stringify(error);
                console.log('error ' + JSON.stringify(error));
                const showError = new ShowToastEvent({
                    title: 'Error >>',
                    message: this.error.body,
                    variant: 'error',
                });
                this.dispatchEvent(showError);
            });
    }
    // Rate Review
    captureRateReviewDetailFn() {
        console.log('capture');
        this.captureRateReviewComments=true;
    }
    requestRateReviewCancel() {
        this.captureRateReviewComments=false;
    }
   
    requestRateReview(event) {
       //handle Rate Review
    }
    handleRateReview() {
        this.isLoaded = true;
        this.captureRateReviewComments=false;
        requestRateReview({
            OpportunityId: this.recordId               
            }).then(response => {
                if (response) {                    
                    if (response !== null) {
                        const showSuccess = new ShowToastEvent({
                            title: 'Success!!',
                            message: 'Successfully Raised Rate Review Request.',
                            variant: 'Success',
                        });
                        this.dispatchEvent(showSuccess); 
                        this.executeBtnCalculation();
                        eval("$A.get('e.force:refreshView').fire();");
                        this.isLoaded = false;
                    }
                    this.error = undefined;
                } else {
                    this.error = 'You dont have permission to raise this Request.';
                    const showError = new ShowToastEvent({
                        title: 'Error!!',
                        message: this.error,
                        variant: 'error',
                    });
                    this.dispatchEvent(showError);
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                this.isLoaded = false;
                this.error = JSON.stringify(error);
                console.log('error ' + JSON.stringify(error));
                const showError = new ShowToastEvent({
                    title: 'Error >>',
                    message: this.error.body,
                    variant: 'error',
                });
                this.dispatchEvent(showError);
            });
    }
    updateMoreInfoProvided(){
        this.isLoaded = true; 
        statusMoreInfoProvided({
            oppId: this.recordId               
            }).then(response => {
                if (response) {                    
                    if (response !== null) {
                        const showSuccess = new ShowToastEvent({
                            title: 'Success!!',
                            message: 'Successfully sent message to Pricing Team about Information Provided.',
                            variant: 'Success',
                        });
                        this.dispatchEvent(showSuccess); 
                        this.executeBtnCalculation(); 
                        eval("$A.get('e.force:refreshView').fire();");
                        this.isLoaded = false;
                    }
                    this.error = undefined;
                } else {
                    this.error = 'You dont have permission to raise this Request.';
                    const showError = new ShowToastEvent({
                        title: 'Error!!',
                        message: this.error,
                        variant: 'error',
                    });
                    this.dispatchEvent(showError);
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                this.isLoaded = false;
                this.error = JSON.stringify(error); 
                console.log('error ' + JSON.stringify(error));
                const showError = new ShowToastEvent({
                    title: 'Error >>',
                    message: this.error.body,
                    variant: 'error',
                });
                this.dispatchEvent(showError);
            }); 
    }
    getContactAndRelatedContact(){
        this.toggleSpinner=true;         
        getRelatedContact({
            AccId: this.oppObj.opp.Account.Id               
            }).then(response => {
                if (response) {                     
                    if (response !== null) {
                      
                        this.ConArray=response;
                        this.toggleSpinner=false;  
                    }
                   
                } else {
                    this.toggleSpinner=false; 
                }
            })
            .catch(error => {
                this.toggleSpinner=false; 
                this.error = JSON.stringify(error);
                console.log('error ' + JSON.stringify(error));
                const showError = new ShowToastEvent({
                    title: 'Error',
                    message: this.error.body,
                    variant: 'error',
                });
                this.dispatchEvent(showError);
            })
    }
    ConchangeHandler(event) {
        
        if(event.target.value){
            this.toggleSpinner=true; 
            this.pmntAsine=event.target.value; 
            savePaymntAssignee({
                ConId: event.target.value,
                OppId:this.recordId
                }).then(response => {
                    if (response) {                     
                        if (response !== null) {
                            this.toggleSpinner=false;
                            this.selectedContact=response;
                            this.ToggleContactDetail=true;
                            //alert(JSON.stringify(response));
                            if(!response.Phone){
                                
                                this.ToggleContactDetail=false;
                                const event = new ShowToastEvent({
                                    "title": "Success!",
                                    "message": "Phone is Blank on selected contact See it {1}!",
                                    "variant": 'error',
                                    "messageData": [
                                        'Salesforce',
                                        {
                                            url: `/ ${response.Id}/`,
                                            label: 'here'
                                        }
                                    ]
                                });
                                this.dispatchEvent(event);
                            }

                            if(!response.Email){
                                this.ToggleContactDetail=false;
                                const event = new ShowToastEvent({
                                    "title": "Success!",
                                    "message": "Email is Blank on selected contact See it {1}!",
                                    "variant": 'error',
                                    "messageData": [
                                        'Salesforce',
                                        {
                                            url: `/ ${response.Id}/`,
                                            label: 'here'
                                        }
                                    ]
                                });
                                this.dispatchEvent(event);
                            }
                            
                        }
                       
                    } else {
                        this.toggleSpinner=false;
                    }
                })
                .catch(error => {
                    this.toggleSpinner=false;
                    this.ToggleContactDetail=false;
                    this.error = JSON.stringify(error);
    
                    console.log('error ' + JSON.stringify(error));
                    const showError = new ShowToastEvent({
                        title: 'Error >>',
                        message: this.error.body,
                        variant: 'error',
                    });
                    this.dispatchEvent(showError);
                })
        }
        else{
            //alert("please select the value");
            this.pmntAsine='';
            this.selectedContact='';
            this.ToggleContactDetail=false;
            const showError = new ShowToastEvent({
                title: 'Error',
                message: 'please select the value',
                variant: 'error',
            });
            this.dispatchEvent(showError);
        }
    }
}