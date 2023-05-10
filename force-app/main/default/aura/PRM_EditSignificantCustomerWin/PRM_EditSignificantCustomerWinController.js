({
	getSignificantCustomer : function(component, event, helper) {
		var action = component.get("c.getSignificantCustomerWin");
        action.setParams({ "recId" : component.get("v.partnerSpotlightId")});
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ObjPartnerSpotlight", response.getReturnValue().objPS);
                
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
	},
    
   	saveSignificantCustomerWinController : function(component, event, helper) 
    {
        if(helper.isValidate(component, event, helper))
        {    
        var action = component.get("c.updateSignificantCustomerWin");
        action.setParams({ "objSpotlight" : component.get("v.ObjPartnerSpotlight")});
            
        //Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") 
            {
                component.getEvent("DetailRequestEvt").setParams({"mdfRecordId" : response.getReturnValue(),"backFrom" : "Edit"}).fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
           	else if (state === "ERROR") 
            {
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
        else
        {
            console.log('Error');
        }
	},
    openDetail : function(component, event, helper) {
        component.getEvent("EditCancelRequestEvt").fire();
	}
})