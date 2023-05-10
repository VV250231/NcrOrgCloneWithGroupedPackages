import { LightningElement, track, wire, api } from "lwc";
import REWARD_INCENTIVES from "@salesforce/label/c.REWARD_INCENTIVES";
import TIER_ATTAINMENT from "@salesforce/label/c.TIER_ATTAINMENT";
import HOSPSMB from "@salesforce/label/c.HOSPSMB";
import REV_PERFORMANCE from "@salesforce/label/c.REV_PERFORMANCE";
import YYYY_YTD_Solution_Revenue_Details from "@salesforce/label/c.YYYY_YTD_Solution_Revenue_Details";
/* eslint-disable no-console */
/* eslint-disable no-alert */
import getAccountId from "@salesforce/apex/PRM_DashboardUserAccountProvider.getCurrentPartnerAccount";
import dashboardVisibility from '@salesforce/apex/PRM_DashboardUserAccountProvider.dashboardVisibility';

import getDashboardVisibility from '@salesforce/apex/PRM_DashboardUserAccountProvider.getDashboardVisibility';

export default class ChannelProgramDashboard extends LightningElement {
  @track ShowHideSubsSites = false;
  @track showHidepercenRev = false;
  @track cmpload = false;
  @track loaded = false;
  @track AccId;
	@track currYear = new Date().getFullYear().toString();
  /* setcmploaded (event)
  {
    alert(cmploaded);
    this.cmploaded = event.detail;
    
  } */

  label = {
    REWARD_INCENTIVES,
    TIER_ATTAINMENT,
		REV_PERFORMANCE,
    YYYY_YTD_Solution_Revenue_Details
  };

  renderedCallback() {
    //this.loaded = true;
    this.dashboardLoading();
    console.log("Parents Rendered Callback");
  }

  // Getting the AccountId of Current user and Assigning it to the @API Enabled Attribute:
  // AccId. This AccId will be Passed-on to the child Graphical Components.
  @wire(getAccountId) RecieveId({ error, data }) {
   
    if (data) {
     // alert(data);
      this.AccId = data;
    }
    if (error) {
      alert("Current User has Access Issues!");
    }
  }

  @track dashboardLoaded;
  @track Tier_attainment_annual_revenue;
  @track Percent_revenue_net_new_customers;
  @track Growth_reward_gold_and_platinum_only;
  @track Market_development_funds_MDF;

  @wire(getDashboardVisibility) dashboardVisibilityWier({error, data}){
    
    if(data){
    
      
      /*
      this.loaded = true;
      this.Market_development_funds_MDF = data.Partner_User__r.Market_development_funds_MDF__c;
      window.console.log("=== Partner Program Industry  ====",data.Account.Partner_Program_Industry__c);

      if(data.Account.Partner_Program_Industry__c === 'HOSPITALITY' && data.Account.ISO_Country_Code__c === 'US'){

        this.dashboardLoaded =false; 
        window.console.log("=== Is Visable false ====");
        
      }else{

        this.dashboardLoaded =true;
        this.Tier_attainment_annual_revenue = data.Partner_User__r.Tier_attainment_annual_revenue__c;
        this.Percent_revenue_net_new_customers = data.Partner_User__r.Percent_revenue_net_new_customers__c;
        this.Growth_reward_gold_and_platinum_only = data.Partner_User__r.Growth_reward_gold_and_platinum_only__c;
        
      }
      */
      
      this.loaded = true;
      if(data.userRecord){
        this.Market_development_funds_MDF = data.userRecord.Market_development_funds_MDF__c;
      } 
      if(data.accountRecord)
	  {
     //1518
     // //now showing subscription sites chart only to users who belongs to profile Hospitality SMB Partner Manager instead of account condition
   if(data.usrPrfl!== undefined && data.usrPrfl!== null){
   // console.log("data.usrPrfl", data.usrPrfl);

		 // if(data.accountRecord.Account_Region__c === 'NAMER SMB' && data.accountRecord.LOB__c === 'HOSPITALITY' )
		  
        
			  this.ShowHideSubsSites = true;
        if(data.prmrevrecord.Subscription_Sites__c!== undefined || data.prmrevrecord.Traditional_Sites__c!== undefined)
        {
this.cmpload = true;

        }
        

		  }
      else
      {
        this.showHidepercenRev = true;
      }
      //EBA_SF-1435
       /* if(data.accountRecord.Partner_Program_Industry__c === 'HOSPITALITY' && data.accountRecord.ISO_Country_Code__c === 'US'){
          this.dashboardLoaded =false;           
          
        }*/
		//else
		//{
  
          this.dashboardLoaded =true;

          
          this.Tier_attainment_annual_revenue = data.userRecord.Tier_attainment_annual_revenue__c;
          this.Percent_revenue_net_new_customers = data.userRecord.Percent_revenue_net_new_customers__c;
          this.Growth_reward_gold_and_platinum_only = data.userRecord.Growth_reward_gold_and_platinum_only__c;          
        //}
      }
      
    } 

    if(error){
      this.loaded = false;
    }
  }

  //To hide/show revenue graph charts data on IPT dashboard in case of Hospitality inside US and vice-versa

  dashboardLoading() {
   /* dashboardVisibility()
      .then(result => {
          this.dashboardLoaded = result;
          this.error = undefined;
          this.loaded = true;
      })
      .catch(error => {
          this.error = error;
          this.dashboardLoaded = undefined;
          this.loaded = false;
      });
      */
  }
}