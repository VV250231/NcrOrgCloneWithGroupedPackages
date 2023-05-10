({
    // function call on component Load
    doInit: function(component, event, helper) 
    {  
        //var idParam = helper.getJsonFromUrl().eid;
        var recId = component.get("v.recordId");
        var action = component.get("c.getEngineerDetail");
        action.setParams({ "recId" : recId});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ObjEngineers", response.getReturnValue());
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
    saveEngineerController : function(component, event, helper) 
    {
        //alert('Outside');
        component.set("v.Spinner", true); 
        if(helper.isValidate(component, event, helper))
        {
            //alert('Inside');
            var action = component.get("c.saveEngineer");
            action.setParams({ 
                "objEng" : component.get("v.ObjEngineers") 
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    $A.get("e.force:navigateToURL").setParams({ 
                        "url": "/engineer-record?recordId=" + response.getReturnValue()
                    }).fire();
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
        }
        else
        {
            component.set("v.Spinner", false); 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error:",  
                "type": "error",
                "message": "Review the errors on this page."
            });
            toastEvent.fire();
        }
    },
    
    cancel : function(component, event, helper) {
       // var idParam = helper.getJsonFromUrl().eid;
       var recId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "/engineer-record?recordId=" + component.get("v.recordId")
        }).fire();
    }
})