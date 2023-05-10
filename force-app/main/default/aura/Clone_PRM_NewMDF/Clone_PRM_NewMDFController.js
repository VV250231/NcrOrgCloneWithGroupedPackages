({
    saveMDFRequest: function(component, event, helper) 
    {
    	
        if(helper.isValidate(component, event, helper))
        	helper.saveRequest(component, event, helper);
    },
    // function call on component Load
    doInit: function(component, event, helper) {
        
        var action = component.get("c.getActivitiesAndVendors");
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.activities", response.getReturnValue().activityOptions);
                component.set("v.vendors", response.getReturnValue().vendors);
                component.set("v.activityContact", response.getReturnValue().activityContact);
                component.set("v.activityValue", '---None---');
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
        
        // by call this helper function  
        helper.createObjectData(component, event);
    },
	renderSection : function(component, event, helper) {
        component.set("v.activityValue", event.getSource().get("v.value"));
        helper.clearAllErrorMessages(component, event);
        
	},
    
    
    // function for create new object Row in Contact List 
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
    },
 
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        component.get("v.isExpenseError", false);
        var index = event.getParam("indexVar");
        // get the all List (requestExpenseList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.requestExpenseList");
        var listSize = AllRowsList.length;
       
        if(listSize > 1)
        {
            AllRowsList.splice(index, 1);
            // set the requestExpenseList after remove selected row element  
            component.set("v.requestExpenseList", AllRowsList);
        }
        component.set("v.expenseListSize", AllRowsList.length);
    },
    
    cancelNewRequest: function(component, event, helper) {
         //component.getEvent("CancelRequestEvt").fire();  
         
        $A.get("e.force:navigateToURL").setParams({ 
           "url": "/mdf-request" 
        }).fire();
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       	// make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   	},
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     	// make Spinner attribute to false for hide loading spinner    
       	component.set("v.Spinner", false);
    },
})