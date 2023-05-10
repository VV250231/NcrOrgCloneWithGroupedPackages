import { LightningElement, wire, track, api } from "lwc";

import { loadStyle, loadScript } from "lightning/platformResourceLoader";

import prmAnyChart from "@salesforce/resourceUrl/prmAnyChart";
import GetRevenueDetailsbyTypeDataValues from "@salesforce/apex/PRM_YOYchartController.GetRevenueDetailsbyTypeData";
import Annual_Revenue from "@salesforce/label/c.Annual_Revenue";

/* eslint-disable no-console */
/* eslint-disable no-alert */
export default class PrmPercentRevenueNetNewCustomer extends LightningElement {
  @api acId; // Getting Set from Parent Component.
  @track revenuedata;
  chart;
 
  @track hardware=0;
  @track software=0;
  @track PS=0;
  @track TS=0;
 // @track saas=0;
  @track RecurringSW=0;
  @track RecurringPS=0;
  label = {
    Annual_Revenue
  };

  // eslint-disable-next-line @lwc/lwc/no-async-operation
  connectedCallback() {
    console.log("Childs Connectedcallback");
  }

  renderedCallback() {
    console.log("Childs RenderedCallback");
    Promise.all([
      loadScript(this, prmAnyChart + "/anychart/Chart.js"),
      loadStyle(this, prmAnyChart + "/anychart/Chart.min.css")
    ])
      .then(value => {
        let ctx = this.template.querySelector('[data-id^="pieChart"]').getContext('2d');
        // eslint-disable-next-line no-undef
        {
          if (this.hardware == 0 && this.software==0 && this.PS ==0 && this.TS==0 && this.RecurringSW==0 && this.RecurringPS==0) {
            this.revenuedata = false;

            console.log("killing chart");
            console.log("revenuedata"+revenuedata);
            this.chart.destroy();
          } else {
            console.log("prepare chart");
            this.chart = new Chart(ctx, {
              
              type: "pie",
              data: {
                labels: ["Hardware", "Software","Recurring SW","Professional Services","Recurring PS","TS"],
                datasets: [
                  {
                    data: [
                      this.hardware,
                      this.software,
                      this.RecurringSW,
                     // this.saas,
                      this.PS,
                      this.RecurringPS,
                      this.TS  
                    ],
                    backgroundColor: ["#4775CA", "#71B346","#F07622","#FFC609","#A5A5A5","#5197D7"],
										//backgroundColor: '#FFFFFF',
                    borderWidth:0 
                  }
                ]
              },
              options: {
              legend: {
                align:"center",
                position: "right",
                display: true,
                padding:400,
                labels:{
                  boxWidth:10,
                  fontSize:10,
                  padding:5,
                  
                }
              },
              layout:{
                padding:{
                  left:0
                }
              },
              
              responsive:true,
              tooltips:{
                enabled:true,
                mode:"point",
              },
              plugins:{
                lables:{
                  align:"center",
                  render:"value",
                  fontSize:12,
                }
              },
              }
              
            });
          }
        }
      })
      .catch(error => {
        window.console.log(" === catch Value ===", error);
      });
  }

  @wire(GetRevenueDetailsbyTypeDataValues, { accId: "$acId" }) wirepartnerRevenue({
    data,
    error
  }) {
    if (JSON.stringify(data) == "null") {
      
      console.log("Null error condition with string");
    }
    if (data) {
      
      if (this.revenuedata) {
        this.revenuedata = [];
      }
      this.revenuedata = data;

      this.hardware = data.hw;
      this.software = data.sw;
      this.RecurringSW=data.Rsw;
      this.PS = data.ps;
      this.RecurringPS=data.Rps;
      this.TS = data.ts;
      //this.saas = data.saas;
      
      

      console.log("hw: " + this.hardware);
      console.log("sw: " + this.software);
      console.log("Rsw:" +this.RecurringSW);


      
    } else if (error) {
      this.revenuedata = [];
      this.chart.destroy();
     
      window.console.log(" === Revenue error ===", error);
    }
  }

  convertnumber(value) {
    let K = 1000;
    let M = 1000000;
    let B = 1000000000;
    let T = 1000000000000;
    let numberFormat = "";

    if (value <= 0) {
      numberFormat = 0 + "";
    } else if (value > 0 && value < 999) {
      numberFormat = value + "";
    } else if (value > 999 && value <= 999999) {
      numberFormat = this.removedotzero_K((value / K).toFixed(2) + "K");
    } else if (value > 999999 && value <= 999999999) {
      numberFormat = this.removedotzero_M((value / M).toFixed(2) + "M");
    } else if (value > 999999999 && value <= 999999999999) {
      numberFormat = this.removedotzero_B((value / B).toFixed(2) + "B");
    } else if (value > 999999999999 && value <= 999999999999999) {
      numberFormat = this.removedotzero_T((value / T).toFixed(2) + "T");
    } else {
      numberFormat = value + "";
    }
    return numberFormat;
  }

  removedotzero_K(value) {
    let temp = value;
    if (value.includes(".00K")) {
      temp = value.replace(".00K", "K");
    }

    if (value.includes(".0K")) {
      temp = value.replace(".0K", "K");
    }
    return temp;
  }
  removedotzero_M(value) {
    let temp = value;
    if (value.includes(".00M")) {
      temp = value.replace(".00M", "M");
    }

    if (value.includes(".0M")) {
      temp = value.replace(".0M", "M");
    }
    return temp;
  }

  removedotzero_B(value) {
    let temp = value;
    if (value.includes(".00B")) {
      temp = value.replace(".00B", "B");
    }

    if (value.includes(".0B")) {
      temp = value.replace(".0B", "B");
    }
    return temp;
  }

  removedotzero_T(value) {
    let temp = value;
    if (value.includes(".00T")) {
      temp = value.replace(".00T", "T");
    }

    if (value.includes(".0T")) {
      temp = value.replace(".0T", "T");
    }
    return temp;
  }
}