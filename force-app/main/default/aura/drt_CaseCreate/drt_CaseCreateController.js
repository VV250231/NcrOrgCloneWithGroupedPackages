({
    
    closeModal:function(component,event,helper){  
        component.set('v.show', false);
        
    },    
    handleShowModal : function(component, event, helper) {        
        if(!component.get("v.created")){
            $A.createComponent(
                "c:caseToLeadConversion",
                {
                    "recordId":component.get("v.recordId"),
                    
                },                
                function(newButton, status, errorMessage){
                    //Add the new button to the body array
                    if (status === "SUCCESS") {
                        component.set("v.created", true);
                        var body = component.get("v.body");
                        body.push(newButton);
                        component.set("v.body", body);
                        component.set("v.show",true);
                        
                    }
                    else if (status === "INCOMPLETE") {
                        alert('Fail');
                        // Show offline error
                    }
                        else if (status === "ERROR") {
                            alert('Fail1');
                            // Show error message
                        }
                }
            );  
        }else{
            component.set("v.show",true);
        }
        
    }
})