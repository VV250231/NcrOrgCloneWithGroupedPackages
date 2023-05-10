import { LightningElement, track, api, wire } from 'lwc';
import getRelatedContactData from '@salesforce/apex/ReportScheduleController.getRelatedContactData';
import getScheduleReportDetail from '@salesforce/apex/ReportScheduleController.getScheduleReportDetail';
import getReportDetails from '@salesforce/apex/ReportScheduleController.getReportDetails'; 
import validateReport from '@salesforce/apex/ReportScheduleController.validateReport'; 
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import Schedule_External_Report_Type from '@salesforce/label/c.Schedule_External_Report_Type';

export default class CustomReportScheduler extends LightningElement{
    @track frequencyValue;
    @track scheduleTime;
    @track frmtTime;
    @track startDate;
    @track endDate;
    @track strEndDate;
    @track strStartDate;
    @track selectedContactId = [];  /* Contains all selected contact id */
    isModalShown;  isModalShown2;
    @track modalMessage; @track modalMessage2;
    isLoading = false;
    @track contactMap = [];
    @track reportName;
    @api recordId;    /* contains current record id */
    showLookUp2 = false;
    showLookUp3 = false;
    disableAddBtn = false;
    disableRemoveBtn = true;
    @track error;
    @track name;
    @track selectedUser = USER_ID;
    @track report1 = '';
    @track report2 = '';
    @track report3 = '';
    emailRecipientIdList = [];
    scheduleId;     /* Contains schedule external report id */
    @track initialMap = [];  /* Contans Initial data when existing record updated */
    @track initialConId = []; /* Contans Initial contactId when existing record updated */
    @track deleteEmailRecipientId = []; /* Contains email recipient id needs to deleted*/
    @track report1Name=''; @track report2Name=''; @track report3Name='';
    @track objectMap = [];      /* Map to store all input and exisiting data */
    @track errorMap =new Map();
    @track additionalRecipientErrorMap = new Map();
    @track accountOwnerError = false;
    @track reportingFlterError = false;
    @track emailSubject='';
    @track emailBody='';
    nextbatchdate='';	
    endDateBatchTriggered = false;	
    initialEndDate ='';
    @track report1Validate = false;
    @track report2Validate = false;
    @track report3Validate = false;
    @track isMcnModalShown= false;
    @track mcnOptions =[];
    @track currentRowId=[];
    @track selectedMCNs =[] ;
    @track isFuaModalShown =false;
    @track selectedFUAs=[];
    @track fuaOptions =[];
    
      
   
    connectedCallback() {
        /* Setting Schedule Report Requested by field value on component load*/
        this.setUserOnLoad();
    }
 
