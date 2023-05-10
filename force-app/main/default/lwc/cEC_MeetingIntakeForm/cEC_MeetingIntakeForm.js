import { LightningElement,api,track,wire } from 'lwc';
//import getResults from '@salesforce/apex/lwcMultiLookupController.getResults';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord } from "lightning/uiRecordApi";
import { getRecord } from 'lightning/uiRecordApi';
import pickListValueDynamically from '@salesforce/apex/cECGetPickListValueController.pickListValueDynamically';
import launchCECFLow from '@salesforce/apex/cECGetPickListValueController.start';
import { NavigationMixin } from 'lightning/navigation'; 
import TRAILHEAD_LOGO from '@salesforce/resourceUrl/CEC_Image';
import CEC_OBJECT from "@salesforce/schema/CEC__c";
import CEC_Attendees_OBJECT from "@salesforce/schema/CEC_Attendees__c";
import CECWelcomeMessage from '@salesforce/label/c.CECWelcomeMessage';
import Cecprogramguideurl from '@salesforce/label/c.Cecprogramguideurl';
//import moreinfoWelcomemessage from '@salesforce/label/c.moreinfoWelcomemessage';
const FIELDS = [
    'Opportunity.Name',
   
];
export default class Lwc_QuickAction extends NavigationMixin(LightningElement) {

		trailheadLogoUrl = TRAILHEAD_LOGO;
		label = {
				CECWelcomeMessage,
				Cecprogramguideurl,
				//moreinfoWelcomemessage
		};
		//Sushant starts
		@api recordId;
		@api objectApiName;
		@track selectedContactsToDisplay = ''; //to display items in comma-delimited way
		@track selectedContactsIdsToDisplay = ''; //to display items Ids in comma-delimited way
		@api selectedContactsEleToDisplay = [];
		//@api selectedLeadsEleToDisplay = []; commented as part of eba-sf-1791
		@api selectedUsersEleToDisplay = [];
		@api selectedOppsEleToDisplay = [];
		//@track selectedLeadsToDisplay = ''; //to display items in comma-delimited way    commented as part of eba-sf-1791
		//@track selectedLeadsIdsToDisplay = ''; //to display items Ids in comma-delimited way   commented as part of eba-sf-1791
		@track selectedUsersToDisplay = ''; //to display items in comma-delimited way
		@track selectedUsersIdsToDisplay = ''; //to display items Ids in comma-delimited way
		@track selectedOppsToDisplay = ''; //to display items in comma-delimited way
		@track selectedOppsIdsToDisplay = ''; //to display items Ids in comma-delimited way
		@track elements=''; //to display all item details in comma-delimited way
		@track values = []; //stores the labels in this array
		@track ItemIds = []; //stores the ids in this array
		@track isItemExists = false; //flag to check if message can be displayed
		loaded = false;
		@api cECRecord ={};
		@track cECId='';
		@api oppId='';
		@track attendeepicklistVal;
		@track isContactVisible = false;
		@track isLeadVisible = false;
		@track isInternalVisible = false;
		@track isExternalVisible = false;	
		@track isUserNotInSfVisibility = false;	//EBA_SF-1792 
		@track isOppVisible = false;
		@track isAccVisible = false;
		keyIndex = 0;
		@api itemList = [{
				id: 0,
				Attendee_Name_External__c:"",
				Role__c:"",
			    Email__c:""
			}];

			addRow() {
			  ++this.keyIndex;
			  var newItem = [{ id: this.keyIndex}];
		      this.itemList = this.itemList.concat(newItem);
		}

		removeRow(event) {
				if (this.itemList.length >= 2) {
						this.itemList = this.itemList.filter(function (element) {
								return parseInt(element.id) !== parseInt(event.target.accessKey);
						});
				}
				--this.keyIndex;
		}
		
		//EBA_SF-1792
		keyIndexUser = 0;
		@api itemListUser = [{
				id: 0,
				Non_Sf_NCR__c:"",
				Role__c:"",
			    Email__c:""
			}];

			addRowUser() {
			  ++this.keyIndexUser;
			  var newItem = [{ id: this.keyIndexUser}];
		      this.itemListUser = this.itemListUser.concat(newItem);
		}

		removeRowUser(event) {
				if (this.itemListUser.length >= 2) {
						this.itemListUser = this.itemListUser.filter(function (element) {
								return parseInt(element.id) !== parseInt(event.target.accessKey);
						});
				}
				--this.keyIndexUser;
		}

