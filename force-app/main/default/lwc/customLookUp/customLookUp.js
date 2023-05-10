import lookUp from '@salesforce/apex/ReportScheduleController.search';
import getAllReports from '@salesforce/apex/ReportScheduleController.getAllReports';
import { api, LightningElement, track, wire } from 'lwc';


export default class customLookUp extends LightningElement {

    @api objName;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Search';
    @api labelName;
    @api isRequired = false;
    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;
    isModalShown = false;
    isLoading =false;
    @track reportList=[];
    @track showReportBttn = false;
    @track reportSelectedId;
    searchTerm;
    @track isChkTrue =false;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }

    connectedCallback(){
        if(this.objName=='Report'){
            this.showReportBttn = true;
        }
        else{
            this.showReportBttn = false; 
        }

    }
    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail: '' });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = false;
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }


    @api handleOnLoad(name){
        console.log('name=='+name);
        this.isValueSelected = true;
        this.selectedName = name;
    }

    handleReports(event){
        this.getReportData();
       
        this.isModalShown =true;
        this.isLoading =true;
    }

    closeModal(){
        this.isModalShown =false;
    }

    submit(){
     /*   if(this.reportSelectedId!=undefined && this.isChkTrue){
            const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  this.reportSelectedId });
            this.dispatchEvent(valueSelectedEvent);
            this.isValueSelected = true;
          //  this.selectedName = this.reportSelectedName;
            if(this.blurTimeout) {
                clearTimeout(this.blurTimeout);
            }
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        } */
       
        this.isModalShown =false;
    }

    getReportData(){
        getAllReports()
        .then(result=>{
            this.reportList = result;
            this.isLoading =false;
            console.log('result=='+JSON.stringify(result));
        })
        .catch(error=>{
            this.isLoading =false;
           console.log('getAllReports=='+JSON.stringify(error));
        })
    }

    handleChkBox(event) {
       this.reportSelectedId = event.target.dataset.id;
        let allChkBtn = this.template.querySelectorAll(".chk");
        if (event.target.checked) {
            this.isChkTrue = true;
            allChkBtn.forEach(item => {

                if (item.dataset.id != event.target.dataset.id) {
                    item.disabled = true;
                }
            })
        }
        else {
            this.isChkTrue = false;
            allChkBtn.forEach(item => {
                if (item.dataset.id != event.target.dataset.id) {
                    item.disabled = false;
                }
            })
           // this.handleRemovePill();
        }

    }

}