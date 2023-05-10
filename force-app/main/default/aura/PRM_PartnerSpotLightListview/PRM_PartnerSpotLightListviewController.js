({
    doInit : function(component, event, helper) {
        var action = component.get("c.getPartnerSpotlight");
        action.setParams({
            "selectedView" : component.get("v.selectedView"),
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
        var values = exbRdId.split('--');
        component.set("v.partnerFeatureId", values[0]);
        if(values[1] == 'Partner Feature Friday') 
        {
            component.set("v.isPFF", true);
            component.set("v.isMDF", false);
            component.set("v.isPME", false);
            component.set("v.isSCW", false);
            component.set("v.isMBRT", false);
        }
        else if(values[1] == 'MDF Success Story') 
        {
            component.set("v.isPFF", false);
            component.set("v.isMDF", true);
            component.set("v.isPME", false);
            component.set("v.isSCW", false);
            component.set("v.isMBRT", false);
        }
        else if(values[1] == 'Partner Ambassador Event') 
        {
            component.set("v.isPFF", false);
            component.set("v.isMDF", false);
            component.set("v.isPME", true);
            component.set("v.isSCW", false);
            component.set("v.isMBRT", false);                   
        }
        else if(values[1] == 'Significant Customer Win') 
        {
            component.set("v.isPFF", false);
            component.set("v.isMDF", false);
            component.set("v.isPME", false);
            component.set("v.isSCW", true);
            component.set("v.isMBRT", false);
        }
        else if(values[1] == 'Miscellaneous Business Related Topic') 
        {
            component.set("v.isPFF", false);
            component.set("v.isMDF", false);
            component.set("v.isPME", false);
            component.set("v.isSCW", false);
            component.set("v.isMBRT", true);
        }
    },
    
    cNext : function(component, event, helper) {
        helper.hNext(component, event);
    }, 
    
    cPrevious: function(component, event, helper) {
        helper.hPrevious(component,event);
    },
    
    cNewSpotlight: function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
           "url": "/partner-spotlight" 
        }).fire();
    },
    
    cViewChange: function(component, event, helper) {
        var action = component.get("c.getPartnerSpotlight");
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