		selectOptionAttendeeValue(event){
				this.attendeepicklistVal = event.target.value;
				if(event.target.value == 1){
						this.isContactVisible = true;

				}
				if(event.target.value == 2){
						this.isLeadVisible = true;

				}
				if(event.target.value == 3){
						this.isInternalVisible = true;
				}
				if(event.target.value == 4){
						this.isExternalVisible = true;
				}
				//added as part of story eba_sf -1792
				if(event.target.value == 7){
						this.isUserNotInSfVisibility = true;
				}
				if(event.target.value == 6){
				}
		}
		get attPickVal(){
				return this.attendeepicklistVal;
		}
@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        Opportunity;
		@track picklistVal;
		@track saleslookUpValue;
		@track rVPLookUp;
		@track cUSLookUpValue;
		@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'Meeting_Purpose__c'}) selectTargetValues;
		//eba_sf-1715
		/*@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'Meeting_Type__c'}) typeTargetValues;*/
		@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'Meeting_Reason__c'}) reasonTargetValues;
		@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'RVP_Aware__c'}) rVPTargetValues;
		@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'Visited_NCR_CEC_Location__c'}) VLocTargetValues;
		@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'RFP_Affiliation__c'}) rPFTargetValues;
		@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'Customer_Relationship__c'}) cusRelationTargetValues;
		@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'Experience_Center__c'}) ExpTargetValues;
		@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'Temperature__c'}) tempTargetValues;
			@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'Customer_Time_Zone__c'}) cusTimeTargetValues;
		@wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'CEC__c'},
																		 selectPicklistApi: 'Ideal_Meeting_Duration__c'}) durationTargetValues;
		@track cusTimeZonePickValue;
		@track meetingPickVal;
		@track typeOfVisitPickListValue;
		//@track typeOfVisitPickListValue;   eba-sf-1715
		@track durationPickVal;  ///eba-sf 1715
		@track isDetailsVisible = false;  //EBA_SF- 1715 
		@track flagOpp=false;  //eba-sf 1715 
		@track meetingPurposeValue;   //eba-sf 1715		
		@track isRFPVisible;  ///eba-sf 1715
		@track flagRfp =false;  //eba-sf 1715
		@track rfpvalue = 'abcd';   //eba-sf 1715
		@track islastVisit;   //eba-sf 1715
		@track flaglastVisit;   //eba-sf 1715
		@track lastVisitValue;   //eba-sf 1715
		@track accountVar=''; //eba-sf 1793  // to show the account name on last screen
		@track  tourBool = false; //eba-sf 1793 // this is for Tour Only checkbox
		@track reasonForPickListValue1;
		@track cusRelPickListValue;
		@track briefPickListValue;
		@track rvpAwarePickListValue;
		@track visitPickListValue;
		@track experCenterValue;
		@track tempPickValue;
		@track accVal;
		 @track chareBackManagerValue;
		selectOptionChanveValue(event){       
				this.picklistVal = event.target.value;
		}

		get ValidateContactVisibility() { return (this.isContactVisible || this.selectedContactsIdsToDisplay !='');}
		//get ValidateLeadVisibility() { return (this.isLeadVisible || this.selectedLeadsIdsToDisplay !='');}   commented as part of eba-sf-1791
		get ValidateUserVisibility() { return (this.isInternalVisible || this.selectedUsersIdsToDisplay !='');}
		//EBA_SF-1792 Added for the Internal Attendee Not in Salesforce
		get ValidateUserNotInSfVisibility() { 
				return (this.isUserNotInSfVisibility || this.itemListUser[0].Non_Sf_NCR__c !=''
			|| this.itemListUser[0].Role__c !='' || this.itemListUser[0].Email__c !='');
		}
		get ValidateExtUserVisibility() { 
			return (this.isExternalVisible || this.itemList[0].Attendee_Name_External__c !=''
			|| this.itemList[0].Role__c !='' || this.itemList[0].Email__c !='');
		}
		
		
		//EBA_SF - 1792
		handleChange3(event){
				
				if(event.target.name=='Non_Sf_NCR__c'){
						this.itemListUser[this.keyIndexUser].Non_Sf_NCR__c = event.target.value;
				}
				if(event.target.name=='Role__c'){
						this.itemListUser[this.keyIndexUser].Role__c = event.target.value;
				}
				if(event.target.name=='Email__c'){
						this.itemListUser[this.keyIndexUser].Email__c = event.target.value;
				}
		}

		handleChange2(event){
				
				if(event.target.name=='Attendee_Name_External__c'){
						this.itemList[this.keyIndex].Attendee_Name_External__c = event.target.value;
				}
				if(event.target.name=='Role__c'){
						this.itemList[this.keyIndex].Role__c = event.target.value;
				}
				if(event.target.name=='Email__c'){
						this.itemList[this.keyIndex].Email__c = event.target.value;
				}
		}

		handleChange1(event) {
				if(this.objectApiName =='Account'){
						this.isAccVisible =true;
				}else{
						this.isOppVisible=true;
						this.oppId=this.recordId;
				}
				this.cECRecord[event.target.name] = event.target.value;

				if(event.target.name=='Account_Name__c'){
						this.accVal = event.target.value;;
				}
				if(event.target.name=='Chargeback_Manager_Name__c'){
						this.chareBackManagerValue = event.target.value;;
				}
				////eba-sf 1793 // this is for Tour Only checkbox
				if(event.target.name=='Tour_Only__c'){
						this.tourBool = event.target.checked;
						this.cECRecord.Tour_Only__c = this.tourBool;	
				}
				if(event.target.name=='Customer_Time_Zone__c'){
						this.cusTimeZonePickValue = event.target.value;;
				}
				if(event.target.name=='Experience_Center__c'){
						this.experCenterValue =event.target.value; 
						this.template.querySelector('.Atlanta').classList.remove('radioButtonCss');
						this.template.querySelector('.Belgrade').classList.remove('radioButtonCss'); 		 
						this.template.querySelector('.Dundee').classList.remove('radioButtonCss');
						this.template.querySelector('.Virtual').classList.remove('radioButtonCss');
				}
				if(event.target.name=='Temperature__c'){
						this.tempPickValue =event.target.value;
						this.template.querySelector('.Red').classList.remove('tempButtonCss');
						this.template.querySelector('.Yellow').classList.remove('tempButtonCss'); 		 
						this.template.querySelector('.Green').classList.remove('tempButtonCss');
				}
				//eba-sf 1715
					if(event.target.name=='Ideal_Meeting_Duration__c'){
						this.durationPickVal =event.target.value;
							//alert(this.durationPickVal);
				}
				/*if(event.target.name=='Meeting_Purpose__c'){
						this.meetingPickVal =event.target.value;
				}*/
				
				if(event.target.name=='Meeting_Purpose__c'){
						this.meetingPickVal =event.target.value;
						//alert(this.meetingPickVal);
						if(event.target.value == 'Other'){
								this.flagOpp =true;
						}
						else{							
								this.flagOpp =false;
						}
			 	}
			//	alert(this.flagOpp);
				if(this.flagOpp==true){
						this.isDetailsVisible = true
						if(event.target.name=='Meeting_Purpose_Other__c'){
								this.meetingPurposeValue =event.target.value;
						}
				}
				else{
						this.meetingPurposeValue =null;
						this.isDetailsVisible = false;
				}
				
				/*  eba-sf-1715
				if(event.target.name=='Meeting_Type__c'){
						this.typeOfVisitPickListValue =event.target.value;
				}*/
				if(event.target.name=='Meeting_Reason__c'){
						this.reasonForPickListValue1 =event.target.value;
				}
				if(event.target.name=='Customer_Relationship__c'){
						this.cusRelPickListValue =event.target.value;
				}
				//eba-sf-1715
				/*if(event.target.name=='RFP_Affiliation__c'){
						this.briefPickListValue =event.target.value;
				}*/
				if(event.target.name=='RFP_Affiliation__c'){
						this.briefPickListValue =event.target.value;
						if(event.target.value == 'Yes'){
								this.flagRfp =true;
						}
						else{							
								this.flagRfp =false;
						}
			 	}
				if(this.flagRfp==true){
						this.isRFPVisible = true
						if(event.target.name=='RFP_Name__c'){
								this.rfpvalue =event.target.value;
						}
				}
				else{
						this.rfpvalue =null;
						this.isRFPVisible = false;
				}
				
				if(event.target.name=='RVP_Aware__c'){
						this.rvpAwarePickListValue =event.target.value;
				}
				/*eba-sf 1715
				/*if(event.target.name=='Visited_NCR_CEC_Location__c'){
						this.visitPickListValue =event.target.value;
				}*/
				if(event.target.name=='Visited_NCR_CEC_Location__c'){
						this.visitPickListValue =event.target.value;
						if(event.target.value == 'Yes'){
								this.flaglastVisit =true;
						}
						else{							
								this.flaglastVisit =false;
						}
			 	}
				if(this.flaglastVisit==true){
						this.islastVisit = true
						if(event.target.name=='When_last_visit__c'){
								this.lastVisitValue =event.target.value;
						}
				}
				else{
						this.lastVisitValue =null;
						this.islastVisit = false;
				}
				
				if(event.target.name=='Sales_Leader_Name__c'){
						this.saleslookUpValue =event.target.value;
				}
				if(event.target.name=='RVP_Name__c'){
						this.rVPLookUp =event.target.value;
				}
				if(event.target.name=='Customer_Competitors__c'){
						this.cUSLookUpValue =event.target.value;
				}
		}
		get Oppname() {
        return this.Opportunity.data.fields.Name.value;
    }
		get ExpCentPickVal(){
				return this.experCenterValue;
		}
		get chareBackManager(){
				return this.chareBackManagerValue;
		}
			get cusTimeZonePickVal(){
				return this.cusTimeZonePickValue;
		}
		get durationPickList(){  //eba-sf 1715	
				return this.durationPickVal;	
		}
		get meetIngPickList(){
				return this.meetingPickVal;
		}
		get tempPickVal(){
				return this.tempPickValue;
		}
		get reasonForPickList(){
				return this.reasonForPickListValue1;
		}
		//eba_sf-1715
		/*get typeOfVisitPickList(){
				return this.typeOfVisitPickListValue;
		}*/
			get meetingPurpose(){
				return this.meetingPurposeValue;
		}
		get rfpName(){
				return this.rfpvalue;
		}
		get lastVisit(){
			  return this.lastVisitValue;
		}
		get cusRelPickList(){
				return this.cusRelPickListValue;
		}
		get briefPickList(){
				return this.briefPickListValue;
		}
		get rvpAwarePickList(){
				return this.rvpAwarePickListValue;
		}
		get visitPickList(){
				return this.visitPickListValue;
		}
		get SalesLookUp(){
				return this.saleslookUpValue;
		}
		get rVPLookUp(){
				return this.rVPLookUp;
		}
		get cUSLookUp(){
				return this.cUSLookUpValue;
		}
		@track isfirstPage1 = true;
		@track isfirstPage=false;
		@track isAttendeePage;
		@track isMeetingPage;
		@track isVisible = false;
		@track isFinalPage;
		@track isReasonPage =false;
		firstPageCEC(){
				this.isfirstPage = true;
				this.isfirstPage1=false;	
		}
		gotoFirstPage(event){
			    event.preventDefault();
				this.isMeetingDates = true;
				this.isReasonPage=false;
				this.cECRecord.Tour_Only__c = this.tourBool; //eba-sf 1793

				if(this.experCenterValue == 'Atlanta' && this.isfirstPage){
					setTimeout(() => {
						this.template.querySelector('.Atlanta').classList.add('radioButtonCss'); 		 
					}, 1000);
				}

				if(this.experCenterValue == 'Belgrade' && this.isfirstPage){
					setTimeout(() => {
						this.template.querySelector('.Belgrade').classList.add('radioButtonCss'); 		 
					}, 1000);
				}

				if(this.experCenterValue == 'Dundee' && this.isfirstPage){
					setTimeout(() => {
						this.template.querySelector('.Dundee').classList.add('radioButtonCss'); 		 
					}, 1000);
				}

				if(this.experCenterValue == 'Virtual' && this.isfirstPage){
					setTimeout(() => {
						this.template.querySelector('.Virtual').classList.add('radioButtonCss'); 		 
					}, 1000);
				}

		}
		gotoDatesPage(){
				this.isMeetingDates=true;
				this.isAttendeePage=false;
		}

		gotoAttendees(){
			this.isMeetingDates=false;
			this.isAttendeePage=true;
	}

		gotoReasonPage(event){
				let isflag = false;
				let fieldErrorMsg="Please Enter The";
					this.template.querySelectorAll('.validate').forEach(element => {
						let fieldValue1 = element.value;
						element.reportValidity();
						if(!fieldValue1){
								isflag =true;
						}
				});


				this.template.querySelectorAll('lightning-input-field').forEach(element => {
						let fieldValue1 = element.value;
						element.reportValidity();
						if(!fieldValue1){
							isflag =true;
						}
				});

				this.template.querySelectorAll("lightning-textarea").forEach(item => {
						let fieldValue=item.value;
						let fieldLabel=item.label;  
						if(!fieldValue && fieldLabel!='If yes, what is the name of the RFP?' && fieldLabel!='Special notes/requests' && fieldLabel!='When/where was last visit to an NCR CEC?' && fieldLabel!='Presenters already secured?' && fieldLabel!='Special requests for personalization?' && fieldLabel!='Name of company for meeting materials'){
							item.setCustomValidity(fieldErrorMsg+' '+fieldLabel);
							isflag =true;
						}
						else{

							item.setCustomValidity("");
						}
						item.reportValidity();
				});
				
				/*let fieldErrorMsgpick="Please Select The Value";
				this.template.querySelectorAll("select").forEach(item => {
						let fieldValue=item.value;
						let fieldLabel=item.label;            
						if(!fieldValue){
							item.setCustomValidity(fieldErrorMsgpick);
							isflag =true;
						}
						else{

							item.setCustomValidity("");
						}
						item.reportValidity();
				});*/
				
				
        //2357
				/*if(!isflag){
						this.isAttendeePage=true;
						this.isReasonPage=false;
						this. isContactVisible = false;
						this.isLeadVisible = false;
						this.isInternalVisible = false;
						this.isExternalVisible = false;
						this.isUserNotInSfVisibility = false;
				}*/
				
				
				//2357
				if(isflag==false){
						this.loaded = true;
						launchCECFLow({              
										OApiName : this.objectApiName,
										rId : this.recordId,										
										cecRecordData: this.cECRecord,
										ContactIds: this.selectedContactsIdsToDisplay, 
										//LeadIds: this.selectedLeadsIdsToDisplay, commented as part of eba-sf-1791
										UserIds: this.selectedUsersIdsToDisplay,
										OppIds: this.selectedOppsIdsToDisplay,
								    UserNotInSF: this.itemListUser,  // EBA_SF-1792
										ExtUserList: this.itemList  })
								.then(data => {
						        this.cECId= data.Id;	
								    this.accountVar =data.Account_Name__r.Name;  //eba-sf-1793
							    this.loaded = false;
								this.error = null;
								/*this.dispatchEvent(
									new ShowToastEvent({
											title: "Success",
											message: "CEC Meeting created successfully!",
											variant: "success"
									})
							);*/

								this.isFinalPage=true;
								this.isReasonPage=false;
						})
								.catch(error => {
							
							    this.loaded = false;
							    let errorMessage='';
								this.error = error;
								console.error('@@Error: '+JSON.stringify(this.error ));
							//	alert('this.error.body.message'+this.error);
								if(this.error.body.message!='' && this.error.body.message!=undefined){
									//	alert('this.error.body.message'+this.error.body.message);
									errorMessage=this.error.body.message;
								}
								

								else if(this.error.body.pageErrors[0].message !='' && this.error.body.pageErrors[0].message !=undefined){
									errorMessage=this.error.body.pageErrors[0].message;	
										//alert('this.error.body.message'+errorMessage);
								}

								else {
									errorMessage='Something Went Wrong.Please Contact Salesforce Admin Team..';
								
								}
								console.log('flowError: '+JSON.stringify(this.error));
								this.dispatchEvent(
									new ShowToastEvent({
											title: "Error While Creating CEC Meeting Record: ",
											message: JSON.stringify(errorMessage),
											variant: "error"
									})
							);
						})
						.finally(() => {
							this.loaded = false;
							this.isLoading = false;
					});
		}
				
				
				
				
				
				
				
				
				


		}
		gotoAttendeePage(event){
				event.preventDefault();
				const fields = this.cECRecord;
				let isflag = false;
				const recordInput = { apiName: CEC_OBJECT.objectApiName, fields };
				this.template.querySelectorAll('lightning-input-field').forEach(element => {
						let fieldValue1 = element.value;
						element.reportValidity();
						if(!fieldValue1){
								isflag =true;
						}
				});

				let fieldErrorMsg="Please Select The Value";
				this.template.querySelectorAll("select").forEach(item => {
						let fieldValue=item.value;
						let fieldLabel=item.label;            
						if(!fieldValue){
								item.setCustomValidity(fieldErrorMsg);
								isflag =true;
						}
						else{

								item.setCustomValidity("");
						}
						item.reportValidity();
				});

				if(!isflag){
						this.isReasonPage = False;
						this.isMeetingPage=false;	
				}

		}
		closeAction(){
				this.dispatchEvent(new CloseActionScreenEvent());
		}
		handleNavigate(event) {
				event.preventDefault();
				let isflag = false;
				const fields = this.cECRecord;

				const recordInput = { apiName: CEC_OBJECT.objectApiName, fields };
				if(this.experCenterValue == undefined){
						isflag =true;
						this.dispatchEvent(
								new ShowToastEvent({
										title: "Error",
										message: "Please Select Experience Center!",
										variant: "error"
								})
						);
				}
				/*if(this.tempPickValue == undefined){
						isflag =true;
						this.dispatchEvent(
								new ShowToastEvent({
										title: "Error",
										message: "Please Select Temperature!",
										variant: "error"
								})
						);
				}*/
				let fieldErrorMsg="Please Enter The";
				this.template.querySelectorAll('.validate').forEach(element => {
						let fieldValue1 = element.value;
						element.reportValidity();
						if(!fieldValue1){
								isflag =true;
						}
				});

				this.template.querySelectorAll("lightning-textarea").forEach(item => {
						let fieldValue=item.value;
						let fieldLabel=item.label;  
						if(!fieldValue && fieldLabel!='Customer Strategic Priorities'){
								item.setCustomValidity(fieldErrorMsg+' '+fieldLabel);
								isflag =true;
						}
						else{

								item.setCustomValidity("");
						}
						item.reportValidity();
						
				});
				let fieldErrorMsgpick="Please Select the value";
				this.template.querySelectorAll("select").forEach(item => {
						let fieldValue=item.value;
						let fieldLabel=item.label;            
						if(!fieldValue){
								item.setCustomValidity(fieldErrorMsgpick);
								isflag =true;
						}
						else{

								item.setCustomValidity("");
						}
						item.reportValidity();
				});

				if(!isflag){
						this.isfirstPage = false;
						this.isAttendeePage=true;
						this. isContactVisible = false;
						this.isLeadVisible = false;
						this.isInternalVisible = false;
						this.isExternalVisible = false;
						this.isUserNotInSfVisibility = false;
						//Set Temperature Value
						//commentes as part of story 2356
				/*if(this.tempPickValue == 'Red' && this.isReasonPage){

					setTimeout(() => { 
						this.template.querySelector('.Red').classList.add('tempButtonCss');
						
					}, 1000);
				}

				if(this.tempPickValue == 'Yellow' && this.isReasonPage){
					
					setTimeout(() => { 
						this.template.querySelector('.Yellow').classList.add('tempButtonCss');
						
					}, 1000);
				}

				if(this.tempPickValue == 'Green' && this.isReasonPage){
					
					setTimeout(() => { 
						this.template.querySelector('.Green').classList.add('tempButtonCss');
						
					}, 1000);
				}*/
				}




		}
		handleChange(event){
				this.isVisible = event.target.checked;
		}
