({
	loadPartnerMaturityLevels : function(component, event, hideSpinner) {
        var action = component.get("c.getPartnerMaturityLevels");
        // set params        
        action.setParams({ 
            "accId" : component.get("v.accId")            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();   
            
            // hide loading
            if (hideSpinner != undefined && typeof hideSpinner === "function") {
                hideSpinner(component);
            }
              
            if(component.isValid() && state == "SUCCESS" ) {
                var responseData = response.getReturnValue(); 
                
                // set accordian data
                console.log(responseData);
                component.set("v.matLvlRecords", response.getReturnValue());   
                this.resetData(component, response.getReturnValue()); // set edit modal data and reset data on cancel
                this.showESTWarningonLoad(component); // show EST warmning on load if any issue with EST date
            } else {
                console.log("component load error");
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
	},
       
    showESTWarningonLoad : function(component) {
    	var currMatLvl = component.get("v.currentMatLvl");
        
        // if current mat level non blank and not approved
        if(!$A.util.isEmpty(currMatLvl)) {
        	//var allMatLvlRcrds = component.get("v.matLvlRecords");
            //var actionList = allMatLvlRcrds[currMatLvlIndex].actionsList;
            var actionList =  currMatLvl.actionsList;
                
            for(var j = 0; j < actionList.length; j++) {
              if ($A.util.isEmpty(actionList[j].dateCompleted) && (!$A.util.isEmpty(actionList[j].estCompleteDate))) {
                  var estcmpldate = new Date(actionList[j].estCompleteDate); 
                  var today = new Date($A.localizationService.formatDate(new Date(), "YYYY-MM-DD"));
                  if (estcmpldate < today) { 
                     var wrngmsg ="EST Complete Date has already passed for some actions, please update it to a future date";
                     this.showPrompt(component, wrngmsg); 
                     // show EST warning if there is issue with one signle EST date
                     break; 
                  }
              }
            }
        }
    },
    
    loadStatusPickListVals : function(component, event) {
    	var action = component.get("c.getStatusPickListVals"); // server action
        action.setCallback(this, function(response) { // callback
            var state = response.getState();            
            if( component.isValid() && state == "SUCCESS" ) {
                component.set("v.statusOptions", response.getReturnValue());     
            }
        });
        $A.enqueueAction(action);
    },
    
    // modal save click
    saveMatLevel : function(component, event, hideSpinner) {
        if (!this.valActionDates(component)) {
            var action = component.get("c.saveCurrentMatLevel");
            action.setParams({
                "activeLevel" : component.get("v.editMatRecords").level, 
                "accId" : component.get("v.accId"),
                "currMatJson" : JSON.stringify(component.get("v.editMatRecords").actionsList)          
            });
            action.setCallback(this, function(response) {
                var state = response.getState();            
                if(component.isValid() && state == "SUCCESS" ) {
                    this.loadPartnerMaturityLevels(component, event, this.savesuccess);  
                } else {
                     console.error(response.getError());
                     // hide spinner
                     $A.util.addClass(component.find("modalspinner"),'slds-hide');
                     // show error message and set focus
                     var errorMsg = this.evalError(response.getError());
                     this.showModalError(component, errorMsg);
                }  
            });
            
            // show modal spinner
       	    $A.util.removeClass(component.find("modalspinner"),'slds-hide'); 
            $A.enqueueAction(action);
        }
    }, 
    
    valActionDates : function(component) {
    	var actionList = component.get("v.editMatRecords").actionsList;
        var now = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var today = new Date(now);
        var isFutCompDate = false, ispastESTDate = false;
       
        // highlight input dates
        for(var j = 0; j < actionList.length; j++) {
            if(!$A.util.isEmpty(actionList[j].dateCompleted)) {
            	var datecmpl = new Date(actionList[j].dateCompleted);
                if (datecmpl > today) {
                    $A.util.addClass(component.find('actionCompDate')[j], "pmsinputError");
                    isFutCompDate = true;
                }
            } 
            else if(!$A.util.isEmpty(actionList[j].estCompleteDate)) {
             	var estcmpldate = new Date(actionList[j].estCompleteDate);  
                if (estcmpldate < today) { 
                    $A.util.addClass(component.find('inputESTDate')[j], "pmsinputError");
                    ispastESTDate = true;
                }
            }   
        } 
        
        // show error msg
        var errorMsg = "";
        if(isFutCompDate) {
            errorMsg = "- Date Completed should not be in future";    
        }
        
        if(ispastESTDate) {
            if(errorMsg.length > 0) { errorMsg += "<br/>- EST Complete Date should not be in past"; } 
            else { errorMsg = "- EST Complete Date should not be in past"; } 
        }
        
        if(errorMsg.length > 0) {
            this.showModalError(component, errorMsg); 
        }
        return (isFutCompDate || ispastESTDate); // return true if there is errors 
    },
    
    showModalError : function(component, errorMsg) {
         // show error message and set focus
    	 $A.util.removeClass(component.find("psmuimsg"),'slds-hide'); 
        component.find("psmerrortxt").set("v.value", errorMsg);
         var modaldiv = component.find("editmodal_content").getElement();
         modaldiv.scrollTop = 0;      
    },
    
    savesuccess : function(component) {
        $A.util.addClass(component.find("modalspinner"),'slds-hide'); 
        $A.util.addClass(component.find("accrdEditModal"),'slds-hide');  
        $A.util.addClass(component.find("hoverSection"),'slds-hide');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Your changes are saved successfully",
            "type": "Success",
            "message": " "
        });
        toastEvent.fire();
    },
    
    resetData : function(component, allMatLvlRcrds) {
        var wrngFlag = false;
        
        //clone using json stringify
        for(var i = 0; i < allMatLvlRcrds.length; i++) {
            if((allMatLvlRcrds[i].level === allMatLvlRcrds[i].currentMatlevel) && (allMatLvlRcrds[i].aprvlStatus != "Approved")) {
               
                // set current mat level index and open mat level
                component.set("v.currentMatLvl", allMatLvlRcrds[i]); 
                if($A.util.isEmpty(component.get("v.activeMatLvl"))) {
                	component.set("v.activeMatLvl", allMatLvlRcrds[i].level);     
                }
                
                if(allMatLvlRcrds[i].aprvlStatus == 'Rejected') {
                    component.set("v.approverComments", {'hascomments' : true, 'comments' : allMatLvlRcrds[i].aprvlComments});    
                } else if(allMatLvlRcrds[i].aprvlStatus == 'New' && i > 0) { // current mat level > 0
                	component.set("v.lastLvlApprvdComments", {'hascomments' : true, 'comments' : allMatLvlRcrds[i-1].aprvlComments});                                      
                }
                break;
            } 
        }  
        
       
        this.clearEditRecord(component);
        if($A.util.isEmpty(component.get("v.currentMatLvl"))) {
            $A.util.removeClass(component.find("allcompletemsg"),'slds-hide');
            component.set("v.lastLvlApprvdComments", {'hascomments' : true, 'comments' : allMatLvlRcrds[allMatLvlRcrds.length-1].aprvlComments});              
        } 
         // remove error message
         $A.util.addClass(component.find("psmuimsg"),'slds-hide'); 
         component.find("psmerrortxt").set("v.value", "");
    },
    
    
    modalCancel : function(component) {
        this.clearEditRecord(component);
        this.hideEditModal(component);
        // remove error messages
        $A.util.addClass(component.find("psmuimsg"),'slds-hide'); 
        component.find("psmerrortxt").set("v.value", "");
    },
    
    clearEditRecord : function(component)  {
        if(!$A.util.isEmpty(component.get("v.editMatRecords"))) {
            var clearRecord = component.get("v.editMatRecords");
            clearRecord.actionsList = [];   
            component.set("v.editMatRecords", clearRecord);
        }
    },
    
    submitForApproval : function(component) {
        var blankdate = this.validateActions(component); 
        if(blankdate) {
            var wrngmsg ="For each level, populating all fields (except comments) for each action is required, before Submitting for Approval.";
            this.showPrompt(component, wrngmsg);    
        } else  {
            // submit for approval
            var action = component.get("c.submitForApproval"); // server action
            action.setParams({
                "accId" : component.get("v.accId"),
                "currentMatlevel" : component.get("v.currentMatLvl").currentMatlevel
            });
            action.setCallback(this, function(response) { // callback
                this.hideSpinner(component);
                var state = response.getState();            
                if( component.isValid() && state == "SUCCESS" ) {
                    // change approval status on current mat level
                    var currMatLvl = component.get("v.currentMatLvl");
                    var allMatLvlRcrds = component.get("v.matLvlRecords");
                    currMatLvl.aprvlStatus = 'Submitted';
                    component.set("v.currentMatLvl", currMatLvl);
                   
                    for(var i = 0; i < allMatLvlRcrds.length; i++) {
                        if(allMatLvlRcrds[i].level === allMatLvlRcrds[i].currentMatlevel) {
                        	allMatLvlRcrds[i] = currMatLvl;  
                            break;
                        }
                    } component.set("v.matLvlRecords", allMatLvlRcrds);
                    
                    
                    // show success msg
                    var successMsg = component.get("v.currentMatLvl").currentMatlevel + " submitted for approval successfully.";
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": successMsg
                    });
                    toastEvent.fire();
                } else { // incomplete or error state
                    // show error
                    var errorMsg = this.evalError(response.getError());
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": errorMsg,
                    });
                	toastEvent.fire()
                }
            });
            this.showSpinner(component);
            $A.enqueueAction(action);  
        }
    },
    
    validateActions : function(component) {
    	var allMatLvlRcrds = component.get("v.matLvlRecords");
        var blankflag = false;
        //clone using json stringify
        for(var i = 0; i < allMatLvlRcrds.length; i++) {
            if(allMatLvlRcrds[i].level == allMatLvlRcrds[i].currentMatlevel) {
                var actionList = allMatLvlRcrds[i].actionsList;
                
                for(var j = 0; j < actionList.length; j++) {
                    if($A.util.isEmpty(actionList[j].dateCompleted) || $A.util.isEmpty(actionList[j].status)
                      	|| $A.util.isEmpty(actionList[j].actionOwner) || $A.util.isEmpty(actionList[j].estCompleteDate)) {
                    	blankflag = true;
                        break;
                    }		    
                }  break; 
            } 
        } 
        return blankflag;
    },
    
    /**********  utitlity functions **********/ 
    showSpinner : function(component) {
    	$A.util.removeClass(component.find("spinnerDiv"),'slds-hide');     
    }, 
    
    hideSpinner : function(component) {
    	$A.util.addClass(component.find("spinnerDiv"),'slds-hide');
	},
    
    showEditModal : function(component, editIndex) {
        var allMatLvlRcrds = component.get("v.matLvlRecords");
        var currEditRecord = allMatLvlRcrds[editIndex];
        
        if((!$A.util.isEmpty(currEditRecord.editAccesss)) && currEditRecord.editAccesss) {
            component.set("v.editMatRecords", JSON.parse(JSON.stringify(currEditRecord)));
            $A.util.removeClass(component.find("accrdEditModal"),'slds-hide');  
            $A.util.removeClass(component.find("hoverSection"),'slds-hide');  
            this.valActionDates(component); // validate edit form on edit click 
        }
    },
    
    hideEditModal : function(component) {
    	$A.util.addClass(component.find("accrdEditModal"),'slds-hide');  
        $A.util.addClass(component.find("hoverSection"),'slds-hide');    
    },
    
    showPrompt:function(component, msg) {
    	$A.util.removeClass(component.find("prmtForBlkAct"), 'slds-hide');
        component.find("warningprmpt").set("v.value", msg);
    },
    
    hidePrompt:function(component) {
    	$A.util.addClass(component.find("prmtForBlkAct"), 'slds-hide');
    },
    
    findElement: function(elem, type) {
        console.log(elem);
        type = type.toUpperCase();
        while (true) {
            if ((elem != undefined) && (elem.tagName != undefined) && (elem.tagName.toUpperCase() == type)) {
                return elem;
            } else {
                elem = elem.parentNode;
            }
        }
        return elem;
    },
    
    evalError : function(errors) {
        var errmsg = "Unknown error";
        if(errors) {
            if(errors[0] && (!$A.util.isUndefinedOrNull(errors[0].message))) // To show other type of exceptions
                errmsg = errors[0].message;
            if(errors[0] && (!$A.util.isUndefinedOrNull(errors[0].pageErrors)) && (!$A.util.isEmpty(errors[0].pageErrors))) {// To show DML exceptions
                errmsg = errors[0].pageErrors[0].message;
            }
            if(errors[0] && (!$A.util.isUndefinedOrNull(errors[0].fieldErrors))) {// To show DML exceptions
                if($A.util.isArray(errors[0].fieldErrors) && (!$A.util.isEmpty(errors[0].fieldErrors)))
                    errmsg = errors[0].fieldErrors[0].message;
                else if($A.util.isObject(errors[0].fieldErrors)) {
                    var fielderrMap = errors[0].fieldErrors;
                    for(key in fielderrMap) {
                        if((!$A.util.isUndefinedOrNull(fielderrMap[key][0].message))) {
                            errmsg = fielderrMap[key][0].message;   
                            break;
                        }
                    }
                }
            }   
        }
        return errmsg;
    }
})