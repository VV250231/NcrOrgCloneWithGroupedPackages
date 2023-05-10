({
    doInit:function(component,event,helper,OppId){
        $A.createComponent(
            "c:CustomAccordian",
            {
                "OppId":component.get("v.OpportunityId"),
                "popUpclass":'pop-up-LargeScreen',
                "TriggerScreenName" : component.get("v.TriggerScreenName"),
                "isCatm": component.get("v.isCatm")  //EBA_SF-2209
                //"HeaderValue": component.get("v.HeaderValue")
                
            },
            function(newButton, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newButton); 
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
    
    getSelectProduct:function(component, event, helper){
        //var selectedProductid = event.getParam("SelectedProduct");
        //var Status = event.getParam("Status");
        
        var Selected_Product=component.get("v.Selected_Product");
        Selected_Product[event.getParam("SelectedProduct")] = event.getParam("Status");
        component.set("v.Selected_Product",Selected_Product);
        
        
        
    },
    getSelectBundle:function(component, event, helper){
         //var selectedBundleid = event.getParam("SelectedBundle");
         var Selected_Bundle=component.get("v.Selected_Bundle");
         Selected_Bundle[event.getParam("SelectedBundle")] = event.getParam("Status");
         component.set("v.Selected_Bundle",Selected_Bundle); 
    },
    Save:function(component, event, helper){
        //var Productvalues=component.get("v.Selected_Product");
        
        var myMap = component.get("v.Selected_Product");
        var MyMap_Bundle = component.get("v.Selected_Bundle");
        var Obj=[];
                for (var key in myMap){
                    
                    if(myMap[key] == true && myMap[key] != ''){
                        Obj.push({Id:key,Status:myMap[key]});
                    }
  
                }
        
        
        
        var Obj_Bundle= []; 

         
        for (var key in MyMap_Bundle){
                    
                    if(MyMap_Bundle[key] == true && MyMap_Bundle[key] != ''){
                        Obj_Bundle.push({Id:key,Status:MyMap_Bundle[key]});
                    }
  
                }
        //var Bundlevalues=component.get("v.Selected_Bundle");
        //console.log(JSON.stringify(Obj));
        
        if(Obj_Bundle.length > 0 && Obj.length > 0){
			 //console.log(JSON.stringify(Obj_Bundle));
        var action = component.get("c.AddProductToBundleMethod");
        action.setParams({                    
            "PrdList" :JSON.stringify(Obj),
            "BndlList":JSON.stringify(Obj_Bundle)
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var OppId=component.get("v.OpportunityId");
                
                    
                    /*var appEvent = $A.get("e.c:EverntFromBundleComptoSearchComp");
                    appEvent.setParams({
                        "CallFromBundleforRefresh" : 'call from child '
                        
                    });
                    appEvent.fire();*/
                
                    var appEvent = $A.get("e.c:CustomAccordianRefreshEvent");
                    appEvent.setParams({
                        "message" : "Refresh" 
                         });
                    appEvent.fire();
                    
                    component.set("v.body",'');
                    
                    helper.doInit(component, event, helper,OppId);
                        
              /*  var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Product Added Successfully.",
                        "Category" : "Success",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();	*/
                var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Added Successfully.",
        			"type":"success"
   			 		});
    				toastEvent.fire();
                MyMap_Bundle={}; 
               component.set("v.Selected_Bundle",MyMap_Bundle); 
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
		} 
         
	 	else{
            
            //alert(Obj.length);
            if(Obj_Bundle.length == 0  && Obj.length == 0){
                /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Please select Product and corresponding Bundle",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();*/
                //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "Please select Product and corresponding Bundle",
        			"type":"warning"
   			 		});
    				toastEvent.fire();

            }
            
            
           else if(Obj_Bundle.length == 0){
                /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Please select Bundle",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();*/
               var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "Please select Bundle",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
            }
             
            
            else{
                /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Please select Product",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();*/
                //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "Please select Bundle",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
            }
			/*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Please select Product",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();*/
		} 
 
    },
   
})