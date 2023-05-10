({
	 logActivity : function(component) {        
        var tabName= component.get("v.tabName");
        var action = component.get("c.logUserActivityLtngPage");
        action.setParams({tabName:tabName});       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //seismic log activity login
            }
            else {
               // console.log(a.getError());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Error in logging User activity',           
                    type: 'error',                    
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})