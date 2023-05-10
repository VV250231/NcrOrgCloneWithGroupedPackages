({
     doInit : function(component, event, helper) {
    },
    toggle : function(component, event, helper) {
        var qiConShow=component.find("hide");
        var qiConHide=component.find("show");
        var ans=component.find("ans");
        if (!component.get("v.visible")){
            $A.util.removeClass(qiConShow, 'slds-hide');
            $A.util.addClass(qiConShow, 'slds-show');
            $A.util.addClass(qiConHide, 'slds-hide');
            $A.util.removeClass(qiConHide, 'slds-show');
            $A.util.removeClass(ans, 'slds-hide');
            $A.util.addClass(ans, 'slds-show');
            component.set("v.visible",true);
        }else{
            $A.util.addClass(qiConShow, 'slds-hide');
            $A.util.removeClass(qiConShow, 'slds-show');
            $A.util.removeClass(qiConHide, 'slds-hide');
            $A.util.addClass(qiConHide, 'slds-show');
            $A.util.addClass(ans, 'slds-hide');
            $A.util.removeClass(ans, 'slds-show');
            component.set("v.visible",false);
        }
    }
})