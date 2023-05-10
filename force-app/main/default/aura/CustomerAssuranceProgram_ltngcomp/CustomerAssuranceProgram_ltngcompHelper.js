({
    helperMethod : function() {
        
    },
    loadinitialdetails: function(component, event, helper)
    {
        var action = component.get("c.LoadCasedetails");
        action.setParams({ 
            "recordID" : component.get("v.CID")       
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                console.log('success Received from Apex controller.');
                component.set("v.Retrunfromcontroller", a.getReturnValue()); 
                var value =  component.get("v.Retrunfromcontroller");
                //alert(value);
                if(value[0] == 'Not Submitted'){
                    component.set("v.firststage", true);
                    if(value[1] == 'true'){
                        component.set("v.firststageapprovalbutton",true);
                    }
                    else{
                        component.set("v.firststagenonrecorduser",true);
                    }
                    if(value[2] == 'true'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            type:"warning",
                            title: "Warning !",
                            message: 'FYI: Another user has already submitted a CAP/CA request for this customer',
                        });
                        toastEvent.fire();
                    }
                }
                else if(value[0] == 'Submitted'){
                    component.set("v.secondstage", true); 
                    if(value[1] == 'true'){
                        component.set("v.secondstagebuttons",true);
                    }
                    else{
                        component.set("v.secondstagenonapprovers",true);
                    }
                    
                }
                    else if(value[0] == 'Approved CAP'){
                        component.set("v.thirdstageapproved", true); 
                    }
                        else if(value[0] == 'Approved for Watchlist'){
                            component.set("v.fourthstageapproved", true); 
                        }
                        else if(value[0] == 'Approved Customer Assurance'){
                            component.set("v.thirdstageapproved", true); 
                        }
                            else if(value[0] == 'Rejected'){
                                component.set("v.thirdstagerejected", true); 
                                if(value[1] == 'true'){
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        mode: 'sticky',
                                        type:"warning",
                                        title: "Warning !",
                                        message: 'FYI: Another user has already submitted a CAP/CA request for this customer',
                                    });
                                    toastEvent.fire();
                                }
                            }
                                else{
                                    component.set("v.errormessage",true);
                                }
            } else if (a.getState() === "ERROR") { 
                component.set("v.errormessage",true);
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    submitforapproval: function(component, event, helper)
    {
        var action = component.get("c.submitforapprovals");    
        action.setParams({ 
            "recordID" : component.get("v.CID")       
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var $j = jQuery.noConflict();
                location.reload(true); 
                
            } else if (a.getState() === "ERROR") { 
                component.set("v.errormessage",true);
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    approvecaps: function(component, event, helper)
    {
        // alert('approvecaps');
        var action = component.get("c.approvecapss");    
        action.setParams({ 
            "recordID" : component.get("v.CID")       
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                // alert('success Received from Apex controller.');
                var $j = jQuery.noConflict();
                location.reload(true);
            } else if (a.getState() === "ERROR") { 
                //  alert('Error Received from Apex controller.');
                component.set("v.errormessage",true);
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    approvecustomerassurances: function(component, event, helper)
    {
        // alert('approvecustomerassurances');
        var action = component.get("c.approvecustomerassurancess");    
        action.setParams({ 
            "recordID" : component.get("v.CID")       
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                //  alert('success Received from Apex controller.');
                var $j = jQuery.noConflict();
                location.reload(true);
            } else if (a.getState() === "ERROR") { 
                //  alert('Error Received from Apex controller.');
                component.set("v.errormessage",true);
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    approveToWatchlist_helper: function(component, event, helper)
    {
        // alert('approvecustomerassurances');
        var action = component.get("c.approveWatchlist");    
        action.setParams({ 
            "recordID" : component.get("v.CID")       
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                //  alert('success Received from Apex controller.');
                var $j = jQuery.noConflict();
                location.reload(true);
            } else if (a.getState() === "ERROR") { 
                //  alert('Error Received from Apex controller.');
                component.set("v.errormessage",true);
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    rejects: function(component, event, helper)
    {
        var action = component.get("c.rejectss");    
        action.setParams({ 
            "recordID" : component.get("v.CID")       
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var $j = jQuery.noConflict();
                location.reload(true);
            } else if (a.getState() === "ERROR") { 
                component.set("v.errormessage",true);
                $A.log("Errors", a.getError()); 
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
})