/*
		gotoSubmitPage(event){
				event.preventDefault();
				const fields = this.cECRecord;

				const recordInput = { apiName: CEC_OBJECT.objectApiName, fields };
				createRecord(recordInput)
						.then((CEC__C) => {
						this.dispatchEvent(
								new ShowToastEvent({
										title: "Success",
										message: "CEC Meeting created successfully!",
										variant: "success"
								})
						);

						this.cECRecord = {};
						this.launchSubmitMethod();
						this.isFinalPage=true;
						this.isMeetingDates=false;
				})
						.catch((error) => {
						this.dispatchEvent(
								new ShowToastEvent({
										title: "Error creating record",
										message: "Error",
										variant: "error"
								})
						);
				})
						.finally(() => {
						this.isLoading = false;
				});

		} */
		gotoMeetPage(event){
				event.preventDefault();
				this.isAttendeePage=false;
				this.isfirstPage=true;
				
				
				
				//2356
				this.cECRecord.Tour_Only__c = this.tourBool; //eba-sf 1793

				if(this.experCenterValue == 'Atlanta' && this.isfirstPage){
					setTimeout(() => {
						this.template.querySelector('.Atlanta').classList.add('radioButtonCss'); 		 
					}, 1000);
				}

				if(this.experCenterValue == 'Belgrade' && this.isfirstPage){
					setTimeout(() => {
						this.template.querySelector('.Belgrade').classList.add('radioButtonCss'); 		 
					}, 1000);
				}

				if(this.experCenterValue == 'Dundee' && this.isfirstPage){
					setTimeout(() => {
						this.template.querySelector('.Dundee').classList.add('radioButtonCss'); 		 
					}, 1000);
				}

				if(this.experCenterValue == 'Virtual' && this.isfirstPage){
					setTimeout(() => {
						this.template.querySelector('.Virtual').classList.add('radioButtonCss'); 		 
					}, 1000);
				}
				
				
				
				
				
				
				
				
				
				//Set Temperature Value
				//commented as part of story - 2356
				/*if(this.tempPickValue == 'Red' && this.isReasonPage){

					setTimeout(() => { 
						this.template.querySelector('.Red').classList.add('tempButtonCss');
						
					}, 1000);
				}

				if(this.tempPickValue == 'Yellow' && this.isReasonPage){
					
					setTimeout(() => { 
						this.template.querySelector('.Yellow').classList.add('tempButtonCss');
						
					}, 1000);
				}

				if(this.tempPickValue == 'Green' && this.isReasonPage){
					
					setTimeout(() => { 
						this.template.querySelector('.Green').classList.add('tempButtonCss');
						
					}, 1000);
				}*/

		}

		//captures the retrieve event propagated from lookup component
		selectedContactsEventHandler(event){
				let args = JSON.parse(JSON.stringify(event.detail.arrItems));
				//let contactArgs = event.detail.arrItems;

				this.displayContacts(args); 
				this.cecRecord;
		}

		//captures the remove event propagated from lookup component
		deleteContactsEventHandler(event){
				let args = JSON.parse(JSON.stringify(event.detail.arrItems));
				this.displayContacts(args);
		}

		selectedLeadsEventHandler(event){
				let args = JSON.parse(JSON.stringify(event.detail.arrItems));
				this.displayLeads(args); 
				this.cecRecord;
		}

		//captures the remove event propagated from lookup component
		deleteLeadsEventHandler(event){
				let args = JSON.parse(JSON.stringify(event.detail.arrItems));
				this.displayLeads(args);
		}

		selectedUsersEventHandler(event){
				let args = JSON.parse(JSON.stringify(event.detail.arrItems));
				this.displayUsers(args); 
				this.cecRecord;
		}

		//captures the remove event propagated from lookup component
		deleteUsersEventHandler(event){
				let args = JSON.parse(JSON.stringify(event.detail.arrItems));
				this.displayUsers(args);
		}

		selectedOppsEventHandler(event){
				let args = JSON.parse(JSON.stringify(event.detail.arrItems));
				this.displayOpps(args); 
				this.cecRecord;

		}

		//captures the remove event propagated from lookup component
		deleteOppsEventHandler(event){
				let args = JSON.parse(JSON.stringify(event.detail.arrItems));
				this.displayOpps(args);
		}


		//displays the items in comma-delimited way
		displayContacts(args){
				this.values = []; //initialize first
				this.ItemIds=[];
				this.elements=[];
				args.map(element=>{
						console.log('element: ',element);
						this.elements.push(element);
						this.values.push(element.label);
						this.ItemIds.push(element.value);
				});

				this.isItemExists = (args.length>0);
				this.selectedContactsToDisplay = this.values.join(', ');
				this.selectedContactsIdsToDisplay=this.ItemIds;
				this.selectedContactsEleToDisplay=this.elements;
		}

		/* commented as part of eba-sf-1791
		//displays the items in comma-delimited way
		displayLeads(args){
				this.values = []; //initialize first
				this.ItemIds=[];
				this.elements=[];
				args.map(element=>{
						console.log('element: ',element);
						this.elements.push(element);
						this.values.push(element.label);
						this.ItemIds.push(element.value);
				});

				this.isItemExists = (args.length>0);
				this.selectedLeadsToDisplay = this.values.join(', ');
				this.selectedLeadsIdsToDisplay=this.ItemIds;
				this.selectedLeadsEleToDisplay=this.elements;

		}*/

		//displays the items in comma-delimited way
		displayUsers(args){
				this.values = []; //initialize first
				this.ItemIds=[];
				this.elements=[];
				args.map(element=>{
						console.log('element: ',element);
						this.elements.push(element);
						this.values.push(element.label);
						this.ItemIds.push(element.value);
				});

				this.isItemExists = (args.length>0);
				this.selectedUsersToDisplay = this.values.join(', ');
				this.selectedUsersIdsToDisplay=this.ItemIds;
				this.selectedUsersEleToDisplay=this.elements;

		}


		//displays the items in comma-delimited way
		displayOpps(args){
				this.values = []; //initialize first
				this.ItemIds=[];
				this.elements=[];

				args.map(element=>{
						console.log('element: ',element);
						this.elements.push(element);
						this.values.push(element.label);
						this.ItemIds.push(element.value);
				});

				this.isItemExists = (args.length>0);
				this.selectedOppsToDisplay = this.values.join(', ');
				this.selectedOppsIdsToDisplay=this.ItemIds;
				this.selectedOppsEleToDisplay=this.elements;

		}

		// call CEC Flow	
				
		launchSubmitMethod(){
			if(this.objectApiName =='Opportunity' && this.selectedOppsIdsToDisplay.length === 0){
				this.selectedOppsIdsToDisplay=this.recordId;
			}	
		  	//this.loaded = true;
				let isflag = false;   // EBA_SF-1792
				const fieldAtts = this.itemList;
				const fieldAttsUser = this.itemListUser; // EBA_SF-1792
				let fieldErrorMsg="Please enter the value";   // EBA_SF-1792
				this.template.querySelectorAll(".validate").forEach(item => {
						let fieldValue=item.value;
						let fieldLabel=item.label;  
						if(!fieldValue){
								item.setCustomValidity(fieldErrorMsg);
								isflag =true;
						}
						else{

								item.setCustomValidity("");
						}
						item.reportValidity();
					
				});
				
				
				const recordInputAtt = { apiName: CEC_Attendees_OBJECT.objectApiName, fieldAtts };
				/* 2356if(isflag==false){
						this.loaded = true;
						launchCECFLow({              
										OApiName : this.objectApiName,
										rId : this.recordId,										
										cecRecordData: this.cECRecord,
										ContactIds: this.selectedContactsIdsToDisplay, 
										//LeadIds: this.selectedLeadsIdsToDisplay, commented as part of eba-sf-1791
										UserIds: this.selectedUsersIdsToDisplay,
										OppIds: this.selectedOppsIdsToDisplay,
								    UserNotInSF: this.itemListUser,  // EBA_SF-1792
										ExtUserList: this.itemList  })
								.then(data => {
						        this.cECId= data.Id;	
								    this.accountVar =data.Account_Name__r.Name;  //eba-sf-1793
							    this.loaded = false;
								this.error = null;
								/*this.dispatchEvent(
									new ShowToastEvent({
											title: "Success",
											message: "CEC Meeting created successfully!",
											variant: "success"
									})
							);*/

								/* 2356this.isFinalPage=true;
								this.isMeetingDates=false;
						})
								.catch(error => {
							
							    this.loaded = false;
							    let errorMessage='';
								this.error = error;
								console.error('@@Error: '+JSON.stringify(this.error ));
							//	alert('this.error.body.message'+this.error);
								if(this.error.body.message!='' && this.error.body.message!=undefined){
									//	alert('this.error.body.message'+this.error.body.message);
									errorMessage=this.error.body.message;
								}
								

								else if(this.error.body.pageErrors[0].message !='' && this.error.body.pageErrors[0].message !=undefined){
									errorMessage=this.error.body.pageErrors[0].message;	
										//alert('this.error.body.message'+errorMessage);
								}

								else {
									errorMessage='Something Went Wrong.Please Contact Salesforce Admin Team..';
								
								}
								console.log('flowError: '+JSON.stringify(this.error));
								this.dispatchEvent(
									new ShowToastEvent({
											title: "Error While Creating CEC Meeting Record: ",
											message: JSON.stringify(errorMessage),
											variant: "error"
									})
							);
						})
						.finally(() => {
							this.loaded = false;
							this.isLoading = false;
					});
		}*/
				if(!isflag){
						this.isMeetingDates = false;
						this.isReasonPage=true;
						if(this.tempPickValue == 'Red' && this.isReasonPage){

					setTimeout(() => { 
						this.template.querySelector('.Red').classList.add('tempButtonCss');
						
					}, 1000);
				}

				if(this.tempPickValue == 'Yellow' && this.isReasonPage){
					
					setTimeout(() => { 
						this.template.querySelector('.Yellow').classList.add('tempButtonCss');
						
					}, 1000);
				}

				if(this.tempPickValue == 'Green' && this.isReasonPage){
					
					setTimeout(() => { 
						this.template.querySelector('.Green').classList.add('tempButtonCss');
						
					}, 1000);
				}
				}
						
				}
						

		redirectcecrecord(){
				this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.cECId,
                        objectApiName: 'CEC__c',
                        actionName: 'view'
                    },
                });	
		}
}