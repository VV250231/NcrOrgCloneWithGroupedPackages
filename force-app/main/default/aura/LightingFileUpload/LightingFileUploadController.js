({  
    doInit:function(component,event,helper){  
       helper.getuploadedFiles(component);
       //alert(component.get("v.recordId")); 
      
    },      
    
    previewFile :function(component,event,helper){  
        var rec_id = event.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });  
    },  
    
    UploadFinished : function(component, event, helper) {  
        var uploadedFiles = event.getParam("files");  
        //var documentId = uploadedFiles[0].documentId;  
        //var fileName = uploadedFiles[0].name; 
        helper.getuploadedFiles(component);         
        component.find('notifLib').showNotice({
            "variant": "info",
            "header": "Success",
            "message": "File Uploaded successfully!!",
            closeCallback: function() {}
        });
    }, 
    
    delFiles:function(component,event,helper){
        component.set("v.Spinner", true); 
        // alert(event.currentTarget.id);
        var documentId = event.currentTarget.id;        
        helper.delUploadedfiles(component,documentId);  
    },
    onButtonPressed: function(cmp, event, helper) {
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();
      // Fire that action
      var navigate = cmp.get('v.navigateFlow');
      navigate(actionClicked);
   }
 })