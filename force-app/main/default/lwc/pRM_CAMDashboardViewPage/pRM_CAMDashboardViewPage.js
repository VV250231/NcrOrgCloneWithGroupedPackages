/* eslint-disable no-alert */
import { LightningElement, track, wire } from "lwc";
import REWARD_INCENTIVES from "@salesforce/label/c.REWARD_INCENTIVES";
import TIER_ATTAINMENT from "@salesforce/label/c.TIER_ATTAINMENT";
import AccountList from "@salesforce/apex/PRM_DashboardUserAccountProvider.getAccountListforCams";
/* eslint-disable no-console */

export default class PRM_CAMDashboardViewPage extends LightningElement {
  @track AccId;
  @track openmodel = false;
  @track showDashboard = false;
  label = {
    REWARD_INCENTIVES,
    TIER_ATTAINMENT
  };
  @track CAMs = [];
  //{ label: "Ritesh's Account", value: "0016C00000Fvi9fQAB" },
  // { label: "Partner Demo Account", value: "0016C00000FFpARQA1" },
  //{ label: "Naman's Account", value: "0016C00000FwQJGQA3" }
  // Get Accounts that the current user owns, which are:
  // Type: Partner
  @wire(AccountList) recieveCAMS({ error, data }) {
    console.log("CALLED ");
    if (data) {
      console.log("Data:===: " + JSON.stringify(data));
      for (let i = 0; i < data.length; i++) {
        console.log("Id: " + data[i].Id);
        console.log("Name: " + data[i].Name);
        this.CAMs = [...this.CAMs, { label: data[i].Name, value: data[i].Id }];
      }
      console.log("this.CAMs =======: " + this.CAMs);
      //
    } else if (error) {
      console.log("In CAM Dashboard load err" + error);
      //
    }
  }

  showhelp() {
    this.openmodel = true;
  }
  closeModal() {
    this.openmodel = false;
  }

  handleChange(event) {
    this.AccId = event.target.value;
    this.showDashboard = true;
    console.log("Changed to: " + this.AccId);
  }
  /*connectedCallback(){
    this.template.querySelector(
      '[id^="opaque"]'
    ).style.backgroundColor = 
  }*/
  get options() {
    return this.CAMs;
  }
}