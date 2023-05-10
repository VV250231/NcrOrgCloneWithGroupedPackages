({
    doInit : function(component, event, helper) {
        var actions = [
            { label: 'Delete', name: 'delete' }
        ]
        component.set('v.FinalListcolumns', [
            {label: 'First Name', fieldName: 'FirstName', type: 'text'},
            {label: 'Last Name',  fieldName: 'LastName', type: 'text'},
            {label: 'Phone',  fieldName: 'Phone', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions } }
            //{ type: 'button', initialWidth: 135,typeAttributes: { label:'Delete', name:'Delete',title:'Delete Row' } }
            
        ]);
        helper.InitializeContactRow(component);
        helper.getExistingContacts(component);
        helper.getExistingSalesSurveyContacts(component);
    },
    GetSelectedExistingContacts : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRows', selectedRows);
        var ConIdsArray = [];
        for(var conObj of selectedRows){
            ConIdsArray.push(conObj.Id);
        }
        component.set('v.selectedConIdsRows', ConIdsArray);
        helper.fillFinalContactsList(component);
    },
    addNewRow: function(component, event, helper) {
        helper.InitializeContactRow(component);
    },
    removeDeletedRow: function(component, event, helper) {
        var index = event.getParam("indexVar");
        var AllRowsList = component.get("v.NewContactList");
        AllRowsList.splice(index, 1);
        component.set("v.NewContactList",AllRowsList);
    },
    handleAdd : function(component, event, helper) {
        helper.validateNewContact(component, event);
    },
    handleCancel : function(component, event, helper) {
        component.set("v.NewContactList",[]);
        helper.InitializeContactRow(component);
        helper.fillFinalContactsList(component);
    },
    handleSave : function(component, event, helper) {
        var action = component.get("c.saveContacts");
        action.setParams({
            "AccId": component.get("v.AccountId"),
            "SalesSurveyid": component.get("v.SalesSurveyid"),
            "FinalContactList":component.get("v.FinalSSContactsList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast("Success!", "Sales Survey Contacts Saved Successfully", "success","dismissible");
                component.set("v.selectedRows",[]);
                component.set("v.selectedConIdsRows",[]);
                component.set("v.NewContactList",[]);
                component.set("v.FinalSSContactsList",[]);
                helper.InitializeContactRow(component);
                helper.getExistingSalesSurveyContacts(component);
            }else if (state === "INCOMPLETE") {
                helper.showToast("Server Failure.!", "Error", "error","sticky");
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showToast("Error.!", errors[0].message, "error","sticky");
                    }
                } else {
                    console.log("Unknown error");
                    helper.showToast("Unknown error.!", "Error", "error","sticky");
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                helper.removeBook(cmp, row);
                break;
        }
    }
    
})