({
	myAction : function(component, event, helper) {
		
	},
    callService: function(component, event, helper) {
        console.log('callService>>>>>');
		// Ajay callout
		var usm_Number = component.get("v.USMNumber");
        if( usm_Number != undefined && usm_Number.length == 10){
            helper.showSpinner(component, event, helper);
            helper.callService(component, event, helper);
        }
            
	}
})