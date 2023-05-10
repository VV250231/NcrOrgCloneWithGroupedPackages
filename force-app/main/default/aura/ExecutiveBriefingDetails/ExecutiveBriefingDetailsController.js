({
    doInit:function(component, event, helper){
        helper.getExbFieldLabel(component, event, helper);
        helper.getLoggedInUserProfile(component, event, helper);
        
        component.set("v.spinnerEnabler", true);
        var action = component.get("c.getReqFields");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.spinnerEnabler",false);
                component.set("v.execBrief", response.getReturnValue());
                component.set("v.NmberOfRelatedRecords", response.getReturnValue().length);
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    proceed:function(component, event, helper) {
        var ExecBriefRec = $A.get("e.force:createRecord");
        ExecBriefRec.setParams({
            "entityApiName": "Executive_Briefing__c",
            "defaultFieldValues": {
            "Name__c": component.get("v.recordId")
            }
        });
        ExecBriefRec.fire();
    },
    goToExecBriefingListView: function(component, event, helper){
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                if(listviews.length>1){
                     var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews[0].Id,
                    "listViewName": null,
                    "scope": "Executive_Briefing__c"
                });
                navEvent.fire();
                }else if(listviews.length<=1){
                    console.log('2nd one');
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Executive_Briefing__c"
                });
                navEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    redirectToExbRecord:function(component, event, helper){
        var exbRdId = event.currentTarget.dataset.record;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": exbRdId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    editTheRecord:function(component, event, helper){
        var idOfRecordToEdit = event.getSource().get("v.value");
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": idOfRecordToEdit
        });
        editRecordEvent.fire();
    }
    
})