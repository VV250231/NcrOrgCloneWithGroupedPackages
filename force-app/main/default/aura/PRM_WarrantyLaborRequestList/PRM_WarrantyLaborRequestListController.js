({
	cWarrantyList: function(component, event, helper) {
         //var idParam = helper.getJsonFromUrl().eqid;
        var action = component.get("c.getWarrantyRequests");
        //alert(component.get("v.recordId"));
        action.setParams({
            recId: component.get("v.eqId")
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('Ncru:' + state);
            if (state === "SUCCESS") {
                
                component.set("v.lstWarrantyRequest", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    cOpenWLR : function(component, event, helper) 
    {
         component.set("v.isWLRR", true);

		var exbRdId = event.currentTarget.dataset.ids;
        
        /*var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": exbRdId
        });
        navEvt.fire();*/
        var action = component.get("c.getWarrantyLaborRequest");
        action.setParams({ "recId" : exbRdId});
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.objWLR", response.getReturnValue());
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

  	closeDocModal: function(component, event, helper) {
        component.set("v.isWLRR", false);
    },
        
})