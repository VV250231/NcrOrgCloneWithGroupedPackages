import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getHelpDeskCases from '@salesforce/apex/OpenHelpDeskHierarchy.getHelpDeskCases';

export default class OpenHelpDeskHierarchy extends LightningElement {
    @api recordId;
    allHelpDeskCases;
    @track getHelpDeskCases;
    @track summaryView = false;
    @track regionOptions =[];

    @wire(getHelpDeskCases,{accountID : '$recordId'}) wireHelpDeskCases({data,error}) {
        if(data){ 
           
            this.getHelpDeskCases = data;
            this.allHelpDeskCases = data;

            if(this.allHelpDeskCases != null && this.allHelpDeskCases.length > 0) {                
                this.summaryView = this.allHelpDeskCases[0].isSummaryView; 
                
                if(this.summaryView) {
                    let regions =[];
                    regions.push({value :"All", label :"All"});
                    for(let i=0;i<this.allHelpDeskCases.length;i++) {
                        regions.push({value :this.allHelpDeskCases[i].Region, label :this.allHelpDeskCases[i].Region});
                    }
                    this.regionOptions  = regions;
                }  
            }
        }
        if(error){
            console.log("== OpenHelpDeskCases==",error);
        }
    }

    handleRegionChange(event) {
        const selectRegion = event.detail.value; 
        
        if(selectRegion == 'All')  {
            this.getHelpDeskCases = this.allHelpDeskCases;
        } else {
            let filteredHelpDeskCases = [];
            for(let i=0;i<this.allHelpDeskCases.length;i++) {
                if(this.allHelpDeskCases[i].Region == selectRegion) {
                    filteredHelpDeskCases.push(this.allHelpDeskCases[i]);
                }
            }
            this.getHelpDeskCases = filteredHelpDeskCases;
        }
    }
}