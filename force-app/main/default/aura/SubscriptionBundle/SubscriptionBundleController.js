({
	doInit : function(cmp, event, helper) {
		// create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.GetUserSpecificBundleAndProduct");
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue()); 
                if(response.getReturnValue() == null){ 
                    
                    cmp.set("v.showErrorIndicator",true);
                    
                } 
                else{
                    cmp.set("v.SubscriptionBundleWithProducts",response.getReturnValue());
                }
				
                
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

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
	},
    handleSelect:function(cmp,event,helper){
        //debugger;
        var selectedMenuItemValue = event.getSource().get("v.value") ;
        console.log(selectedMenuItemValue);
        var ProductId=[];
        if(selectedMenuItemValue.length>0){
            for(var i=0;i<selectedMenuItemValue.length;i++){ 
                if(selectedMenuItemValue[i].Product__r.IsActive){
                    ProductId.push(selectedMenuItemValue[i].Product__c);
                }
            }            
        } 
        
        var action = cmp.get("c.AddProductToBundle");
        action.setParams({ ProductId : ProductId,
                          OppId : cmp.get("v.OppId")

                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                //alert("From server: " + response.getReturnValue());
				$A.get("e.force:refreshView").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Bundle Product successfully Added to Scheduler."  
                });
                toastEvent.fire();
                
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //alert("Error message: " + errors[0].message);
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error Message',
                                    message:errors[0].message,
                                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'pester'
                                });
                                toastEvent.fire();
                          
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);   
    },
    
})