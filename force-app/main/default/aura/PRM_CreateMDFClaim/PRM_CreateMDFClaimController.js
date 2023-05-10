({
	 // function call on component Load
    doInit: function(component, event, helper){
        var action = component.get("c.getClaimDetails");
        action.setParams({ "requestId" : component.get("v.mdfRequestId")});
        //action.setParams({ "requestId" : "a0Wc0000005L1M7EAK"})
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                component.set("v.mdfRequest", response.getReturnValue().objMDFRequest);
                component.set("v.mdfClaim", response.getReturnValue().objMDFClaim);
                component.set("v.activityContact", response.getReturnValue().activityContact);
                
                
                /* Start Set Expense Table*/
                var RowItemList = response.getReturnValue().lstExpense;
                component.set("v.expenseListSize", RowItemList.length);
                var allContactRows = component.get("v.expenseList");
                for (var indexVar = 0; indexVar < RowItemList.length; indexVar++) {
                    allContactRows.push({
                        'sobjectType': 'MDF_Expense_Detail__c',
                        'Actvity__c': RowItemList[indexVar].Actvity__c,
                        'Estimated_Cost__c': RowItemList[indexVar].Estimated_Cost__c,
                        'Id': RowItemList[indexVar].Id,
                        'NCR_Estimated_Participation__c': RowItemList[indexVar].NCR_Estimated_Participation__c,
                        'Actual_Cost__c': RowItemList[indexVar].Actual_Cost__c
                    });  
                }
                component.set("v.expenseList", allContactRows);
                /* End Set Expense Table */
                
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
    createClaim: function(component, event, helper){
    	if(helper.isValidate(component, event, helper)){
            var action = component.get("c.createMDFClaim");
            console.log(component.get("v.mdfRequest"));
            action.setParams({ "mdfRequest" :  component.get("v.mdfRequest"),
                               "mdfClaim" :  component.get("v.mdfClaim"),
                               "lstExpense" :  component.get("v.expenseList")});
            
            // Create a callback that is executed after the server-side action returns
            action.setCallback(this, function(response){
                var state = response.getState();
                
                //alert('State---'+state + '---result--'+response.getReturnValue());
                if (state === "SUCCESS") {
                     component.getEvent("DetailRequestEvt").setParams({"mdfRecordId" : response.getReturnValue(),"backFrom" : "Edit"}).fire();
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
    
    cancelRequest: function(component, event, helper) {
         component.getEvent("CloneCancelRequestEvt").fire();  
    }
})