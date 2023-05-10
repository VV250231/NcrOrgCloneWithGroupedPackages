({
    myAction : function(component, event, helper) {
        
    },
    doInit : function(component, event, helper)
    {       
        console.log('do init Loaded');
        helper.loadinitialdetails(component, event, helper);
    },
    SG_Errorpop : function(component, event, helper) {
        var $j = jQuery.noConflict();
        var id=component.get("v.recordId");
    },
    
    submitforapproval : function(component, event, helper)
    {       
        helper.submitforapproval(component, event, helper);
    },
    approvecap : function(component, event, helper)
    {       
        helper.approvecaps(component, event, helper);
    },
    approvecustomerassurance : function(component, event, helper)
    {       
        helper.approvecustomerassurances(component, event, helper);
    },
    approveToWatchlist : function(component, event, helper)
    {       
        helper.approveToWatchlist_helper(component, event, helper);
    },
    reject : function(component, event, helper)
    {       
        helper.rejects(component, event, helper);
    },
    
})