({
    doInit : function(component, event, helper) {
        component.set("v.home",true);
        component.set("v.team",false);
        component.set("v.faq",false);
        component.set("v.news",false);
        var action = component.get("c.loggedInAs");
        
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result)){
                    component.set("v.userinfo",result); 
                }
            } else if(state == "ERROR"){
                alert('Error in calling server side action');
            }
        });
        
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
    },
    home : function(component, event, helper) {
        component.set("v.home",true);
        component.set("v.team",false);
        component.set("v.faq",false);
        component.set("v.news",false);
        helper.handleTabClick(component, event, helper, 'tab_home');
    }
    ,
    team : function(component, event, helper) {
        component.set("v.team",true);
        component.set("v.faq",false);
        component.set("v.home",false);
        component.set("v.news",false);
        helper.handleTabClick(component, event, helper, 'tab_team');
    }
    ,
    faq : function(component, event, helper) {
        component.set("v.faq",true);
        component.set("v.home",false);
        component.set("v.team",false);
        component.set("v.news",false);
        helper.handleTabClick(component, event, helper, 'tab_faq');
    },
    
    news : function(component, event, helper) {
        component.set("v.faq",false);
        component.set("v.home",false);
        component.set("v.team",false);
        component.set("v.news",true);
        helper.handleTabClick(component, event, helper, 'tab_news');
    }
})