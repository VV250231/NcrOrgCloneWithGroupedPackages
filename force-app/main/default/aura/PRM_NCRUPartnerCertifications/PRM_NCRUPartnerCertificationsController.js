({
	getDetail: function(component, event, helper) {
        var action = component.get("c.getNCRUPartnerCertifications");
        //var idParam = helper.getJsonFromUrl().acid;
        
        var idParam = component.get("v.recordId");
        
        action.setParams({
            accId: idParam
        });
 		
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('Ncru:' + state);
            if (state === "SUCCESS") {
                
                component.set("v.lstCertification", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    }
})