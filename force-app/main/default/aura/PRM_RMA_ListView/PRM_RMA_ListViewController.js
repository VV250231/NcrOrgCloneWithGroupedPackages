({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRmaList");
        action.setCallback(this,function(a){
            component.set("v.ObjectData", a.getReturnValue());
            helper.pagination(component, event);
        })       
        $A.enqueueAction(action);
    },
    
    onClick : function(component, event, helper) {
        component.set("v.isListView", false);
        var exbRdId = event.currentTarget.dataset.record;
        
        $A.get("e.force:navigateToURL").setParams({ "url": "/rma-view?recordId=" + exbRdId }).fire();
        //component.set("v.recordId", exbRdId);
        //component.set("v.isDetail", true);
    },
    
    cNext : function(component, event, helper) {
        helper.hNext(component, event);
    }, 
    
    cPrevious: function(component, event, helper) {
        helper.hPrevious(component,event);
    },
    
    cNewRMA: function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ "url": "/rma" }).fire();
    },
    
    cViewChange: function(component, event, helper) {
        var action = component.get("c.getRmaList");
        action.setParams({
            "selectedView" : component.get("v.selectedView"),
        })
        
        action.setCallback(this,function(a){
            component.set("v.ObjectData", a.getReturnValue());
            helper.pagination(component, event);
        })
        
        $A.enqueueAction(action);
    },    
})