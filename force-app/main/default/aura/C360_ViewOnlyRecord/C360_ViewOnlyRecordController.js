({
	init : function(component, event, helper) {
		var action = component.get("c.getAccountBasics");
        action.setParams({
            accId:component.get("v.recordId")          
        });
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        action.setCallback(this, function(response) {
              var spinner = component.find("mySpinner");
              $A.util.toggleClass(spinner, "slds-hide");
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                console.log('c360 read only veiw');
                console.log(records);
                if(records.CDM_Account_Type__c=='Enterprise' || records.CDM_Account_Type__c=='Enterprise' || $A.util.isEmpty(records.CDM_Account_Type__c)){
                     component.set("v.oppCreate", false);
                }else{
                    component.set("v.oppCreate", true);
                }
                component.set("v.acc", records);
            }
            
        });
        
        $A.enqueueAction(action);
	}
})