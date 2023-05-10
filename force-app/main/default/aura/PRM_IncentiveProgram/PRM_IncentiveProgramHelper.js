({
    getInsentivePrgOptions : function(component) {
        var action = component.get("c.getAvailableIncentivePrograms");
        action.setCallback(this, function(a) {
            console.log(a.getReturnValue());
            component.set("v.options",a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
    processIPRequest: function(component) {
        var action = component.get("c.submitEnrollmentReq");
        action.setParams({incentivePrg: component.get("v.selectedValue"), isAgree: true});
        action.setCallback(this,function(a){
            //component.set("v.message",a.getReturnValue());
            if (a.getState() === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "message": a.getError()[0].message
                });
                toastEvent.fire();
            }
            
            if (a.getState() === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                if (a.getReturnValue().state === 'ERROR') {
                    toastEvent.setParams({
                        "type" : "error",
                        "message": a.getReturnValue().message
                    });
                } else if (a.getReturnValue().state === 'SUCCESS') {
                    toastEvent.setParams({
                        "type" : "success",
                        "message": a.getReturnValue().message
                    });
                }
                toastEvent.fire();
            }
            
        });
        
        $A.enqueueAction(action);
    }
})