({
    helperMethod : function() {
        
    },
    checkifnsspulselineitems : function(component, event, helper){ 
        console.log('inside checkifnsspulselineitems helper method');
        var action = component.get("c.validateproductlist");
        var oppid = component.get("v.oppid");
        action.setParams({
            "oppid":oppid
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                console.log('Success Received from Apex controller.');
                component.set("v.tresult", a.getReturnValue()); 
                var result = component.get("v.tresult");
                console.log('result from server is:'+result);
                if(result == true)
                {
                    console.log('value is true');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Warning!',
                        message: 'This Customer has not previously purchased NCR Secured Services. Offer this service with this Opportunity',
                        mode:'dismissible',
                        type: 'warning'
                    });
                    toastEvent.fire();
                }
                if(result == false)
                {
                    console.log('value is false');
                }
            } 
            else if (a.getState() === "ERROR") { 
                console.log('Error Received from Apex controller.');
                $A.log("Errors", a.getError()); 
            }
        });
        $A.enqueueAction(action);
        console.log('exiting checkifnsspulselineitems helper method');
    },
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Warning!',
            message: 'Account does not have any NSS or Pulse products previously purchased, Please add one !',
            mode:'dismissible',
            type: 'warning'
        });
        toastEvent.fire();
    }
})