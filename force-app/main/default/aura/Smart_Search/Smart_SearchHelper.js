({
    helperMethod : function() {
        
    },
    checkprofile : function(component, event, helper)
    {
        var action = component.get("c.checkprofile");
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.toggleprofileaccess", a.getReturnValue());
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    searchusers : function(component, event, helper)
    {
        var action = component.get("c.loadobjects");
        var searchkey = component.find("searchkey").get("v.value");
        var objectname = component.get("v.objectname");
        action.setParams({
            "searchkey":searchkey,
            "objectname":objectname
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.objectresultuser", a.getReturnValue());
                var numbers = component.get("v.objectresultuser");
                if(numbers.length == 0){
                    component.set("v.togglesearchcriteria", "true");
                }
                component.set("v.toggleloader", "false");
                
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                component.set("v.toggleloader", "false");
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    searchclass : function(component, event, helper)
    {
        var action = component.get("c.loadclass");
        var searchkey = component.find("searchkey").get("v.value");
        var objectname = component.get("v.objectname");
        action.setParams({
            "searchkey":searchkey,
            "objectname":objectname
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.objectresult", a.getReturnValue()); 
                var numbers = component.get("v.objectresult");
                if(numbers.length == 0){
                    component.set("v.togglesearchcriteria", "true");
                }
                component.set("v.toggleloader", "false");
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                component.set("v.toggleloader", "false");
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    searchpage : function(component, event, helper)
    {
        var action = component.get("c.loadpage");
        var searchkey = component.find("searchkey").get("v.value");
        var objectname = component.get("v.objectname");
        action.setParams({
            "searchkey":searchkey,
            "objectname":objectname
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.objectresult", a.getReturnValue()); 
                var numbers = component.get("v.objectresult");
                if(numbers.length == 0){
                    component.set("v.togglesearchcriteria", "true");
                }
                component.set("v.toggleloader", "false");
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                component.set("v.toggleloader", "false");
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    searchreport : function(component, event, helper)
    {
        var action = component.get("c.loadreport");
        var searchkey = component.find("searchkey").get("v.value");
        var objectname = component.get("v.objectname");
        action.setParams({
            "searchkey":searchkey,
            "objectname":objectname
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.objectresultreport", a.getReturnValue());
                var numbers = component.get("v.objectresultreport");
                if(numbers.length == 0){
                    component.set("v.togglesearchcriteria", "true");
                }
                component.set("v.toggleloader", "false");
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                component.set("v.toggleloader", "false");
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    searchltng : function(component, event, helper)
    {
        var action = component.get("c.loadltngcomponent");
        var searchkey = component.find("searchkey").get("v.value");
        var objectname = component.get("v.objectname");
        //alert(objectname);
        action.setParams({
            "searchkey":searchkey,
            "objectname":objectname
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.objectresult", a.getReturnValue()); 
                var numbers = component.get("v.objectresult");
                if(numbers.length == 0){
                    component.set("v.togglesearchcriteria", "true");
                }
                component.set("v.toggleloader", "false");
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                component.set("v.toggleloader", "false");
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    searchclass : function(component, event, helper)
    {
        var action = component.get("c.loadclass");
        var searchkey = component.find("searchkey").get("v.value");
        var objectname = component.get("v.objectname");
        action.setParams({
            "searchkey":searchkey,
            "objectname":objectname
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.objectresult", a.getReturnValue()); 
                var numbers = component.get("v.objectresult");
                component.set("v.toggleloader", "false");
                if(numbers.length == 0){
                    component.set("v.togglesearchcriteria", "true");
                }
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                //             component.set("v.toggleloader", "false");
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    searchprofile : function(component, event, helper)
    {
        var action = component.get("c.searchprofile");
        var searchkey = component.find("searchkey").get("v.value");
        var objectname = component.get("v.objectname");
        action.setParams({
            "searchkey":searchkey,
            "objectname":objectname
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.objectresult", a.getReturnValue()); 
                var numbers = component.get("v.objectresult");
                component.set("v.toggleloader", "false");
                if(numbers.length == 0){
                    component.set("v.togglesearchcriteria", "true");
                }
                
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                component.set("v.toggleloader", "false");
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    searchtemplate : function(component, event, helper)
    {
        var action = component.get("c.searchtemplate");
        var searchkey = component.find("searchkey").get("v.value");
        var objectname = component.get("v.objectname");
        action.setParams({
            "searchkey":searchkey,
            "objectname":objectname
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.objectresult", a.getReturnValue()); 
                var numbers = component.get("v.objectresult");
                component.set("v.toggleloader", "false");
                if(numbers.length == 0){
                    component.set("v.togglesearchcriteria", "true");
                }
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                component.set("v.toggleloader", "false");
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    searchpermissionset : function(component, event, helper)
    {
        var action = component.get("c.searchpermissionset");
        var searchkey = component.find("searchkey").get("v.value");
        action.setParams({
            "searchkey":searchkey
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.objectresult", a.getReturnValue()); 
                var numbers = component.get("v.objectresult");
                component.set("v.toggleloader", "false");
                if(numbers.length == 0){
                    component.set("v.togglesearchcriteria", "true");
                }
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                component.set("v.toggleloader", "false");
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
   
    
})