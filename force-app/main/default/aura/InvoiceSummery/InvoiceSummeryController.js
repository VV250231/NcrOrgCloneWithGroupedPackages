({
	doInit : function(cmp, event, helper) {
         //alert(cmp.get("v.DataTableJson"));
         
        // Create the action
        var action = cmp.get("c.GetInvoiceSummery");
        // Add callback behavior for when response is received
        action.setParams({ jonString : cmp.get("v.DataTableJson") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.InvoiceSummery", response.getReturnValue());
                 cmp.set("v.MasterCustomerNo",response.getReturnValue().MCN);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
        
	}
})