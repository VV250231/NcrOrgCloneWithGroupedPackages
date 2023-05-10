({
    myAction : function(component, event, helper) {
        
    },
    executestep: function(component,event,helper){
        var currentstep = component.get("v.currentStep");
        
        if(currentstep == '1'){
            helper.checknewroles(component, event, helper);
        }
        else if(currentstep == 2){
            if(component.get("v.progressbarvalue1")>0){
                helper.updatenewsubroles(component, event, helper);
                helper.getsize(component, event, helper);
            }
            if(component.get("v.progressbarvalue2")>0){
                helper.updatenewroles(component, event, helper);
                helper.getsize(component, event, helper);
            }
            else{
                helper.getsize(component, event, helper);
            }
        }
            else if(currentstep== 3){
                component.set("v.currentStep",'4');
                 component.set("v.togglefinalbutton",false);
            }
                else if(currentstep == 4){
                    component.set("v.currentStep",'5');
                    component.set("v.togglefinalbutton",true);
                }
                    else if(currentstep == 5){
                        component.set("v.togglefinalbutton",true);
                    }
    },
    
    updatesuballroles: function(component,event,helper){
        var action = component.get("c.updateallsubrole");
        action.setParams({
            "subroleid":component.get("v.resultforcontroller[0].receivedlist1")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.resultforcontroller", a.getReturnValue());
                // alert(component.get("v.resultforcontroller[0].allvalue1"));
                if(component.get("v.resultforcontroller[0].allvalue1") == '1'){
                    helper.showsuccesstoast(component, event, helper);
                    component.set("v.sizeofrolelids1",component.get("v.resultforcontroller[0].allvalue2"));  
                    if(component.get("v.sizeofrolelids1")>component.get("v.heapsize1") + 100){
                        component.set("v.heapsize1",component.get("v.heapsize1") + 100);
                    }
                    if(component.get("v.sizeofrolelids1")<=component.get("v.heapsize1") + 100){
                        component.set("v.heapsize1",component.get("v.sizeofrolelids1"));
                        component.set("v.togglesubbutton",true);
                        component.set("v.togglefinalbutton",false);
                        
                    }
                    component.set("v.progressbarstatus1",component.get("v.heapsize1") + ' update out of ' + component.get("v.sizeofrolelids1"));
                }
                if(component.get("v.resultforcontroller[0].allvalue1") =='0'){
                    alert('error received :: '+ component.get("v.resultforcontroller[0].errors"));
                }
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError()); 
            }
        });
        $A.enqueueAction(action);
    },
    
    updateallroles: function(component,event,helper){
        var action = component.get("c.updateallrole");
        action.setParams({
            "subroleid":component.get("v.resultforcontroller[0].receivedlist2")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.resultforcontroller", a.getReturnValue());
                if(component.get("v.resultforcontroller[0].allvalue1") == '1'){
                    helper.showsuccesstoast(component, event, helper);
                    component.set("v.sizeofrolelids2",component.get("v.resultforcontroller[0].allvalue2"));  
                  
                    if(component.get("v.sizeofrolelids2")>component.get("v.heapsize2") + 100){
                        component.set("v.heapsize2",component.get("v.heapsize2") + 100);
                        
                    }
                      if(component.get("v.sizeofrolelids2")<=component.get("v.heapsize2") + 100){
                        component.set("v.heapsize2",component.get("v.sizeofrolelids2"));
                        component.set("v.toggleallbutton",true);
                         component.set("v.togglefinalbutton",true);
                    }
                    
                    component.set("v.progressbarstatus2",component.get("v.heapsize2") + ' update out of ' + component.get("v.sizeofrolelids2"));
                }
                if(component.get("v.resultforcontroller[0].allvalue1") =='0'){
                    alert('error received :: '+ component.get("v.resultforcontroller[0].errors"));
                }
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError()); 
            }
        });
        $A.enqueueAction(action);
    },
    
    showerrortoast: function(component,event,helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            title: "Error !",
            type:"error",
            message: component.get("v.toastmessage"),
        });
        toastEvent.fire();
    },
    showsuccesstoast : function(component,event,helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            title: "Success !",
            type:"success",
            message: component.get("v.toastmessage"),
        });
        toastEvent.fire();
    },
    
})