({
	handleOk:function(component, event, helper) {
      		var action = component.get("c.UpdateOpportunityRecordNewCB"); 
            component.set("v.opportunity.CLM_Sales_Acknowledgment__c",true);
        	component.set("v.opportunity.Id",component.get("v.OpportunityId"));
            action.setParams({
                opp:component.get("v.opportunity"),  
                isClosed: false
                
            });        
            action.setCallback(this, function(response){
                //resetting the values
                //component.set("v.QuoteConfirmation", "NONE");
                //component.set("v.confirmQuote", false);
                //component.find("qtcnf").set("v.value","NONE");
               // alert(JSON.stringify(component.get("v.opportunity")));
                component.set("v.openModal", false);
                var state = response.getReturnValue();
                if (state == "Success") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                            "title": "Success!",
                            "mode":"dismissible",
                            "type":"Success",
                            "message":"Thank you for the acknowledgement!"
                        })
                        toastEvent.fire();
                    $A.get('e.force:refreshView').fire();                
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    console.log(state.split("FIELD_CUSTOM_VALIDATION_EXCEPTION,")[0]);
                    if (state.length>6) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "mode":"sticky",
                            "type":"error",
                            "message": state.split("FIELD_CUSTOM_VALIDATION_EXCEPTION,")[1]
                        })
                        toastEvent.fire();
                    }
                    else {
                        toastEvent.setParams({
                            "title": "Error!",
                            "mode":"sticky",
                            "type":"error",
                            "message": "Unknown Error occured, Please retry and contact Admin if issue still persist"
                        })
                        toastEvent.fire();  
                    }
                }
                
            });        
            $A.enqueueAction(action); 
     },
    
    
    closeModal : function(component, event, helper) {
        component.set('v.openModal',false);
        $A.get('e.force:refreshView').fire(); 
    }
})