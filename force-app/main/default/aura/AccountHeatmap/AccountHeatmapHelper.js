({
	loadFinancialAccountDetail : function(component, helper) {
        var action = component.get("c.getAccount"); 
        action.setParams({ 
            "Accountid" : component.get("v.recordId")       
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                
                if(a.getReturnValue()==null){
                    component.set("v.nonfinancial", true); 
                } else{
                    component.set("v.accountObj", a.getReturnValue());
                }                
                
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());   
            }
            
        });
        $A.enqueueAction(action);
    },
    getLabels1 : function(component) {
        var action = component.get("c.getLabels"); 
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {                
                component.set("v.labels", a.getReturnValue()); 
                
                
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());   
            }
            
        });
        $A.enqueueAction(action);
    },
    
    loadOppProductsYellowData : function(component, helper) {
        debugger ;
        var action = component.get("c.getHeatMapData"); 
        action.setParams({ 
            "acctId" : component.get("v.recordId")       
        });
        action.setCallback(this, function(a) {
            
            //var jsonStr = '' ;
            if (a.getState() === "SUCCESS") { 
               /* for(var i=0 ; i < a.getReturnValue().length ; i++) {
                    jsonStr.
                } */
                component.set("v.productsYellowMap", a.getReturnValue()); 
                
                
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());   
            }
            
        });
        $A.enqueueAction(action);
        
    } ,
    
})