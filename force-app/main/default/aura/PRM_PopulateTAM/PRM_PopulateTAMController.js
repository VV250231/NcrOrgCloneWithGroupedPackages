({
	 doInit: function(component, event, helper) {
        
        var action = component.get("c.getTAMvalues");
        action.setParams({
           "recId":component.get("v.recordId")
            //"recId" : "a0tc00000048rS5"
        });
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstTAM", response.getReturnValue().lstTAMName);
                component.set("v.isSelected", response.getReturnValue().isPopulated);
                //alert(component.get("v.isSelected"));
              	 console.log( response.getReturnValue().lstTAMName);
                console.log( response.getReturnValue().isPopulated);
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModal: function(component, event, helper) {
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    updatePartnerOpportunity: function(component, event, helper) {
        //alert(component.find("selectTAM").get("v.value"));
        var action = component.get("c.updatePartnerOpp");
       	action.setParams({
           "recId":component.get("v.recordId"),
            //"recId" : "a0tc00000048rS5",
            "selectedTAM": component.find("selectTAM").get("v.value")
          
        });
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 // Display the total in a "toast" status message
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success",
                    "message": "Partner Opportunity has updated successfully."
                });
                resultsToast.fire();
                $A.get('e.force:refreshView').fire();
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    isRefreshed: function(component, event, helper) {
        location.reload();
    },
})