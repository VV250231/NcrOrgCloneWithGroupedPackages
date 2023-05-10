({
    showReports : function(component, event, helper, reportType) {
        var action = component.get("c.getReports");
        action.setParams({ DashboardType : reportType });
        
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result)){
                    component.set("v.reports",result); 
                    component.set("v.showNoRecordMessage",false);
                }else{                    
                    component.set("v.showNoRecordMessage",true);
                    component.set("v.reports",null);
                }
            } else if(state == "ERROR"){
                alert('Error in calling server side action');
            }
        });
        
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
    },
    
    removeActiveClass: function (cmp, event, helper) {
        $A.util.removeClass(cmp.find('WFR'), 'active');  
        $A.util.removeClass(cmp.find('Industry'), 'active');  
        $A.util.removeClass(cmp.find('Regional'), 'active');  
        $A.util.removeClass(cmp.find('Country'), 'active');
        $A.util.removeClass(cmp.find('ISG'), 'active');
        $A.util.removeClass(cmp.find('HC'), 'active');
        $A.util.removeClass(cmp.find('OT'), 'active');
    }
    ,
    
    submit: function (cmp, event, helper) {
        var action = cmp.get("c.submitMessage");
        if(cmp.get("v.usertype")=='Guest'){
            action.setParams({ name : cmp.get("v.name"), email : cmp.get("v.email"), message : cmp.get("v.msg") });            
        }else{
            action.setParams({ name : cmp.get("v.name1"), email : cmp.get("v.email1"), message : cmp.get("v.msg") });
        }
        
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                cmp.set("v.name","");
                cmp.set("v.email","");
                cmp.set("v.msg","");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"success",
                    "message": "The Email has been sent successfully."
                });
                toastEvent.fire();
            } else if(state == "ERROR"){
                alert('Error in calling server side action');
            }
        });
        
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
    }
})