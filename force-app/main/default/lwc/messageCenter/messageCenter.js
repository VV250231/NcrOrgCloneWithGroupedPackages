/* eslint-disable @lwc/lwc/no-inner-html */
/* Class Name : Message Center
 * Date : 05/09/19
 * Description : This Class  is used in Partner Portal for displaying Message for
 *               Channel Partner under 2020 Program
 * DeveloperName : Deeksharth Sriwastava
 */
import { LightningElement, wire, api } from "lwc";
import getMessageInfo from "@salesforce/apex/MessageCenter.getMessageInfo";
export default class MessageCenter extends LightningElement {
  @api acId;
  writeMarkup = true;
  @wire(getMessageInfo, { AccId: "$acId" })
  wiredMessage({ error, data }) {
    if (data) {
      this.template.querySelector(".desc1").innerHTML = "";
      let mData = JSON.stringify(data);
      // eslint-disable-next-line vars-on-top
      var parseData = JSON.parse(mData);
      let i = 0;
      if (parseData.length > 0) {
        // eslint-disable-next-line guard-for-in
        for (i in parseData) {
          if (parseData[i].Description_box_1__c !== null)
            this.template.querySelector(".desc1").innerHTML +=
              '<div class="messageText">' +
              parseData[i].Description_box_1__c +
              "</div>";
          if (
            parseData[i].Description_box_2__c !== null &&
            parseData[i].Description_box_2__c != undefined
          )
            this.template.querySelector(".desc1").innerHTML +=
              '<div class="messageText">' +
              parseData[i].Description_box_2__c +
              "</div>";
          if (
            parseData[i].Description_box_3__c !== null &&
            parseData[i].Description_box_3__c != undefined
          )
            this.template.querySelector(".desc1").innerHTML +=
              '<div class="messageText">' +
              parseData[i].Description_box_3__c +
              "</div>";
          if (
            parseData[i].Description_box_4__c !== null &&
            parseData[i].Description_box_4__c != undefined
          )
            this.template.querySelector(".desc1").innerHTML +=
              '<div class="messageText">' +
              parseData[i].Description_box_4__c +
              "</div>";
        }
      } else {
        this.template.querySelector(".desc1").innerHTML +=
          '<div class="messageText">' + "No Message to Display" + "</div>";
      }
    } else if (error) {
      console.log("error data", error);
    }
  }
}