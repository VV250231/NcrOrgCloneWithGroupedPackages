({
	showQuotsError : function(component, event, helper) {
        console.log('showQuotsError');
        var errorMessage = event.getParam("errorMessage");
        console.log('errorMessage' + errorMessage);
        component.set("v.errorMessage", errorMessage);
        component.set("v.showError", true);
            
		
	}
})