({
    getExbFieldLabel:function(component, event, helper){
        var action = component.get("c.getLabelofEXBFields");
        action.setCallback(this, function(response){
        var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set('v.ExbFieldLabel',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
       
    },
    getLoggedInUserProfile: function(component, event, helper){
         var action = component.get("c.getUserProfile");
        action.setCallback(this, function(response){
        var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.AccessCheck", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})