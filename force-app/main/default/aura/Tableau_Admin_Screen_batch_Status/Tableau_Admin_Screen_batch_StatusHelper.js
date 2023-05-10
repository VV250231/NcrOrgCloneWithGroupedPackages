({
    helperMethod : function() {
        
    },
    checknewroles: function(component,event,helper){
        var action = component.get("c.roleidset_updateroleidset");
        component.set("v.spin",true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.spin",false);
                component.set("v.resultforcontroller", a.getReturnValue());
                component.set("v.progressbarvalue1",component.get("v.resultforcontroller[0].allvalue1"));
                component.set("v.progressbarvalue2",component.get("v.resultforcontroller[0].allvalue2"));
                if(component.get("v.progressbarvalue1")>0){
                    component.set("v.progressbarstatus1",'New Sub-Role Exist !');
                    component.set("v.progressinfo1",component.get("v.progressbarvalue1")+' - new Sub-Role');
                }
                else if(component.get("v.progressbarvalue1")==0){
                    component.set("v.progressbarstatus1",'No new Sub-Role !');
                    component.set("v.progressinfo1",'');
                }
                if(component.get("v.progressbarvalue2")>0){
                    component.set("v.progressbarstatus2",'New Role Exist !');
                    component.set("v.progressinfo2",component.get("v.progressbarvalue2")+' - new Role');
                }
                else if(component.get("v.progressbarvalue2")==0){
                    component.set("v.progressbarstatus2",'No new Role !');
                    component.set("v.progressinfo2",'');
                }
                component.set("v.currentStep",'2');
            } else if (a.getState() === "ERROR") { 
                component.set("v.spin",false);
                alert('error');
                //component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
        });
        $A.enqueueAction(action);
    },
    updatenewsubroles: function(component,event,helper){
        var action = component.get("c.update_sub_role_id");
        component.set("v.spin",true);
        action.setParams({
            "subroleid":component.get("v.resultforcontroller[0].currentuserlist1")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.spin",false);
                component.set("v.resultforcontroller", a.getReturnValue());
                component.set("v.progressbarvalue1",component.get("v.resultforcontroller[0].allvalue1"));
                alert(component.get("v.resultforcontroller[0].allvalue1"));
                if(component.get("v.resultforcontroller[0].allvalue1") == 0){
                    alert(component.get("v.resultforcontroller[0].errors"));
                    
                }
                component.set("v.currentStep",'3');
            } else if (a.getState() === "ERROR") { 
                component.set("v.spin",false);
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
        });
        $A.enqueueAction(action);
    },
    updatenewroles: function(component,event,helper){
        var action = component.get("c.update_role_id");
        component.set("v.spin",true);
        action.setParams({
            "subroleid":component.get("v.resultforcontroller[0].currentuserlist2")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.spin",false);
                component.set("v.resultforcontroller", a.getReturnValue());
                component.set("v.progressbarvalue1",component.get("v.resultforcontroller[0].allvalue1"));
                alert(component.get("v.resultforcontroller[0].allvalue1"));
                if(component.get("v.resultforcontroller[0].allvalue1") == 0){
                    alert(component.get("v.resultforcontroller[0].errors"));
                    
                }
                component.set("v.currentStep",'3');
            } else if (a.getState() === "ERROR") { 
                component.set("v.spin",false);
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
        });
        $A.enqueueAction(action);
    },
    getsize: function(component,event,helper){
        var action = component.get("c.returnsize");
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.resultforcontroller", a.getReturnValue());
                component.set("v.sizeofrolelids1",component.get("v.resultforcontroller[0].allvalue1"));  
                component.set("v.sizeofrolelids2",component.get("v.resultforcontroller[0].allvalue2"));  
                if(component.get("v.sizeofrolelids1")>component.get("v.heapsize1") + 100){
                    component.set("v.heapsize1",component.get("v.heapsize1") + 100);
                }
                if(component.get("v.sizeofrolelids1")<=component.get("v.heapsize1") + 100){
                    component.set("v.heapsize1",component.get("v.sizeofrolelids1"));
                }
                component.set("v.progressbarstatus1", 'Total to update : ' + component.get("v.sizeofrolelids1"));
                if(component.get("v.sizeofrolelids2")>component.get("v.heapsize") + 100){
                    component.set("v.heapsize2",component.get("v.heapsize2") + 100);
                }
                if(component.get("v.sizeofrolelids2")<=component.get("v.heapsize") + 100){
                    component.set("v.heapsize2",component.get("v.sizeofrolelids2"));
                }
                component.set("v.progressbarstatus2", 'Total to update : ' + component.get("v.sizeofrolelids2"));
                component.set("v.currentStep",'3');
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError()); 
            }
        });
        $A.enqueueAction(action);
    },
    showsuccesstoast : function(component,event,helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'pester',
            title: "Success !",
            duration:'5',
            type:"success",
            message: 'Update successfully !',
            
        });
        toastEvent.fire();
    },
})