({
	doInit : function(component, event, helper) {
        component.set("v.ShowButton", false);
		helper.GetNotification(component,event, helper);
	},
    
    hidemsg : function(component, event, helper) {
        helper.hideMsg(component,'floatMsg', 'slds-hide');
    },
    handleClick : function(component, event, helper) {
       // alert('hi');
         component.set("v.openModal", true);
    }
})