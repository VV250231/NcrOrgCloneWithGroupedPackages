({
	doInit : function(component, event, helper) {
		helper.getEquipment(component);
	},
    
    dosubmitWLR : function(component, event, helper) {
        if (helper.validateWLRform(component)) {
            helper.submitWLR(component);
        }        
    },
    
    closeModal : function() {
        $A.get("e.force:closeQuickAction").fire();
    }
})