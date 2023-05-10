import { LightningElement, wire, track, api } from "lwc";

import { loadStyle, loadScript } from "lightning/platformResourceLoader";

import prmAnyChart from "@salesforce/resourceUrl/prmAnyChart";
import Rev_Sub_Perf from "@salesforce/label/c.Rev_Sub_Perf";
import getPartnerRevenueByYear from "@salesforce/apex/PRM_RevenueDataController.getPartnerRevenueByYear";

/* eslint-disable no-console */
/* eslint-disable no-alert */
export default class PrmDoughnutChart extends LightningElement {
  @api acId; // Getting Set from Parent Component.
  @track revenuedata;
  chart;
  @track YTDRevenu = "0";
  @track QuotaRevenu = "0";
  @track QuotaData = 0;
  @track YTDOrderData = 0;
  @track year = new Date().getFullYear().toString();
  @track dataAvail = true;
  @track msg;
  label = {
    Rev_Sub_Perf
  };

  // eslint-disable-next-line @lwc/lwc/no-async-operation
  connectedCallback() {
    console.log("Childs Connectedcallback");
  }

  renderedCallback() {
			if(this.chart){
			this.chart.destroy();
			}
    console.log("Childs RenderedCallback");
    Promise.all([
      loadScript(this, prmAnyChart + "/anychart/Chart.js"),
      loadStyle(this, prmAnyChart + "/anychart/Chart.min.css")
    ])
      .then(value => {
        let ctx = this.template
          .querySelector('[data-id^="doughnutChart"]')
          .getContext("2d");
        // eslint-disable-next-line no-undef
         if (this.QuotaData == -1&&this.YTDOrderData==-1) {
            this.chart.destroy();
		   this.dataAvail = false;
		   this.msg="You do not have data in this section to display results!"
            console.log("killing chart");
          }else if(this.QuotaData == -1){
							this.chart.destroy();
							console.log("hello two");
			this.dataAvail = false;
		   this.msg="Annual Quota Target data is not available!"
		  }else if(this.YTDOrderData == -1){
					this.chart.destroy();
					console.log("hello three");
			this.dataAvail = false;
		   this.msg="Actual YTD Order data is not available!";
		  }
		  else {
					console.log("hello four");
					this.dataAvail=true;
            this.chart = new Chart(ctx, {
              plugins: [
                {
                  beforeDraw: function(chart, options) {
                    // eslint-disable-next-line vars-on-top
                    var width = chart.chart.width,
                      height = chart.chart.height,
                      ctx = chart.chart.ctx;
                    ctx.restore();
                    // eslint-disable-next-line vars-on-top
                    var fontSize = (height / 100).toFixed(2);
                    ctx.font = "bold " + fontSize + "em sans-serif";
                    //ctx.font = "32px em Comic Sans MS";
                    ctx.textBaseline = "middle";
                    ctx.fillStyle = "#54B948";
                    // eslint-disable-next-line vars-on-top
                    var text = chart.config.centerText.text,
                      textX = Math.round(
                        (width - ctx.measureText(text).width) / 2
                      ),
                      textY = height / 2;
                    ctx.fillText(text, textX, textY);
                    ctx.save();
                  }
                }
              ],
              type: "doughnut",
							
              data: {
								labels: [this.QuotaRevenu,this.YTDRevenu],
                datasets: [
                  {
                    data: [
                      this.YTDOrderData,
												this.QuotaData,
                    ],
                    backgroundColor: ["rgb(100,108,100)", "rgb(84,185,72)"],
                    borderWidth: 1
                  }
                ]
              },
              options: {
									tooltips:{
											callbacks: {
													label: function(tooltipItem, data) {
															let label = data.labels[tooltipItem.index] || '';
															return label;
													}
											}
									},
                cutoutPercentage: 60,
                responsive: true,
                maintainAspectRatio: true,
                rotation: -0.5 * Math.PI,
                animateScale: true,
                legend: {
                  display: false
                }
              },
              centerText: {
                display: true,
                text: this.QuotaData+'%'
              }
            });
		  }
      })
      .catch(error => {
        window.console.log(" === catch Value ===", error);
      });
  }

  @wire(getPartnerRevenueByYear, {  accountId: "$acId",year:"$year" }) wirepartnerRevenue({
    data,
    error
  }) {
			  console.log("hello");
			console.log( data);
    if (JSON.stringify(data) == "null") {
      
      console.log("Null error condition with string");
    }
    if (data) {
     	if (this.revenuedata) {
        this.revenuedata = [];
      }
      this.revenuedata = data;
				console.log("quota"+this.revenuedata.Quota__c);
				console.log("YTDOrderData"+this.revenuedata.Order_YTD__c)
				if(this.revenuedata.Quota__c===undefined){
						this.QuotaData = -1;
				}
				if(this.revenuedata.Order_YTD__c===undefined){
					this.YTDOrderData =-1;
				}
      if ( this.revenuedata.Quota__c!==undefined &&  this.revenuedata.Quota__c>=0&&
       this.revenuedata.Order_YTD__c!==undefined&&this.revenuedata.Order_YTD__c>=0
      ) {
        //showing solution revenue in form of english number format. like 20K, 20M etc.
        this.QuotaRevenu = this.convertnumber(
          this.revenuedata.Quota__c
        );
					
        // Showing actural amount. like 20000. This makes Green Part of the graph.
        if (
          this.revenuedata.Quota__c <= 0
        ) {
          this.QuotaData = 0;
        } else {
          this.QuotaData = (this.revenuedata.Order_YTD__c/this.revenuedata.Quota__c*100).toFixed();
        }
        //showing solution revenue in form of english number format. like 20K, 20M etc.
        this.YTDRevenu = this.convertnumber(
          this.revenuedata.Order_YTD__c
        );
        // if (this.revenuedata.nextLevel.targetToMinRevenue !== 0) {
        // Showing actural amount. like 20000
					if(this.QuotaData<=100){
        this.YTDOrderData = 100-this.QuotaData;}
					else{
							this.YTDOrderData =0;
					}
        //}
      } 
      else {
        this.QuotaRevenu = "0";
					this.YTDRevenu = "0";
						/*this.QuotaData = 0;
				this.YTDOrderData = 0;*/
      }
		 

      

 
    } else if (error) {
      	this.revenuedata = [];
				if(this.chart){
				this.chart.destroy();
				}
				this.YTDRevenu = "0";
				this.QuotaRevenu = "0";
				this.QuotaData = 0;
				this.YTDOrderData = 0;
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