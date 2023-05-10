({
	getEngineer : function(component, event, helper) {
        var action = component.get("c.getEngineerDetail");
        //var idParam = helper.getJsonFromUrl().eid;
        var recId = component.get("v.recordId");
        //component.set("v.myRecordId",recId);
        
        action.setParams({ "recId" : recId});
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ObjEngineers", response.getReturnValue());
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
    
  
    cBackEngineerListview : function(component, event, helper) 
    {
      	$A.get("e.force:navigateToURL").setParams({ 
                   "url": "/engineer-listview"
                }).fire();
    },
    
    cPortalAccessApprovalRequest : function(component, event, helper) {
        var action = component.get("c.submitPortalRequest");
        //alert(component.get("v.recordId") +'----------'+component.get("v.requestComment"));
        action.setParams({
            "recordId": component.get("v.recordId"),
            "comment": component.get("v.requestComment"),
            "objEngineer" : component.get("v.ObjEngineers")
        });
        
        action.setCallback(this, function(a) {
            var toastEvent = $A.get("e.force:showToast");
            
            component.set("v.ObjEngineers", a.getReturnValue().objEng);
            if(a.getReturnValue().status === "success") {
                toastEvent.setParams({
                    "type" : "success",
                    "message": a.getReturnValue().message
                });
            }
            else if(a.getReturnValue().status === "error") {
                toastEvent.setParams({
                    "type" : "error",
                    "message": a.getReturnValue().message
                });
            }
            else if(a.getReturnValue().status === "info") {
                toastEvent.setParams({
                    "type" : "info",
                    "message": a.getReturnValue().message
                });
            }
            component.set("v.isPortalAccessApproval", false);
        	component.set("v.isDiagnosticsApproval", false);
            toastEvent.fire();
              $A.get('e.force:refreshView').fire();
        });
        
        $A.enqueueAction(action);
    },
    
    cDiagnosticsApprovalRequest: function(component, event, helper) {
        var action = component.get("c.submitDiagnosticsApprovalRequest");
        //alert(component.get("v.recordId") +'----------'+component.get("v.requestComment"));
        action.setParams({
            "recordId": component.get("v.recordId"),
            "comment": component.get("v.requestComment"),
            "objEngineer" : component.get("v.ObjEngineers")
        });
        
        action.setCallback(this, function(a) {
            var toastEvent = $A.get("e.force:showToast");
            component.set("v.ObjEngineers", a.getReturnValue().objEng);
            if(a.getReturnValue().status === "success") {
                toastEvent.setParams({
                    "type" : "success",
                    "message": a.getReturnValue().message
                });
            }
            else if(a.getReturnValue().status === "error") {
                toastEvent.setParams({
                    "type" : "error",
                    "message": a.getReturnValue().message
                });
            }
            else if(a.getReturnValue().status === "info") {
                toastEvent.setParams({
                    "type" : "info",
                    "message": a.getReturnValue().message
                });
            }
        	component.set("v.isPortalAccessApproval", false);
        	component.set("v.isDiagnosticsApproval", false);
            toastEvent.fire();
             $A.get('e.force:refreshView').fire();
        });
        
        $A.enqueueAction(action);
    },
    
    closeDocModal: function(component, event, helper) {
      	
      	component.set("v.isPortalAccessApproval", false);
        component.set("v.isDiagnosticsApproval", false);
        component.set("v.isAttachment", false);
    },
    
    showPortalAccessModal: function(component, event, helper) {
      	
      	component.set("v.isPortalAccessApproval", true);
    	component.set("v.requestComment", '');
        component.set("v.isDiagnosticsApproval", false);
    },
 	
  	showDiagnosticsModal: function(component, event, helper) {
      	
      	component.set("v.isPortalAccessApproval", false);
    	component.set("v.requestComment", '');
        component.set("v.isDiagnosticsApproval", true);
    },
    
    showAttachmentModal : function(component, event, helper) {
      	
      	component.set("v.isPortalAccessApproval", false);
    	component.set("v.requestComment", '');
        component.set("v.isDiagnosticsApproval", false);
        
        component.set("v.isAttachment", true);
        component.set("v.fileName", "No File Selected..");
        
    },
    
    openEdit: function(component, event, helper) 
    {
        //var idParam = helper.getJsonFromUrl().eid;
        var recId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/edit-engineer?recordId="+recId
                }).fire();
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    doSaveRequestAttachment: function(component, event, helper) 
    {
       
        var submitREcord = true ; 
        if(component.get("v.fileName") == 'No File Selected..')
        {
            
        
            var toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({
                    "type" : "info",
                    "message": "Please select a file."
                });
            toastEvent.fire();
           submitREcord = false ;
        }
        if(submitREcord) 
        {
            helper.uploadHelper(component, event);
        }
    },


})