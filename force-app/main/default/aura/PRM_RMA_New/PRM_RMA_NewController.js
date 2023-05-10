({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRmaRecordTypes");
        action.setCallback(this, function(response){
            component.set("v.rmaRecordTypes",response.getReturnValue());
        })
        $A.enqueueAction(action);
    },
    
    handleRecTypeChange : function(component, event, helper) {      
        component.set("v.recordTypeDevName",component.get("v.selectedRecType"));
        component.set("v.isRecordTypeSelection",false);
    },
    
    chandleSuccess : function(component, event, helper){
        component.set("v.mode",'readonly');
    },
    
    handleRecTypeChangeCancel  : function(component, event, helper){
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "/rma-list",
            "isredirect": true
        });
        navEvt.fire();
    },
    
    handleEdit : function(component, event, helper){
        component.set("v.mode",'edit');
    },
    
    chandleRecSave : function(component, event, helper) {
        var action = component.get("c.saveRecord");
        action.setParams({"rec": component.get("v.rmaObj")});
        action.setCallback(this,function(response){
            var state = response.getState();
            
            var toastEvent = $A.get("e.force:showToast");
            
            if(state == 'SUCCESS') {
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": " Request is created successfully." 
                })
                
                /*
                console.log(response.getReturnValue());
                component.set("v.recordId",response.getReturnValue().obj.Id);
                component.set("v.mode","view");*/
            
            var navEvt = $A.get("e.force:navigateToURL");
            navEvt.setParams({
                "url": "/rma-view?recordId="+response.getReturnValue().obj.Id,
                "isredirect": true
            });
            navEvt.fire();
            
        } else if(state == 'INCOMPLETE') {
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": " Something has gone wrong. State=INCOMPLETE"
            });
        } else if(state == 'ERROR') {
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": " Something has gone wrong."
            });
        }
        toastEvent.fire();
        console.log(response.getReturnValue());
    })
    $A.enqueueAction(action);
 },
    
    handleTest : function(component, event, helper) { alert(1);
                                                     component.set("v.mode","view");
                                                    },
    handleTest1 : function(component, event, helper) { alert(3);
                                                      component.set("v.mode","edit");
                                                     }
})