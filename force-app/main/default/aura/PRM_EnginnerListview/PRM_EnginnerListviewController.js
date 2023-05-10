({
    doInit : function(component, event, helper) {
        var action = component.get("c.getEngineer");
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
        component.set("v.isListView", false);
        var exbRdId = event.currentTarget.dataset.record;
        component.set("v.drId", exbRdId);
        component.set("v.isDetail", true);
    },
    
    cNext : function(component, event, helper) {
        helper.hNext(component, event);
    }, 
    
    cPrevious: function(component, event, helper) {
        helper.hPrevious(component,event);
    },
    
    cNewEngineer: function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
           "url": "/new-engineer" 
        }).fire();
    },
    
    cViewChange: function(component, event, helper) {
        var action = component.get("c.getEngineer");
        action.setParams({
            "selectedView" : component.get("v.selectedView"),
        })
        
        action.setCallback(this,function(a){
            component.set("v.ObjectData", a.getReturnValue());
            helper.pagination(component, event);
        })
        
        $A.enqueueAction(action);
    },   
    
     redirectToRecord: function(cmp, event, helper){
   		var exbRdId = event.currentTarget.dataset.record;
   		cmp.set("v.recId", exbRdId);
        
        $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/engineer-record?recordId=" + exbRdId
                }).fire();
        
        //helper.getMDFDetails(cmp, event, helper,exbRdId);
        
    },
})