({
    doInit : function(component, event, helper) {
        var action = component.get("c.getEditCustomerExceptionDetail");
        var idParam = helper.getJsonFromUrl().ceid;
        //alert(idParam);
        action.setParams({
            "recId" : idParam
        })
        component.set("v.Spinner", true);
        action.setCallback(this,function(a){
            
            //component.set("v.ObjCustomerException", a.getReturnValue().objCE);
            component.set("v.ObjCustomerException", a.getReturnValue());
            
            var value = [{ 
                type: 'Exception_Account__c', 
                id: a.getReturnValue().Customer_Name__c, 
                label: a.getReturnValue().Customer_Name__r.Name, 
            }]; 	
            component.find("Customer_Name").get("v.body")[0].set("v.values", value); 
            
            component.set("v.Spinner", false);
            
            //alert(a.getReturnValue().Customer_Name__c);
        })
        
        $A.enqueueAction(action);
    },
    
    cancel : function(component, event, helper) {
        var idParam = helper.getJsonFromUrl().ceid;
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "/customer-exception-record?ceid=" + idParam
        }).fire();
        
    },
    
    saveCustomerExceptionController : function(component, event, helper) {
        
        component.set("v.Spinner", true); 
        if(helper.isValidate(component, event, helper))
        {
            var action = component.get("c.saveEditedCustomerException");
            action.setParams({
                "objCE" : component.get("v.ObjCustomerException"),
                "customerNameId": component.find("Customer_Name").get("v.value")            
            })
            
            action.setCallback(this,function(a){
                
                //alert(a.getReturnValue());
                $A.get("e.force:navigateToURL").setParams({ 
                    "url": "/customer-exception-record?ceid=" + a.getReturnValue()
                }).fire();
                
                component.set("v.Spinner", false); 
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