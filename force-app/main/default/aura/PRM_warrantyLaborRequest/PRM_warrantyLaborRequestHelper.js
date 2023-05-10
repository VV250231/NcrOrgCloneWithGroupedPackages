({
	getEquipment : function(component) {
        // Get a reference to the getEquipmentDetail() function defined in the Apex controller
        var action = component.get("c.getEquipmentDetail");
        action.setParams({
            "equipmentId": component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            //console.log(a.getReturnValue());
            component.set("v.equipment",a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    validateWLRform : function(component){
        if (!component.find("dateOfService").get("v.value")){
            component.find("dateOfService").set("v.errors",[{message:"Please Enter Date of Service "}]);
            return false;
        }
        return true;
    },
    
    submitWLR : function(component) {       
        var action = component.get("c.submitWarrLabReq");
        action.setParams({
            "equipment": component.get("v.equipment"),
            "problemDescription": component.get("v.problemDescription")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "message": "Request has been submitted successfully"
                });
            } else {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "message": "Error: Please contact your account manager"
                });
            }
            
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    }
})