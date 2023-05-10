({
	CheckContactActivation : function(component) {
		var action = component.get("c.getContactActivation");   
        action.setParams({   
        Contactid : component.get("v.ContactId")   
    });
       
        action.setCallback(this, function(a) {
        if (a.getState() === "SUCCESS") {
             component.set("v.contact", a.getReturnValue());  
             this.Finder(component);  
        } 
            else if (a.getState() === "ERROR") { 
            $A.log("Errors", a.getError()); 
        }
            
    });
    $A.enqueueAction(action);
	},
    
       
    Finder :function(component){
        window.setTimeout(
   		$A.getCallback(function() {
        
        $A.get("e.force:refreshView").fire();
        
    }), 2000  
	); 
    }
})