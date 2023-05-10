({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
   	CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
	getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    },
    
   
    submitMDFRequest : function(cmp, event, helper){
    	var action = cmp.get("c.submitMdfRequestForApproval");
        action.setParams({ "objRequest" : cmp.get("v.mdfRequest"),
                          "comment" : cmp.get("v.mdfReqeustApprovalComment") });
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.isMDFRequestApproval", false);
            if (state === "SUCCESS") {
                cmp.set("v.mdfRequest", response.getReturnValue().objMDFRequest);
                var toastEvent = $A.get("e.force:showToast");
                   // alert('test');
                if(response.getReturnValue().approvalMessage=='Your Request has been submitted')
                {
                    toastEvent.setParams({
                        "title": "Success!",  
                        "type": "success",
                        "message": response.getReturnValue().approvalMessage
                    });
                }else
                {
                  toastEvent.setParams({
                        "title": "Error!",  
                        "type": "error",
                        "message": response.getReturnValue().approvalMessage
                    });  
                }
                 toastEvent.fire();
                    
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
    
     uploadHelper: function(component, event) {
        // start/show the loading spinner   
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
        var action = component.get("c.saveChunk");
        action.setParams({
            attachmentType: component.get("v.selectedType"),
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
                    //alert('your File is uploaded successfully : ' + attachId);
                    component.set("v.isAttachment", false);
                   	component.set("v.showLoadingSpinner", false);
                    //this.fetchRefreshedFiles(component, 'upload');
                    
                     $A.get('e.force:refreshView').fire();
                }
                      
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
   
    
   
    /*fetchRefreshedFiles : function(cmp, source)
    {
        var action = cmp.get("c.getRefreshedFiles");
        action.setParams({ "requestId" : cmp.get("v.mdfRequest.Id"),
                           "claimId" : cmp.get("v.mdfClaim.Id")});
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('fetchRefreshedFiles---'+state);
            if (state === "SUCCESS") {
                var noOfPreApprovalDocs = 0;
                var noOfClaimDocs = 0;
              	cmp.set("v.files", response.getReturnValue());
                var allFileRows = response.getReturnValue();
        		for (var indexVar = 0; indexVar < allFileRows.length; indexVar++) 
                {  
                    if(allFileRows[indexVar].Pre_Approval__c)
                    {
                        noOfPreApprovalDocs = noOfPreApprovalDocs + 1;
                    }
                    if(allFileRows[indexVar].Claim__c)
                    {
                        noOfClaimDocs = noOfClaimDocs + 1; 
                    }
                }
                if(source === 'delete')
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({  
                        "type": "success",
                        "message": "File has been deleted successfully."
                    });
                    toastEvent.fire();
                }
                else if(source === 'upload')
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({  
                        "type": "success",
                        "message": "File has been uploaded successfully."
                    });
                    toastEvent.fire();
                }
                else if(source === 'edit')
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({  
                        "type": "success",
                        "message": "File has been modified successfully."
                    });
                    toastEvent.fire();
                }
                
                cmp.set("v.numOfPreApprovalDoc", noOfPreApprovalDocs);
                cmp.set("v.numOfPOPDoc", noOfClaimDocs);
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
    },*/
})