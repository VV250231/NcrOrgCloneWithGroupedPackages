({
    doInit : function(component, event, helper) {
        var action = component.get("c.getDemoReq");
        action.setParams({'demoRecordId':component.get("v.recordId")});
        action.setCallback(this,function(response){
            component.set("v.demoReq",response.getReturnValue());
        })
        $A.enqueueAction(action);
        
        helper.fetchFiles(component);
        
        //disable up, down, right, left arrow keys
        window.addEventListener("keydown", function(e) {
            if([37, 38, 39, 40].indexOf(e.keyCode) > -1) {
                e.preventDefault();
            }
        }, false);
        
        //disable mousewheel
        window.addEventListener("mousewheel", function(e) {
            e.preventDefault();
        }, false);
        
        window.addEventListener("DOMMouseScroll", function(e) {
            e.preventDefault();
        }, false);
    },
    
    showApprovalModal : function(component, event, helper){
        component.set("v.approvalComment", null);
        component.set("v.isApproval", true);
    },
    
    closeDocModal: function(component, event, helper) {
        component.set("v.isApproval", false);
    },
    
    submitRecordForApproval : function(cmp, event, helper)
    {
        var action = cmp.get("c.submitRequest");
        action.setParams({ 
            "recId" : cmp.get("v.recordId"),
            "comment" : cmp.get("v.approvalComment") 
        });
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) { 
            cmp.set("v.isApproval", false);
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if (response.getReturnValue().isSuccess == false) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",  
                        "type": "error",
                        "duration":"7000",
                        "message": response.getReturnValue().message
                    });
                    toastEvent.fire();
                } else {                   
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "success!",  
                        "type": "success",
                        "message": response.getReturnValue().message
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
            }
            else if (state === "INCOMPLETE") {
                
            } else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error!",  
                    "type": "error",
                    "duration":"7000",
                    "message": response.getReturnValue().message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    showFileModal : function(component, event, helper){
        component.set("v.isFileUpload", true);
    },
    
    closeFileModal: function(component, event, helper) {
        component.set("v.isFileUpload", false);
    },
    
    handleUploadFinished: function (cmp, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "success!",  
            "type": "success",
            "message": "File has been uploaded successfully."
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
    },
    
    openFile : function(component, event, helper) 
    {
        var idx = event.currentTarget;
        var idd = idx.dataset.ids; 
        var url1;
        url1="/PartnerCentral/sfc/servlet.shepherd/document/download/"+idd;
        window.open(url1,'_blank'); 
    },
    
    openSingleFile: function(cmp, event, helper) {
        $A.get('e.lightning:openFiles').fire({
            recordIds: ['0696C0000009hoW']
        });
    },
    
    handleDelete: function(component, event, helper)  {
        var action = component.get("c.deleteDemoReq");
        action.setParams({'recId': component.get("v.recordId")});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue().isSuccess == false) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",  
                        "type": "error",
                        "duration":"7000",
                        "message": response.getReturnValue().message
                    });
                    toastEvent.fire();
                } else {                   
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "success!",  
                        "type": "success",
                        "message": "Request has been deleted successfully."
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToURL");
                    navEvt.setParams({
                        "url": "/demo-program-list",
                    });
                    navEvt.fire();
                    $A.get("e.force:refreshView").fire();
                }
            } else if (state === "INCOMPLETE") {
                
            } else if (state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error!",  
                    "type": "error",
                    "duration":"7000",
                    "message": response.getReturnValue().message
                });
                toastEvent.fire();
            }
        })
        $A.enqueueAction(action);
    },
    
    handleEdit: function(component, event, helper)  {
        component.set("v.isEdit","true");
        component.set("v.isView",false);
    },
    
    handleCancelEdit: function(component, event, helper)  {
        component.set("v.isEdit","false");
        component.set("v.isView",true);
    },
    
    handleSubmit : function(component, event, helper) {
        //event.preventDefault(); To prevent default behaviour of 
        //var demoReq = event.getParams().fields;
        //console.log(JSON.stringify(demoReq));
    },
    
    handleSuccess  : function(component, event, helper) {
        var demoReq = event.getParams().response;
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : "success",
            "message": "Request is updated successfully"
        });
        
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
    }
    
    
})