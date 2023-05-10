({
    // function call on component Load
    doInit: function(component, event, helper) 
    {  
        /*var action = component.get("c.getPicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.requestFor", response.getReturnValue().requestFor);
                component.find("selectRequestFor").set("v.value", '--None--');
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
        $A.enqueueAction(action);*/
        
        
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);
   
    },
    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        var depnedentFieldMap2 = component.get("v.depnedentFieldMap2");
        if (controllerValueKey != '-- None --') 
        {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0)
            {
                component.set("v.bDisabledDependentFld" , false);  
                component.find("Class_Type").set("v.required", true); 
                component.set("v.objEquipment.Class_Type__c", '-- None --');
                helper.fetchDepValues(component, ListOfDependentFields);  
            }
            else
            {
                component.find("Class_Type").set("v.required", false); 
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.classTypes", ['-- None --']);
                component.set("v.objEquipment.Class_Type__c", '-- None --');
            }  
            
            var ListOfDependentFields2 = depnedentFieldMap2[controllerValueKey];
            
            if(ListOfDependentFields2.length > 0)
            {
                component.set("v.bDisabledDependentFld2" , false);   
                component.find("Features").set("v.required", true); 
                component.set("v.objEquipment.Features__c", '-- None --');
                helper.fetchDepValues2(component, ListOfDependentFields2);   
            }
            else
            {
                component.find("Features").set("v.required", false); 
                component.set("v.bDisabledDependentFld2" , true); 
                component.set("v.features", ['-- None --']);
                component.set("v.objEquipment.Features__c", '-- None --');
            }  
        } 
        else 
        {
            component.set("v.classTypes", ['-- None --']);
            component.find("Class_Type").set("v.required", false); 
            component.set("v.bDisabledDependentFld" , true);
            component.set("v.objEquipment.Class_Type__c", '-- None --');
            
            component.set("v.features", ['-- None --']);
            component.find("Features").set("v.required", false); 
            component.set("v.bDisabledDependentFld2" , true);
            component.set("v.objEquipment.Features__c", '-- None --');
        }
    },
    
    cSaveEquipment : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        //helper.isValidate(component, event, helper)
        if(helper.isValidate(component, event, helper))
        {
            var action = component.get("c.saveEquipment");
            action.setParams({
                "objEq" : component.get("v.objEquipment"),
            })
            
            action.setCallback(this,function(a){
                if (a.getState() == "SUCCESS") 
            	{
                    if(a.getReturnValue() == 'Duplicate Serial Number')
                    {
                        component.find("serialNumber").set("v.errors",[{message:"Record already exists with same Serial Number and Partner Account:"}]);
                        component.set("v.Spinner", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error:",  
                            "type": "error",
                            "message": "Record already exists with same Serial Number and Partner Account. Please provide different Serial Number."
                        });
                        toastEvent.fire();
                    }
                    else{
                        $A.get("e.force:navigateToURL").setParams({ 
                            "url": "/equipment-record?recordId=" + a.getReturnValue()
                        }).fire();
                    }
                }
            })
            
            $A.enqueueAction(action); 
        }    
        else
        {
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error:",  
                "type": "error",
                "message": "Review the errors on this page."
            });
            toastEvent.fire();
        }
    },
    cancel : function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "/equipment-listview"
        }).fire();
    },
    
   
    
})