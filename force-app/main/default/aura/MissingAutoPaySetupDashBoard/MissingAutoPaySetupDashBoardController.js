({
	init : function(component, event, helper) {
		var action = component.get("c.instantiate");
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
				component.set("v.QuoteList", response.getReturnValue());
            }
        }); 
        $A.enqueueAction(action);
	},
    hideSpinner : function(component,event,helper){
        component.set("v.spinner", false);
    }
})