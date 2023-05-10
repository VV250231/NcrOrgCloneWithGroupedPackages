({
    // this method load intially
	doInit : function(component, event, helper) {
        var action = component.get("c.islocked");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.islock",result.isLock);
                component.set("v.isApproved",result.isApproved);
                component.set("v.isDataLoaded",true);
            }            
        });
        $A.enqueueAction(action);
	},
    // This method call when user clicked on unlock record
    unlockRecordcr : function(component, event, helper) {
       var action = component.get("c.unlockRecord");
        action.setParams({
            objId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(result){
                var showToast = $A.get("e.force:showToast");
                component.set("v.islock",false);
                showToast.setParams({ 
                    title : 'Record unlocked!!!', 
                    message : 'Record Unlocked Successfully.' ,
                    type : 'success',
                    mode : 'pester'
                });
                showToast.fire(); 
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
	}
})