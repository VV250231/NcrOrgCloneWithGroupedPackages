({
    doInit : function(component, event, helper) {
        var action = component.get("c.getEquipments");
        action.setParams({
            "selectedView" : component.get("v.selectedView"),
            "orderBy"      : component.get("v.sortBy"),
            "order"       : component.get("v.sortIn")
        })
        action.setCallback(this,function(a){
            component.set("v.ObjectData", a.getReturnValue());
            helper.pagination(component, event);
        })
        
        $A.enqueueAction(action);
    },
    
    /*onClick : function(component, event, helper) {
        var exbRdId = event.currentTarget.dataset.record;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": exbRdId
        });
        navEvt.fire();
       
    },*/
    
    onClick : function(component, event, helper) {
        var exbRdId = event.currentTarget.dataset.record;
       
        
        $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/equipment-record?recordId=" + exbRdId
                }).fire();
    },
    cNext : function(component, event, helper) {
        helper.hNext(component, event);
    }, 
    
    cPrevious: function(component, event, helper) {
        helper.hPrevious(component,event);
    },
    
    cPageChange: function(component, event, helper) {
        helper.hPageChange(component,event);
    },
    
    cPageSizeChange: function(component, event, helper) {
        helper.hPageSizeChange(component,event);
    },
    
    cNewEquipment: function(component, event, helper) {
        /*var createEquipmentEvent = $A.get("e.force:createRecord");
        createEquipmentEvent.setParams({
            "entityApiName": "Equipment_Declaration__c",           
        });
        createEquipmentEvent.fire();*/
        
         $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/new-equipment"
                }).fire();
    },
    
    cViewChange: function(component, event, helper) {
        var action = component.get("c.getEquipments");
        action.setParams({
            "selectedView" : component.get("v.selectedView"),
            "orderBy"      : component.get("v.sortBy"),
            "order"        : component.get("v.sortIn")
        })
        
        action.setCallback(this,function(a){
            component.set("v.ObjectData", a.getReturnValue());
            helper.pagination(component, event);
        })
        
        $A.enqueueAction(action);
    },
    
    sorting: function (component, event, helper) {
       var fieldAPIName = event.currentTarget.dataset.record;
        if (component.get("v.sortBy") === fieldAPIName) {
            if (component.get("v.sortIn") === 'ASC') {
                component.set("v.sortIn",'DESC')
            } else {
                component.set("v.sortIn",'ASC')
            }
        } else {
            component.set("v.sortBy",fieldAPIName);
            component.set("v.sortIn",'ASC');
        }
        
        var action = component.get("c.getEquipments");
        action.setParams({
            "selectedView" : component.get("v.selectedView"),
            "orderBy"      : component.get("v.sortBy"),
            "order"       : component.get("v.sortIn")
        })
        action.setCallback(this,function(a){
            component.set("v.ObjectData", a.getReturnValue());
            helper.pagination(component, event);
        })
        
        $A.enqueueAction(action);
    }
    
})