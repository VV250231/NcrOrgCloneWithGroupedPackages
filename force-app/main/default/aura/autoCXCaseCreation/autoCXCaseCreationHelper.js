({
    
    autoCreateCase: function(component, newcase) { 
         component.set('v.show', false); 
        var action = component.get("c.CreateCxCase");
        action.setParams({
            detractorcaseDetails: JSON.stringify(newcase)
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var result=a.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    message: "CX Case Created Successfully!",
                    type: "success"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
                //alert('New Case id: '+result);
                //console.log('New Case id: '+JSON.stringify(result));
                // Get the record ID attribute
                var caserecordid = result.Id;
                // Get the Lightning event that opens a record in a new tab
                var redirect = $A.get("e.force:navigateToSObject");
                // Pass the record ID to the event
                redirect.setParams({
                    "recordId": caserecordid
                });
                // Open the record
                redirect.fire();
            } 
            
            else if (a.getState() === "ERROR") { 
                alert('error: '+ JSON.stringify(a.getError()));
                $A.log("Errors", a.getError()); 
            }
        });
        $A.enqueueAction(action);
    },
})