({
    get_progressdetails : function(component) {
        var action = component.get("c.get_tracker_details");
        action.setParams({ 
            "recordid":component.get("v.recordidd")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.tracker_details", a.getReturnValue()); 
                console.log('here are the values received from apex: '+JSON.stringify(component.get("v.tracker_details")));
                var t = component.get("v.tracker_details");
                console.log('value if disqualified or nurture : '+t[0].if_nurt_disq);
                
                if(!$A.util.isUndefinedOrNull(t) && !$A.util.isEmpty(t)) {
                	 component.set("v.isCATMRecord", t[0].isCATMRecord);     
                }
            } 
            else if (a.getState() === "ERROR") { 
                alert('error');
                $A.log("Errors", a.getError()); 
            }
            
        });
        $A.enqueueAction(action);
    },
    get_field_details : function(component,event,helper){
        var action = component.get("c.load_lead");
        action.setParams({
            "query" : event.currentTarget.value
        });
        action.setCallback(this,function(a){
            if(a.getState() == "SUCCESS"){
                component.set("v.dependentlist",a.getReturnValue());
                console.log('dependent pick list is : '+component.get("v.dependentlist"));
            }  
            else
                if(a.getState() == "ERROR"){
                    alert('error'); 
                }
        }) ;
        $A.enqueueAction(action);
    },
    get_depend_field_details : function(component,event,helper){
        var action = component.get("c.get_dependent_fieldvalue");
        action.setParams({
            "query" : event.currentTarget.value
        });
        action.setCallback(this,function(a){
            if(a.getState() == "SUCCESS"){
                component.set("v.depend_value",a.getReturnValue());
                console.log('list of values are : '+component.get("v.depend_value"));
            }  
            else
                if(a.getState() == "ERROR"){
                    alert('error'); 
                }
        }) ;
        $A.enqueueAction(action);
    },
    updateLeadRec : function(component,event,helper){
        //alert('');isCATMRecord
        var isCATMLead = component.get("v.isCATMRecord");
        var action = component.get("c.updateLead");
        var modaltype = component.get("v.modaldetials[0]");
        
        
        if(isCATMLead && !$A.util.isEmpty(modaltype) && modaltype == 'Disqualified') {
            action.setParams({
                "recordId" : component.get("v.recordId"),
                "lStatus" : component.get("v.modaldetials[0]"),
                "reason" : component.find("InputSelectSingle").get("v.value"),
                "dsqRsnCmmnts": component.find("dsqRsnCmmnts").get("v.value")
            });
        } else {
            action.setParams({
                "recordId" : component.get("v.recordId"),
                "lStatus" : component.get("v.modaldetials[0]"),
                "reason" : component.find("InputSelectSingle").get("v.value")
            });
        }
        
        action.setCallback(this,function(a){
            //  alert(a.getState());
            if(a.getState() == "SUCCESS"){
                component.set("v.show_modal",!component.get("v.show_modal"));
                $A.get('e.force:refreshView').fire();
            }  
            else
                if(a.getState() == "ERROR"){
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            // alert(errors[0].message);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": errors[0].message,
                                "type": "error"
                            });
                            toastEvent.fire();
                        }
                    }
                }
        }) ;
        $A.enqueueAction(action);
    },
    
})