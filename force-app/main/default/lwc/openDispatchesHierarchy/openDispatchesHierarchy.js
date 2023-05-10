import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getDispatch from '@salesforce/apex/OpenDispatchesHierarchyHandler.getDispatch';

export default class OpenDispatchesHierarchy extends LightningElement {
    @api recordId;
    allDispatchList;
    @track getDispatchList;
    @track summaryView = false;
    @track regionOptions =[];
    
    @wire(getDispatch,{accountID : '$recordId'}) wireDispatch({data,error}) {
        if(data){ 
            this.getDispatchList = data;
            this.allDispatchList = data;
            console.log('@@@@');
            console.log(JSON.stringify(data));
            
            if(this.allDispatchList != null && this.allDispatchList.length > 0) {                
                this.summaryView = this.allDispatchList[0].isSummaryView; 
                
                if(this.summaryView) {
                    let regions =[];
                    regions.push({value :"All", label :"All"});
                    for(let i=0;i<this.allDispatchList.length;i++) {
                        if (this.allDispatchList[i].Region) {
                            regions.push({value :this.allDispatchList[i].Region, label :this.allDispatchList[i].Region});
                        }
                    }
                    this.regionOptions  = regions;
                }  
            }
        }
        if(error){
            window.console.log("==== Open Help Desk Error ==== : ",error);
        }
    }



    handleRegionChange(event) {
        const selectRegion = event.detail.value; 
    
        if(selectRegion == 'All')  {
            this.getDispatchList = this.allDispatchList;
        } else {
            let filteredDispatches = [];
            for(let i=0;i<this.allDispatchList.length;i++) {
                if(this.allDispatchList[i].Region == selectRegion) {
                    filteredDispatches.push(this.allDispatchList[i]);
                }
            }
            this.getDispatchList = filteredDispatches;
        }
        
    }
}