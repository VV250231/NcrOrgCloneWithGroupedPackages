({
    
    getAccount : function(component, event, helper) {
        var action = component.get("c.getAccountDetail");
        //var idParam = helper.getJsonFromUrl().acid;
        
       	var idParam = component.get("v.recordId");
        component.set("v.recordId", idParam);
        
        action.setParams({ "recId" : idParam});
        component.set("v.Spinner",true);
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.objAccount", response.getReturnValue());
                component.set("v.Spinner",false);
            }
            else if (state === "INCOMPLETE") {
                // do something
                component.set("v.Spinner",false);
            }
           else if (state === "ERROR") {
               component.set("v.Spinner",false);
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
    
    back : function(component, event, helper) {
        
   		$A.get("e.force:navigateToURL").setParams({ 
            "url": "/account-listview"
        }).fire(); 
    },
})