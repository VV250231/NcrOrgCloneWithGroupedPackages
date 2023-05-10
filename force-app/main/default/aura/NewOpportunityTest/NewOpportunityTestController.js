({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRecordType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                 
                component.set("v.opportunityRecordType",response.getReturnValue());
            }
        }); 
        $A.enqueueAction(action);
    },
    navigateToOpp : function(component, event, helper){
        var createOppEvent = $A.get("e.force:createRecord");
        createOppEvent.setParams({
            "entityApiName": "Opportunity",
            "recordTypeId": event.getSource().get("v.value") 
        });
        createOppEvent.fire();
    }
    
})