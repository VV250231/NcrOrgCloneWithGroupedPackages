({
	HandelQuantity : function(component, event, helper) {
		var action = component.get("c.UpdateBundleProduct");
        action.setParams({ 
            ProductId : component.get("v.ProductId"),
            UnitPrice : component.get("v.UnitPrice"),
            Quantity : component.get("v.Quantity") 
            });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) { 
            var state = response.getState(); 
            if (state === "SUCCESS") {
                
               
	        /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Update Successful.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();*/
               
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
})