import { LightningElement, api, wire,track } from 'lwc';
import ENTITLEMENT_OBJECT from '@salesforce/schema/Account_Entitlements__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import getAccountEntitlementList from '@salesforce/apex/EntitlementSectionHandler.getAccountEntitlementList';



export default class EntitlementSection extends LightningElement {
    @api recordId;
    @track accountEntitlementList;
    @track entitlementObjInfo;

    @wire(getObjectInfo, { objectApiName: ENTITLEMENT_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            this.entitlementObjInfo = data;
        }

        if(error) console.log("Account Entitlement Object Info error>>",error);
    }
    
    @wire(getAccountEntitlementList,{accountRecordID : '$recordId'}) wireAccountEntitlement({data,error}){
        if(data){
            console.log("===Account Entitlement List==",data);
            this.accountEntitlementList = data;
        }

        if(error){
            console.log("===Account Entitlement List error==",error);
        }
    }

 
    
}