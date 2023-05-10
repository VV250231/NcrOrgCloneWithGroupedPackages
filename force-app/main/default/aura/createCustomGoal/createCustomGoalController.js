({
	doInit : function(component, event, helper) {
        var actions = [
            { label: 'Delete', name: 'delete' }
        ]
        component.set('v.FinalListcolumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Details',  fieldName: 'Details__c', type: 'text'},
            {label: 'Aligned',  fieldName: 'Aligned_Solution__c', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions } }
            //{ type: 'button', initialWidth: 135,typeAttributes: { label:'Delete', name:'Delete',title:'Delete Row' } }
            
        ]);
		 helper.InitializeCustGoalRow(component);
        // helper.getCustomerGoals(component);

	},
     addNewRow: function(component, event, helper) {
        helper.InitializeCustGoalRow(component);
    },
    removeDeletedRow: function(component, event, helper) {
        var index = event.getParam("indexVar");
        var AllRowsList = component.get("v.NewCustomerGoalList");
        AllRowsList.splice(index, 1);
        component.set("v.NewCustomerGoalList",AllRowsList);
    },
     handleAdd : function(component, event, helper) {
        //helper.validateNewCustGoal(component, event);
         helper.fillFinalCustGoalList(component);
    },
       handleSave : function(component, event, helper) {
          helper.fillFinalCustGoalList(component); 
        var action = component.get("c.saveCustGoals");
        action.setParams({
            
            "SalesSurveyid": component.get("v.SalesSurveyid"),
            "NewCustomerGoalList":component.get("v.FinalSSCustGoal")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast("Success!","Sales Survey Customer Goal Saved Successfully","success","dismissable");
                component.set("v.FinalSSCustGoal",[]);
                component.set("v.NewCustomerGoalList",[]);
                helper.InitializeCustGoalRow(component);
                helper.getCustomerGoals(component);
            }else if (state === "INCOMPLETE") {
                helper.showToast("Server Failure.!","Error","error","sticky");
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showToast("Error.!",errors[0].message,"error","sticky");
                    }
                } else {
                    console.log("Unknown error");
                    helper.showToast("Unknown error.!","Error","error","sticky");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
})