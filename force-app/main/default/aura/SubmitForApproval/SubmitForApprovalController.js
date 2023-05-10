({
	onRender : function(component, event, helper) {
            var reid=  component.get("v.recordId");
            var action = component.get("c.getStatus");
            action.setParams({ 
                              "recId":component.get("v.recordId")
                             });
            action.setCallback(this, function(a) {
                if(a.getState() === "SUCCESS"){
                    component.set("v.bVal",a.getReturnValue());
                }
            });
            $A.enqueueAction(action);
            
        //component.set("v.bVal",true);
        if(component.get("v.bVal")){
            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Warning Message',
                            message: 'By clicking No, your request will be saved but not submitted for approval.',
                            messageTemplate: '',
                            duration:'2000',
                            key: 'info_alt',
                            type: 'warning',
                            mode: 'pester'
                        });
                        toastEvent.fire();
        }
				
	},
    handleNoClick:function(component, event, helper){
            var action = component.get("c.setControlModal");
            action.setParams({ 
                              "recId":component.get("v.recordId")
                             });
            action.setCallback(this, function(a) {
                if(a.getState() === "SUCCESS"){
                    component.destroy();
		            component.set("v.bVal",false);	
                }
            });
            $A.enqueueAction(action);
                
    },
    handleSaveSuccess:function(component, event, helper){
         var action = component.get("c.SendForApproval");
            action.setParams({ 
                              "recId":component.get("v.recordId"),
                              "Comments": component.get("v.MyComment")
                             });
            action.setCallback(this, function(a) {
                if(a.getState() === "SUCCESS"){
                    var str ='This does not guarantee you tickets. You will be notified within 48 hours if the request has been approved or rejected.';
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Warning Message',
                            message: str,
                            messageTemplate: 'Record {0} created! See it {1}!',
                            duration:' 3000',
                            key: 'info_alt',
                            type: 'warning',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    //component.destroy();
		            component.set("v.bVal",false);
                     $A.get('e.force:refreshView').fire();

                }
            });
            $A.enqueueAction(action);
    }
    
})