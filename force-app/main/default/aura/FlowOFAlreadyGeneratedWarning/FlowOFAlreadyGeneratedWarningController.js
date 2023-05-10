({

    doInit : function(component, event, helper) {
       //helper.GetQuoteFromId(component); 
        var invokeFromValue = component.get('v.invokeFrom');
        if(invokeFromValue == '' || invokeFromValue == null){
            helper.GetQuoteFromId(component);
        }
        else if(invokeFromValue != ''){  
            helper.Showwarningmessage(component,invokeFromValue);
        }
        
    }
})