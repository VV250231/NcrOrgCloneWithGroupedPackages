({
	doInit : function(component, event, helper) {
		helper.loadOpportunity(component);
        helper.UserDefaultCurrency(component, event, helper);
        helper.getFieldsDetail(component, event, helper);
    },
    
    
})