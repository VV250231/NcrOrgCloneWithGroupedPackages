({
	 saveUSMDetail : function(component, event, helper) {
        
		console.log('Inside Footer');
         var appEvent = $A.get("e.c:saveUSMDetails");
        // Optional: set some data for the event (also known as event shape)
        // A parameter’s name must match the name attribute
        // of one of the event’s <aura:attribute> tags
        //appEvent.setParams({ "myParam" : myValue });
        appEvent.fire();
        //component.find("overlayLib").notifyClose();
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