({
	doInit : function(component, event, helper) {
		var action = component.get("c.fetchPriceList");
        action.setCallback(this,function(response) {
            component.set("v.priceWrapper", response.getReturnValue());
            console.log(response.getReturnValue());
        })
        $A.enqueueAction(action);
	}
})