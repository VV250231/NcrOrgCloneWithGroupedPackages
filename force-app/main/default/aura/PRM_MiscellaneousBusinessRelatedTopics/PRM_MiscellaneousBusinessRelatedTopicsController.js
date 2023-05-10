({
	saveMiscellaneousBusinessController : function(component, event, helper) 
    {
        //alert(component.find("Partner_Name").get("v.value"));
		if(helper.isValidate(component, event, helper))
        {
			var action = component.get("c.saveMiscellaneousBusinessRelatedTopic");
            
            action.setParams({ "objSpotlight" : component.get("v.ObjPartnerSpotlight")});
            
            // Create a callback that is executed after the server-side action returns
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.MiscellaneousBusinessId", response.getReturnValue());
                    console.log(response.getReturnValue());
                    component.set("v.isNew", false);
                    component.set("v.isDetail", true);
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
        else
        {
            console.log('Error');
        }
	},
    redirectToPage : function(component, event, helper) {
        
         component.getEvent("CancelRequestEvt").fire();
		
	}
})