    /* Fetching current user details using userId */
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
            console.log('wireuser error=='+JSON.stringify(error));
        } else if (data) {
            this.name = data.fields.Name.value;
        }
    }


    /* Fetching schedule report details for existing records */
    @wire(getScheduleReportDetail, { scheduleReportId: '$recordId' })
    wiredData({
        error,
        data
    }) {
        if (error) {
            this.error = error;
            console.log('getScheduleReportDetail error=='+JSON.stringify(error));
        } else if (data) {
            let result = data;
            this.scheduleId = result[0].Id
            this.reportName = result[0].Schedule_external_report_name__c;
            this.frequencyValue = result[0].Frequency__c;
            this.strStartDate = result[0].Start_Date__c;
            this.strEndDate = result[0].End_Date__c;
            var strDate = new Date(result[0].Start_Date__c);
            this.startDate = strDate.setDate(strDate.getDate()+1);
            var endDte = new Date(result[0].End_Date__c);
            this.endDate = endDte.setDate(endDte.getDate()+1);
            this.scheduleTime = this.msToTime(result[0].Schedule_Time__c);
            this.name = result[0].Schedule_report_requested_by__c != undefined ? result[0].Schedule_report_requested_by__r.Name : this.name;
            this.report1 = result[0].Report_1_Id__c;
            this.report2 = result[0].Report_2_Id__c;
            this.report3 = result[0].Report_3_Id__c;
            this.selectedUser =result[0].Schedule_report_requested_by__c;
            this.emailBody =result[0].Email_Body__c;
            this.emailSubject = result[0].Email_Subject__c;
            this.nextbatchdate = result[0].NextBatchDate__c;	
            this.endDateBatchTriggered =result[0].Is_Batch_Triggered_on_End_Date__c;	
            this.initialEndDate = result[0].End_Date__c;
            let multiLookUpItems = [];
            var scheduleObj = [];
            this.isLoading =true;
            if (result[0].Report_1_Id__c) {
                this.getReportDetail(result[0].Report_1_Id__c, 'report1Lookup');
                this.validateReport(result[0].Report_1_Id__c,'report1Lookup');
            }

            if (result[0].Report_2_Id__c) {
                this.showLookUp2 = true;
                this.disableRemoveBtn = false;
                this.disableAddBtn = false;
                this.getReportDetail(result[0].Report_2_Id__c, 'report2Lookup');
                this.validateReport(result[0].Report_2_Id__c,'report2Lookup');
            }

            if (result[0].Report_3_Id__c) {
                this.showLookUp2 = true;
                this.showLookUp3 = true;
                this.disableAddBtn = true;
                this.disableRemoveBtn = false;
                this.getReportDetail(result[0].Report_3_Id__c, 'report3Lookup');
                this.validateReport(result[0].Report_3_Id__c,'report3Lookup');
            }
            // Creating a map object
            var objMap = new Map();
            result[0].Email_Recipient__r.forEach(conObj => {
                this.emailRecipientIdList.push(conObj.Id);
                multiLookUpItems.push({
                    value: conObj.Contact__c,
                    label: conObj.Contact_Name__c + ' - ' + conObj.Email__c,

                })
                this.selectedContactId.push(conObj.Contact__c);
                this.initialConId.push(conObj.Contact__c);
                scheduleObj = ({
                    recordStatus: "Update",
                    recordEmailRecipientId: conObj.Id,
                    recordId: conObj.Contact__c,
                    recordName: conObj.Contact_Name__c,
                    recordEmail: conObj.Email__c,
                    recordDirectMCN: conObj.Direct_MCN__c,
                    recordIndirectMCN: conObj.Indirect_MCN__c,
                    recordReportingFilter: conObj.Reporting_Filter__c,
                    recordAdditinalRecipientType: conObj.Additional_Recipient_Type__c,
                    recordAdditionalRecipient1: conObj.Additional_Email_1__c,
                    recordAdditionalRecipient2: conObj.Additional_Email_2__c,
                    recordAdditionalRecipient3: conObj.Additional_Email_3__c,
                    recordAdditionalRecipient4: conObj.Additional_Email_4__c,
                    recordDirectFUA: conObj.Direct_FUA__c,
                    recordIndirectFUA: conObj.Indirect_FUA__c
                });
                objMap.set(conObj.Contact__c, scheduleObj);
            })
            this.initialMap = objMap;
            // Setting table values for step-2 and step-5
           // this.getRelatedContact(this.selectedContactId);

            // Setting value for contact multiselect lookup
            this.template.querySelector('c-custom-multi-select-lookup').setInitialItems(multiLookUpItems);
        }
    }

  /* Setting user lookup field */
    setUserOnLoad() {
        setTimeout(() => {
            this.template.querySelector('[data-id="userLookup"]').handleOnLoad(this.name);
        }, 1000);

    }

    /* Convert millisecond value to time format */
    msToTime(s) {
        let ms = s % 1000;
        s = (s - ms) / 1000;
        let secs = s % 60;
        s = (s - secs) / 60;
        let mins = s % 60;
        let hrs = (s - mins) / 60;
        hrs = hrs < 10 ? '0' + hrs : hrs;
        mins = mins < 10 ? '0' + mins : mins;
      //  console.log(hrs + '  ' + mins);
        return hrs + ':' + mins + ':00.000Z';
    }
  
    // Fetching report details using report id
    getReportDetail(reportId, reportLookup) {
        getReportDetails({ reportId: reportId })
            .then(result => {
                this.template.querySelector('[data-id="' + reportLookup + '"]').handleOnLoad(result.Name);
                if (reportLookup == 'report1Lookup') {
                  
                    this.report1Name = result.Name;
                }
                else if (reportLookup == 'report2Lookup') {
                    this.report2Name = result.Name;
                }
                else {
                    this.report3Name = result.Name;
                }
                
            })
            .catch(error => {
              
                console.log('getReportDetail Error ==' + JSON.stringify(error));
            })
    }

   // Validating Report type 
   validateReport(rptId,reportLookup){
        validateReport({reportId:rptId})
        .then(result=>{
          //  console.log('result=='+JSON.stringify(result));
            if(reportLookup=='report1Lookup'){
                this.report1Validate = result;
               }
           else if(reportLookup=='report2Lookup'){
            this.report2Validate = result;
           }
           else{
            this.report3Validate = result;
           }
          
           this.isLoading =false;
        })
        .catch(error=>{
            this.isLoading =false;
            console.log('validateReport Error ==' + JSON.stringify(error));
        })
    }

   /* Dropdown options for the select frequency field */
    get frqOptions() {
        return [
            { label: 'Daily', value: 'Daily' },
            { label: 'Weekly', value: 'Weekly' },
            { label: 'Monthly', value: 'Monthly' },
            { label: 'Quarterly', value: 'Quarterly' },
            { label: 'Yearly', value: 'Yearly' }
        ];
    }
  
     // Method will run when schedule external report record updated or created
     scheduleReport() {
        this.isLoading = true;
        if (this.recordId == undefined) {
            this.createScheduleJobs();
        }
        else {
            this.updateSchedule(this.scheduleId);
            this.createEmailRecipient(this.scheduleId);
            if (this.deleteEmailRecipientId.length > 0)
                this.deleteEmailRecipient();
        }
    }

    // Insert schedule external report record.
    createScheduleJobs() {
       // console.log('this.selectedUser=='+JSON.stringify(this.selectedUser));
       // console.log('USER_ID=='+JSON.stringify(USER_ID));
        // Creating mapping of fields of Schedule Report Job with values
        var fields = {
            Schedule_external_report_name__c: this.reportName, 'Frequency__c': this.frequencyValue, 'Start_Date__c': this.strStartDate, 'End_Date__c': this.strEndDate,
            'Schedule_Time__c': this.scheduleTime, 'Schedule_report_requested_by__c':this.getUserId(), 'Report_1_Id__c': this.report1,
            'Report_2_Id__c': this.report2, 'Report_3_Id__c': this.report3, 'Report_1_Name__c': this.report1Name, 'Report_2_Name__c': this.report2Name,
            'Report_3_Name__c': this.report3Name,'NextBatchDate__c':this.strStartDate, 'Email_Subject__c':this.emailSubject,'Email_Body__c':this.emailBody
        };
        // Record details to pass to create method with api name of Object.
        var objRecordInput = { 'apiName': 'Schedule_External_Report__c', fields };
        // LDS method to create record.
        createRecord(objRecordInput).then(response => {
            this.createEmailRecipient(response.id);

        })
            .catch(error => {
                console.log('createScheduleJobs error =='+JSON.stringify(error));
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

    getUserId(){
        if(this.selectedUser != null && this.selectedUser != undefined && this.selectedUser != ''){
            return this.selectedUser;
        }
        else{
          return USER_ID;
        }
    }
    // Insert email recipient record.
    createEmailRecipient(scheduleReportId) {
        var error1 = false;
        var email1; var email2; var email3; var email4;
        var contactMap = Array.from(this.objectMap.values());
        contactMap.forEach(conObj => {
            if (conObj.recordStatus == 'New') {
                if (conObj.recordAdditinalRecipientType == 'Account Owner') {
                    var emailIdList = conObj.recordAdditionalRecipient.split(', ');
                    if (emailIdList.length > 1) {
                        email1 = emailIdList[0] != undefined ? emailIdList[0] : '';
                        email2 = emailIdList[1] != undefined ? emailIdList[1] : '';
                        email3 = emailIdList[2] != undefined ? emailIdList[2] : '';
                        email4 = emailIdList[3] != undefined ? emailIdList[3] : '';
                    }
                    else {
                        email1 = emailIdList[0];
                    }
                }
                else {
                    email1 = conObj.recordAdditionalRecipient1;
                    email2 = conObj.recordAdditionalRecipient2;
                    email3 = conObj.recordAdditionalRecipient3;
                    email4 = conObj.recordAdditionalRecipient4;
                }
                console.log('conObj.filteredMCN=='+JSON.stringify(conObj.filteredMCN));
                // Creating mapping of fields for Email Recipient  with values
                var fields = {
                    'Contact__c': conObj.recordId,
                    'Contact_Name__c': conObj.recordName,
                    'Direct_MCN__c': ((conObj.recordReportingFilter=='Direct MCN')||(conObj.recordReportingFilter=='All MCN'))?conObj.recordDirectMCN:'',
                    'Indirect_MCN__c':((conObj.recordReportingFilter=='Indirect MCN')||(conObj.recordReportingFilter=='All MCN'))?conObj.filteredMCN:'',
                    'Direct_FUA__c': ((conObj.recordReportingFilter=='Direct FUA')||(conObj.recordReportingFilter=='All FUA'))?conObj.recordDirectFUA:'',
                    'Indirect_FUA__c':((conObj.recordReportingFilter=='Indirect FUA')||(conObj.recordReportingFilter=='All FUA'))?conObj.filteredFUA:'',
                    
                    'Email__c': conObj.recordEmail,
                    'Reporting_Filter__c': conObj.recordReportingFilter,
                    'Schedule_External_Report__c': scheduleReportId,
                    'Additional_Email_1__c': conObj.recordAdditinalRecipientType!='--None--'?email1:'',
                    'Additional_Email_2__c': conObj.recordAdditinalRecipientType!='--None--'?email2:'',
                    'Additional_Email_3__c': conObj.recordAdditinalRecipientType!='--None--'?email3:'',
                    'Additional_Email_4__c': conObj.recordAdditinalRecipientType!='--None--'?email4:'',
                    'Additional_Recipient_Type__c': conObj.recordAdditinalRecipientType
                };
                // Record details to pass to create method with api name of Object.
                var objRecordInput = { 'apiName': 'Email_Recipient__c', fields };
                createRecord(objRecordInput).then(response => {

                }).catch(error => {
                    console.log('createEmailRecipient error =='+JSON.stringify(error));
                    error1 = true;
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
            }
        });

        if (!error1 && this.recordId == undefined) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Schedule external report created successfully',
                    variant: 'success',
                }),

            );
            setTimeout(() => {
                window.location.assign("/" + scheduleReportId);
            }, 4000);
        }
    }

   

    // Updating schedule external record 
    updateSchedule(scheduleId) {
        var fields = {
            'Id': scheduleId, Schedule_external_report_name__c: this.reportName, 'Frequency__c': this.frequencyValue, 'Start_Date__c': this.strStartDate, 'End_Date__c': this.strEndDate,
            'Schedule_Time__c': this.scheduleTime, 'Schedule_report_requested_by__c': this.getUserId(), 'Report_1_Id__c': this.report1,
            'Report_2_Id__c': this.report2, 'Report_3_Id__c': this.report3, 'Report_1_Name__c': this.report1Name, 'Report_2_Name__c': this.report2Name,
            'Report_3_Name__c': this.report3Name,'Email_Subject__c':this.emailSubject,'Email_Body__c':this.emailBody,'NextBatchDate__c':this.updateNextBatchDate(),	
            'Is_Batch_Triggered_on_End_Date__c':this.strEndDate>this.initialEndDate?false:this.endDateBatchTriggered
        };

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.updateEmailRecipient();

            })
            .catch(error => {
                this.isLoading = false;
                console.log('updateSchedule error==' + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    updateNextBatchDate(){	
        if(this.nextbatchdate<this.strStartDate){	
            return this.strStartDate;	
        }	
        else if(this.nextbatchdate<this.strEndDate && this.nextbatchdate==this.initialEndDate){	
            var d = new Date(this.nextbatchdate);	
            this.nextbatchdate = d.setDate(d.getDate() + 1);	
            return new Date(this.nextbatchdate);	
            // (d.setDate(d.getDate() + 1)); 	
        }	
        else if(this.nextbatchdate>this.strEndDate){	
            return this.strEndDate;	
        }	
    }
    
    // Update email recipient record
    updateEmailRecipient() {
        var email1; var email2; var email3; var email4; var error1 = false;
        var contactMap = Array.from(this.objectMap.values());
        contactMap.forEach(conObj => {
            if (conObj.recordStatus == 'Update') {
                if (conObj.recordAdditinalRecipientType == 'Account Owner') {
                    var emailIdList = conObj.recordAccountOwnerEmail.split(', ');
                   
                        email1 = emailIdList[0] != undefined ? emailIdList[0] : '';
                        email2 = emailIdList[1] != undefined ? emailIdList[1] : '';
                        email3 = emailIdList[2] != undefined ? emailIdList[2] : '';
                        email4 = emailIdList[3] != undefined ? emailIdList[3] : '';
                   
                }
                else {
                    email1 = conObj.recordAdditionalRecipient1;
                    email2 = conObj.recordAdditionalRecipient2;
                    email3 = conObj.recordAdditionalRecipient3;
                    email4 = conObj.recordAdditionalRecipient4;
                }
                console.log('conObj.filteredMCN=='+JSON.stringify(conObj.filteredMCN));
                var fields = {
                    'Contact__c': conObj.recordId,
                    'Id': conObj.recordEmailRecipientId,
                    'Contact_Name__c': conObj.recordName,
                    'Direct_MCN__c': ((conObj.recordReportingFilter=='Direct MCN')||(conObj.recordReportingFilter=='All MCN'))?conObj.recordDirectMCN:'',
                    'Indirect_MCN__c':((conObj.recordReportingFilter=='Indirect MCN')||(conObj.recordReportingFilter=='All MCN'))?conObj.filteredMCN.toString():'',
                    'Direct_FUA__c': ((conObj.recordReportingFilter=='Direct FUA')||(conObj.recordReportingFilter=='All FUA'))?conObj.recordDirectFUA:'',
                    'Indirect_FUA__c':((conObj.recordReportingFilter=='Indirect FUA')||(conObj.recordReportingFilter=='All FUA'))?conObj.filteredFUA.toString():'',
                    'Email__c': conObj.recordEmail,
                    'Reporting_Filter__c': conObj.recordReportingFilter,
                    'Additional_Email_1__c': conObj.recordAdditinalRecipientType!='--None--'?email1:'',
                    'Additional_Email_2__c': conObj.recordAdditinalRecipientType!='--None--'?email2:'',
                    'Additional_Email_3__c': conObj.recordAdditinalRecipientType!='--None--'?email3:'',
                    'Additional_Email_4__c': conObj.recordAdditinalRecipientType!='--None--'?email4:'',
                    'Additional_Recipient_Type__c': conObj.recordAdditinalRecipientType
                };
                console.log('fields=='+JSON.stringify(fields));
                const recordInput = { fields };
                updateRecord(recordInput)
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Record updated',
                                variant: 'success'
                            })
                        );

                    })
                    .catch(error => {
                        error1 = true;
                        this.isLoading = false;
                        console.log('updateEmailRecipient error==' + JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error updating record',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    });
            }
        });
        if (!error1) {
            setTimeout(() => {
                window.location.assign("/" + this.recordId);
                //eval("$A.get('e.force:refreshView').fire();"); 
            }, 4000);
        }
    }


    // Delete email recipient record
    deleteEmailRecipient() {
        this.deleteEmailRecipientId.forEach(recordId => {
            if (!this.selectedContactId.includes(recordId)) {
                var emailRecepientId = this.initialMap.get(recordId).recordEmailRecipientId;
                deleteRecord(emailRecepientId)
                    .then(() => {

                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('deleteEmailRecipient error ==' + JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error deleting record',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    });
            }
        })
    }

    /**METHOD TO FETCH DIRECT AND INDIRECT CONTACTS AND SET TABLE*/
    getRelatedContact(conIdList) {
        let contactIdList = [];
        var objMap = new Map();
        getRelatedContactData({ contactIdList: conIdList })
            .then(result => {
                if (result != null) {
                    result.forEach(conObj => {
                        contactIdList.push(conObj.recordId);
                        if (this.recordId != undefined) {
                            if (this.initialMap.get(conObj.recordId)) {
                                var schdlObj = this.initialMap.get(conObj.recordId);
                                
                                var conObjMap = ({
                                    recordStatus: "Update",
                                    recordAccountOwnerEmail: conObj.recordAccountOwnerEmail,
                                    recordAccountOwnerQuickLookId: conObj.recordAccountOwnerQuickLookId,
                                    recordEmailRecipientId: schdlObj.recordEmailRecipientId,
                                    recordId: schdlObj.recordId,
                                    recordName: conObj.recordName,
                                    recordEmail: conObj.recordEmail,
                                    recordDirectMCN: conObj.recordDirectMCN,
                                    recordIndirectMCN: conObj.recordIndirectMCN,
                                    recordReportingFilter: schdlObj.recordReportingFilter,
                                    recordAdditinalRecipientType: schdlObj.recordAdditinalRecipientType,
                                    recordAdditionalRecipient1:schdlObj.recordAdditinalRecipientType!='Manually Enter Emails'?this.setAccountOwnerEmail(conObj,1):schdlObj.recordAdditionalRecipient1,
                                    recordAdditionalRecipient2: schdlObj.recordAdditinalRecipientType!='Manually Enter Emails'?this.setAccountOwnerEmail(conObj,2):schdlObj.recordAdditionalRecipient2,
                                    recordAdditionalRecipient3: schdlObj.recordAdditinalRecipientType!='Manually Enter Emails'?this.setAccountOwnerEmail(conObj,3):schdlObj.recordAdditionalRecipient3,
                                    recordAdditionalRecipient4: schdlObj.recordAdditinalRecipientType!='Manually Enter Emails'?this.setAccountOwnerEmail(conObj,4):schdlObj.recordAdditionalRecipient4,
                                    recordAccountOwnerName: conObj.recordAccountOwnerName,
                                    recordAccountName: schdlObj.recordAdditinalRecipientType == 'Account Owner' ? conObj.recordAccountOwnerName : '',
                                    isAccountOwner: schdlObj.recordAdditinalRecipientType == 'Account Owner' ? true : false,
                                    isManual: schdlObj.recordAdditinalRecipientType == 'Manually Enter Emails' ? true : false,
                                    isNone: schdlObj.recordAdditinalRecipientType == '--None--' ? true : false,
                                    isDirectMCN: schdlObj.recordReportingFilter == 'Direct MCN' ? true : false,
                                    isIndirectMCN: schdlObj.recordReportingFilter == 'Indirect MCN' ? true : false,
                                    isAllFUA: schdlObj.recordReportingFilter == 'All FUA' ? true : false,
                                    isAllMCN: schdlObj.recordReportingFilter == 'All MCN' ? true : false,
                                    recordDirectFUA: conObj.recordDirectFUA,
                                    recordIndirectFUA: conObj.recordIndirectFUA,
                                    isDirectFUA: schdlObj.recordReportingFilter == 'Direct FUA' ? true : false,
                                    isIndirectFUA: schdlObj.recordReportingFilter == 'Indirect FUA' ? true : false,
                                    recordShowAllFUA: this.setShowAll(conObj.recordDirectFUA,conObj.recordIndirectFUA),
                                    recordShowAllMCN: this.setShowAll(conObj.recordDirectMCN,conObj.recordIndirectMCN),
                                    indirectCharLimitMCN: conObj.recordIndirectMCNSize>68?true:false,
                                    indirectCharLimitFUA: conObj.recordIndirectFUASize>68?true:false,
                                    filteredMCN:schdlObj.recordIndirectMCN!=null?schdlObj.recordIndirectMCN:conObj.recordIndirectMCN,
                                    singleIndirectMCN:this.checkComma(conObj.recordIndirectMCN),
                                    charLimitMCN:this.checkSize(schdlObj.recordIndirectMCN!=null?schdlObj.recordIndirectMCN:conObj.recordIndirectMCN),
                                    showAdditionalEmail:schdlObj.recordAdditinalRecipientType!='--None--'?true:false,
                                    filteredFUA:schdlObj.recordIndirectFUA!=null?schdlObj.recordIndirectFUA:conObj.recordIndirectFUA,
                                    singleIndirectFUA:this.checkComma(conObj.recordIndirectFUA),
                                    charLimitFUA:this.checkSize(schdlObj.recordIndirectFUA!=null?schdlObj.recordIndirectFUA:conObj.recordIndirectFUA)

                                })
                                objMap.set(conObj.recordId, conObjMap);
                            }
                            else {
                                if (this.objectMap.size != undefined) {
                                    if (this.objectMap.get(conObj.recordId) != undefined) {
                                        objMap.set(conObj.recordId, this.objectMap.get(conObj.recordId));
                                    }
                                    else {
                                        var conObjMap = this.setConMap(conObj);
                                        objMap.set(conObj.recordId, conObjMap);
                                    }
                                }
                                else {
                                    var conObjMap = this.setConMap(conObj);
                                    objMap.set(conObj.recordId, conObjMap);
                                }
                            }
                        }
                        else {
                            if (this.objectMap.size != undefined) {
                                if (this.objectMap.get(conObj.recordId) != undefined) {

                                    objMap.set(conObj.recordId, this.objectMap.get(conObj.recordId));
                                }
                                else {
                                    var conObjMap = this.setConMap(conObj);
                                    objMap.set(conObj.recordId, conObjMap);
                                }
                            }
                            else {
                                var conObjMap = this.setConMap(conObj);
                                objMap.set(conObj.recordId, conObjMap);
                            }
                        }
                    })
                    this.objectMap = objMap;
                    this.contactMap = Array.from(this.objectMap.values());
                    this.isLoading = false;
                  //  console.log('this.contactMap==' + JSON.stringify(this.contactMap));
                }
                
            })
            .catch(error => {
                console.log('getRelatedContact error==' + JSON.stringify(error));
                this.error = error;
            });
           
    }
    checkSize(str){
        if(str!=null){
            console.log('str lngth=='+JSON.stringify(str.length));
            if(str.length>68)
            return true;
            else false;

        }

    }
    checkComma(str){
      if(str!=null){
       if(str.includes(','))
       return false;
       else
       return true;

      }

    }

    setAccountOwnerEmail(conObj,num){
        var emailIdList = conObj.recordAccountOwnerEmail.split(', ');
        if(num==1){
            return emailIdList[0];
        }
        else if(num==2){
            return emailIdList[1]; 
        }
        else if(num==3){
            return emailIdList[2]; 
        }
        else{
            return emailIdList[3];
        }
    }

    // Setting object map values
    setConMap(conObj) {
      
        var conMap = ({
            recordStatus: "New",
            recordId: conObj.recordId,
            recordName: conObj.recordName,
            recordEmail: conObj.recordEmail,
            recordDirectMCN: conObj.recordDirectMCN,
            recordIndirectMCN: conObj.recordIndirectMCN,
            recordAccountOwnerEmail: conObj.recordAccountOwnerEmail,
            recordAccountOwnerQuickLookId: conObj.recordAccountOwnerQuickLookId,
            recordReportingFilter: 'Direct MCN',
            recordAdditinalRecipientType: '--None--',
            recordAccountOwnerName: conObj.recordAccountOwnerName,
            recordAccountName: '',
            recordAdditionalRecipient: '',
            recordAdditionalRecipient1: '',
            recordAdditionalRecipient2: '',
            recordAdditionalRecipient3: '',
            recordAdditionalRecipient4: '',
            isAccountOwner: false,
            isManual: false,
            isNone: true,
            isDirectMCN: conObj.recordDirectMCN!=null?true:false,
            isIndirectMCN: false,
            isAllFUA: false,
            isAllMCN: false,
            recordDirectFUA: conObj.recordDirectFUA,
            recordIndirectFUA: conObj.recordIndirectFUA,
            isDirectFUA: conObj.recordDirectMCN==null?true:false,
            isIndirectFUA: false,
            recordShowAllFUA: this.setShowAll(conObj.recordDirectFUA,conObj.recordIndirectFUA),
            recordShowAllMCN: this.setShowAll(conObj.recordDirectMCN,conObj.recordIndirectMCN),
            indirectCharLimitMCN: conObj.recordIndirectMCNSize>68?true:false,
            indirectCharLimitFUA: conObj.recordIndirectFUASize>68?true:false,
            filteredMCN:conObj.recordIndirectMCN,
            singleIndirectMCN:this.checkComma(conObj.recordIndirectMCN),
            charLimitMCN:this.checkSize(conObj.recordIndirectMCN),
            showAdditionalEmail:false,
            filteredFUA:conObj.recordIndirectFUA,
            singleIndirectFUA:this.checkComma(conObj.recordIndirectFUA),
            charLimitFUA:this.checkSize(conObj.recordIndirectFUA)
            
        });
        return conMap;
    }

   
    setShowAll(direct,indirect){
        if(direct!=null && indirect!=null){
           return true;
        }
        
        else{
            false;
        }
    
    }

   
  // This method will validate step-3 on click of next button
    validateStep3() {

        // 1 - Takes all the inputs from the step -3 "this" is bind to wizard-step component
        //const allValid = [...this.querySelectorAll('lightning-combobox')]
        const allValid = [...this.querySelectorAll('[data-id="rsd"]')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        // 2 - Returns true/false; if the validation were asynchronous, it should return a Promise instead
        return allValid;
    }

     // This method will validate step-4 on click of next button
    validateStep4() {

        // 1 - Takes all the inputs from the step -4"this" is bind to wizard-step component
        //const allValid = [...this.querySelectorAll('lightning-combobox')]
        const allValid = [...this.querySelectorAll('[data-id="emailFields"]')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        // 2 - Returns true/false; if the validation were asynchronous, it should return a Promise instead
        return allValid;
    }

  
    //Handling Enter Schedule Report Name change 
    handleName(event) {
        this.reportName = event.detail.value;
    }
   
    //Handling Select frequency change 
    handleFrequencyChange(event) {
        this.frequencyValue = event.detail.value;
    }

     //Handling Schedule Time change 
    handleTime(event) {
        this.scheduleTime = event.detail.value;
    }

     //Handling  Start date change 
    handleStartDate(event) {
        let inputDate = this.template.querySelector(".dateCmp");
        let inputDate2 = this.template.querySelector(".dateCmp2");
        this.strStartDate = event.detail.value;
        let dateValue = event.detail.value;
        var d1 = new Date(dateValue);
        this.startDate = d1.setDate(d1.getDate() + 1);
        var today = new Date();
        var result = today.setDate(today.getDate());
        var d2 = d1.setDate(d1.getDate());
        if (dateValue == null) {
            inputDate.setCustomValidity("Invalid date format! Please select date again");
        }
        else if (d2 < result) {
            inputDate.setCustomValidity("Date value can not be less than today");
        }
        else {
            if (this.endDate != null) {
                if (this.strEndDate == null) {
                    inputDate.setCustomValidity("End date is invalid . please select again");
                }
                else if (this.endDate < this.startDate) {
                    inputDate.setCustomValidity("Start date can not be more than end date");
                }
                else if (this.endDate == this.startDate) {
                    inputDate.setCustomValidity("Start date can not be equal to end date");
                }
                else {
                    inputDate.setCustomValidity("");
                    inputDate2.setCustomValidity("");
                    if(inputDate2.value!=''|| inputDate2.value!=null|| inputDate2.value!=undefined)
                    inputDate2.reportValidity();
                }
            }
            else {
                inputDate.setCustomValidity("");
                inputDate2.setCustomValidity("");                
            }
        }
    }

     //Handling  End  date change 
    handleEndDate(event) {
        let inputDate2 = this.template.querySelector(".dateCmp");
        let inputDate = this.template.querySelector(".dateCmp2");
        this.strEndDate = event.detail.value;
        let dateValue = event.detail.value;
        var d1 = new Date(dateValue);
        this.endDate = d1.setDate(d1.getDate() + 1);
        var d2 = this.startDate;
        var today = new Date();
        var result = today.setDate(today.getDate());
        var d3 = d1.setDate(d1.getDate());
        if (dateValue == null) {
            inputDate.setCustomValidity("Invalid date format . please select again");
        }
        else if (d3 < result) {
            inputDate.setCustomValidity("Date value can not be less than today");
        }
        else if (this.strStartDate == null) {
            inputDate.setCustomValidity("Start Date is invalid");
        }
        else if (d1 < d2) {
            inputDate.setCustomValidity("End date can not be less than start date");
        }
        else if (this.endDate == this.startDate) {
            inputDate.setCustomValidity("End date can not be equal to start date");
        }
        
        else {
            if(this.startDate <result && this.recordId==undefined){
                inputDate2.setCustomValidity("Date value can not be less than today");
            }
            else{
                inputDate2.setCustomValidity("");
            }
            inputDate.setCustomValidity("");
            if(inputDate2.value!=''|| inputDate2.value!=null|| inputDate2.value!=undefined)
            inputDate2.reportValidity();
        }

    }

    // Method will run contacts selected from custom multi select lookup lwc
    handleConLookUp(event) {
        var selectedContact = [];
        selectedContact = event.detail.arrItems;
        var selectedContactId = [];

        setTimeout(() => {
            if (selectedContact.length > 0) {
                selectedContact.forEach(record => {
                    selectedContactId.push(record.value);
                })
                this.initialConId.forEach(conId => {
                    if (!selectedContactId.includes(conId) && !this.deleteEmailRecipientId.includes(conId)) {
                        selectedContactId.push(conId);
                    }
                })
                this.selectedContactId = selectedContactId;
              //  this.getRelatedContact(selectedContactId);
            }
            else {
                this.selectedContactId = [];
            }
        }, 1000);

      
        
    }

    // Method will run when contacts removed from custom multi select lookup lwc
    handleRemoveConLookUp(event) {
        var selectedContact = [];
        var removedContact = [];
        var selectedContactId = [];
        const values = Array.from(this.objectMap.values());
        selectedContact = event.detail.arrItems;
        removedContact = event.detail.removeItem;
        if (selectedContact.length > 0) {
            selectedContact.forEach(record => {
                selectedContactId.push(record.value);
            })
            this.selectedContactId = selectedContactId;
          //  this.getRelatedContact(selectedContactId);
        }
        else {
            this.selectedContactId = [];
        }
        if (this.initialConId.includes(removedContact)) {
            this.deleteEmailRecipientId.push(removedContact);
        }

    }

 
    // Method to handle validation when next button click on step-1
    handleNextStep1() {
       
      
        if (this.selectedContactId.length < 1) {
            this.isModalShown = true;
            this.modalMessage = 'Please select atleast one contact to proceed';
        }
        else if (this.selectedContactId.length > 10) {
            this.isModalShown = true;
            this.modalMessage = 'You can not select more than 10 Contacts';
        }
        else if (this.reportName == undefined || this.reportName == '') {
            this.isModalShown = true;
            this.modalMessage = 'Please enter report scheduler name';
        }
        else if ((this.report1 == null || this.report1 == '') && (this.report2 == null || this.report2 == '') && (this.report3 == null || this.report3 == '')) {
            this.isModalShown = true;
            this.modalMessage = 'Please select atleast one report to proceed';
        }
        else if ((this.report1 == this.report2 && (this.report1 != '' && this.report1 != undefined)) || (this.report1 == this.report3 && (this.report1 != '' && this.report1 != undefined)) || (this.report2 == this.report3 && (this.report3 != '' && this.report3 != undefined))) {
            this.isModalShown = true;
            this.modalMessage = 'Duplicate reports not allowed';
        }
        else if((this.report1Validate==false && this.report1Name!='')||(this.report2Validate==false && this.report2Name!='')||(this.report3Validate==false && this.report3Name!='')){
            this.isModalShown = true;
            if(this.report1Validate==false && this.report1Name!=''){
                
                this.modalMessage = 'Report type of "'+this.report1Name+'" is not appropriate. Please select a report with the following "' +Schedule_External_Report_Type+ '" report type.';
            }
            else if(this.report2Validate==false && this.report2Name!=''){
                this.modalMessage = 'Report type of "'+this.report2Name+'" is not appropriate. Please select a report with the following "' +Schedule_External_Report_Type+ '" report type.';
            }
            else{
                this.modalMessage = 'Report type of "'+this.report3Name+'" is not appropriate. Please select a report with the following "' +Schedule_External_Report_Type+ '" report type.';
            }
            
        }
        else {
            this.count = this.count+1;
            this.isLoading = true;
            this.getRelatedContact(this.selectedContactId);
            this.template.querySelector('c-wizard').currentStep = 'step-2';

        }

    }
  
    handleShowMore(event){
           var conObj = this.objectMap.get(event.target.dataset.id);
        this.isModalShown2 = true;
        this.modalMessage2 = conObj.recordIndirectMCN;
    }

    handleShowMoreFUA(event){
        var conObj = this.objectMap.get(event.target.dataset.id);
     this.isModalShown2 = true;
     this.modalMessage2 = conObj.recordIndirectFUA;
 }

     // Method to handle validations when next button click on step-2
    handleNextStep2() {
        const allInput = this.template.querySelectorAll('input');
        let additionalRecipientTextErrElement = this.template.querySelectorAll(".additionalRecipientInputError");
        let additionalRecipientTextErrElement2 = this.template.querySelectorAll(".additionalRecipientInputError2");
        var manualEmailError = false;
        this.contactMap.forEach(recordObj => {
            const rec1 = recordObj.recordAdditionalRecipient1 != undefined ? recordObj.recordAdditionalRecipient1 : '';
            const rec2 = recordObj.recordAdditionalRecipient2 != undefined ? recordObj.recordAdditionalRecipient2 : '';
            const rec3 = recordObj.recordAdditionalRecipient3 != undefined ? recordObj.recordAdditionalRecipient3 : '';
            const rec4 = recordObj.recordAdditionalRecipient4 != undefined ? recordObj.recordAdditionalRecipient4 : '';
           
            if (rec1 == '' && rec2 == '' && rec3 == ''
                && rec4 == '' && recordObj.recordAdditinalRecipientType == 'Manually Enter Emails') {
               
                additionalRecipientTextErrElement.forEach(element => {
                    if (element.dataset.id == recordObj.recordId && element.name == 'input1') {
                        element.hidden = false;
                        element.value = 'Please fill out this field';
                    }
                })
                manualEmailError = true;
            }
            else if ((rec1 != '' && !rec1.includes('ncr.com')) || (rec2 != '' && !rec2.includes('ncr.com')) || (rec3 != '' && !rec3.includes('ncr.com')) || (rec4 != '' && !rec4.includes('ncr.com'))) {
                manualEmailError = true;

            }
            else if ((rec1 == rec2 && rec1 != '') || (rec1 == rec3 && rec1 != '') || (rec1 == rec3 && rec1 != '') || (rec2 == rec3 && rec2 != '') || (rec2 == rec4 && rec2 != '') || (rec3 == rec4 && rec3 != '') || (rec1 == rec4 && rec1 != '')) {
                manualEmailError = true;
                additionalRecipientTextErrElement2.forEach(element => {
                    if (element.dataset.id == recordObj.recordId) {
                        if (rec1 == rec2 && element.name == 'input2' && rec1 != '') {
                            element.hidden = false;
                            element.value = 'Duplicate email Id';
                        }
                        else if (rec2 == rec3 && element.name == 'input3' && rec2 != '') {
                            element.hidden = false;
                            element.value = 'Duplicate email Id';
                        }
                        else if (rec3 == rec4 && element.name == 'input4' && rec3 != '') {
                            element.hidden = false;
                            element.value = 'Duplicate email Id';
                        }
                        else if (rec1 == rec4 && element.name == 'input1' && rec4 != '') {
                            element.hidden = false;
                            element.value = 'Duplicate email Id';
                        }
                        else if (rec1 == rec3 && element.name == 'input3' && rec1 != '') {
                            element.hidden = false;
                            element.value = 'Duplicate email Id';
                        }

                    }
                })
            }

        });
        if (this.accountOwnerError || this.reportingFlterError) {
        }
        else if (manualEmailError) {
         //   this.setInputTextFieldError();
        }
        else {
            var isValid = true;
            this.contactMap.forEach(conItem=>{
                let additionalRecipientTextErrElement = this.template.querySelectorAll(".additionalRecipientTextError");
                let additionalRecipientInputErrElement = this.template.querySelectorAll(".additionalRecipientInputError"); 
                if(conItem.recordAccountOwnerQuickLookId=='adminnsc' && conItem.recordAdditinalRecipientType=='Account Owner'){
                  this.setAccountOwnerError(additionalRecipientTextErrElement,additionalRecipientInputErrElement,conItem.recordId, false, 'Please select other options as no valid account owner found');
                  isValid = false;
                }
                else if(conItem.recordAccountOwnerEmail.split(', ').length > 4 && conItem.recordAdditinalRecipientType=='Account Owner'){
                    this.setAccountOwnerError(additionalRecipientTextErrElement,additionalRecipientInputErrElement, conItem.recordId, false, 'Please select other options as unique account owner are greater than four');
                    isValid = false;
                }

                let reportingFilterError = this.template.querySelectorAll(".reportingFilterError");
                if(conItem.recordReportingFilter=='Indirect MCN'){
                    this.setReportingFilterError(reportingFilterError,conItem.recordId,conItem.filteredMCN);
                }
                else if(conItem.recordReportingFilter=='Indirect FUA'){
                    this.setReportingFilterError(reportingFilterError,conItem.recordId,conItem.filteredFUA);
                }
                
                isValid = !this.reportingFlterError;
            })
           
            allInput.forEach(element => {
                if (!element.checkValidity()) {
                    isValid = false;
                }
            })
          //  console.log('isValid ==' + isValid);
            if (isValid) {
                additionalRecipientTextErrElement.forEach(element => {
                    element.hidden = true;
                    element.value = '';
                })
                this.template.querySelector('c-wizard').currentStep = 'step-3';
            }

        }
    }

 // Setting error for additonal email input fields present on step-2
    setInputTextFieldError() {
        const allInput = this.template.querySelectorAll('input');
        let additionalRecipientTextErrElement = this.template.querySelectorAll(".additionalRecipientInputError");
        allInput.forEach(element => {
            const validityState = element.validationMessage;
          //  console.log('validityState0==' + JSON.stringify(validityState));

            if (element.validationMessage.includes('Please match the requested format') ){
                additionalRecipientTextErrElement.forEach(item => {
                    if (item.name == element.name && item.dataset.id == element.dataset.id) {
                        item.hidden = false;
                        item.value = 'Please enter NCR email id.';
                    }
                })
            }
            else  {
               
                additionalRecipientTextErrElement.forEach(item => {
                    if (item.name == element.name && item.dataset.id == element.dataset.id) {
                        item.hidden = false;
                        item.value = element.validationMessage;
                    }
                })
            }
          
        })
    }

    closeModal() {
        this.isModalShown = false;
        this.isModalShown2 = false;
        this.isMcnModalShown = false;
        this.isFuaModalShown =false;
    }


    next() {
        this.isModalShown = false;
        this.isModalShown2 = false;
        this.isMcnModalShown = false;
        this.isFuaModalShown=false;
    }

    // Handle reporting filter change
    handleReportFilter(event) {
        let reportingFilterError = this.template.querySelectorAll(".reportingFilterError");
        const conId = (event.target.dataset.id);
        this.objectMap.get(conId).recordReportingFilter = event.target.value;
        if (event.target.value == 'Direct MCN') {
            this.objectMap.get(conId).isDirectMCN = true;
            this.objectMap.get(conId).isIndirectMCN = false;
            this.objectMap.get(conId).isAllFUA = false;
            this.objectMap.get(conId).isAllMCN = false;
            this.objectMap.get(conId).isDirectFUA = false;
            this.objectMap.get(conId).isIndirectFUA = false;
            this.setReportingFilterError(reportingFilterError,conId,this.objectMap.get(conId).recordDirectMCN);
        }
        else if (event.target.value == 'Indirect MCN') {
            this.objectMap.get(conId).isDirectMCN = false;
            this.objectMap.get(conId).isIndirectMCN = true;
            this.objectMap.get(conId).isAllFUA = false;
            this.objectMap.get(conId).isAllMCN = false;
            this.objectMap.get(conId).isDirectFUA = false;
            this.objectMap.get(conId).isIndirectFUA = false;
            this.setReportingFilterError(reportingFilterError,conId,this.objectMap.get(conId).filteredMCN);
        }
        else if (event.target.value == 'Direct FUA') {
            this.objectMap.get(conId).isDirectMCN = false;
            this.objectMap.get(conId).isIndirectMCN = false;
            this.objectMap.get(conId).isAllFUA = false;
            this.objectMap.get(conId).isAllMCN = false;
            this.objectMap.get(conId).isDirectFUA = true;
            this.objectMap.get(conId).isIndirectFUA = false;
            this.setReportingFilterError(reportingFilterError,conId,this.objectMap.get(conId).recordDirectFUA);

        }
        else if (event.target.value == 'Indirect FUA') {
            this.objectMap.get(conId).isDirectMCN = false;
            this.objectMap.get(conId).isIndirectMCN = false;
            this.objectMap.get(conId).isAllFUA = false;
            this.objectMap.get(conId).isAllMCN = false;
            this.objectMap.get(conId).isDirectFUA = false;
            this.objectMap.get(conId).isIndirectFUA = true;
            this.setReportingFilterError(reportingFilterError,conId,this.objectMap.get(conId).filteredFUA);

        }
        else if (event.target.value == 'All FUA') {
            this.objectMap.get(conId).isDirectMCN = false;
            this.objectMap.get(conId).isIndirectMCN = false;
            this.objectMap.get(conId).isAllFUA = true;
            this.objectMap.get(conId).isAllMCN = false;
            this.objectMap.get(conId).isDirectFUA = false;
            this.objectMap.get(conId).isIndirectFUA = false;
            this.setReportingFilterError(reportingFilterError,conId,this.objectMap.get(conId).filteredFUA);


        }
        else {
            this.objectMap.get(conId).isDirectMCN = false;
            this.objectMap.get(conId).isIndirectMCN = false;
            this.objectMap.get(conId).isAllFUA = false;
            this.objectMap.get(conId).isAllMCN = true;
            this.objectMap.get(conId).isDirectFUA = false;
            this.objectMap.get(conId).isIndirectFUA = false;
            this.setReportingFilterError(reportingFilterError,conId,this.objectMap.get(conId).filteredMCN);
            
        }
        this.contactMap = Array.from(this.objectMap.values());
    }
  
    // Set reporting filter error
    setReportingFilterError(errorElement,conId,str){
        
        this.reportingFlterError = false;
        if(str.length>1330 ){
            errorElement.forEach(item => {
                if(item.dataset.id==conId){
                    item.hidden = false;
                    item.value = 'Maximum character limit reached, please select other filter';
                    this.errorMap.set(conId,true);
                }
           
            })
          
        }
        else{
            
            errorElement.forEach(item => {
                if(item.dataset.id==conId){
                item.hidden = true; 
                this.errorMap.set(conId,false);
                }
            })
          
        }

        Array.from(this.errorMap.values()).forEach(item=>{
            if(item){
                this.reportingFlterError = true;    
            }
        })
        
       
    }

   
    // Handle additional recipient filter change
    handleAdditionalRecipient(event) {
        this.accountOwnerError = false;
        let additionalRecipientTextErrElement = this.template.querySelectorAll(".additionalRecipientTextError");
        let additionalRecipientInputErrElement = this.template.querySelectorAll(".additionalRecipientInputError");
        const conId = (event.target.dataset.id);
        this.objectMap.get(conId).recordAdditinalRecipientType = event.target.value;
       if( event.target.value!='--None--'){
        this.objectMap.get(conId).showAdditionalEmail =true;
       }
       else{
        this.objectMap.get(conId).showAdditionalEmail =false;
       }
        

        if (event.target.value == 'Manually Enter Emails') {
            this.setObjectMap(conId, false, true, false, '', '');
            this.setAccountOwnerError(additionalRecipientTextErrElement,additionalRecipientInputErrElement, event.target.dataset.id, true, '');
            this.additionalRecipientErrorMap.set(conId,false);
          //  this.accountOwnerError = false;
        }
        else if (event.target.value == 'Account Owner') {
            this.objectMap.get(conId).isAccountOwner = true;
            this.objectMap.get(conId).isNone = false;
            this.objectMap.get(conId).isManual = false;
            if (this.objectMap.get(conId).recordAccountOwnerQuickLookId == 'adminnsc') {
                this.setAccountOwnerError(additionalRecipientTextErrElement,additionalRecipientInputErrElement, event.target.dataset.id, false, 'Please select other options as no valid account owner found');
              //  this.accountOwnerError = true;
                this.additionalRecipientErrorMap.set(conId,true);
            }
            else {
                if (this.objectMap.get(conId).recordAccountOwnerEmail.split(', ').length < 5) {
                    this.setObjectMap(conId, true, false, false, this.objectMap.get(conId).recordAccountOwnerEmail, this.objectMap.get(conId).recordAccountOwnerName);
                    additionalRecipientInputErrElement.forEach(elmnt => {
                        if (elmnt.dataset.id == event.target.dataset.id) {
                            elmnt.hidden = 'true';
                            elmnt.value = '';
                        }
                    })
                    this.additionalRecipientErrorMap.set(conId,false);
                }
                else {
                    this.setAccountOwnerError(additionalRecipientTextErrElement,additionalRecipientInputErrElement, event.target.dataset.id, false, 'Please select other options as unique account owner are greater than four');
                  //  this.accountOwnerError = true;
                    this.additionalRecipientErrorMap.set(conId,true);
                }
            }
        }
        else {
            this.setObjectMap(conId, false, false, true, '', '');
            this.setAccountOwnerError(additionalRecipientTextErrElement,additionalRecipientInputErrElement, event.target.dataset.id, true, '');
           // this.accountOwnerError = false;
            this.additionalRecipientErrorMap.set(conId,false);
        }

        this.contactMap = Array.from(this.objectMap.values());
        Array.from(this.additionalRecipientErrorMap.values()).forEach(item=>{
            if(item){
                this.accountOwnerError = true;    
            }
        })
    }

    // Setting Object Map on clcik of additional recipient filter
    setObjectMap(conId, accOwner, manual, none, accntOwnerEmail, accntOwnerName) {
        this.objectMap.get(conId).isAccountOwner = accOwner;
        this.objectMap.get(conId).isNone = none;
        this.objectMap.get(conId).isManual = manual;
        this.objectMap.get(conId).recordAdditionalRecipient = accntOwnerEmail;
        this.objectMap.get(conId).recordAccountName = accntOwnerName;
        this.objectMap.get(conId).recordAdditionalRecipient1 = '';
        this.objectMap.get(conId).recordAdditionalRecipient2 = '';
        this.objectMap.get(conId).recordAdditionalRecipient3 = '';
        this.objectMap.get(conId).recordAdditionalRecipient4 = '';
    }
 

    // Setting error if account owner is not valid
    setAccountOwnerError(element,inputError,id, hidden, value) {
        element.forEach(item => {
           // console.log('element=='+JSON.stringify(item.dataset.id));

            if (item.dataset.id == id) {
                item.hidden = hidden;
                item.value = value;
            }
        })

        inputError.forEach(elmnt => {
            if (elmnt.dataset.id == id) {
                elmnt.hidden = hidden;
                elmnt.value = '';
            }
        })
    }

    // Handle Schedule Report Requested by field change
    handleRequester(event) {
        this.selectedUser = event.detail;
    }

     // Handle Report Lookup 1 change
    handleReportLookUp1(event) {
        this.report1 = event.detail;
        if (event.detail){
            this.isLoading =true;
            this.getReportDetail(event.detail, 'report1Lookup');
            this.validateReport(event.detail,'report1Lookup');
           
        }
        else{
            this.report1Name = '';
        }
            
    }

   // Handle Report Lookup 2 change
    handleReportLookUp2(event) {
        this.report2 = event.detail;
        if (event.detail){
            this.isLoading =true;
            this.getReportDetail(event.detail, 'report2Lookup');
            this.validateReport(event.detail,'report2Lookup');
        }
        else{
            this.report2Name = '';
        }
           
    }
   
     // Handle Report Lookup 3 change
    handleReportLookUp3(event) {
        this.report3 = event.detail;
        if (event.detail){
            this.isLoading =true;
            this.getReportDetail(event.detail, 'report3Lookup');
            this.validateReport(event.detail,'report3Lookup');
        }
        else{
            this.report3Name = '';
        }
            
    }

   
   
   // Handle add button for reports on step-1
    handleAddClick() {
        if (this.showLookUp2 == false) {
            this.showLookUp2 = true;
            this.disableRemoveBtn = false;
        }
        else if (this.showLookUp2 == true && this.showLookUp3 == false) {
            this.showLookUp3 = true;
            this.disableAddBtn = true;
        }

    }

     // Handle remove button for reports on step-1
    handleRemoveClick() {
        if (this.showLookUp2 == true && this.showLookUp3 == false) {
            this.showLookUp2 = false;
            this.disableRemoveBtn = true;
            this.disableAddBtn = false;
            this.report2 = '';
            this.report2Name = '';
        }
        else if (this.showLookUp2 == true && this.showLookUp3 == true) {
            this.showLookUp3 = false;
            this.disableAddBtn = false;
            this.report3 = '';
            this.report3Name = '';
        }

    }

   // Handle select recipient 1 change on step-2
    handleRecipientInput1(event) {
        const conId = event.target.dataset.id;
        this.objectMap.get(conId).recordAdditionalRecipient1 = event.target.value;
        this.contactMap = Array.from(this.objectMap.values());
        this.checkDuplicate(conId, 'input1');
        this.setInputTextFieldError();
    }

     // Handle select recipient 2 change on step-2
    handleRecipientInput2(event) {
        const allInput = this.template.querySelectorAll('input');
        const conId = event.target.dataset.id;
        this.objectMap.get(conId).recordAdditionalRecipient2 = event.target.value;
        this.contactMap = Array.from(this.objectMap.values());
      //  this.setInputFieldRequired(allInput, event);
        this.checkDuplicate(conId, 'input2');
        this.setInputTextFieldError();
    }
 
     // Handle select recipient 3 change on step-2
    handleRecipientInput3(event) {
        const allInput = this.template.querySelectorAll('input');
        const conId = event.target.dataset.id;
        this.objectMap.get(conId).recordAdditionalRecipient3 = event.target.value;
        this.contactMap = Array.from(this.objectMap.values());
      //  this.setInputFieldRequired(allInput, event);
        this.checkDuplicate(conId, 'input3');
        this.setInputTextFieldError();
    }

     // Handle select recipient 4 change on step-2
    handleRecipientInput4(event) {
        const allInput = this.template.querySelectorAll('input');
        const conId = event.target.dataset.id;
        this.objectMap.get(conId).recordAdditionalRecipient4 = event.target.value;
        this.contactMap = Array.from(this.objectMap.values());
       // this.setInputFieldRequired(allInput, event);
        this.checkDuplicate(conId, 'input4');
        this.setInputTextFieldError();
    }
    
    // Setting select recipient 1 required
    setInputFieldRequired(allInput, event) {
        const conId = event.target.dataset.id;
        const rec2 = this.objectMap.get(conId).recordAdditionalRecipient2 != undefined ? this.objectMap.get(conId).recordAdditionalRecipient2 : '';
        const rec3 = this.objectMap.get(conId).recordAdditionalRecipient3 != undefined ? this.objectMap.get(conId).recordAdditionalRecipient3 : '';
        const rec4 = this.objectMap.get(conId).recordAdditionalRecipient4 != undefined ? this.objectMap.get(conId).recordAdditionalRecipient4 : '';

        allInput.forEach(item => {
            if (item.id == event.target.id && item.name == 'input1') {
                if (event.target.value.length > 0) {
                    item.required = false;
                }
                else if (rec2.length < 1 && rec3.length < 1 && rec4.length < 1) {
                    item.required = true;
                }
            }
        })

        this.contactMap = Array.from(this.objectMap.values());
    }
  
    // Checking select recipient field value for duplicate values
    checkDuplicate(conId, input) {
        var uniqueEmailIdList = [];
        var countDuplicates = 0;
        let additionalRecipientTextErrElement = this.template.querySelectorAll(".additionalRecipientInputError2");
        const rec1 = this.objectMap.get(conId).recordAdditionalRecipient1 != undefined ? this.objectMap.get(conId).recordAdditionalRecipient1 : '';
        const rec2 = this.objectMap.get(conId).recordAdditionalRecipient2 != undefined ? this.objectMap.get(conId).recordAdditionalRecipient2 : '';
        const rec3 = this.objectMap.get(conId).recordAdditionalRecipient3 != undefined ? this.objectMap.get(conId).recordAdditionalRecipient3 : '';
        const rec4 = this.objectMap.get(conId).recordAdditionalRecipient4 != undefined ? this.objectMap.get(conId).recordAdditionalRecipient4 : '';
        if (!uniqueEmailIdList.includes(rec1) && rec1 != '') {
            uniqueEmailIdList.push(rec1);
        }
        else if (rec1 != '') {
            countDuplicates = countDuplicates + 1;
        }
        if (!uniqueEmailIdList.includes(rec2) && rec2 != '') {
            uniqueEmailIdList.push(rec2);
        }
        else if (rec2 != '') {
            countDuplicates = countDuplicates + 1;
        }
        if (!uniqueEmailIdList.includes(rec3) && rec3 != '') {
            uniqueEmailIdList.push(rec3);
        }
        else if (rec3 != '') {
            countDuplicates = countDuplicates + 1;
        }
        if (!uniqueEmailIdList.includes(rec4) && rec4 != '') {
            uniqueEmailIdList.push(rec4);
        }
        else if (rec4 != '') {
            countDuplicates = countDuplicates + 1;
        }
        additionalRecipientTextErrElement.forEach(element => {
            if (element.dataset.id == conId) {
                if (countDuplicates == 0) {
                    element.hidden = true;
                    element.value = '';
                }
                else {

                    if (input == 'input1') {
                        if ((rec1 == rec2 || rec1 == rec3 || rec1 == rec4) && element.name == 'input1' && rec1 != '') {
                            element.hidden = false;
                            element.value = 'Duplicate email Id';
                        }
                        else if (element.name == 'input1') {
                            element.hidden = true;
                            element.value = '';
                        }

                    }
                    else if (input == 'input2') {
                        if ((rec2 == rec1 || rec2 == rec3 || rec2 == rec4) && element.name == 'input2' && rec2 != '') {
                            element.hidden = false;
                            element.value = 'Duplicate email Id';
                        }
                        else if (element.name == 'input2') {
                            element.hidden = true;
                            element.value = '';
                        }
                    }
                    else if (input == 'input3') {
                        if ((rec3 == rec1 || rec3 == rec2 || rec3 == rec4) && element.name == 'input3' && rec3 != '') {
                            element.hidden = false;
                            element.value = 'Duplicate email Id';
                        }
                        else if (element.name == 'input3') {
                            element.hidden = true;
                            element.value = '';
                        }
                    }
                    else if (input == 'input4') {
                        if ((rec4 == rec1 || rec4 == rec3 || rec4 == rec2) && element.name == 'input4' && rec4 != '') {
                            element.hidden = false;
                            element.value = 'Duplicate email Id';
                        }
                        else if (element.name == 'input4') {
                            element.hidden = true;
                            element.value = '';
                        }
                    }
                    else {
                        element.hidden = true;
                        element.value = '';
                    }
                }
            }
        })
    }
   
    // Handling email subject change on step-4
    handleEmailSubjectChange(event){
          this.emailSubject = event.detail.value;
    }

      // Handling email body change on step-4
    handleEmailBodyChange(event){
        this.emailBody = event.detail.value; 
    }

     handleFilterMCN(event){
        this.isLoading=true;
        this.currentRowId =event.target.dataset.id;
        this.setMCNoptions(event.target.dataset.id) ; 
    }

    handleFilterFUA(event){
        this.isLoading=true;
        this.currentRowId =event.target.dataset.id;
        this.setFUAoptions(event.target.dataset.id) ; 
    }
  
    handleMCNChange(event){
        this.selectedMCNs = event.detail.value;
    }

    handleFUAChange(event){
        this.selectedFUAs = event.detail.value;
    }

    submitFilterMCN(){
        this.isMcnModalShown =false;
        if(this.selectedMCNs.toString().length>0){
            this.objectMap.get(this.currentRowId).filteredMCN = this.selectedMCNs.toString();   
            this.objectMap.get(this.currentRowId).charLimitMCN = this.checkSize(this.selectedMCNs.toString());
        }
        else{
            this.objectMap.get(this.currentRowId).filteredMCN =  this.objectMap.get(this.currentRowId).recordIndirectMCN;   
            this.objectMap.get(this.currentRowId).charLimitMCN = this.checkSize(this.objectMap.get(this.currentRowId).recordIndirectMCN);  
        }
       
    }

    submitFilterFUA(){
        this.isFuaModalShown =false;
        if(this.selectedFUAs.toString().length>0){
        this.objectMap.get(this.currentRowId).filteredFUA = this.selectedFUAs.toString();   
        this.objectMap.get(this.currentRowId).charLimitFUA = this.checkSize(this.selectedFUAs.toString());
        }
        else{
            this.objectMap.get(this.currentRowId).filteredFUA = this.objectMap.get(this.currentRowId).recordIndirectFUA;  
            this.objectMap.get(this.currentRowId).charLimitFUA = this.checkSize(this.objectMap.get(this.currentRowId).recordIndirectFUA); 
        }
    }

    get optionsMCN() {
        return this.mcnOptions;
        
    }

    get optionsFUA() {
        return this.fuaOptions;
        
    }

    setMCNoptions(rowId){
      //  this.currentRowId = rowId;
        this.mcnOptions =[];
        this.selectedMCNs =[];
            if(this.objectMap.get(rowId).filteredMCN!=this.objectMap.get(rowId).recordIndirectMCN){
                if(this.objectMap.get(rowId).filteredMCN!=undefined)
                this.selectedMCNs =  this.objectMap.get(rowId).filteredMCN.split(',');

            }
            else{
                this.selectedMCNs =  this.objectMap.get(rowId).recordIndirectMCN.split(', ');   
            }
            this.objectMap.get(rowId).recordIndirectMCN.split(', ').forEach(item=>{
                this.mcnOptions.push({
                    label:item,
                    value:item
                })
            })

            setTimeout(() => {
                this.isMcnModalShown =true;
                this.isLoading=false;
            }, 1000);
           
        
    }


    setFUAoptions(rowId){
       // this.currentRowId = rowId;
        this.fuaOptions =[];
        this.selectedFUAs=[];
            if(this.objectMap.get(rowId).filteredFUA!=this.objectMap.get(rowId).recordIndirectFUA){
                if(this.objectMap.get(rowId).filteredFUA!=undefined)
                this.selectedFUAs =  this.objectMap.get(rowId).filteredFUA.split(',');

            }
            else{
                this.selectedFUAs =  this.objectMap.get(rowId).recordIndirectFUA.split(', ');   
            }
            this.objectMap.get(rowId).recordIndirectFUA.split(', ').forEach(item=>{
                this.fuaOptions.push({
                    label:item,
                    value:item
                })
            })
           
            setTimeout(() => {
                this.isFuaModalShown =true;
                this.isLoading=false;
            }, 1000);
            
        }
    

}