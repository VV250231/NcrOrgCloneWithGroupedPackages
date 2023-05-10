import { LightningElement, wire, track } from "lwc";

import getMarketShareCaptureMap from "@salesforce/apex/PRM_MarketCaptureProgramController.getMarketShareCaptureMap";
export default class PrmMarketCaptureProgram extends LightningElement {
  @track financialData = [];
  @track hospitalityData;
  @track retailData;

  @wire(getMarketShareCaptureMap) wireMarketShareCapture({ data, error }) {
    if (data) {
      window.console.log("==== Market Share Capture ====", data);
      for (const recordKey of Object.keys(data)) {
        if (recordKey == "Financial") {
          this.financialData = data[recordKey]; 
        }

        if (recordKey == "Hospitality") {
          this.hospitalityData = data[recordKey]; 
        }

        if (recordKey == "Retail") {
          this.retailData = data[recordKey]; 
        }
      }
    } 
  }
}