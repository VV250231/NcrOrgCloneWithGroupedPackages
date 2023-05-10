({
	valdLeadLoadHelp : function(component, event, helper) {
		var action = component.get("c.validateLeadOnLoadHelp");
        action.setParams({ 
        	"leadId" : component.get("v.LeadId")     
        });
        action.setCallback(this, function(a) {
        	if(a.getState() == "SUCCESS") {
                var disableHelpOnLoad = a.getReturnValue();
                
                if(!disableHelpOnLoad) {
                    $A.util.removeClass(component.find("popupSection"),'slds-hide');   
           			$A.util.removeClass(component.find("popupbackdrop"),'slds-hide'); 
                }
            } else if(a.getState() == "ERROR") {
                alert('lead help error');
            }
        }); $A.enqueueAction(action);			
	},
    
    updateUserPref : function(component, event, helper) {
    	var action = component.get("c.updateUserSetting");
        action.setCallback(this, function(a) {
            if(a.getState() == "SUCCESS") {} 
            else if(a.getState() == "ERROR") {console.log(a.getError());}
            
        }); $A.enqueueAction(action);		    
    },
    
    
    closePopup : function(component) {
    	if(component.get("v.showOnLoad")) {
        	$A.util.addClass(component.find("popupSection"),'slds-hide');   
            $A.util.addClass(component.find("popupbackdrop"),'slds-hide');  
        } else {
        	var helpAction = $A.get("e.force:closeQuickAction");
       		helpAction.fire();    
        }    
    }
})