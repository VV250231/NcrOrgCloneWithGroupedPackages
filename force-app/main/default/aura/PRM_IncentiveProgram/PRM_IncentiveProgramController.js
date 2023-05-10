({
    
    doInit : function(component, event, helper) {
        helper.getInsentivePrgOptions(component);
    },
    
    handleChange: function(component, event, helper) {
        var action = component.get("c.getIncentiveProgramDetail");
        action.setParams({
            "prgId": component.get("v.selectedValue") //component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            //console.log(a.getReturnValue());
            component.set("v.incentivePrg",a.getReturnValue());
        });
        
        
        $A.enqueueAction(action);
    },
    
    submitIPRequest: function(component, event, helper) {
        var checkCmp = component.find("checkbox");
        if (checkCmp.get("v.value") == true) {
            helper.processIPRequest(component);
        } else {
            alert('You must acknowledge and accept the terms and conditions before you submit.');
        }
    }
    
})