({
    loadCreditDetail : function(component) {
        
        var action = component.get("c.getCreditDetail"); 
        action.setParams({ 
            "allFields" : component.get("v.fieldString"),
            "creditId": component.get("v.CID")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                if(a.getReturnValue()==null){
                    component.set("v.errorStr", 'NO CREDIT RECORD FOUND ON THIS ACCOUNT.'); 
                }else{
                    component.set("v.creditDetail", a.getReturnValue());  
                }
                
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());   
            }
            
        });
        $A.enqueueAction(action);
    },
    getFieldNames : function(component) {
        console.log('here');
        var action = component.get("c.getFieldsString"); 
        action.setParams({ 
            "objName" : 'Credit_Detail__c',
            "excludeString" : component.get("v.excludeString"),
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                if (a.getReturnValue().indexOf('ERROR') > -1) {
                    component.set("v.errorStr", a.getReturnValue());
                } else {
                    if(a.getReturnValue()==null || a.getReturnValue().length==0){
                        component.set("v.errorStr", 'NO FIELDS DEFINED TO BE CAPTURED IN CREDIT ACTIVITY.'); 
                    }else{
                        component.set("v.fieldString", a.getReturnValue());
                        this.getFieldValues(component);
                        this.loadCreditDetail(component); 
                    }
                    
                }       
                
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError()); 
                console.log(a.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
    getFieldValues : function(component) {
        console.log('here3');
        var action = component.get("c.getFields"); 
        action.setParams({ 
            "objName" : 'Credit_Detail__c',
            "excludeString" : component.get("v.excludeString"),
        });
        action.setCallback(this, function(a) {
            console.log(typeof a.getReturnValue());
            console.log(JSON.stringify( a.getReturnValue()));
            if (a.getState() === "SUCCESS") {
                component.set("v.fieldnames", a.getReturnValue());
                console.log('@@'+JSON.stringify( component.get("v.fieldnames")));
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());   
            }
            
        });
        $A.enqueueAction(action);
    }
})