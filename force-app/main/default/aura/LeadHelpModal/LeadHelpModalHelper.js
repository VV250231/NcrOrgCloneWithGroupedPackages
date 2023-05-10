({
	getLeadConList : function(component, event, helper) {
		var action = component.get("c.getLeadContacts");
        action.setCallback(this, function(a) {
        	if(a.getState() == "SUCCESS") {
                var response = a.getReturnValue();
                var sortField = 'Region_Order__c';
                
                response.forEach(function(item) {
                    item.Lead_Help_Configs__r.sort(function(a,b){
                        return a[sortField] - b[sortField];
                    });                                      		   
                });
                component.set("v.leadConList", response);
            }
        }); $A.enqueueAction(action);			
	},
    
    
    getHelpText : function(component, event, helper) {
		var action = component.get("c.getHelpContent");
        action.setCallback(this, function(a) {
        	if(a.getState() == "SUCCESS") {
                var response = a.getReturnValue();
                console.log(response.Test1__c);
                component.set("v.helpCont", response);
            }
        }); $A.enqueueAction(action);			
	}
    
    
    
})