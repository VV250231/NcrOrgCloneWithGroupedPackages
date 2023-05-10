import { LightningElement, wire, api, track } from "lwc";
import getPartnerInfo from "@salesforce/apex/partnerInformationCon.getPartnerInfo";
import TIME_ZONE from '@salesforce/i18n/timeZone';
export default class PartnerInformation extends LightningElement {
  @api acId;
  @wire(getPartnerInfo, { AccId: "$acId" }) accountinfo;
  @track timezone = TIME_ZONE;
}