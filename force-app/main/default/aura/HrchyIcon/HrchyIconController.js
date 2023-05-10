({
    
    init : function(cmp, event, helper) {
        //helper.generateNavURL(cmp, event, helper);
    }, 
	handleShowModal : function(component, event, helper) {
	    var navService = component.find("navService");
        // Uses the pageReference definition in the init handler
        /*var pageReference = component.get("v.pageReference");
        event.preventDefault();
        navService.navigate(pageReference); */
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CustomerHierarchy",
            componentAttributes: {
                "showHierarchy" : "true",
                "recordId" :  component.get("v.recordId")
            }
        });
        evt.fire();
	},
    destoryCmp : function (component, event, helper) {
        //component.destroy();
    },
})