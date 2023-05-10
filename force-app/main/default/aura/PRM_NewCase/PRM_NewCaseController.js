({
	 doInit : function(component, event, helper) {
        var action = component.get("c.getContactDetail");
      	component.set("v.Spinner", true);
        action.setCallback(this,function(a){
            var value = [{ 
                type: 'Contact', 
                id: a.getReturnValue().Id, 
                label: a.getReturnValue().Name, 
            }]; 	
            component.find("ContactName").get("v.body")[0].set("v.values", value); 
            
            component.set("v.contactId", a.getReturnValue().Id);
            component.set("v.Spinner", false);
        })
        
        $A.enqueueAction(action);
    },
    
     cancel : function(component, event, helper) {
         
			$A.get("e.force:navigateToURL").setParams({ 
                   "url": "/get-help-listview"
                }).fire();
     },
    
    cSaveCase : function(component, event, helper) {
         
        //alert( component.find("ContactName").get("v.value") +'---------' + component.get("v.contactId"));
        component.set("v.Spinner", true); 
        if(component.find("ContactName").get("v.value") == component.get("v.contactId"))
        {
           
            if(helper.isValidate(component, event, helper))
            {
                var action = component.get("c.saveCase");
                action.setParams({
                    "objCase" : component.get("v.objCase"),
                    "contactId": component.find("ContactName").get("v.value"),
                    "ccId": component.find("CC").get("v.value")
                })
              
                action.setCallback(this,function(a){
                    component.set("v.Spinner", false); 
                    //alert(a.getReturnValue());
                     $A.get("e.force:navigateToURL").setParams({ 
                           "url": "/get-help-record?cid=" + a.getReturnValue()
                        }).fire(); 
                })
                
                $A.enqueueAction(action);
            }
            else
            {
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error:",  
                    "type": "error",
                    "message": "Review the errors on this page."
                }); 
                toastEvent.fire(); 
            }
        }
        else
        {
            component.set("v.Spinner", false);
           	var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error:",  
                "type": "error",
                "message": "Selected 'Contact Name' must be Login Partner Name."
            }); 
            toastEvent.fire(); 
            
        }
     },
})