import { LightningElement, wire, track, api } from "lwc";

import { loadStyle, loadScript } from "lightning/platformResourceLoader";

import prmAnyChart from "@salesforce/resourceUrl/prmAnyChart";
import getDoughnutChartvalues from "@salesforce/apex/PRM_DoughnutChartCon.getDoughnutChartData";
import Annual_Revenue from "@salesforce/label/c.Annual_Revenue";

/* eslint-disable no-console */
/* eslint-disable no-alert */
export default class PrmDoughnutChart extends LightningElement {
  @api acId; // Getting Set from Parent Component.
  @track revenuedata;
  chart;
  @track solutionRevenu = "";
  @track nextYearRevenu = "";
  @track targetRevenu = "";
  @track ytdSolutionRevenue = 0;
  @track nextTierMinTargetRevnue = 0;
  @track onlyCurrentLevel = false;
  @track nextLevelGraph = false;
  @track nextToNextLevelGraph = false;
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
        let ctx = this.template
          .querySelector('[data-id^="doughnutChart"]')
          .getContext("2d");
        // eslint-disable-next-line no-undef
        {
          if (this.solutionRevenu == 0) {
            this.chart.destroy();
            console.log("killing chart");
          } else {
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
                labels: ["Target Rev", "Solution Rev"],
                datasets: [
                  {
                    data: [
                      this.nextTierMinTargetRevnue,
                      this.ytdSolutionRevenue
                    ],
                    backgroundColor: ["rgb(100,108,100)", "rgb(84,185,72)"],
										//backgroundColor: '#FFFFFF',
                    borderWidth: 1
                  }
                ]
              },
              options: {
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
                text: this.convertnumber(this.ytdSolutionRevenue)
              }
            });
          }
        }
      })
      .catch(error => {
        window.console.log(" === catch Value ===", error);
      });
  }

  @wire(getDoughnutChartvalues, { accId: "$acId" }) wirepartnerRevenue({
    data,
    error
  }) {
    if (JSON.stringify(data) == "null") {
      this.solutionRevenu = 0;
      this.nextLevelGraph = false;
      this.nextToNextLevelGraph = false;
      this.onlyCurrentLevel = false;
      console.log("Null error condition with string");
    }
    if (data) {
      this.nextLevelGraph = false;
      this.nextToNextLevelGraph = false;
      this.onlyCurrentLevel = false;

      console.log(
        "YTD_Solution_Revenue: " + JSON.stringify(data.YTD_Solution_Revenue)
      );
      console.log("currentLevel: " + JSON.stringify(data.currentLevel));
      console.log("nextLevel: " + JSON.stringify(data.nextLevel));
      console.log("nextToNextLevel: " + JSON.stringify(data.nextToNextLevel));
      /*if (this.chart) {
        console.log("Destroying Donut Chart!!");
        this.chart.destroy();
      }*/
      if (this.revenuedata) {
        this.revenuedata = [];
      }
      this.revenuedata = data;
      if (
        this.revenuedata.YTD_Solution_Revenue &&
        this.revenuedata.YTD_Solution_Revenue.Total_Solution_Revenue__c
      ) {
        //showing solution revenue in form of english number format. like 20K, 20M etc.
        this.solutionRevenu = this.convertnumber(
          this.revenuedata.YTD_Solution_Revenue.Total_Solution_Revenue__c
        );
        // Showing actural amount. like 20000. This makes Green Part of the graph.
        if (
          this.revenuedata.YTD_Solution_Revenue.Total_Solution_Revenue__c <= 0
        ) {
          this.ytdSolutionRevenue = 0;
        } else {
          this.ytdSolutionRevenue = this.revenuedata.YTD_Solution_Revenue.Total_Solution_Revenue__c;
        }
      } else {
        this.solutionRevenu = 0;
      }
      console.log("this.solutionRevenu::: " + this.solutionRevenu);
      if (this.revenuedata.nextLevel) {
        //showing solution revenue in form of english number format. like 20K, 20M etc.
        this.nextYearRevenu = this.convertnumber(
          this.revenuedata.nextLevel.targetToMinRevenue
        );
        // if (this.revenuedata.nextLevel.targetToMinRevenue !== 0) {
        this.nextLevelGraph = true;
        // Showing actural amount. like 20000
        this.nextTierMinTargetRevnue = this.revenuedata.nextLevel.targetToMinRevenue;
        //}
      } else {
        this.nextYearRevenu = "0";
        this.nextLevelGraph = false;
      }

      if (this.revenuedata.nextToNextLevel) {
        //showing solution revenue in form of english number format. like 20K, 20M etc.
        this.targetRevenu = this.convertnumber(
          this.revenuedata.nextToNextLevel.targetToMinRevenue
        );
        //if (this.revenuedata.nextToNextLevel.targetToMinRevenue !== 0) {
        this.nextToNextLevelGraph = true;

        //}
      } else {
        this.targetRevenu = "0";
        this.nextToNextLevelGraph = false;
      }

      // If there is not next tier level than will show chart based on current level
      if (!this.revenuedata.nextLevel && !this.revenuedata.nextToNextLevel) {
        console.log("Console 1");
        this.onlyCurrentLevel = true;
        if (
          this.revenuedata.currentLevel &&
          this.revenuedata.currentLevel.targetToMinRevenue
        ) {
          console.log("Console 2");
          //showing solution revenue in form of english number format. like 20K, 20M etc.
          this.nextYearRevenu = this.convertnumber(
            this.revenuedata.currentLevel.targetToMinRevenue
          );
          // Showing actural amount. like 20000
          this.nextTierMinTargetRevnue = this.revenuedata.currentLevel.targetToMinRevenue;
        } else {
          this.nextYearRevenu = "0";
        }
      }
    } else if (error) {
      this.revenuedata = [];
      this.solutionRevenu = 0;
      this.chart.destroy();
      this.nextLevelGraph = false;
      this.nextToNextLevelGraph = false;
      this.onlyCurrentLevel = false;
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