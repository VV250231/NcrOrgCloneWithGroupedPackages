({
	getEquipment : function(component, event, helper) {
        var action = component.get("c.getEngineerDetail");
        
        //var idParam = helper.getJsonFromUrl().recordId;
        var idParam = component.get("v.recordId");
        //component.get("v.recordId")
        action.setParams({ "recId" : idParam});
        component.set("v.Spinner", true);
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 component.set("v.Spinner", false);
                component.set("v.objEquipment", response.getReturnValue());
                component.set("v.recordId", response.getReturnValue().Id);
            }
            else if (state === "INCOMPLETE") {
                // do something
                component.set("v.Spinner", false);
            }
            else if (state === "ERROR") {
                component.set("v.Spinner", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
       		
	},
    
  
    cBack : function(component, event, helper) 
    {
      	$A.get("e.force:navigateToURL").setParams({ 
                   "url": "/equipment-listview"
                }).fire();
    },
    
   
    closeDocModal: function(component, event, helper) {
        component.set("v.isWLRR", false);
    },
    
    
    cOpenWLRR: function(component, event, helper) {
        
        if(!component.get("v.objEquipment.Active_Unit__c"))
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "info",
                "message": "The equipment is in inactive state. No mail can be sent against inactive Equipments."
            });
            toastEvent.fire();
        }
        else
      		component.set("v.isWLRR", true);
    },
    
    cSaveWLRR :function(component, event, helper) {
        
        var submitREcord = true;
        if(!component.find("dateOfService").get("v.value"))
        {
            component.find("dateOfService").set("v.errors",[{message:"Please Enter Date of Service: "}]);
            submitREcord = false ;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error:",  
                "type": "error",
                "message": "Review the errors on this page."
            });
            toastEvent.fire();
        }
        else{
            component.find("dateOfService").set("v.errors",null);
        }
        
        if(submitREcord)
        {
            component.set("v.Spinner", true); 
            var action = component.get("c.submitWarrantyLaborRequest");
            var idParam = helper.getJsonFromUrl().eqid;
            action.setParams({ "equipment" : component.get("v.objEquipment"),
                              "problemDescription" : component.get("v.description")});
            // Create a callback that is executed after the server-side action returns
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.isWLRR", false);
                if (state === "SUCCESS") 
                {
                   if(response.getReturnValue() == 'Success')
                   {
                        component.set("v.Spinner", false); 
                       var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                                "type" : "success",
                                "message": "Warranty Labor Request has been submitted."
                            });
                        toastEvent.fire();
                       
                       $A.get('e.force:refreshView').fire();
                   }
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
      	
    openEdit: function(component, event, helper) 
    {
        //var idParam = helper.getJsonFromUrl().eqid;
        $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/edit-equipment?recordId="+component.get("v.recordId")
                }).fire();
    },
    openClone: function(component, event, helper) 
    {
        //var idParam = helper.getJsonFromUrl().eqid;
        $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/clone-equipment?recordId="+component.get("v.recordId")
                }).fire();
    },
   
})