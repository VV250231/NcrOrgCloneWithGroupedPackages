/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable eqeqeq */
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartjs from "@salesforce/resourceUrl/ChartDotJS";
import SitesDetails from "@salesforce/apex/PRM_YOYchartController.SubsSites";
import SitesHeader from "@salesforce/label/c.PRM_SubscriptionSites";

export default class PrmSites extends LightningElement {
  @track cmpload = false;
  @track PercentageSubsSites;
  @api acId;
  @track error;
  chartNew;
 // chart;
  //@track yearList = [];
  @track labelList = [];
 // @track colorlist = ["rgb (178,178,178)" , "rgb (240,144,80)" , "rgb(95,134,204)" ];
 @track colorlist = [];
  @track revenueList = [];


 // @track keys;
  destroyChart = false;
  chartjsInitialized = false;
  @track config = {};
  //@track data2;
  label = {
    SitesHeader
  };
  //@track growthRebateHalf;
  //@track currentYear;
  //@track previousYear;
  @wire(SitesDetails, { AccId: "$acId" }) Sitesdata({ error, data }) {
    if (data) {
      if (this.chartNew) {
        /*this.template.querySelector("canvas.externaldonut").innerHTML +=
          '';*/
        console.log("Destroyingggg!");
        this.chartNew.destroy();
      }
      console.log("Data Label: AAA ", data);
      //this.yearList = [];
      this.revenueList = [];
      this.colorlist = [];
      this.labelList = [];
      this.config = {};

      

     /*  this.revenueList.push(data.Subscription_Sites__c);
      this.revenueList.push(data.Traditional_Sites__c);
      this.revenueList.push(data.Subscription_Sites__c+data.Traditional_Sites__c); */
      if((data.Subscription_Sites__c!== undefined) || (data.Traditional_Sites__c!== undefined )){
        this.cmpload = true;
					var SubS = 0;
					var TradS = 0;
					if(data.Subscription_Sites__c!== undefined && data.Subscription_Sites__c>0 ){
							SubS = data.Subscription_Sites__c;
					}
					if(data.Traditional_Sites__c!== undefined && data.Traditional_Sites__c>0){
							TradS = data.Traditional_Sites__c;
					}
					
							
      let TotalSites = SubS+TradS;
					
      let revenueData = [{
        label: 'Total Sites',
        backgroundColor: '#b2b2b2',
        data: TotalSites,
      }, {
        label: 'Traditional Sites',
        backgroundColor: '#f09050',
        data: TradS
      }, {
        label: 'Subscription Sites',
        backgroundColor: '#5f86cc',
        data: SubS
      }];
      revenueData.forEach(element => {
        //alert(element.label);
//this.revenueList = revenueData;
this.revenueList.push(element.data);
this.colorlist.push(element.backgroundColor);
this.labelList.push(element.label);
//this.PercentageSubsSites = (data.Subscription_Sites__c/TotalSites*100);
      });
			this.PercentageSubsSites =0;
					if(TotalSites>0){
      this.PercentageSubsSites = ((SubS/TotalSites)*100).toFixed();
					}
//this.PercentageSubsSites = (data.Subscription_Sites__c/TotalSites*100).Math.round(decimal);
console.log("Data Label: revenueList " , this.revenueList);
      
    
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
            //label: this.labelList,
          }
        
      ],
      
         // datasets: this.revenueList,
              //backgroundColor: ["rgb (178,178,178)" , "rgb (240,144,80)" , "rgb95,134,204)" ],
              //backgroundColor: this.colorlist,
              //label:[ "Total Sites" , "Traditional Sites", "Subscription Sites"]
              //label: "$ (USD)"
            //}
          //],
         // labels: [" "]
          //labels: this.labelList
         labels: [ "Total" , "Traditional", "Subscription"]
        
        
        }
        ,
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
						//maintainAspectRatio: true,
          legend: {
            position: "bottom",
            display: false,
            //lables: this.labelList,
            //legendText : ['Total Sites' , 'Traditional Sites', 'Subscription Sites'],
          // labels: {usePointStyle: true},
        
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