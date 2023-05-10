({
	/*render : function(component, helper) {
    var returnVal = this.superRender();
    var dataType = "ui:InputText";
    //alert(component.get("v.value"));
   $A.createComponent(
            dataType,
            {
                "aura:id": "findableAuraId",
                "label": "",
                "class":"inputHeight Input_Custom",
                "value":component.get("v.value"),
                "keyup": component.getReference("c.handlePress")
            },
            function(newButton, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newButton);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
       
        
    return returnVal; 
    
	}*/
})