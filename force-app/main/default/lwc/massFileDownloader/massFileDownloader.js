import { LightningElement, wire, api, track } from 'lwc';
import getFiles from '@salesforce/apex/MassFileDownloaderController.getFiles';
import getCases from '@salesforce/apex/MassFileDownloaderController.getCases';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

const COLUMNS = [
    { label: 'Id', fieldName: 'Id',type: 'text',sortable: true  },
    { label: 'Title', fieldName: 'Title',type: 'text',sortable: true  },
    { label: 'FileExtension', fieldName: 'FileExtension',type: 'text',sortable: true  },
];

const caseColumns = [
    { label: 'CaseId', fieldName: 'Id',type: 'text',sortable: true  },
    { label: 'CaseNumber', fieldName: 'CaseURL',type: 'url',sortable: true,
    typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_blank'} },
    { label: 'Subject', fieldName: 'Subject',type: 'text',sortable: true  },
    { label: 'Description', fieldName: 'Description',type: 'text' },
    { label: 'Status', fieldName: 'Status',type: 'text',sortable: true  },
    { label: 'Last Modified Date', fieldName: 'LastModifiedDate',type: 'text',sortable: true  },
    { label: 'Last Modified By', fieldName: 'LastModifiedBy',type: 'text',sortable: true  },
//{ label: 'P&L File Attached', fieldName: 'PLAttached',type: 'text',sortable: true  }
];

const BASE_DOWNLOAD_PATH = '/sfc/servlet.shepherd/version/download';

export default class LightningDatatableExample extends LightningElement {
    @track value;
    @track error;
    @track data;
    @api sortedDirection = 'desc';
    @api sortedBy = 'LastModifieddate';
    @api searchKey = '';
    result;
    @track allSelectedRows = [];
    selectedRows = [];
    @track page = 1; 
    @track items = []; 
    @track itemsbkp = []; 
    @track data = []; 
    @track columns; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 13; 
    @track totalRecountCount = 0;
    @track totalPage = 1;
    isPageChanged = false;
    initialLoad = false;
    mapoppNameVsCase = new Map();
    @api recordId;
    @api caseData;
    @api selectedCaseId=[];
    @api contentDocumentData=[];
    @api caseList;
    @api caseListbkp;
    @api fileList;
    columns = COLUMNS;
    caseField=caseColumns;
    @api selectedQuarter;
    @api selectedYear;
    @api listOfgetSelectedCases;
    quarters = [
      { label: 'Entire Year', value: 'YTD' },
      { label: 'Q1', value: 'Q1' },
      { label: 'Q2', value: 'Q2' },
      { label: 'Q3', value: 'Q3' },
      { label: 'Q4', value: 'Q4' },
    ];

    years = [
        { label: 'None', value: 'None' },
        { label: '2015', value: '2015' },
        { label: '2016', value: '2016' },
        { label: '2017', value: '2017' },
        { label: '2018', value: '2018' },
        { label: '2019', value: '2019' },
        { label: '2020', value: '2020' },
        { label: '2021', value: '2021' },
        { label: '2022', value: '2022' },
        { label: '2023', value: '2023' },
        { label: '2024', value: '2024' },
        { label: '2025', value: '2025' },
        { label: '2026', value: '2026' },
        { label: '2027', value: '2027' },
        { label: '2028', value: '2028' },
        { label: '2029', value: '2029' },
        { label: '2030', value: '2030' },
    
        
      ];

    @wire(getCases, {searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection'}) 
    cases({ error, data }) {
        if (data) {
            this.processRecords(data);
            this.error = undefined;
            //console.log('@@@@Start');
        } else if (error) {
            this.error = error;
            this.caseList = undefined;
            //console.log('@@@@End');
        }
    }

    downloadFiles() {
        //console.log(JSON.stringify(this.files));
               let selectedFiles = this.getSelectedRows();
       
               if(selectedFiles.length === 0) {
                   alert('No files selected');
                   return;
               }
       
               this.initDownloading(
                   this.getDownloadString(selectedFiles)
               );
           }
       
           getDownloadString(files) {
               let downloadString = '';
               files.forEach(item => {
                   downloadString += '/' + item.LatestPublishedVersionId
               });
               return downloadString;
           }
        
           initDownloading(downloadString) {
               //alert(BASE_DOWNLOAD_PATH + downloadString);
               window.open(BASE_DOWNLOAD_PATH + downloadString, '_blank');
           }
       
           getSelectedRows() {
               return this.template.querySelector('lightning-datatable').getSelectedRows(); 
           }
       
           getSelectedCases() {
               return this.template.querySelector('lightning-datatable').getSelectedRows(); 
           }
          
     //clicking on next button this method will be called
    nextHandler() {
       // this.getSelectedRows();
        //this.listOfgetSelectedCases= this.getSelectedCases();
        //alert('selectedRowsOfCurrentScreen: '+caseIdsString);
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }

    onRowSelection(event){  
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selectedRows);
       // alert('selectedItemsSet: '+selectedItemsSet);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();
        this.caseList.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });
        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });
            // Add any new items to the selectedRows list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                //alert('@@');
                selectedItemsSet.delete(id);
            }
        });
        this.selectedRows = [...selectedItemsSet];
        console.log('selectedRows==> ' + JSON.stringify(this.selectedRows));
        this.allSelectedRows=JSON.stringify(this.selectedRows);
    }
    
    //this method displays records page by page
    displayRecordPerPage(page){
 //console.log('@@@@displayRecordPerPage',JSON.stringify(this.items));
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.caseList =this.data;
        this.startingRecord = this.startingRecord + 1;
        this.template.querySelector('[data-id="table"]').selectedRows = this.selectedRows;
    }    
    
    handlePrev(){
        this.contentDocumentData=[];
        this.caseData=[];
        if(this.currentStep == "2"){
            this.currentStep = "1"; 
        }
        else if(this.currentStep = "2"){
            this.currentStep = "1";
        }
    }

    handleNext(){
        let selectedCases = this.selectedRows;
        //alert('Length:'+ selectedCases.length);
        if(selectedCases.length === 0) {
            alert('No Cases selected');
            return;
    }

    else{
        this.getFilesFromCases(selectedCases);
    }
      
        if(this.currentStep == "1"){
            this.currentStep = "2";
        }
        else if(this.currentStep = "1"){
            this.currentStep = "2";
        }
    }

    getFilesFromCases(PARAMETER){ 
       // alert('Parameter:'+PARAMETER);
        getFiles({caseId :PARAMETER})
        .then(data => {
            refreshApex(this.data)
            for(let i=0; i<=data.length; ++i){
              this.caseData = data[i]; 
              if(this.caseData !=null || this.caseData=='Undefined'){
                this.contentDocumentData.push(this.caseData.ContentDocument);
              } 
              
            }
          this.caseData = this.contentDocumentData;
           const arr =JSON.stringify(this.caseData);
          const ids =  this.caseData.map(o => o.Id);
          const filtered =  this.caseData.filter(({Id}, index) => !ids.includes(Id, index + 1));
          this.caseData= filtered;
          
          this.error = null;
        })
        .catch(error => {
          this.caseData = null;
          //console.log('caseData: ',this.caseData);
          this.error = error;
          alert('Error: '+ JSON.stringify(this.error));
        });
      }
 
    sortColumns( event ) {

        if( event.detail.fieldName=='CaseURL'){
           if(event.detail.sortDirection=='asc' &&  this.sortedDirection !='desc'){
            this.sortedDirection = 'desc';
           }
     
           
           else if(this.sortedDirection=='desc'){
            this.sortedDirection = 'asc';
           }
          
            this.sortedBy = 'CaseNumber';
           
        }
        else if(event.detail.fieldName=='LastModifiedBy'){
            if(event.detail.sortDirection=='asc' &&  this.sortedDirection !='desc'){
                this.sortedDirection = 'desc';
               }
               else if(this.sortedDirection=='desc'){
                this.sortedDirection = 'asc';
               }
            this.sortedBy = 'LastModifiedBy.Name';
        }

        else{
            this.sortedBy =   event.detail.fieldName;
            this.sortedDirection = event.detail.sortDirection;
        }
        return refreshApex(this.result);
        
    }
    
    processRecords(data){
        if(this.data){
            //this.data.forEach(item => item['CaseURL'] = '/lightning/r/Account/' +item['Id'] +'/view');
            let accParsedData=JSON.parse(JSON.stringify(data));
            //console.log('@@@@accParsedData@@@',accParsedData);
            let baseUrlOfOrg= 'https://'+location.host+'/';
            accParsedData.forEach(cc => {
                if(cc.Id){
                cc.CaseURL=baseUrlOfOrg+cc.Id;
                cc.PLAttached='Yes';
                }
                
               if(cc.LastModifiedBy.Name !=null &&  cc.LastModifiedBy.Name!= undefined ){
                cc.LastModifiedBy=cc.LastModifiedBy.Name;
               }
                
            });
            this.caseListbkp = accParsedData; 
        }
            //console.log('@@@@',JSON.stringify(this.caseListbkp));
            this.items = this.caseListbkp;
            this.totalRecountCount = this.caseListbkp.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            if(this.totalPage==0) this.totalPage=1;
            this.caseListbkp = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
            this.caseList = this.caseListbkp;   
           
    }

    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        var data = [];
        for(var i=0; i<this.items.length;i++){
           // console.log('@@@: '+this.items[i]);
            if(this.items[i]!= undefined && this.items[i].CaseNumber.includes(this.searchKey)){
                data.push(this.items[i]);
            }
        }
        this.processRecords(data);
    }

    handleQuarterChange(event) {
        this.selectedQuarter = event.detail.value;
        this.handleFilteredData();
    }

    handleYearChange(event) {
        this.selectedYear = event.detail.value;  
        this.handleFilteredData();
    }

    handleFilteredData() {
        var Q=[];
        var data = [];
        const d = new Date();
        let year = d.getFullYear();
        var yeardata = [];
           if( this.selectedQuarter=='Q1')
           Q=['01','02','03'];
           else if( this.selectedQuarter=='Q2')
           Q=['04','05','06'];
           else if( this.selectedQuarter=='Q3')
           Q=['07','08','09'];
          else if( this.selectedQuarter=='Q4')
           Q=['10','11','12'];
           else if( this.selectedQuarter=='YTD')
           Q=['01','02','03','04','05','06','07','08','09','10','11','12'];

         
           for(var i=0; i<this.items.length;i++){
                if(this.items[i]!= undefined && Q.includes((this.items[i].LastModifiedDate).substring(5, 7))  && this.selectedYear==(this.items[i].LastModifiedDate).substring(0, 4)){
                    data.push(this.items[i]);
                }
            }
        
        
            this.processRecords(data);
           
        getCases({searchKey: this.searchKey, sortBy: this.sortedBy, sortDirection: this.sortedDirection})
        .then(result=>{  
            let accParsedData=JSON.parse(JSON.stringify(result));
          //  console.log('accParsedData:'+accParsedData);
            let baseUrlOfOrg= 'https://'+location.host+'/';
            accParsedData.forEach(cc => {
                if(cc.Id){
                cc.CaseURL=baseUrlOfOrg+cc.Id;
                cc.PLAttached='Yes';
                }
               if(cc.LastModifiedBy.Name !=null ||  cc.LastModifiedBy.Name!= undefined ){
                cc.LastModifiedBy=cc.LastModifiedBy.Name;
               }
                
           
            });
            this.items = accParsedData;
            //console.log('Results:'+JSON.stringify(this.items));
        }).catch(error => {
            this.error = error;
           // console.log('Error:'+JSON.stringify(this.error));
        });
    

      }

      
    @track currentStep = '1';
 
           handleOnStepClick(event) {
               this.currentStep = event.target.value;
           }
        
           get isStepOne() {
               return this.currentStep === "1";
           }
        
           get isStepTwo() {
               return this.currentStep === "2";
           }
        
          /* get isStepThree() {
               return this.currentStep === "3";
           } */
        
           get isEnableNext() {
               return this.currentStep != "2";
           }
        
           get isEnablePrev() {
               return this.currentStep != "1";
           }
        
           get isEnableFinish() {
               return this.currentStep === "2";
           }

}