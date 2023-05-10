({
	
	processApprovalRequest : function(component, event, helper) {
        var action = component.get("c.submitApprovalRequest");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "comment": component.get("v.comment")
        });
        
        action.setCallback(this, function(a) {
            var toastEvent = $A.get("e.force:showToast");
            
            if(a.getReturnValue().status === "success") {
                toastEvent.setParams({
                    "type" : "success",
                    "message": a.getReturnValue().message
                });
            }
            else if(a.getReturnValue().status === "error") {
                toastEvent.setParams({
                    "type" : "error",
                    "message": a.getReturnValue().message
                });
            }
            else if(a.getReturnValue().status === "info") {
                toastEvent.setParams({
                    "type" : "info",
                    "message": a.getReturnValue().message
                });
            }
            
            $A.get("e.force:closeQuickAction").fire();
            toastEvent.fire();
        });
        
        $A.enqueueAction(action);
    },
        
    closeWindow : function (component, event, helper) {
    	$A.get("e.force:closeQuickAction").fire();
	}
})