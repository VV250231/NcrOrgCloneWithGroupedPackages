({
    doInit : function(component, event, helper) {
        if(!component.get("v.showDashboard")){
            var action = component.get("c.getMCN");
            action.setParams({ idd : component.get("v.recordId") });        
            //Setting the Callback
            action.setCallback(this,function(a){
                //get the response state
                var state = a.getState();            
                //check if result is successfull
                if(state == "SUCCESS"){
                    var result = a.getReturnValue();
                    if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result)){
                        component.set("v.acc",result);
                        helper.handleShowModal(component, event, helper);  
                    }
                    
                } else if(state == "ERROR"){
                    alert('Error in calling server side action');
                }
            });
            
            //adds the server-side action to the queue        
            $A.enqueueAction(action);  
        }
        
    },
    handleShowModal : function(component, event, helper) {
        helper.handleShowModal(component, event, helper); 
        
    }
    
})