import { LightningElement, api, wire,track } from 'lwc';
import ENTITLEMENT_OBJECT from '@salesforce/schema/Account_Entitlements__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import getAccountEntitlementList from '@salesforce/apex/EntitlementSectionHierarchy.getAccountEntitlementList';


export default class EntitlementSection extends LightningElement {
    @api recordId;
    @track accountEntitlementList = [];
    @track accountEntitlementList2 = [];
    @track entitlementObjInfo;
    @track isSummeryView  = false;
    @track showTable  = false;

    @track isProdDesAsc = true;
    @track isActiveCountAsc = true;
    @track isHoldCountAsc = true;
    @track isExpCountAsc = true;
    @track isExpWarCountAsc = true;

    //sortedDirection = 'asc';
    sortedDirection = 'desc';
    sortedColumn;

    @wire(getObjectInfo, { objectApiName: ENTITLEMENT_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            this.entitlementObjInfo = data;            
        }

        if(error) console.log("Account Entitlement Object Info error>>",error);
    }
    
    @wire(getAccountEntitlementList,{accountRecordID : '$recordId'}) wireAccountEntitlement({data,error}){
        if(data){
            
            if(data.entitlementList.length > 0){
                this.showTable = true;
                console.log('Account RecordType Name --> '+data.entitlementList[0].Account__r.RecordType.Name);
                this.isSummeryView = true;
                /*if(data.entitlementList[0].Account__r.RecordType.Name == 'Enterprise'){
                    this.isSummeryView = true;
                }*/
            }
            this.accountEntitlementList = data.entitlementList;
            this.accountEntitlementList2 = [];
            this.accountEntitlementList2.push(data.wrap);
        }
        
        if(error){
            console.log("===Account Entitlement List error==",error);
        }
    }

    handleViewAll(){
        this.isSummeryView = false;
    }
    handleSummaryView(){
        this.isSummeryView = true;
    }
    handleSort(event){
        let columnName = event.currentTarget.dataset.id;
        
        if(this.sortedColumn == columnName){
            this.sortedDirection = this.sortedDirection == 'asc' ? 'desc' : 'asc';
        }else{
            this.sortedColumn = columnName;
            this.sortedDirection = 'asc';
        }        

        
        let columnInfo = this.entitlementObjInfo.fields[columnName];
        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
        let table = JSON.parse(JSON.stringify(this.accountEntitlementList));
       
        table.sort((a, b) => {
            a = a[columnName] ? a[columnName] : ''; // Handle null values
            b = b[columnName] ? b[columnName] : '';
            
            if(columnInfo.dataType.toUpperCase() == 'DOUBLE') {               
                return (this.sortedDirection == 'asc' ? b-a : a-b);
                
            } else if (columnInfo.dataType.toUpperCase() == 'TEXTAREA') {
                let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
                
                if(b > a) {
                    return (this.sortedDirection == 'asc' ? -1 : 1);    
                } else {
                    return (this.sortedDirection == 'asc' ? 1 : -1); 
                }                  
            }
        });
        this.accountEntitlementList = table;

        let columnLabel = event.currentTarget.dataset.label;
        this.isProdDesAsc = (columnLabel == 'Primary Product Desc' ? !this.isProdDesAsc : this.isProdDesAsc);
        this.isActiveCountAsc = (columnLabel == 'Active Count' ? !this.isActiveCountAsc : this.isActiveCountAsc);
        this.isHoldCountAsc = (columnLabel == 'Hold Count' ? !this.isHoldCountAsc : this.isHoldCountAsc);
        this.isExpCountAsc = (columnLabel == 'Expired Count' ? !this.isExpCountAsc : this.isExpCountAsc);
        this.isExpWarCountAsc = (columnLabel == 'Expired Warranty Count' ? !this.isExpWarCountAsc : this.isExpWarCountAsc);

    }
}