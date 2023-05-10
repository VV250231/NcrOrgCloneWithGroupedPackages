({
    helperMethod : function() {
        
    },
    
    loadcreditdetails : function(component, event, helper)
    {
        console.log('doint - inside loadcreditdetails helper method');
        var action = component.get("c.Loadcompletedetail");
        action.setParams({ 
            "ID" : component.get("v.CID")       
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                console.log('success Received from Apex controller.');
                component.set("v.creditobject", a.getReturnValue()); 
            } else if (a.getState() === "ERROR") { 
                console.log('Error Received from Apex controller.');
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
        console.log('doinit - exiting loadcreditdetails helper method');
    },
    
})