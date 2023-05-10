({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRMAReq");
        action.setParams({'recId':component.get("v.recordId")});
        action.setCallback(this,function(response){
            component.set("v.rmaObj",response.getReturnValue());
        })
        $A.enqueueAction(action);
    },
    
    handleCancel : function(component, event, helper) { 
        component.getEvent("cancelEdit").fire();
    },
    
    chandleRecSave : function(component, event, helper) {
        var action = component.get("c.updateRecord");
        
        action.setParams({"rec": component.get("v.rmaObj")});
        action.setCallback(this,function(response){
            var state = response.getState();
           // var toastEvent = $A.get("e.force:showToast");
            
            if(state == 'SUCCESS') {
              /*  toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": " Request is saved successfully." 
                })*/
                
                component.getEvent("saveEdit").fire();
                
            } else if(state == 'INCOMPLETE') {
               /* toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": " Something has gone wrong. State=INCOMPLETE"
                });*/
            } else if(state == 'ERROR') {
               /* toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": " Something has gone wrong."
                });*/
            }
            //toastEvent.fire();
            console.log(response.getReturnValue());
        })
        $A.enqueueAction(action);
    }
})