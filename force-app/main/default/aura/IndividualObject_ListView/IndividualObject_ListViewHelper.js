({
    helperMethod : function() {
        
    },
    loadalldetails : function(component, event, helper)
    {
        console.log('doint - inside loadalldetails helper method');
        var action = component.get("c.getalldetails");
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.indobject", a.getReturnValue()); 
                var t = component.get("v.indobject");
                if(t==0){
                    component.set('v.togglesearchcriteria',true);
                    component.set('v.norecords',true);
                }
                else{
                    component.set('v.somerecords',true);
                }
            } else if (a.getState() === "ERROR") { 
                console.log('Error received from loadUserDetails controller.');
                component.set('v.toggleerrorfromserver',true);
                $A.log("Errors", a.getError()); 
            }
            
        });
        $A.enqueueAction(action);
    },
})