/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable eqeqeq */
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartjs from "@salesforce/resourceUrl/ChartDotJS";
import YOYdetails from "@salesforce/apex/PRM_YOYchartController.getYoyDetails2";
import yOYChartHeader from "@salesforce/label/c.YoYGrowth";
export default class chartDetail extends LightningElement {
  @api acId;
  @track error;
  chartNew;
  chart;
  @track yearList = [];
  @track colorlist = [];
  @track revenueList = [];
  @track keys;
  destroyChart = false;
  chartjsInitialized = false;
  @track config = {};
  @track data2;
  label = {
    yOYChartHeader
  };
  @track growthRebateHalf;
  @track currentYear;
  @track previousYear;
  @wire(YOYdetails, { AccId: "$acId" }) YOYdata({ error, data }) {
    if (data) {
      if (this.chartNew) {
        /*this.template.querySelector("canvas.externaldonut").innerHTML +=
          '';*/
        console.log("Destroyingggg!");
        this.chartNew.destroy();
      }
      console.log("Data Label: AAA ", data);
      this.yearList = [];
      this.revenueList = [];
      this.colorlist = [];
      this.config = {};
      data.forEach(element => {
        this.yearList.push(element.year);
        this.colorlist.push(element.color);
        this.revenueList.push(element.dataValue);
        this.growthRebateHalf = element.growthRebateHalf;
        if (element.year == new Date().getFullYear()) {
          this.currentYear = element.year;
        } else if (element.year == new Date().getFullYear() - 1) {
          this.previousYear = element.year;
        }
      });
      if (error) {
        console.log("Look it is error: ", error);
      }

      this.config = {
        type: "horizontalBar",
        data: {
          datasets: [
            {
              data: this.revenueList,
              backgroundColor: this.colorlist,
              label: "$ (USD)"
            }
          ],
          labels: this.yearList
        },
        options: {
          scales: {
            yAxes: [
              {
                categoryPercentage: 0.8,
                barPercentage: 0.8,
                ticks: {
                  // To set start limit of y axis of YOY
                  beginAtZero: false,
                  max: 100,
                  min: 0,
                  fontColor: "black",
                  fontStyle: "bold"
                }
              },
              {
                id: "y-axis-2",
                type: "category",
                display: false,
                categoryPercentage: 0.4,
                barPercentage: 1,
                position: "left",
                barThickness: 15,
                gridLines: {
                  offsetGridLines: false
                }
              }
            ],
            xAxes: [
              {
                ticks: {
                  // To set start limit of y axis of YOY
                  beginAtZero: true,
                  fontColor: "black",
                  min: 0,
                  callback: function(value) {
                    return Math.abs(value) > 999 && Math.abs(value) < 1000000
                      ? Math.sign(value) * (Math.abs(value) / 1000).toFixed(1) +
                          "k"
                      : Math.abs(value) >= 1000000
                      ? Math.sign(value) *
                          (Math.abs(value) / 1000000).toFixed(1) +
                        "M"
                      : Math.sign(value) * Math.abs(value);
                  }
                },
                barPercentage: 0.1
              }
            ]
          },
          responsive: true,
          legend: {
            position: "right",
            display: false
          },
          animation: {
            animateScale: true,
            animateRotate: true
          }
        }
      };
      const ctx = this.template.querySelector("canvas.donut").getContext("2d");
      // eslint-disable-next-line no-unused-vars
      this.chartNew = new window.Chart(ctx, this.config);
      this.destroyChart = true;
    }
  }
  renderedCallback() {
    console.log("Inside ChartDetail RenderedCallback");
    if (this.chartjsInitialized) {
      console.log("chartjsInitialized--InsideIf----", +this.chartjsInitialized);
      return;
    }
    console.log(
      "chartjsInitialized--Outside If BELOW IF----",
      +this.chartjsInitialized
    );
    this.chartjsInitialized = true;

    loadScript(this, chartjs)
      .then(() => {
        //const ctx = this.template
        //.querySelector("canvas.donut")
        //.getContext("2d");
        //this.chart = new window.Chart(ctx, this.config);
      })
      .catch(error => {
        this.error = error;
      });
  }
}