({
	GetRelatedContact:function (component,Acc){
        var action = component.get("c.GetAllACHContacts");
        var Options = [];
        action.setParams({"AccId":Acc});
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") { 
                var resp = response.getReturnValue();
                
                if(resp.length > 0){
                     for(var i=0;i<resp.length;i++){
                      
                        Options.push({ label: resp[i].ConName , value:resp[i].ConId });
                    }
                    component.set("v.options",Options);
                }
                
                
                
                else{
                    		var msg;
                            component.set("v.isApproved",true);
                            msg='No Related contact avalable under Customer Account.';
                            component.set("v.msg",msg);
                }
            }
        }); 
        $A.enqueueAction(action);
    }
})