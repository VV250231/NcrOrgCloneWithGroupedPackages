({
	doInit : function(cmp, event, helper) {
		var action = cmp.get("c.getPicklistValues");
        action.setParams({
            objectName : cmp.get("v.objectName"),
            fieldName : cmp.get("v.parentFieldAPI"),
        });
        
        action.setCallback(this, function(response){
         	var status = response.getState();
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();
                //console.log(JSON.stringify(pickListResponse));
                cmp.set("v.parentList",pickListResponse);
                
            }
            else{
                alert('error')
            }
        });
        
        $A.enqueueAction(action);
	},
    parentFieldChange : function(component, event, helper) {
        
        
        var controllerValue = component.find("parentField").get("v.value");
        
        if((controllerValue)  &&  (controllerValue !== 'Assigned to Queue')){
            helper.GetUserInfo(component, event,controllerValue);
        }
        
        else{
              		component.set("v.DisputeAnalystUserId",'');
                    component.set("v.DisputeAnalysteUserEmail",'');
                    component.set("v.DisputeAnalystUserPhone",'');
                    component.set("v.RecordData",'');
                    component.set("v.DisputeAnalysteUserName",'');
                    component.set("v.togglephone",true);
        }
        
    },
    handleDisputeDisplayEvent :function(component, event, helper){
    	var message = event.getParam("DisplayMsg");
        component.set("v.ToggleDisplayMsg",true);
        component.set("v.DisplayMsg",message);
	}
})