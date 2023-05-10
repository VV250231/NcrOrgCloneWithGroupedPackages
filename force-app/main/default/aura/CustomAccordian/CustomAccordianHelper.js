({
	doInit : function(component,event,helper) {
		var action = component.get("c.GetUserFavBundle_Product");
        action.setParams({
                "OppId": component.get("v.OppId") //By stuti - EBA-2059
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                console.log(JSON.stringify(response.getReturnValue()));
                component.set('v.HeaderValue', response.getReturnValue());  
                
                if(response.getReturnValue().length > 0){
                    component.set("v.ToggleDelMsg","Select Item to Delete ");
                    //component.set("v.ToggleBundelCreateMsg","Please Select Bundle");
                    component.set("v.ToggleBundelCreateMsg","Add Bundle to Scheduler ");
                    component.set("v.CursorCustom",'');
                    component.set("v.disabledWithZero_Bundle",false); 
                }
                else{
                    component.set("v.ToggleDelMsg","No Bundle Created please Create Bundle");
                    component.set("v.ToggleBundelCreateMsg","No Bundle Created please Create Bundle");
                    component.set("v.CursorCustom",'CursorCustom');
                    component.set("v.disabledWithZero_Bundle",true);
                }
            }
            else if (state === "INCOMPLETE") {
                
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
	},
    
    CallDeletemethod:function(component,event,helper,BundleIds,BundleProductIds){
        var action = component.get("c.delbundle");
         
        action.setParams({ 
        BundleIds : JSON.stringify(BundleIds),
        ProductIds : JSON.stringify(BundleProductIds)
        
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
               /* var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Selected Item Deleted",
                    "Category" : "Success",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire();*/
                var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Selected Item Deleted",
        			"type":"success"
   			 		});
    				toastEvent.fire();
                
                helper.doInit(component,event,helper);
                
                
            }
            else if (state === "INCOMPLETE") {
                
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
        
    },
    AddBundel_to_ItemtoSchedule:function(component,event,helper,BundleObjToDelete,BundleSpecificProduct,OppId){
     	//alert(OppId); 
        var action = component.get("c.AddBundle_Product_To_ItemToSchedule");
        action.setParams({  
        MapForInsert : JSON.stringify(BundleObjToDelete),
        OpportunityId:  OppId,
        MapBundleSpecificProduct:JSON.stringify(BundleSpecificProduct)    
    	});
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") { 
                
				$A.get("e.force:refreshView").fire();
            }  
            else{
                var errors = a.getError();

                //alert(errors[0].message);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                title : 'Error Message',
                message:errors[0].message,
                messageTemplate: errors[0].message,
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
        		});
        		toastEvent.fire(); 
            }
    	});
       $A.enqueueAction(action); 
    }
})