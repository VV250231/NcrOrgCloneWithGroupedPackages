({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRMAReq");
        action.setParams({'recId':component.get("v.recordId")});
        action.setCallback(this,function(response){
            component.set("v.rmaObj",response.getReturnValue());
        })
        $A.enqueueAction(action);
        
        helper.fetchFiles(component);
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
    
    chandleEdit : function (component, event, helper) {
        component.set("v.mode","edit");
    },
    cHandlecancelEdit : function (component, event, helper) {
        component.set("v.mode","view");
    },
    
    cHandleSaveEdit : function (component, event, helper) {
        component.set("v.mode","view");
        component.set("v.rmaObj", null);
        var action = component.get("c.getRMAReq");
        action.setParams({'recId':component.get("v.recordId")});
        action.setCallback(this,function(response){ 
            component.set("v.rmaObj",response.getReturnValue());
        })
        $A.enqueueAction(action); 
        
        //$A.get('e.force:refreshView').fire();
        window.location.reload();

    },
    
    openFile : function(component, event, helper) 
    {
        var idx = event.currentTarget;
        var idd = idx.dataset.ids; 
        var url1;
        url1="/PartnerCentral/sfc/servlet.shepherd/document/download/"+idd;
        window.open(url1,'_blank'); 
    },
})