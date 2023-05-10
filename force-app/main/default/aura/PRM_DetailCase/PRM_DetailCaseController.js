({
    
    getCase : function(component, event, helper) {
        var action = component.get("c.getCaseDetail");
        var idParam = helper.getJsonFromUrl().cid;
        action.setParams({ "recId" : idParam});
        component.set("v.Spinner",true);
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.objCase", response.getReturnValue());
                component.set("v.recordId", response.getReturnValue().Id);
                component.set("v.Spinner",false);
            }
            else if (state === "INCOMPLETE") {
                // do something
                component.set("v.Spinner",false);
            }
           else if (state === "ERROR") {
               component.set("v.Spinner",false);
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
            "url": "/get-help-listview"
        }).fire(); 
    },
    
   
    
    cOpenAttachment : function(component, event, helper) {
        component.set("v.isAttachment", true);
    },
    
    
    
     cOpenCaseComment : function(component, event, helper) {
        component.set("v.isCaseComment", true);
    },
    closeDocModal : function(component, event, helper) {
        component.set("v.isAttachment", false);
        component.set("v.isCaseComment", false);
        
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
    
    saveCaseComment: function(component, event, helper) {
    	var action = component.get("c.createComment");
        var idParam = helper.getJsonFromUrl().cid;
        action.setParams({ "caseId" : idParam, "body" : component.get("v.caseComment")});
        component.set("v.Spinner",true);
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Spinner",false);
                component.set("v.isCaseComment",false);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success:",  
                        "type": "success",
                        "message": "Comment added successfully."
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
                component.set("v.Spinner",false);
            }
           else if (state === "ERROR") {
               component.set("v.Spinner",false);
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
    }
    
})