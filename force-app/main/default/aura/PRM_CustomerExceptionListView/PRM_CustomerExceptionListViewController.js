({
    doInit : function(component, event, helper) {
        var action = component.get("c.getCustomerException");
        action.setParams({
            "selectedView" : "All",
        })
        action.setCallback(this,function(a){
            component.set("v.ObjectData", a.getReturnValue());
            helper.pagination(component, event);
        })
        
        $A.enqueueAction(action);
    },
    
    onClick : function(component, event, helper) {
        var exbRdId = event.currentTarget.dataset.record;
        component.set("v.drId", exbRdId);
    },
    
    cNext : function(component, event, helper) {
        helper.hNext(component, event);
    }, 
    
    cPrevious: function(component, event, helper) {
        helper.hPrevious(component,event);
    },
    
    cNewCustomerException: function(component, event, helper) {
        /*$A.get("e.force:navigateToURL").setParams({ 
           "url": "/new-customer-exception" 
        }).fire();*/
        
        var url1 = "/PartnerCentral/s/new-customer-exception";
        window.open(url1,'_self');
    },
    
    cViewChange: function(component, event, helper) {
        component.set("v.Spinner", true); 
        var action = component.get("c.getCustomerException");
        action.setParams({
            "selectedView" : component.get("v.selectedView"),
        })
        
        action.setCallback(this,function(a){
            component.set("v.Spinner", false);
            component.set("v.ObjectData", a.getReturnValue());
            helper.pagination(component, event);
        })
        
        $A.enqueueAction(action);
    },   
    
     redirectToRecord: function(cmp, event, helper){
   		var exbRdId = event.currentTarget.dataset.record;
   		cmp.set("v.recId", exbRdId);
        
        $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/customer-exception-record?ceid=" + exbRdId
                }).fire();
    },
})