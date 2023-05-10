({
    doInit : function(component, event, helper) {      
        var IPT_PartnerCentral = $A.get("$Label.c.IPT_PartnerCentral"); //Partner Community URL Label
        component.set("v.IPTPartnerCommunityUrl", IPT_PartnerCentral);
        var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); 
            component.set("v.isCommunityUser",isCommunity);
        });
        $A.enqueueAction(action); 
    },
    hideMsg : function(component, event, helper) { 
        //var fgh = component.find("abc");
        //alert(document.getElementById("fgh"));
        //commenting this for new change @Ajay
        //document.getElementById("containerCollapsable").classList.add("hide");
        var element = document.getElementById("containerCollapsable");
        element.style.display = 'none';              
        //$A.util.addClass(fgh, 'slds-theme--success');

    },
    handleMessages : function(component, event, helper) {
         component.set("v.Error",false);
        component.set("v.Success",false);
        component.set("v.Warning",false);
        
        component.set("v.Msg",event.getParam("Msg"));
        component.set("v.Category",event.getParam("Category"));
        component.set("v.ShowHide",event.getParam("isShow"));
        
        if(component.get("v.Category") === "Success"){
            
            component.set("v.Success",true);
        }
       else if(component.get("v.Category") === "Error"){
            
            component.set("v.Error",true);
        }
       else if(component.get("v.Category") === "Warning"){
            
            component.set("v.Warning",true);
        } 
           else{
               component.set("v.Success",true);
           }
        var container = helper.hideMsgAuto(component, event, helper);
    }
    
    
})