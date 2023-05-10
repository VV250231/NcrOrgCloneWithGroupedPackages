({
    doInit : function(component, event, helper) {
		helper.getLeadConList(component, event, helper);
        //helper.getHelpText(component, event, helper);
    },
    
    closeAction : function(component, event, helper) {
        var showOnLoad = component.get("v.showOnLoad");
        var isDntShowMsg;
        if(showOnLoad) 
            isDntShowMsg = component.get("v.isDntShowMsg");
        else isDntShowMsg = false;    
		var parentComp = component.get("v.parent");
   	    parentComp.closeModal(isDntShowMsg);       
    }
})