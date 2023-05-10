({
    fetchLinksFromCntrl : function(component, event, helper) {
        var action = component.get("c.fetchLinks");
        
        action.setParams({
        });
        action.setCallback(this, function(response) {
            component.set("v.links", response.getReturnValue());
        }); 
        $A.enqueueAction(action);
    }
})