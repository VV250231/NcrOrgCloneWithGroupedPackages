({
	doInit : function(component, event, helper) {
		helper.validatePaymentAppWithdrawal(component);
	},
    
    withdrawPaymentApplication : function(component, event, helper) {
        helper.withdrawPaymentApplication(component);
	}
})