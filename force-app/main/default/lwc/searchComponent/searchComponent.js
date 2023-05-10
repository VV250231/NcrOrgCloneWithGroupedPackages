import { LightningElement, api, track, wire } from 'lwc';
import search from '@salesforce/apex/SearchController.search';
import getRecentlyCreatedRecord from '@salesforce/apex/SearchController.getRecentlyCreatedRecord';
const DELAY = 10;

import { NavigationMixin } from 'lightning/navigation';

export default class SearchComponent extends NavigationMixin(LightningElement) {
    objName  = 'Account';
    displayFields='Name'; 
    /* values for an existing selected record */
    @api valueId;
    @api valueName;
    @api required;
    

    @api iconName = 'standard:account';
    @api labelName;
    @api currentRecordId;
    @api placeholder   = 'Search';
    @api fields        = ['Name'];    
    @api showLabel     = false;
    @api parentAPIName = 'ParentId';
    @api createRecord  = false;
		
		
		get isRequired(){
				return this.required == 'true' ? true : false
		}
		
	
    
    @api get showFields() { //= 'Name, Rating, AccountNumber';
        return this.displayFields;    
    } 
    set showFields(value) {
        
        this.setAttribute('showFields', value);
        this.displayFields = value;

        if(this.hasCompLoaded) {
            this.initialize();
            this.handleClose();
        }   
    }

    @api get objectName() {
        return this.objName;
    }
    set objectName(value) {
        this.setAttribute('objectName', value);
        this.objName = value;

        if(this.hasCompLoaded) {
            this.initialize();
            this.handleClose();
        }   
    }

    /* values to be passed to create the new record */
    @api recordTypeId;
    @api fieldsToCreate = [];
    

    /* Create fields for using in Datatable for Multiple In-line Edit */
    @api index;

    @track error;

    searchTerm;
    delayTimeout;

    searchRecords;
    selectedRecord;
    objectLabel;
    isLoading = false;
    showButton = false;
    showModal = false;
    hasCompLoaded= false;

    field;
    field1;
    field2;

    ICON_URL       = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';
    ICON_URL_NEW   = '/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#add';
    ICON_URL_CLOSE = '/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#close';


    connectedCallback(){
        this.initialize();
    }

    initialize(){   
        if(this.delayTimeout) {
             window.clearTimeout(this.delayTimeout);
        }
        if(!this.hasCompLoaded) this.hasCompLoaded = true;
        let icons           = this.iconName.split(':');
        this.ICON_URL       = this.ICON_URL.replace('{0}',icons[0]);
        this.ICON_URL       = this.ICON_URL.replace('{1}',icons[1]);

        this.field = '';
        this.field1 = '';
        this.field2 = '';
        this.fields = [];
				
				
        if(this.objName.includes('__c')){
            let obj = this.objName.substring(0, this.objName.length-3);
            this.objectLabel = obj.replaceAll('_',' ');
        }else{
            this.objectLabel = this.objName;
        }

        if( this.valueId && this.valueName ){
            this.selectedRecord = {
                FIELD1 : this.valueName,
                Id     : this.valueId
            }
        }

        if(this.objName == 'SBQQ__Quote__c')
            this.objectLabel = 'Quote';
        else 
            this.objectLabel    = this.titleCase(this.objectLabel);
        
        let fieldList;
        if( !Array.isArray(this.displayFields)){
            fieldList       = this.displayFields.split(',');
        }else{
            fieldList       = this.displayFields;
        }

        if(fieldList.length > 0){
            this.field  = fieldList[0].trim();
        }
        if(fieldList.length > 1){
            this.field  = fieldList[0].trim();
            this.field1 = fieldList[1].trim();
        }
        if(fieldList.length > 2){
            this.field2 = fieldList[2].trim();
        }
        let combinedFields = [];
        fieldList.forEach(field => {
            if( !this.fields.includes(field.trim()) ){
                combinedFields.push( field.trim() );
            }
        });

        this.fields = combinedFields.concat(JSON.parse(JSON.stringify(this.fields)) );
        let serachinput = this.template.querySelector('#combobox-id-1'); 
        if(serachinput) serachinput.value=''

      
        if(this.valueId && this.valueName){
            this.selectedRecord = {
                FIELD1   : this.valueName,
                recordId : this.valueId
            }
        }

    }

