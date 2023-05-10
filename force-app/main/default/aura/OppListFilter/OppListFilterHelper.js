({
	clearExistPopup : function(component, event) {
		 // destroy existing component 
        if(!$A.util.isUndefinedOrNull(component.find("fltrPopupBox"))){
           	var fltrPopup = component.find("fltrPopupBox");
        	if(!$A.util.isArray(fltrPopup)) fltrPopup = [fltrPopup];
            fltrPopup.forEach(function(element) { element.destroy();});    
        }	
	},
    
    createFltrPopup : function(component, event) {
         $A.createComponent(
            "c:FilterPopUp",
            {
                "aura:id": "fltrPopupBox",
                "filter" : component.get("v.filter"),
                "fltrIndex": component.get("v.fltrIndex"),
                "fieldsInfoMap": component.get("v.fieldsInfoMap"),
                "currencyList" : component.get("v.currencyList")
            },
            function(newInp, status, errorMessage) {
                if (status === "SUCCESS") {
                    if (component.isValid()) {
                        var body = component.get("v.body");
                        body.push(newInp);
                        component.set("v.body", body);
                    }
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );	
    }
})