/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, track, wire } from "lwc";
import REWARD_INCENTIVES from "@salesforce/label/c.REWARD_INCENTIVES";
import TIER_ATTAINMENT from "@salesforce/label/c.TIER_ATTAINMENT";
import AccountList from "@salesforce/apex/PRM_DashboardUserAccountProvider.getAccountListforCams";
import provisionUsers from "@salesforce/apex/PRM_DashboardUserAccountProvider.getOwnedUsers";
import provisionAccounts from "@salesforce/apex/PRM_DashboardUserAccountProvider.getOwnedAccounts";
export default class PRM_SLDashboard extends LightningElement {
  @track openmodel = false;
  @track ownedUsers = [];
  @track ownedAccounts = [];
  @track AccId;
  @track UserId;
  @track showAccountList = false;
  @track showDashboard = false;
  @track showAnime = false;
  @track showArrow = false;
  @track disableAccBox = false;
  @track enableAccErr = false;

  int = 0;

  label = {
    REWARD_INCENTIVES,
    TIER_ATTAINMENT
  };

  @wire(provisionUsers) Users({ error, data }) {
    if (data) {
      console.log("In here!!!!");
      for (let i = 0; i < data.length; i++) {
        this.ownedUsers = [
          ...this.ownedUsers,
          { label: data[i].Name, value: data[i].Id }
        ];
      }
    }
    if (error) {
      console.log("ERROR");
    }
  }

  @wire(provisionAccounts, { SelectedAcId: "$UserId" }) Accounts({
    error,
    data
  }) {
    this.int++;
    if (data) {
      if (this.showAnime) {
        this.showAnime = false;
        this.showArrow = true;
      }
      for (let i = 0; i < data.length; i++) {
        this.ownedAccounts = [
          ...this.ownedAccounts,
          { label: data[i].Name, value: data[i].Id }
        ];
      }
      console.log("ownedAccounts-: " + JSON.stringify(this.ownedAccounts));
      this.showAccountList = true;
    }
    if (error) {
      console.log("We got Error!: " + JSON.stringify(data));
      if (this.showAnime) {
        this.showAnime = false;
        this.showArrow = true;
      }
      console.log("Error!");
    }

    if (this.ownedAccounts.length === 0 && this.int === 1) {
      this.enableAccErr = false;
    } else if (this.ownedAccounts.length === 0 && this.int > 1) {
      this.enableAccErr = true;
    }

    if (this.ownedAccounts.length > 0) {
      console.log(
        "Setting enableAccErr : false, this.ownedAccounts: " +
          JSON.stringify(this.ownedAccounts).length
      );
      console.log("Length: " + this.ownedAccounts.length);
      this.enableAccErr = false;
    } else {
      console.log(
        "Setting enableAccErr : true, this.ownedAccounts: " +
          JSON.stringify(this.ownedAccounts)
      );
      console.log("Length: " + this.ownedAccounts.length);

      if (this.showAnime) {
        this.showAnime = false;
        this.showArrow = true;
      }
      this.disableAccBox = true;
    }
  }

  handleChangeUser(event) {
    this.showAnime = true;
    this.showArrow = false;
    this.UserId = event.target.value;
    this.ownedAccounts = [];
  }

  handleChangeAccount(event) {
    this.AccId = event.target.value;
    this.showDashboard = true;

    console.log("Changed to: " + this.AccId);
  }

  showhelp() {
    this.openmodel = true;
  }
  closeModal() {
    this.openmodel = false;
  }
}