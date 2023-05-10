({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
   	CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    getMDFRequestHelper : function(cmp,next,prev,offset,con) {
        offset = offset || 0;
        con = con || '';
        var action = cmp.get("c.getMDFRequestController");
        action.setParams({
            "next" : next,
            "prev" : prev,
            "off" : offset ,
            "whereCondtion" : con
        });
        action.setCallback(this,function(res){
            var state = res.getState();   
            //alert(state);         
            if(state=="SUCCESS"){
              	var result = res.getReturnValue();
              	cmp.set('v.offset',result.offst);
                console.log(result.lstMDFDetails)
              	cmp.set('v.mdfDetailRecords',result.lstMDFDetails);	
              	cmp.set('v.next',result.hasnext);
              	cmp.set('v.prev',result.hasprev);
              	cmp.set('v.conditon',result.condition);
               
              	//var listView = cmp.find("ListView");
                //$A.util.removeClass(listView, "slds-hide");
                //$A.util.addClass(listView, "slds-show");  
                cmp.set('v.isListView',true);
                cmp.set('v.isDetailView',false);
                
                //var outputArea = cmp.find("OutputArea");
                //$A.util.removeClass(outputArea, "slds-show");  
                //$A.util.addClass(outputArea, "slds-hide");
                
                
            }
        });        
        $A.enqueueAction(action);
    },
    getDeleteMDFRequest : function(cmp, next, prev, idd){
        var action = cmp.get("c.deleteMDFRequest");
        action.setParams({
            "next" : next,
            "prev" : prev,
            "off" : 0, 
            "mdfId" : idd
        });
        action.setCallback(this,function(res){
            var state = res.getState();   
            //alert(state);         
            if(state=="SUCCESS"){
              	var result = res.getReturnValue();
              	cmp.set('v.offset',result.offst);
                console.log(result.lstMDFDetails)
              	cmp.set('v.mdfDetailRecords',result.lstMDFDetails);
              	cmp.set('v.next',result.hasnext);
              	cmp.set('v.prev',result.hasprev);
              	cmp.set('v.conditon',result.condition);
              	cmp.set("v.isOpen", false);        
                /*var listView = cmp.find("ListView");
                $A.util.removeClass(listView, "slds-hide");
                $A.util.addClass(listView, "slds-show");  
                
                var outputArea = cmp.find("OutputArea");
                $A.util.removeClass(outputArea, "slds-show");  
                $A.util.addClass(outputArea, "slds-hide");*/
                
                cmp.set('v.isListView',true);
                cmp.set('v.isDetailView',false);
            }
        });        
        $A.enqueueAction(action);
    },
    
    changeView : function(cmp, next, prev, selectedValue){
        var action = cmp.get("c.changeViewSelection");
        action.setParams({
            "next" : next,
            "prev" : prev,
            "off" : 0, 
            "val" : selectedValue
        });
        action.setCallback(this,function(res){
            var state = res.getState();   
            //alert(state);         
            if(state=="SUCCESS"){
              var result = res.getReturnValue();
              cmp.set('v.offset',result.offst);
                console.log(result.lstMDFDetails)
              cmp.set('v.mdfDetailRecords',result.lstMDFDetails);
              cmp.set('v.next',result.hasnext);
              cmp.set('v.prev',result.hasprev);
              cmp.set('v.conditon',result.condition);
              
            }
        });        
        $A.enqueueAction(action);
    },
    
    getMDFDetails : function(cmp, event, helper,exbRdId){
        var action = cmp.get("c.getMDFDetailInformation");
        action.setParams({ recId : exbRdId });
		cmp.set("v.mdfRequest", null);
        cmp.set("v.mdfClaim", null);
        cmp.set("v.expenseList", null);
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                cmp.set("v.mdfRequest", response.getReturnValue().objMDFRequest);
                cmp.set("v.mdfClaim", response.getReturnValue().objMDFClaim);
                cmp.set("v.expenseList", response.getReturnValue().lstMDFExpense);
                cmp.set("v.files", response.getReturnValue().lstSupportingAttachment);
                
                cmp.set("v.perApprovedDocs", response.getReturnValue().lstPreApprovalDoc);
                cmp.set("v.proofOfPerformanceDocs", response.getReturnValue().lstProofOfPerformanceDoc);
                
                var noOfPreApprovalDocs = 0;
                var noOfClaimDocs = 0;
                var allFileRows = response.getReturnValue().lstSupportingAttachment;
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
                cmp.set("v.numOfPreApprovalDoc", noOfPreApprovalDocs);
                cmp.set("v.numOfPOPDoc", noOfClaimDocs);
                
                if(cmp.get("v.mdfRequest.Status__c") == 'Request Created' && allFileRows.length == 0)
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Information",  
                        "type": "info",
                        "interval": 15000,
                        "message": "You are almost done! Now attach your Pre-approval Documentation and click \"Submit MDF Request\" to complete the process."
                    });
                 	toastEvent.fire();
                }
                else if(cmp.get("v.mdfClaim") != null && cmp.get("v.mdfClaim.Status__c") == 'Created' && noOfClaimDocs == 0)
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Information",  
                        "type": "info",
                        "interval": 15000,
                        "message": "You are almost done! Now attach your Claim Documentation and click \"Submit Claim\" to complete the process."
                    });
                 	toastEvent.fire();
                }
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
    
    submitMDFClaim : function(cmp, event, helper){
    	var action = cmp.get("c.submitMdfClaimForApproval");
        action.setParams({ "mdfClaim" : cmp.get("v.mdfClaim"),
                           "comment" : cmp.get("v.mdfClaimApprovalComment") });
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.isMDFClaimApproval", false);
            if (state === "SUCCESS") {
                cmp.set("v.mdfClaim", response.getReturnValue().objMDFClaim);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",  
                        "type": "success",
                        "message": response.getReturnValue().approvalMessage
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
            self.uploadProcess(component, file, fileContents, parentType);
        });
 
        objFileReader.readAsDataURL(file);
    },
 	
    /* file upload code */
    uploadProcess: function(component, file, fileContents, parentType) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
 
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '', parentType);
    },
 
 
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId, parentTypeName) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        if(parentTypeName == 'Fund Request')
        {
            //alert('-------parentTypeName------'+parentTypeName);
            action.setParams({
                preApprovalType: component.find("SelectPreApprovalType").get("v.value"),
                description: component.get("v.strDescription"),
                parentId: component.get("v.mdfRequest.Id"),
                fileName: file.name,
                base64Data: encodeURIComponent(getchunk),
                contentType: file.type,
                fileId: attachId,
                parentType: 'Fund Request'
            });
        }
        else if(parentTypeName == 'Fund Claim')
        {
             action.setParams({
                preApprovalType: component.find("SelectProofOfPerformanceType").get("v.value"),
                description: component.get("v.strDescription"),
                parentId: component.get("v.mdfClaim.Id"),
                fileName: file.name,
                base64Data: encodeURIComponent(getchunk),
                contentType: file.type,
                fileId: attachId,
                parentType: 'Fund Claim'
            });
        }
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
                    component.set("v.isPreApprovalModal", false);
                    component.set("v.isProofOfPerformanceModal", false);
                    this.fetchRefreshedFiles(component, 'upload');
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
    helperFun : function(component,event,secId, secId2) {
	  	var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide'); 
        	$A.util.toggleClass(acc[cmp], 'slds-show'); 
       	}
        var acc2 = component.find(secId2);
        for(var cmp2 in acc2) {
            $A.util.toggleClass(acc2[cmp2], 'slds-hide'); 
        	$A.util.toggleClass(acc2[cmp2], 'slds-show'); 
       	}
	},
    
    getFilesForClaimDoc: function(cmp, event, helper)
    {
    	var action = cmp.get("c.preAppFileList");
        action.setParams({ "requestId" : cmp.get("v.mdfRequest.Id")});

        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.filesForClaimDocs", response.getReturnValue());
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
    
    saveClaimFromPreApproval : function(cmp, event, helper)
    {
        var action = cmp.get("c.updatePreAppFileList");
        action.setParams({ "lstFile" : cmp.get("v.filesForClaimDocs"),
                           "claimId" : cmp.get("v.mdfClaim.Id")});
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                cmp.set("v.showLoadingSpinner", false);
                cmp.set("v.isPreApprovalModal", false);
                cmp.set("v.isProofOfPerformanceModal", false);
                this.fetchRefreshedFiles(cmp, 'upload');
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
    
    fetchRefreshedFiles : function(cmp, source)
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
    },
    
    callFileDelete : function(component, event, idd )
    {
    	var action = component.get("c.deletePreApprovalDoc");
        action.setParams({ "fileRecordId" : idd,
                           "mdfStatus" : component.get("v.mdfClaim.Status__c")});
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                
               if(response.getReturnValue() == 'Success')
               		this.fetchRefreshedFiles(component, 'delete');
               else
               {
                   var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({  
                       "type": "info",
                       "message": response.getReturnValue()
                   });
                   toastEvent.fire();
               }
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
    
  	editFileUploadHelper: function(component, event, parentType, fileRecord, docPicklistValue) 
    {
        component.set("v.showLoadingSpinner", true);
        var fileInput = component.find("fileId").get("v.files");
        var file = fileInput[0];
        var self = this;
           
        if (file.size > self.MAX_FILE_SIZE) 
        {
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
            self.editUploadProcess(component, file, fileContents, parentType, fileRecord, docPicklistValue);
        });
 
        objFileReader.readAsDataURL(file);
    },
 	
    /* file upload code */
    editUploadProcess: function(component, file, fileContents, parentType, fileRecord, docPicklistValue) 
    {
        var startPosition = 0;
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        this.editUploadInChunk(component, file, fileContents, startPosition, endPosition, '', parentType, docPicklistValue, fileRecord);
    },
    
    editUploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId, parentTypeName, docPicklistValue, fileRecord) 
    {
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveEditChunk");
        
        action.setParams({
            objFile : fileRecord,
            attachmentId : attachId,
            fileName : file.name,
            base64Data : encodeURIComponent(getchunk),
            contentType : file.type,
            parentType : parentTypeName,
            fileDocValue : docPicklistValue           
        });
       
        // set call back 
        action.setCallback(this, function(response) 
        {
            attachId = response.getReturnValue();
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") 
            {
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                
                /* check if the start postion is still less then end postion then call again 'editUploadInChunk' method, 
                else, diaply alert msg and hide the loading spinner*/
                if (startPosition < endPosition) 
                {
                    this.editUploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, parentTypeName, docPicklistValue, fileRecord);
                } 
                else 
                {
                    component.set("v.isEditSupportingDoc", false);
                    component.set("v.showLoadingSpinner", false);
                    this.fetchRefreshedFiles(component, 'edit');
                }        
            }
        });
        $A.enqueueAction(action);
    },
    
    saveActivityResultHelper : function(component, event)
    {
    	var action = component.get("c.saveActivityResult");
        
        action.setParams({
            objMDFRequest : component.get("v.mdfRequest")
        });
       
        // set call back 
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            alert(state);
            if (state === "SUCCESS") 
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                        "title": "Success!",  
                        "type": "success",
                        "message": "Saved Record"
                    });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	}
})