({
     MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
	getApprovalHistory : function(component) {
        // Get a reference to the getApprovalHistory() function defined in the Apex controller
        var action = component.get("c.getApprovalHistory"); //component.get("v.recordId")
        action.setParams({
            "recId":component.get("v.recordId")
        });
        action.setCallback(this, function(a) {

            component.set("v.approvalHistory",a.getReturnValue().lstHD);
            component.set("v.rejectionReasons",a.getReturnValue().lstRejection);
            component.set("v.objDP",a.getReturnValue().objDP);
            component.set("v.approveLink",a.getReturnValue().isApprover);
            component.set("v.showLink",a.getReturnValue().showLink);
            component.set("v.processInstanceWorkitemId",a.getReturnValue().ProcessInstanceWorkitemId);
            
             //alert(component.get("v.showLink"));
        });
        $A.enqueueAction(action);
    },
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
         
       // alert(component.get("v.fileName"));
        
        if(component.get("v.fileName") != 'No File Selected..'){
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
       
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
 
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
 
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
 
        objFileReader.readAsDataURL(file);
        }        
        else
        {
            component.set("v.showLoadingSpinner", false);
            this.approveRecordWithUpdateHelper(component);
        }
    },
    
     /* file upload code */
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
 
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
 
 
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        //alert(encodeURIComponent(getchunk));
        var action = component.get("c.saveChunk");
        //encodeURIComponent(getchunk)
            action.setParams({
                parentId: component.get("v.recordId"),
                fileName: file.name,
                base64Data: encodeURIComponent(getchunk),
                contentType: file.type,
                fileId: attachId,
            });
       
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") 
            {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                
                /* check if the start postion is still less then end postion then call again 'uploadInChunk' method , 
                else, diaply alert msg and hide the loading spinner*/
                if (startPosition < endPosition) 
                {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } 
                else 
                {
                    component.set("v.showLoadingSpinner", false);
                    this.approveRecordWithUpdateHelper(component);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    approveRecordWithUpdateHelper : function(component)
    {
        var action = component.get("c.approveDemoProgram"); 
        action.setParams({
            "objDemoProgram" : component.get("v.objDP"),
            "comment" : component.get("v.strComment"),       
            "recId":component.get("v.recordId"),
            "workItemId":component.get("v.processInstanceWorkitemId"),
            "isUpdate" : true
        });
        action.setCallback(this, function(a) {

           var result = a.getReturnValue();
            
           if(result == 'Approved')
           {
               component.set("v.isApprovalWithoutUpdateRecord", false);
               component.set("v.isApprovalWithUpdateRecord", false);
               $A.get('e.force:refreshView').fire();
           }
                    
        });
        $A.enqueueAction(action);
    }
})