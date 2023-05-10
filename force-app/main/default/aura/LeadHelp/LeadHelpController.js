({
    doInit : function(component, event, helper) {
		helper.valdLeadLoadHelp(component, event, helper);
    },
    
    closeModal :  function(component, event, helper) {
        if(event.getParam != undefined && typeof event.getParam == "function") {  
            var params = event.getParam('arguments');
            if (params && params.isNotShowMsg) {
                helper.updateUserPref(component, event, helper);
            }
        }
        helper.closePopup(component);
    },
    
    
    
  
})