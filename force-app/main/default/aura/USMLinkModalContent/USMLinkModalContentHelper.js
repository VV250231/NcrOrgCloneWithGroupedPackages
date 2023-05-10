({
	helperMethod : function() {
		
	},
    
    callService : function(cmp,event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.callUSM_LinkService");
        var recordId = cmp.get("v.oppId");
        console.log('here'+recordId+'##'+cmp.get("v.USMNumber"));
        action.setParams({ oppid : recordId,
                         usmoppid : cmp.get("v.USMNumber")});
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            helper.hideSpinner(cmp,event, helper);
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var response = response.getReturnValue();                
                var appEvent = $A.get("e.c:usm_showError");
                if(response.indexOf('ERROR')>-1){
                    appEvent.setParams({  "showError" : true,"fieldName" : response });
                                          appEvent.fire();
                                       }else{
                                        var appEvent1 = $A.get("e.c:UpdateUSMComponent");
                    					appEvent1.fire();
        								console.log('end');
                                        var appEvent = $A.get("e.c:closeUSMDetail");
                                        appEvent.setParams({  "msg" : response});
        								appEvent.fire();
                }
                
                
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
                            var appEvent = $A.get("e.c:usm_showError");
                            appEvent.setParams({  "showError" : true,"fieldName" : errors[0].message  });
                            appEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);  
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.showSpinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.showSpinner", false);
    }
})