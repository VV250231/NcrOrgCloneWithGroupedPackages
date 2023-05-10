({
    getpicklistvalue: function(component){ 
        var action = component.get("c.getpickval");
        var inputsel = component.find("Price"); 
        var opts=[];
        action.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel.set("v.options", opts);
            
        });     
        $A.enqueueAction(action); 
    }, 
    
    getInput:function(component)
    {  
        var Price_Variance = component.find("Price_Variance").get("v.value");
        
        var PV = component.find("PV");
        
        PV.set("v.value", Price_Variance); 
    },
    firePriceVarianceEvent : function(cmp, event ,helper) {
        
        
        var Price_Variance = cmp.find("Price").get("v.value");
        
        //Look up event by name, not by type
        var compEvents = cmp.getEvent("PriceVarianceEventFired");
        compEvents.setParams({ "pricevariance" : Price_Variance });
        compEvents.fire();
    }
    
    
})