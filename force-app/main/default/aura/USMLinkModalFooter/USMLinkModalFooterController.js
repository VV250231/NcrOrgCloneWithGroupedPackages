({
	handleAssociate : function(component, event, helper) {
        var appEvent = $A.get("e.c:usm_associate");
           appEvent.fire();
		//alert('Association is in development phase.');
	},
    
    handleCloseEvent : function(component, event, helper) {
		console.log('handleCloseEvent');
        var message = event.getParam("msg");
        component.find("overlayLib").notifyClose();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Success!",
            message: message,
            type: "success"
        });
        toastEvent.fire();
        $A.get('e.force:refreshView').fire();
	}
})