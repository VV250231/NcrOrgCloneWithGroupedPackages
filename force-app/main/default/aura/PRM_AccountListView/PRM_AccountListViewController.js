({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAccounts");
        action.setParams({
            "selectedView" : "All Accounts"
        })
        action.setCallback(this,function(a){
            component.set("v.ObjectData", a.getReturnValue());
            helper.pagination(component, event);
        })
        
        $A.enqueueAction(action);
    },
    
   
    
    cNext : function(component, event, helper) {
        helper.hNext(component, event);
    }, 
    
    cPrevious: function(component, event, helper) {
        helper.hPrevious(component,event);
    },
    
    
    
    cViewChange: function(component, event, helper) {
        component.set("v.Spinner", true); 
        var action = component.get("c.getAccounts");
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
                   "url": "/account-record?recordId=" + exbRdId
                }).fire();
    },
})