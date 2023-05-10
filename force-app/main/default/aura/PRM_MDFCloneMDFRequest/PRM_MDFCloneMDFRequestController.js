({
    saveMDFRequest: function(component, event, helper) 
    {
       if(helper.isValidate(component, event, helper))
        	helper.saveRequest(component, event, helper);
    },
    // function call on component Load
    doInit: function(component, event, helper){
        var action = component.get("c.getCloneMDFDetail");
        action.setParams({ "mdfRecordId" : component.get("v.mdfRequestId")});
        //action.setParams({ "mdfRecordId" : "a0Wc0000006S0CREA0"});
        // Create a callback that is executed after the server-side action returns
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.activities", response.getReturnValue().activityOptions);
                component.set("v.vendors", response.getReturnValue().vendors);
                component.set("v.activityContact", response.getReturnValue().activityContact);
                component.set("v.request", response.getReturnValue().objCloneMDFRequest);
                //component.set("v.requestExpenseList", response.getReturnValue().lstCloneExepeseList);
                component.set("v.activityValue", response.getReturnValue().objCloneMDFRequest.Activity_Type__c);
                component.set("v.currentActivityName", response.getReturnValue().currentActivityName);
                /* Start Set Expense Table*/ 
                var RowItemList = response.getReturnValue().lstCloneExepeseList;
                component.set("v.expenseListSize", RowItemList.length);
               	var allContactRows = component.get("v.requestExpenseList");
        		for (var indexVar = 0; indexVar < RowItemList.length; indexVar++) {
                    allContactRows.push({
                        'sobjectType': 'MDF_Expense_Detail__c',
                        'Actvity__c': RowItemList[indexVar].Actvity__c,
                        'Estimated_Cost__c': RowItemList[indexVar].Estimated_Cost__c
                    });  
                }
                component.set("v.requestExpenseList", allContactRows);
                
                /* End Set Expense Table */
                
            	/* Start Set selected Activities */
                var opts = [];
                var activityValues = response.getReturnValue().activityOptions;
                if (activityValues != undefined && activityValues.length > 0){
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < activityValues.length; i++) {
                    
                    if(activityValues[i] === response.getReturnValue().objCloneMDFRequest.Activity_Type__c){
                        opts.push({
                            class: "optionClass",
                            label: activityValues[i],
                            value: activityValues[i],
                            selected: "true" 
                        });
                    }
                    else{
                        opts.push({
                            class: "optionClass",
                            label: activityValues[i],
                            value: activityValues[i]
                        });
                    } 
                }
                component.find("selectActivity").set("v.options", opts);
                /* End Set selected Activities */
            	
            	/* Start Set selected Vendors */
                var optVendors = [];
                var vendorValues = response.getReturnValue().vendors;
                var selectedVendors = response.getReturnValue().objCloneMDFRequest.Other_Vendors_Represented__c;
                for (var i = 0; i < vendorValues.length; i++) {
                    
                    if(selectedVendors && selectedVendors.indexOf(vendorValues[i]) > -1){
                        optVendors.push({
                            class: "optionClass",
                            label: vendorValues[i],
                            value: vendorValues[i],
                            selected: "true" 
                        });
                    }
                    else{
                        optVendors.push({
                            class: "optionClass",
                            label: vendorValues[i],
                            value: vendorValues[i]
                        });
                    } 
                }
                component.find("selectVendor").set("v.options", optVendors);
            
            	/* End find selected Ventors */
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
       
    },
	renderSection : function(component, event, helper) {
        component.set("v.activityValue", event.getSource().get("v.value"));
        helper.clearAllErrorMessages(component, event);
        
        //helper.clearAllErrorMessages(component, event);
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
         component.getEvent("CloneCancelRequestEvt").fire();  
    }
})