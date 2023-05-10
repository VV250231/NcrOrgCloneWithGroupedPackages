import { LightningElement, wire, track, api } from "lwc";
import getNPSdata from "@salesforce/apex/prmGenericDataHelper.setNPSScore";
import npsHeaderLabel from "@salesforce/label/c.NetPromotorscore";
export default class PRM_NPSDetails extends LightningElement {
  @api acId;
  @track NPSData;
  @track ErrorData;
  label = {
    npsHeaderLabel
  };
  @wire(getNPSdata, { AccId: "$acId" }) getNPSdata({ data }) {
    if (data && data[0].Net_Promotor_Score__c) {
      this.NPSData = data[0].Net_Promotor_Score__c;
    } else {
      this.NPSData = "";
    }
  }
}