({
    "init" : function(cmp) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.instantiate");
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
				//approvals
				cmp.set("v.approvals", response.getReturnValue());
            }

        });

        $A.enqueueAction(action);
        cmp.set("v.order",'ASC');
        cmp.set("v.orderBy",'qtc_Requested_Date_Display__c');
    },

    "doShorting" : function(component, event, helper) {
        component.set("v.spinner", true); 
        var target = event.currentTarget;
        var fieldAPIName;
        switch (target.getAttribute("title")) {
            case 'Approval Name':
                fieldAPIName = "Name";
              break;
            case 'Date Assigned':
                fieldAPIName = "qtc_Requested_Date_Display__c";
              break;
            case 'Assigned To':
                fieldAPIName = "qtc_Assigned_To_Name__c";
              break;
            case 'Rule Name':
                fieldAPIName = "QS_Approval_Rule_Name__c";
              break;
            case 'Requested By':
                fieldAPIName = "qtc_Requested_By__c";
              break;
            case 'Customer':
                fieldAPIName = "qtc_Customer__c";
              break;
            case 'Quote':
                fieldAPIName = "QS_Quote_Name__c";
          }


        var order = component.get("v.order");
        if (fieldAPIName === component.get("v.orderBy")) {
            // If same field than change between order
            if (order === 'ASC') {
                component.set("v.order",'DESC');
            } else {
                component.set("v.order",'ASC');
            } 
            helper.sortBy(component,fieldAPIName,component.get("v.order"));
        } else {
            component.set("v.orderBy", fieldAPIName);
            component.set("v.order",'ASC');
            helper.sortBy(component,fieldAPIName,component.get("v.order"));
        }
        
    },
 
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        component.set("v.spinner", false);
    }
})