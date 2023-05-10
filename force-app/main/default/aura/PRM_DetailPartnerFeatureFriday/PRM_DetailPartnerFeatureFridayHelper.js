({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
   	CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    uploadHelper: function(component, event, parentType) {
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
            parentId: component.get("v.partnerSpotlightId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
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
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, parentTypeName);
                } 
                else 
                {
                    //alert('your File is uploaded successfully : ' + attachId);
                    component.set("v.showLoadingSpinner", false);
                    component.set("v.isAttachment", false);
                    this.fetchAllAttachment(component);
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
    
    fetchAllAttachment : function(component)
    {
        var action = component.get("c.getAllAttachment");
        action.setParams({ "parentRecId" : component.get("v.partnerSpotlightId")});
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('fetchRefreshedFiles---'+state);
            if (state === "SUCCESS") {
               
              	component.set("v.lstAttach", response.getReturnValue().lstPSAttachment);
               
                component.set("v.attachmentCount", response.getReturnValue().attachmentCount);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({  
                    "type": "success",
                    "message": "File has been uploaded successfully."
                });
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
    
    getFeatureFridayHelper : function(component, event, helper){
        
        var action = component.get("c.getPartnerFeatureFriday");
        //alert(component.get("v.partnerSpotlightId"));
        action.setParams({ "recId" : component.get("v.partnerSpotlightId")});
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ObjPartnerSpotlight", response.getReturnValue().objPS);
                component.set("v.lstAttach", component.get("v.ObjPartnerSpotlight.Attachments"));
                component.set("v.attachmentCount", response.getReturnValue().attachmentCount);
                component.set("v.licenseName", response.getReturnValue().userLicenseName);
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
    }
})