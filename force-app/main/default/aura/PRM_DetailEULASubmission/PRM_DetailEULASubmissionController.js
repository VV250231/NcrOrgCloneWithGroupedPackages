({
    
    getEULA : function(component, event, helper) {
        var action = component.get("c.getEULASubmissionDetail");
        var idParam = helper.getJsonFromUrl().esid;
        action.setParams({ "recId" : idParam});
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.objEULA", response.getReturnValue());
                component.set("v.recordId", response.getReturnValue().Id);
            }
            else if (state === "INCOMPLETE") {
                // do something
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
    
    back : function(component, event, helper) {
        
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "/eula-submission-list-view"
        }).fire();
    },
    
    openEdit : function(component, event, helper) {
        var action = component.get("c.getEULASubmissionDetail");
        var idParam = helper.getJsonFromUrl().esid;
        
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "/edit-eula-submission?esid=" + idParam
        }).fire();
    },
    
    cOpenAttachment : function(component, event, helper) {
        component.set("v.isAttachment", true);
    },
    cOpenApproval: function(component, event, helper) {
        component.set("v.isApproval", true);
    },
    closeDocModal : function(component, event, helper) {
        component.set("v.isAttachment", false);
        component.set("v.isApproval", false);
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    saveFileController: function(component, event, helper) {
        var submitREcord = true ; 
        //alert(component.find("fileId").get("v.files"));
        if(component.find("fileId").get("v.files") == null)
        {
            component.set("v.fileName", "Please Select a File: ");
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error:",  
                "type": "error",
                "message": "Please Select a File."
            });
            toastEvent.fire();
        }
        else
        { 
            helper.uploadHelper(component, event);
        }
    },
    
    cSubmitForApproval : function(component, event, helper) {
        var action = component.get("c.submitApprovalRequest");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "comment": component.get("v.comment")
        });
        
        action.setCallback(this, function(a) {
            var toastEvent = $A.get("e.force:showToast");
            component.set("v.isApproval", false);
           
            toastEvent.setParams({
                "type" : a.getReturnValue().status,
                "message": a.getReturnValue().message
            });
            
            toastEvent.fire();
            $A.get('e.force:refreshView').fire();
            
            /*var idParam = helper.getJsonFromUrl().coid;
        
            $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/co-branded-collateral-record?coid=" + idParam
                }).fire();*/
        });
        
        $A.enqueueAction(action);
    },
})