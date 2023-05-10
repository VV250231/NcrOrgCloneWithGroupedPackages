({
    doInit : function(component, event, helper) {
    },
    
    handleCancel: function (event) {
        $A.get("e.force:closeQuickAction").fire();       
    },
    
    openOppNewPage: function(component, event) {
        
        var action = component.get("c.convertToOpportunity");
        action.setParams({
            "specialBidRegID":component.get("v.recordId")
        });
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                component.set("v.objOpp", response.getReturnValue().objOppoturnity);
                var errorMessage = response.getReturnValue().errorMsg;
                
                if(errorMessage === 'Success')
                {
                    var createOppEvent = $A.get("e.force:createRecord");
                    createOppEvent.setParams({
                        "entityApiName": "Opportunity",
                        "recordTypeId": event.getParam('recordTypeId'),
                        "defaultFieldValues": {
                            'Name' :  component.get("v.objOpp.Name"),
                            'Partner_End_Customer__c' :  component.get("v.objOpp.Partner_End_Customer__c"),
                            'Amount' :  component.get("v.objOpp.Amount"),
                            'CloseDate' :  component.get("v.objOpp.CloseDate"),
                            'CAM__c' :  component.get("v.objOpp.CAM__c"),
                            'TAM__c' :  component.get("v.objOpp.TAM__c"),
                            'AccountId' :  component.get("v.objOpp.AccountId"),
                            'StageName' : component.get("v.objOpp.StageName"),
                            'Linked_Special_Bid_Registration__c':component.get("v.objOpp.Linked_Special_Bid_Registration__c"),
                            'Probability': component.get("v.objOpp.Probability")
                        }
                    });
                    createOppEvent.fire();
                }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Information",  
                        "type": "info",
                        "interval": 15000,
                        "message": errorMessage
                    });
                    toastEvent.fire();
                }
                
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
    }
})