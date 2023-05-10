({
	doInit : function(component, event, helper) {
        var action = component.get("c.getActvityResult");
        action.setParams({mdfReqId:component.get("v.recordId")});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state = "SUCCESS"){
                if (response.getReturnValue().mdfReq != null) {
                    component.set("v.activityValue",response.getReturnValue().mdfReq.Activity_Type__c)
                    component.set("v.mdf",response.getReturnValue().mdfReq);
                    if (response.getReturnValue().mdfClaim != null) {
                        component.set("v.claim",response.getReturnValue().mdfClaim);
                    }
                }
                
            }
            console.log(response.getReturnValue().mdfReq.Estimated_New_Leads__c);
        })
        $A.enqueueAction(action);
	}
})