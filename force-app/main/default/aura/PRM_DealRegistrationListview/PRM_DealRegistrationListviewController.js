({
    doInit : function(component, event, helper) {
        var action = component.get("c.getDealRegistration");
        action.setParams({
            "selectedView" : "All",
        })
        action.setCallback(this,function(a){
            component.set("v.ObjectData", a.getReturnValue().lstDR);
            component.set("v.objPartnerAccount", a.getReturnValue().objAccount);
          //  component.set("v.isRecordLock", response.getReturnValue().isRecordLock);
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
    
    onEditClick : function(component, event, helper) {      
        component.set("v.isListView", false);
        var exbRdId = event.currentTarget.dataset.record;
        component.set("v.drId", exbRdId);
        component.set("v.isDetail", true);  
        component.set("v.mode","Edit");
    },
    
    cNext : function(component, event, helper) {
        helper.hNext(component, event);
    }, 
    
    cPrevious: function(component, event, helper) {
        helper.hPrevious(component,event);
    },
    
    cNewSpotlight: function(component, event, helper) {
        //alert(component.get("v.objPartnerAccount.Partner_Type__c"));
        
        if(component.get("v.objPartnerAccount.Partner_Type__c") != 'Distributor')
        {
            $A.get("e.force:navigateToURL").setParams({ 
               "url": "/new-deal-registration" 
            }).fire();
        }
        else{
             $A.get("e.force:navigateToURL").setParams({ 
               "url": "/distributor-deal-registration" 
            }).fire();
        }
        
    },
    
    cViewChange: function(component, event, helper) {
        var action = component.get("c.getDealRegistration");
        action.setParams({
            "selectedView" : component.get("v.selectedView"),
        })
        
        action.setCallback(this,function(a){
            component.set("v.ObjectData", a.getReturnValue().lstDR);
            helper.pagination(component, event);
        })
        
        $A.enqueueAction(action);
    },    
})