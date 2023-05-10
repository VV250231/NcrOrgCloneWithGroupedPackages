({
    // function call on component Load
    /*doInit: function(component, event, helper) 
    {  
        var action = component.get("c.saveCustomerException");
        component.set("v.Spinner", true);
        action.setCallback(this,function(a){
            
            component.set("v.Spinner", false);
        })
        
        $A.enqueueAction(action);
    }, */
    
    cancel : function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "/customer-exception-list-view"
        }).fire();
    },
   
    saveCustomerExceptionController : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        if(helper.isValidate(component, event, helper))
        {
        var action = component.get("c.saveCustomerException");
     //   alert(component.find("Customer_Name").get("v.value"));
        action.setParams({
            "objCE" : component.get("v.ObjCustomerException"),
            "customerNameId": component.find("Customer_Name").get("v.value")
        })
        
        action.setCallback(this,function(a){
            component.set("v.Spinner", false); 
            //alert(a.getReturnValue());
            $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/customer-exception-record?ceid=" + a.getReturnValue()
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
    },
    
    
    
    
})