    handleInputChange(event){
        if(this.delayTimeout) window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        //this.isLoading = true;
        this.delayTimeout = setTimeout(() => {
            //if(searchKey.length >= 2){
                search({
                    objectName : this.objName,
                    fields     : this.fields,
                    searchTerm : searchKey
                })
                .then(result => {
                    let stringResult = JSON.stringify(result);
                    let allResult    = JSON.parse(stringResult);
                    allResult.forEach( record => {
                        //console.log(record);
                        //console.log(this.field1);
                        //record.FIELD1   = record[this.field];
                        
                        if(this.field && this.field.indexOf('.') != -1) {
                            let relfield=this.field.split('.');
                            let recordData = record;

                            relfield.forEach(field => {
                                recordData = recordData[field];
                            });
                            record.FIELD1 = recordData;
                        } else {
                            record.FIELD1   = record[this.field];
                        }

                        if(this.field1 && this.field1.indexOf('.') != -1) {
                            let relfield=this.field1.split('.');
                            let recordData = record;

                            relfield.forEach(field => {
                                recordData = recordData[field];
                            });
                            record.FIELD2 = recordData;
                        } else {
                            record.FIELD2   = record[this.field1];
                        }


                        if( this.field2 ){
                            record.FIELD3   = record[this.field2];

                            if(this.field2 && this.field2.indexOf('.') != -1) {
                                let relfield=this.field2.split('.');
                                let recordData = record;
    
                                relfield.forEach(field => {
                                    recordData = recordData[field];
                                });
                                record.FIELD3 = recordData;
                            } else {
                                record.FIELD3   = record[this.field2];
                            }
    
                        }else{
                            record.FIELD3 = '';
                        }
                    });
                    this.searchRecords = allResult;

                    
                })
                .catch(error => {
                    console.error('Error:', error);
                })
                .finally( ()=>{
                    this.showButton = this.createRecord;
                });
            //}
        }, DELAY);
    }

    handleSelect(event){
        let recordId = event.currentTarget.dataset.recordId;
        let selectRecord = this.searchRecords.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {
                data : {
                    record          : selectRecord,
                    recordId        : recordId,
                    currentRecordId : this.currentRecordId,
                    parentAPIName   : this.parentAPIName,
                    index           : this.index
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleClose(){
        this.selectedRecord = undefined;
        this.searchRecords  = undefined;
        this.showButton     = false;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {
                data : {
                    record          : undefined,
                    recordId        : undefined,
                    currentRecordId : this.currentRecordId,
                    parentAPIName   : this.parentAPIName,
                    index           : this.index
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    titleCase(string) {
        var sentence = string.toLowerCase().split(" ");
        for(var i = 0; i< sentence.length; i++){
            sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
        }
        return sentence;
    }

    handleNewRecord = event => {
        event.preventDefault();
        this.showModal = true;
    }

    handleCancel = event => {
        event.preventDefault();
        this.showModal = false;
    }

    handleSuccess = event => {
        event.preventDefault();
        this.showModal = false;
        let recordId   = event.detail.id;
        this.hanleCreatedRecord(recordId);
    }

    hanleCreatedRecord = (recordId) => {
        getRecentlyCreatedRecord({
            recordId   : recordId,
            fields     : this.fields,
            objectName : this.objName
        })
        .then(result => {
            if(result){
                this.selectedRecord = {
                    FIELD1   : result[this.field],
                    Id       : recordId
                };
                const selectedEvent = new CustomEvent('lookup', {
                    bubbles    : true,
                    composed   : true,
                    cancelable : true,
                    detail: {
                        data : {
                            record          : this.selectedRecord,
                            recordId        : recordId,
                            currentRecordId : this.currentRecordId,
                            parentAPIName   : this.parentAPIName,
                            index           : this.index
                        }
                    }
                });
                this.dispatchEvent(selectedEvent);
            }
        })
        .catch(error => {
            console.error('Error: \n ', error);
        })
        .finally( ()=>{
            this.showModal = false;
        });
    }
}