({
	getSpotlightController : function(component, event, helper) 
    {
        component.set("v.partnerFeatureId", component.get("v.recordId"));
        //alert('------record Id-----'+component.get("v.partnerFeatureId"));
		var action = component.get("c.getSpotlight");
        action.setParams({ "recId" : component.get("v.recordId")});
        
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.selectedSpotLight", response.getReturnValue());
                
                if (component.get("v.selectedSpotLight") == 'Partner Feature Friday') 
                {
                    component.set("v.isPFF", true);
                    component.set("v.isMDF", false);
                    component.set("v.isPME", false);
                    component.set("v.isSCW", false);
                    component.set("v.isMBRT", false);
                }
                else if (component.get("v.selectedSpotLight") == 'MDF Success Story') 
                {
                    component.set("v.isPFF", false);
                    component.set("v.isMDF", true);
                    component.set("v.isPME", false);
                    component.set("v.isSCW", false);
                    component.set("v.isMBRT", false);
                }
                
                else if (component.get("v.selectedSpotLight") == 'Partner Ambassador Event') 
                {
                    component.set("v.isPFF", false);
                    component.set("v.isMDF", false);
                    component.set("v.isPME", true);
                    component.set("v.isSCW", false);
                    component.set("v.isMBRT", false);                   
                }
                else if (component.get("v.selectedSpotLight") == 'Significant Customer Win') 
                {
                    component.set("v.isPFF", false);
                    component.set("v.isMDF", false);
                    component.set("v.isPME", false);
                    component.set("v.isSCW", true);
                    component.set("v.isMBRT", false);
                }
                else if (component.get("v.selectedSpotLight") == 'Miscellaneous Business Related Topic') 
                {
                    component.set("v.isPFF", false);
                    component.set("v.isMDF", false);
                    component.set("v.isPME", false);
                    component.set("v.isSCW", false);
                    component.set("v.isMBRT", true);
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
        $A.enqueueAction(action);
	},
})