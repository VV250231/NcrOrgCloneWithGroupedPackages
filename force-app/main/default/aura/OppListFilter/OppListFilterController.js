({
    doInit : function(component, event, helper) {
    	//alert('list comp init');
        if(component.get("v.isActiveFltr")) {
        	window.setTimeout(
                $A.getCallback(function() {
                    helper.createFltrPopup(component, event);
                }), 50
            );    
        }
    },
    editfilter : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                helper.createFltrPopup(component, event);
            }), 50
        );
    },
    removeFltr : function(component, event, helper) {
        component.getEvent("removefilter").setParams({"selFilterIndex" : component.get("v.fltrIndex")}).fire();	
    },
    
  
})