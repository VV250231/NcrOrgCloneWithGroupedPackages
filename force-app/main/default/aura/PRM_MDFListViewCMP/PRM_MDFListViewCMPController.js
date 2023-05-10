({
    showListview : function(cmp, evt, helper) {
      	cmp.set("v.isOpen", false);
        
        var listView = cmp.find("ListView");
        //$A.util.removeClass(listView, "slds-hide");
		//$A.util.addClass(listView, "slds-show");  
        
    	var outputArea = cmp.find("OutputArea");
        //$A.util.removeClass(outputArea, "slds-show");  
        //$A.util.addClass(outputArea, "slds-hide");
        
        cmp.set('v.isListView',true);
        cmp.set('v.isDetailView',false);
    },
    cancelRequest: function(cmp, evt, helper) {
      	cmp.set("v.isOpen", false);
        var listView = cmp.find("ListView");
        //$A.util.removeClass(listView, "slds-hide");
		//$A.util.addClass(listView, "slds-show");  
		
        cmp.set('v.isListView',true); 
    },
    cloneCancelRequest : function(cmp, evt, helper) {
        cmp.set("v.isClone", false);
        cmp.set("v.isEdit", false);
        cmp.set("v.isClaim", false);
        var outputArea = cmp.find("OutputArea");
        //$A.util.removeClass(outputArea, "slds-hide");
		//$A.util.addClass(outputArea, "slds-show"); 
		cmp.set('v.isDetailView',true);
    },
    showNewRequest: function(cmp, evt, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
      	cmp.set("v.isOpen", true);
        var listView = cmp.find("ListView");
        //$A.util.removeClass(listView, "slds-show");
		//$A.util.addClass(listView, "slds-hide");
		cmp.set('v.isListView',false);
        cmp.set('v.isDetailView',false);
    },
    
    openCloneMDF : function(cmp, evt, helper) {
        cmp.set("v.isClone", true);
        var outputArea = cmp.find("OutputArea");
        //$A.util.removeClass(outputArea, "slds-show");  
        //$A.util.addClass(outputArea, "slds-hide");
        cmp.set('v.isListView',false);
        cmp.set('v.isDetailView',false);
    },
    showEditMDFRequest : function(cmp, evt, helper) {
        cmp.set("v.isEdit", true);
        var outputArea = cmp.find("OutputArea");
        //$A.util.removeClass(outputArea, "slds-show");  
        //$A.util.addClass(outputArea, "slds-hide");
        cmp.set('v.isListView',false);
        cmp.set('v.isDetailView',false);  
    },
    callCreateClaim  : function(cmp, evt, helper) {
        cmp.set("v.isClaim", true);
        var outputArea = cmp.find("OutputArea");
       //$A.util.removeClass(outputArea, "slds-show");  
        //$A.util.addClass(outputArea, "slds-hide");
        cmp.set('v.isListView',false);
        cmp.set('v.isDetailView',false);      
    },
    closeNewRequest : function(cmp, evt, helper) {
    	// for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      	cmp.set("v.isOpen", false);
	},
    getMDFRequest : function(cmp, evt, helper) {
    	var next = false;
        var prev = false;
        //component.set("v.Spinner", true); 
        helper.getMDFRequestHelper(cmp,next,prev);
    },
    Next:function(cmp,event,helper){
        var next = true;
        var prev = false;
        var offset = cmp.get("v.offset");
        var con = cmp.get("v.conditon")
        helper.getMDFRequestHelper(cmp,next,prev,offset, con); 
    },
    Previous:function(cmp,event,helper){
        var next = false;
        var prev = true;
        var offset = cmp.get("v.offset");
        var con = cmp.get("v.conditon")
        helper.getMDFRequestHelper(cmp,next,prev,offset,con); 
    },
    onSelectChange: function (cmp, event, helper) {
        //Do something with the change handler
        var next = false;
        var prev = false;
        var selectedValue = cmp.find("levels").get("v.value");
        helper.changeView(cmp, next, prev, selectedValue);
    },
    
    deleteMdf:function(cmp, event, helper){
        var idx = event.currentTarget;
        var idd = idx.dataset.ids; 
       	
        var next = false;
        var prev = false;
        helper.getDeleteMDFRequest(cmp, next, prev, idd);
    },
    deleteMDFDetail : function(cmp, event, helper){
        var next = false;
        var prev = false;
        //alert(cmp.get("v.recId"));
        helper.getDeleteMDFRequest(cmp, next, prev, cmp.get("v.recId"));
        
    },
    backOnListViewDetail : function(cmp, event, helper){
        var next = false;
        var prev = false;
        //cmp.find("levels").set('v.value','All');
        helper.getMDFRequestHelper(cmp, next, prev);
        
    },
    redirectToMdfRecord: function(cmp, event, helper){
   		var exbRdId = event.currentTarget.dataset.record;
   		cmp.set("v.recId", exbRdId);
        /*var listView = cmp.find("ListView");
        $A.util.removeClass(listView, "slds-show");
		$A.util.addClass(listView, "slds-hide");
        
        var outputArea = cmp.find("OutputArea");
        $A.util.addClass(outputArea, "slds-show");*/
        cmp.set('v.isListView',false);
        cmp.set('v.isDetailView',true);
        helper.getMDFDetails(cmp, event, helper,exbRdId);
        
    },
    
    detailMDFRequest : function(cmp, event, helper){
        cmp.set("v.isOpen", false);
        cmp.set("v.isClone", false);
        cmp.set("v.isEdit", false);
        cmp.set("v.isClaim", false);
   		var exbRdId = event.getParam("mdfRecordId");
        cmp.set("v.recId", exbRdId);
        cmp.set("v.strBack", event.getParam("backFrom"));
        //alert(cmp.get("v.strBack"));
        var listView = cmp.find("ListView");
        //$A.util.removeClass(listView, "slds-show");
		//$A.util.addClass(listView, "slds-hide");
        
        var outputArea = cmp.find("OutputArea");        
        //$A.util.addClass(outputArea, "slds-show");
        
        cmp.set('v.isListView',false);
        cmp.set('v.isDetailView',true);       
        helper.getMDFDetails(cmp, event, helper, exbRdId);
    },
    
    submitMDFRequestApproval : function(cmp, event, helper){
        //alert(cmp.get("v.numOfPreApprovalDoc"));
        if(cmp.get("v.numOfPreApprovalDoc") < 1)
        {
            var toastEvent = $A.get("e.force:showToast");
            cmp.set("v.isMDFRequestApproval", false);
            toastEvent.setParams({  
                        "type": "info",
                        "message": "Please attach Pre Approval Document with the Request."
                    });
            toastEvent.fire();
        }
		else            
        	helper.submitMDFRequest(cmp, event, helper);
    },
    
    submitMDFClaimApproval : function(cmp, event, helper){
        if(cmp.get("v.numOfPOPDoc") < 1)
        {
            cmp.set("v.isMDFClaimApproval", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({  
                        "type": "info",
                        "message": "Please attach Proof of Performance Document with Claim."
                    });
            toastEvent.fire();
        }
		else        
        	helper.submitMDFClaim(cmp, event, helper);
    },
    doSaveRequestAttachment: function(component, event, helper) {
        
        var submitREcord = true ; 
        
        if(component.find("fileId").get("v.files").length <= 0)
        {
            component.set("v.fileName", "Please Select a Valid File: ");
            submitREcord = false ;
        }
        if(component.find("SelectPreApprovalType").get("v.value") == '--None--')
        {
            component.find("SelectPreApprovalType").set("v.errors",[{message:"Please select Pre-Approval Document Type: "}]);
            submitREcord = false ;
        }
        else
        {
            component.find("SelectPreApprovalType").set("v.errors",null);
        }
        if(submitREcord) 
        {
            helper.uploadHelper(component, event, 'Fund Request');
        }
    },
 	
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    openPreApprovalModal: function(component, event, helper) {
        component.set("v.strDescription", null);
      	component.set("v.fileName", null);
      	component.set("v.isPreApprovalModal", true);
        component.set("v.showLoadingSpinner", false);
        var opts = [];
		var preApprovalValues = component.get("v.perApprovedDocs");
       	for (var i = 0; i < preApprovalValues.length; i++) {
            opts.push({
                class: "optionClass",
                label: preApprovalValues[i],
                value: preApprovalValues[i]
            });
        }
        component.find("SelectPreApprovalType").set("v.options", opts);
      	
   	},
 
   	closeDocModal: function(component, event, helper) {
      	// for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      	component.set("v.isPreApprovalModal", false);
       	component.set("v.isProofOfPerformanceModal", false);
        component.set("v.isNewClaimDoc", true);
       	component.set("v.isFromPreApproval", false);
        component.set("v.isEditSupportingDoc", false);
        component.set("v.isActivityResult", false);
        component.set("v.isActivityResultError", false);
        component.set("v.isMDFRequestApproval", false);
        component.set("v.isMDFClaimApproval", false);
   	},
    
   	openProofOfPerformanceModal: function(component, event, helper) {
        component.set("v.strDescription", null);
      	component.set("v.fileName", null);
        component.set("v.isPreApprovalModal", false);
      	component.set("v.isProofOfPerformanceModal", true);
        component.set("v.showLoadingSpinner", false);
        var opts = [];
		var preApprovalValues = component.get("v.proofOfPerformanceDocs");
       	for (var i = 0; i < preApprovalValues.length; i++) {
            opts.push({
                class: "optionClass",
                label: preApprovalValues[i],
                value: preApprovalValues[i]
            });
        }
        component.find("SelectProofOfPerformanceType").set("v.options", opts);
        helper.getFilesForClaimDoc(component, event, helper);
      	
   	},
   	doSaveClaimAttachment: function(component, event, helper) {
        var submitREcord = true ; 
        
        if(component.find("fileId").get("v.files").length <= 0)
        {
            component.set("v.fileName", "Please Select a Valid File: ");
            submitREcord = false ;
        }
        if(component.find("SelectProofOfPerformanceType").get("v.value") == '--None--')
        {
            component.find("SelectProofOfPerformanceType").set("v.errors",[{message:"Please select Proof of Performance Document Type: "}]);
            submitREcord = false ;
        }
        else
        {
            component.find("SelectProofOfPerformanceType").set("v.errors", null);
        }
        if(submitREcord) 
        {
        	helper.uploadHelper(component, event, 'Fund Claim');
        }
    },
    
    sectionOne : function(component, event, helper) {
        var vbool = component.get("v.isNewClaimDoc" )? false : true;
        component.set("v.isNewClaimDoc", vbool);
        
        var vbool2 = component.get("v.isFromPreApproval" )? false : true;
        component.set("v.isFromPreApproval", vbool2);
    	helper.helperFun(component,event,'articleOne', 'articleTwo');
    },
    
    sectionTwo : function(component, event, helper) {
        
        var vbool = component.get("v.isFromPreApproval" )? false : true;
      	component.set("v.isFromPreApproval", vbool);
        
        var vbool2 = component.get("v.isNewClaimDoc" )? false : true;
        component.set("v.isNewClaimDoc", vbool2);
      	helper.helperFun(component,event,'articleTwo', 'articleOne');
    },
    
    doSaveClaimFromPreApproval : function(component, event, helper){
        helper.saveClaimFromPreApproval(component, event, helper);
    },
    
    openEditDocumentModal: function(component, event, helper) {
        component.set("v.strDescription", null);
      	component.set("v.fileName", null);
        component.set("v.showLoadingSpinner", false);
        var idx = event.currentTarget;
        var idd = idx.dataset.ids; 
        component.set("v.isEditSupportingDoc", true); 
        component.set("v.fileRecordId", idd);
        
        //alert(idd);
        var fileRecord;
        /* Start find File record*/ 
        var RowItemList = component.get("v.files");
        for (var indexVar = 0; indexVar < RowItemList.length; indexVar++) {
            //alert('----indexVar-'+indexVar);
            if(RowItemList[indexVar].Id === idd)
            {
                //alert('----indexVar-'+indexVar);
                fileRecord = RowItemList[indexVar];
                break;
            }
        }
		
        /* End Find File record */
        
        var opts = [];
        if(fileRecord.Pre_Approval__c && fileRecord.Claim__c == false)
        {
            //alert('----inside approval--');
            var preApproval = component.find("EditPreApproval");
            $A.util.addClass(preApproval, "slds-show");
            
            var ProofOfPerformance = component.find("EditProofOfPerformance");
            $A.util.addClass(ProofOfPerformance, "slds-hide"); 
            
            var preApprovalValues = component.get("v.perApprovedDocs");
            for (var i = 0; i < preApprovalValues.length; i++) {
                if(fileRecord.Pre_Approval_Document_Type__c == preApprovalValues[i]){
                    opts.push({
                        class: "optionClass",
                        label: preApprovalValues[i],
                        value: preApprovalValues[i],
                        selected: true
                    });
                }
                else
                {
                    opts.push({
                        class: "optionClass",
                        label: preApprovalValues[i],
                        value: preApprovalValues[i]
                    });
                }
            }
            component.find("Edit_SelectPreApprovalType").set("v.options", opts);
        }
        else if(fileRecord.Claim__c)
        {	
            //alert('----inside proof--');
            var preApproval = component.find("EditPreApproval");
            $A.util.addClass(preApproval, "slds-hide");
            
            var ProofOfPerformance = component.find("EditProofOfPerformance");
            $A.util.addClass(ProofOfPerformance, "slds-show"); 
            
            var proofValues = component.get("v.proofOfPerformanceDocs");
            for (var i = 0; i < proofValues.length; i++) {
                 if(fileRecord.Proof_of_Performance_Document_Type__c == proofValues[i]){
                    opts.push({
                        class: "optionClass",
                        label: proofValues[i],
                        value: proofValues[i],
                        selected: true
                    });
                 }
                else{
                    opts.push({
                        class: "optionClass",
                        label: proofValues[i],
                        value: proofValues[i],
                    });
                }
            }
            component.find("Edit_SelectProofOfPerformancelType").set("v.options", opts);
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({  
                        "type": "info",
                        "message": "Record can not be edited."
                    });
            toastEvent.fire();
            return;
        }
   	},
    
    doDeleteFileRecord : function(component, event, helper) {
        component.set("v.strDescription", null);
      	component.set("v.fileName", null);
        var idx = event.currentTarget;
        var idd = idx.dataset.ids; 
        //alert(idd);
        var fileRecord;
        /* Start find File record*/ 
        var RowItemList = component.get("v.files");
        var indexVar = 0;
        for (; indexVar < RowItemList.length; indexVar++) {
            //alert('----indexVar-'+indexVar);
            if(RowItemList[indexVar].Id === idd )
            {
                //alert('----indexVar-'+indexVar);
                fileRecord = RowItemList[indexVar];
                break;
            }
        }
        
        if(fileRecord.Pre_Approval__cv == false && fileRecord.Claim__c == false)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({  
                        "type": "info",
                        "message": "You can not delete approved document."
                    });
            toastEvent.fire();
        }
        else
        {
			helper.callFileDelete(component, event, idd);          
        }
    },
    
    doEditAttachment : function(component, event, helper){
        component.set("v.strDescription", null);
        
        var submitREcord = true ;
        var idd = component.get("v.fileRecordId"); 
        var fileRecord;
        var docPicklistValue;
        var parentType;
        var RowItemList = component.get("v.files");
        var indexVar = 0;
            
        /* Start find File record*/ 
        for (; indexVar < RowItemList.length; indexVar++)
        {
            if(RowItemList[indexVar].Id === idd )
            {
                fileRecord = RowItemList[indexVar];
                break;
            }
        }
        	
        if(component.find("fileId").get("v.files").length <= 0)
        {
            component.set("v.fileName", "Please Select a Valid File: ");
            submitREcord = false ;
        }
            
        if(fileRecord.Pre_Approval__c && fileRecord.Claim__c == false)
        {
            parentType = "Request";
            docPicklistValue =  component.find("Edit_SelectPreApprovalType").get("v.value");
            if(docPicklistValue == '--None--')
            {
                component.find("Edit_SelectPreApprovalType").set("v.errors",[{message:"Please select Pre-Approval Document Type: "}]);
                submitREcord = false ;
            }
            else
            {
                component.find("Edit_SelectPreApprovalType").set("v.errors", null);
            }
        }
        else if(fileRecord.Claim__c)
        {
            parentType = "Claim";
            docPicklistValue =  component.find("Edit_SelectProofOfPerformancelType").get("v.value");
            if(docPicklistValue == '--None--')
            {
                component.find("Edit_SelectProofOfPerformancelType").set("v.errors",[{message:"Please select Proof of Performance Document Type: "}]);
                submitREcord = false ;
            }
            else
            {
                component.find("Edit_SelectProofOfPerformancelType").set("v.errors", null);
            }
        }
        if(submitREcord)
            helper.editFileUploadHelper(component, event, parentType, fileRecord, docPicklistValue);
        
    },
    openActivityResult : function(component, event, helper)
    {
        var date1 = new Date();
        var date2 = new Date(component.get("v.mdfRequest.End_Date__c"));
        
        var timeDiff = Math.abs(date2.getTime() - date1.getTime());
        var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
        if(diffDays < 120){
             component.set("v.isActivityResultError", true);
        }
        else{
    		component.set("v.isActivityResult", true);
        }
    },
    
    doSaveActivityResult : function(component, event, helper)
    {
        helper.saveActivityResultHelper(component, event);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       	// make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   	},
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     	// make Spinner attribute to false for hide loading spinner    
       	component.set("v.Spinner", false);
    },
    
    showMDFRequestModal : function(component, event, helper){
        component.set("v.mdfReqeustApprovalComment", null);
        component.set("v.isMDFRequestApproval", true);
    },
    showMDFClaimModal : function(component, event, helper){
        component.set("v.mdfClaimApprovalComment", null);
        component.set("v.isMDFClaimApproval", true);
    }
    
})