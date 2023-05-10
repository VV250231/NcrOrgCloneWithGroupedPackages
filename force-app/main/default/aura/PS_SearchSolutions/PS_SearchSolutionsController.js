({
	doInit : function(component, event, helper) {
		helper.getSolutionName(component, event, helper);
	},
    SearchSolution : function(component, event, helper) {
         
         component.set("v.ToggleSearch",'show'); 
		//document.getElementById("searchsolutionwindow").style.display = "block";
        //document.getElementById("grayoutsolutionbackground").style.display = "block";
	},
    CancelSolutionSearch : function(component, event, helper) {
         component.set("v.noOfProductCount",0); 
         var abc=new Array();
         component.set("v.prodname",abc);
        component.set("v.selItem",abc);
        component.set("v.ToggleSearch",'hide'); 
		//document.getElementById("searchsolutionwindow").style.display = "none";
        //document.getElementById("grayoutsolutionbackground").style.display = "none";
	},
    selectChanged : function(component, event, helper) {
       
	},
    onSolutionSelect : function(component, event, helper) { 
        if(event.getParam("Action")== 'Account Selection'){
            console.log("inside account selection");
            helper.getProductList(component, event, helper); 
        }else{
            var abc=new Array();
           component.set("v.prodname",abc); 
            
           component.set("v.noOfProductCount",0); 
          
        }
            
	},
    fireCheckAllCheckboxes : function(component, event, helper){
            var FireSelectAll = event.getSource();
       
        if(component.get("v.noOfProductCount")!=0){
          if(FireSelectAll.get("v.value")){
                helper.fireCheckAllCheckboxes(component, event, helper);
            }else{
                helper.fireUncheckAllCheckboxes(component, event, helper);
            }  
        }
     },
    SingleFavProduct: function(component, event, helper){ 	         
            helper.SingleFavProduct(component,event,helper);  
    },
    SingleUnFavProduct: function(component, event, helper){            
            helper.SingleUnFavProduct(component,event,helper); 
     },
        
     SingleScheduleProduct: function(component, event, helper){
                
            helper.SingleScheduleProduct(component,event,helper);    
      },
       
      SingleUnScheduleProduct: function(component, event, helper){                
            helper.SingleUnScheduleProduct(component,event,helper);    
      },
    showAlertMessage:function(component, event, helper){
        var idUnschedule = event.currentTarget;
        var iddx = idUnschedule.dataset.ids;
        component.set("v.unScheduleId", iddx);

        var idd = component.get("v.unScheduleId") ; 
         document.getElementById('SolutionModal').style.display='block';
         document.getElementById('SolutiongreyBackground').style.display='block';

     },
    closeAlertWindow:function(component, event, helper){
        document.getElementById('SolutionModal').style.display='none';
        document.getElementById('SolutionBulkModal').style.display='none';
        document.getElementById('SolutiongreyBackground').style.display='none';

        var checkedProds = component.find( "TheCheckBox" );
        var selectedprod = [];
        for (var i = 0; i < component.find( "TheCheckBox" ).length ; i++){  
            if(component.find( "TheCheckBox" )[i].get("v.value") == true){  
                component.find( "TheCheckBox" )[i].set("v.value",false); 
                
            }
        }
       /*for (var j = 0; j < component.get("v.prodname").length; j++) {
            for (var k = 0; k < selectedprod.length ; k++){  
                if(selectedprod[k] == component.get("v.prodname")[j].prd.Id){  
                    component.get("v.prodname")[j].HasSchedule=true;  
                }
            }                
        }*/
        
    },
     bulkfavourite: function(component, event, helper){
         if(component.get("v.noOfProductCount")!=0){
            if(component.find("SelectAllCheckBox").get("v.value") ){
             
				helper.bulkfavourite(component,event,helper); 
             }
             else if(component.find("SelectAllCheckBox").get("v.value")==false){          
                   helper.bulkfavourite(component,event,helper); 
              }  
         }
                
     },
    bulkSchedule: function(component, event, helper){ 
        console.log(component.get("v.noOfProductCount"));
        if(component.get("v.noOfProductCount")>0){
           if(component.find("SelectAllCheckBox").get("v.value") ){
			       helper.bulkSchedule(component,event,helper); 
           }else if(component.find("SelectAllCheckBox").get("v.value")==false){
               helper.bulkSchedule(component,event,helper);
           } 
        }else{
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "There are no product in list.",
                    "Category" : "Warning",
                    "isShow" : "True"
                });
             FloatMsgEvent.fire(); 
        }    
    },
    BulkunScheduleProduct:function(component,event,helper){
        helper.BulkunScheduleProduct(component,event,helper);
        
    },
    addSchedule :function(component,event,helper){
        //document.getElementById('searchsolutionwindow').style.display='None';
        //document.getElementById('grayoutsolutionbackground').style.display='None';
        var isSchedule=false;
        var checkedProds = component.find( "TheCheckBox" );
        
        var prodIds = [];
        var scheduleNew=[];
        //alert(component.get("v.prodname").length);
        console.log(component.get("v.prodname").length);
        if(component.get("v.prodname").length==0){
           var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "There are no product in cart.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire(); 
          return;  
        }
        if(component.get("v.prodname").length==1){
           if(checkedProds[0]){ 
               if(checkedProds[0].get("v.value") == true){
                   prodIds.push(checkedProds[0].get("v.text"));  
               }
                
           }else{
               if(checkedProds.get("v.value") == true){
                   prodIds.push(checkedProds.get("v.text"));  
               }
           } 
        }
        else if(component.get("v.prodname").length>1){
           for (var i = 0; i < checkedProds.length ; i++){ 
            console.log(checkedProds[i].get("v.value"));
            if(checkedProds[i].get("v.value") == true){  
                prodIds.push(checkedProds[i].get("v.text"));  
            }
          } 
        }
        
        if(prodIds.length >0 ){
            if(component.get("v.ScreenName") == 'PS'){
                var appEvent = $A.get("e.c:InsertScheduleEvent");
                appEvent.setParams({
                    "ProductIds" : prodIds});
                appEvent.fire();
            }else{
                 var appEvent = $A.get("e.c:ceEvent");
                appEvent.setParams({
                    "ProductIds" : prodIds});
                appEvent.fire();
            }
            
            
            
            
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Product Added To Schedule Succesfully.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
            component.set("v.ToggleSearch",'hide');
            //document.getElementById('searchsolutionwindow').style.display='None';
            //document.getElementById('grayoutsolutionbackground').style.display='None';
        }
        else{
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "No product is selected to make schedule,Please select the products from list.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();  

            //document.getElementById('grayoutsolutionbackground').style.display='none';
            
        }  
    }
    
})