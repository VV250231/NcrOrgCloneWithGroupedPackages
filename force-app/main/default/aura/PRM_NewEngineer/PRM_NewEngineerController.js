({
    // function call on component Load
    doInit: function(component, event, helper) 
    {  
        var action = component.get("c.getPicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.requestFor", response.getReturnValue().requestFor);
                component.find("selectRequestFor").set("v.value", '--None--');
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
    cSaveEngineer : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        if(helper.isValidate(component, event, helper))
        {
            var action = component.get("c.saveEngineer");
            action.setParams({
                "objEng" : component.get("v.ObjEngineers"),
            })
            
            action.setCallback(this,function(a){
                //alert(a.getReturnValue());
                
                $A.get("e.force:navigateToURL").setParams({ 
                    "url": "/engineer-record?recordId=" + a.getReturnValue()
                }).fire();
            })
            
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
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "/engineer-listview"
        }).fire();
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    
})