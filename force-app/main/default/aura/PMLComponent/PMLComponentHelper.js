({
	loadPartnerMaturityLevel : function(component, event, hideSpinner) {
		var action = component.get("c.getPartnerMaturityStatusList");
        // set params        
        action.setParams({ 
            "lvlId" : component.get("v.levelId")            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();   
            
            if (hideSpinner != undefined && typeof hideSpinner === "function") {
                hideSpinner(component); // hide loading
            }
            
            if(component.isValid() && state == "SUCCESS" ) {
                console.log(response.getReturnValue());
                component.set("v.matLvlRecord", response.getReturnValue()); 
            } else {
                console.log("component load error");
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
	},
    
    showSpinner : function(component) {
    	$A.util.removeClass(component.find("spinnerDiv"),'slds-hide');     
    }, 
    
    hideSpinner : function(component) {
    	$A.util.addClass(component.find("spinnerDiv"),'slds-hide');
	}
})