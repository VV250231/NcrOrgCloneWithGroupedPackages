({ 
    loadValuePrompter : function(component, successCallback) {
    	var action = component.get("c.getOppValuePrompter"); 
        action.setParams({ 
        	"OppId" : component.get("v.OppId")     
        });   
        action.setCallback(this, function(a) {
            this.hideSpinner(component);
            if (a.getState() == "SUCCESS") {
                if(a.getReturnValue() != null) {
                    
                    var resp = a.getReturnValue();
                    component.set("v.apprvlStatus", resp.Approval_Process_Status__c);
                    component.set("v.apprvlbtnVsb", component.get("v.validUserProfile").editbtnaccess); // if opp is closed
                    

                    // if(resp.Approval_Process_Status__c == 'Submitted' || resp.Approval_Process_Status__c == 'Approved')
                    if(resp.Approval_Process_Status__c == 'Submitted') {
                        console.log('inside approval check');
                        var accessObj = component.get("v.validUserProfile"); 
                        component.set("v.validUserProfile", {'valproaccess' : accessObj.valproaccess, 'editbtnaccess': false});
                    } 
                    component.set("v.vprompter", a.getReturnValue()); 
                    //$A.get('e.force:refreshView').fire();
                    
                } else {
                    component.set("v.vprompter",{'sobjectType':'Value_Prompter__c', 'Contact__c': '', 'Opportunity__c': component.get("v.OppId"),
							   					'Business_Issue__c': '', 'Anxiety_Question__c': '',
                                                 'Problem__c': '', 'Solution__c': '', 'VPQ_Score__c' : 0, 
                                               'Value__c': '', 'Power__c': '', 'Plan__c': '',
                                               'VisionMatch_Comments__c': '','Value_Comments__c': '','Plan_Comments__c': '','Power_Comments__c': '',
                                               'Organizational_chart_Completed__c': false, 'Access_to_the_Power_Person__c': false, 
                                               'Have_we_developed_an_eVP__c': false, 'Validatd_Power_Person_decsion_authority__c': false,
                                                'Power_Person_has_access_to_funds_bdgt__c': false, 'Has_the_Business_Value_been_quantified__c': false,
                                                'Has_a_cost_justification_been_completed__c': false, 'Do_prospect_agreed_potential_buss_value__c': false,
                                                'Was_any_personal_value_uncovered__c': false, 'Understand_personal_value_of_dec_maker__c': false,
                                                'Can_it_be_related_to_Revenue_or_Profit__c': false, 'Has_prspect_acknowledged_business_issue__c': false,
                                                'Find_prob_make_this_issue_hard_to_solve__c': false, 'identified_prblm_that_only_we_can_solve__c': false,
                                                'Is_prospect_req_any_unique_or_diff_sol__c': false, 'Has_Plan_confirmed_with_customer__c': false,
                                                'Has_client_agreed_to_a_completion_date__c': false, 'Has_power_person_agreed_on_mutual_plan__c': false,
                                                'Is_this_Plan_with_a_sponsor__c': false, 'Are_checkpnts_for_Decision_Maker_review__c': false}); 
                }
                
                var vpperm = component.get("v.validUserProfile");
                this.updateBadgeBar(component, vpperm.editbtnaccess);
                this.updateSectionScore(component);
                if (successCallback != undefined && typeof successCallback == "function") {
                	successCallback();
            	}
            } else if (a.getState() == "ERROR") {  
                console.log(a.getError());
            } 
 
    	});
        this.showSpinner(component);
        $A.enqueueAction(action);
    },
    
   updateValuePrompter : function(component) {
    	var action = component.get("c.saveValuePrompter"); 
        var valPro = component.get("v.vprompter"); 
        var msgelem = component.find("errorMsg").getElement();
        console.log(valPro);
        action.setParams({'valpro' : valPro, 'OppId' : component.get("v.OppId")});  
        action.setCallback(this, function(a) {
             this.hideSpinner(component);
            
			 if(a.getState() == "SUCCESS") {
		
             	if(a.getReturnValue() != null) {
                    component.set("v.vprompter", a.getReturnValue()); 
                }  
                msgelem.innerHTML = ""; 
                $A.util.addClass(component.find("errorMsgDiv"),'slds-hide');
                component.find("backGroundSection").getElement().style.display = "None";
                component.find("hoverSection").getElement().style.display = "None";
             } else if (a.getState() == "ERROR") { 
                $A.log("Errors", a.getError()); 
                console.log("update error" + a.getError());
                console.log(a.getError());
                this.showError(component, a.getError());
            } 
        });
        this.showSpinner(component);
        $A.enqueueAction(action);
    },
    
  
    
    validateUserProfile : function(component, successCallback) {
    	var action = component.get("c.checkValuePrompterAccess");  
        var vp = component.get("v.vprompter"); 
        console.log(vp.Id);
        action.setParams({ 
        	"OppId" : component.get("v.OppId")
        }); 
        action.setCallback(this, function(a) {
        	if (a.getState() == "SUCCESS") {
                if(a.getReturnValue() != null) {
                    try {
                        var vpAccess = JSON.parse(a.getReturnValue());
                        component.set("v.validUserProfile", vpAccess); 
                        if(vpAccess.valproaccess) {
                            this.loadValuePrompter(component, successCallback);    
                        }
                    } catch(e) {console.log(e.message);}
                }
            } else if (a.getState() === "ERROR") { 
                console.log(a.getError());
            }     
        });
        $A.enqueueAction(action);
    },

    txtFocusChange : function(component, event) {      
         var spinId = event.getSource().getLocalId()  + '_ajax'; 
         $A.util.removeClass(component.find(spinId),'slds-hide'); 
        
         var action = component.get("c.saveValuePrompter"); 
         var valPro = component.get("v.vprompter"); 
         action.setParams({'valpro' : valPro, 'OppId' : component.get("v.OppId")});
        
          action.setCallback(this, function(a) {
                 $A.util.addClass(component.find(spinId),'slds-hide');
                
                 if(a.getState() == "SUCCESS") {
                    if(a.getReturnValue() != null) { 
                        var updateResp = a.getReturnValue();
                        console.log(updateResp);
                        if(!$A.util.isUndefinedOrNull(updateResp.Id)) {
                        	valPro.Id = updateResp.Id;  	    
                        }
                    	this.updateBadgeBar(component, true); 
                    }
                 } else if (a.getState() == "ERROR") { 
                    $A.log("Errors", a.getError()); 
                    console.log("update error" + a.getError());
                    console.log(a.getError());
                    this.showError(component, a.getError());
                } 
            });
            $A.enqueueAction(action);
        
    },     
    
    
        
	updateBadgeBar : function(cmp, editPerm) {
        var valPro = cmp.get("v.vprompter");
        
        var bussIssueStr = editPerm ? cmp.find("issuetxt").get("v.value") : valPro.Business_Issue__c; 
        var probStr = editPerm ? cmp.find("probtxtarea").get("v.value") : valPro.Problem__c; 
        var solStr = editPerm ? cmp.find("soltxtarea").get("v.value") : valPro.Solution__c; 
        var valueStr = editPerm ? cmp.find("valuetxtarea").get("v.value") : valPro.Value__c;
        var powerStr = editPerm ? cmp.find("powertxt").get("v.value") : valPro.Power__c;
        var planStr =  editPerm ? cmp.find("plantxt").get("v.value") : valPro.Plan__c;
        
        var diffvis = false, valueflag = false, powerflag = false, planflag = false; 
        
        if(!($A.util.isEmpty(bussIssueStr) || $A.util.isEmpty(probStr) || $A.util.isEmpty(solStr))) {
        	cmp.set("v.diffbadge", true);
            diffvis = true;
        } else { cmp.set("v.diffbadge", false);}
        
        if(!$A.util.isEmpty(valueStr)) {
        	cmp.set("v.valuebadge", true);   
            valueflag = true;
        } else { cmp.set("v.valuebadge", false);}
        
        if(!$A.util.isEmpty(powerStr)) {
        	cmp.set("v.powerbadge", true);   
            powerflag = true;
        } else { cmp.set("v.powerbadge", false);}
        
        if(!$A.util.isEmpty(planStr)) {
        	cmp.set("v.planbadge", true);   
            planflag = true;
        } else { cmp.set("v.planbadge", false);}

        if((diffvis == true) && (valueflag == true) && (powerflag == true) && (planflag == true)) {
        	cmp.set("v.qpbadge", true);   
        } else {cmp.set("v.qpbadge", false); }
	},
    
    showModal : function(component) {
        var msgelem = component.find("errorMsg").getElement();
        msgelem.innerHTML = ""; 
        $A.util.addClass(component.find("errorMsgDiv"),'slds-hide');
        component.find("backGroundSection").getElement().style.display = "None";
        component.find("hoverSection").getElement().style.display = "None";
    },
    
    showEditModel : function(component) {
        component.find("backGroundSection").getElement().style.display = "block";
        component.find("hoverSection").getElement().style.display = "block";
	},
    
    showSpinner : function(component) {
    	$A.util.removeClass(component.find("loadingDiv"),'slds-hide');     
    }, 
    
    hideSpinner : function(component) {
    	$A.util.addClass(component.find("loadingDiv"),'slds-hide');
	},
    
    emailValuePrompter : function(component) {
    	var action = component.get("c.emailMeValPrompter"); 
        var valPro = component.get("v.vprompter"); 
        action.setParams({'valpro' : valPro}); 
        action.setCallback(this, function(a) {
            this.hideSpinner(component);
        	if (a.getState() == "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "email sent successfully."
                });
                toastEvent.fire();
               
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError()); 
            }         
        });
        this.showSpinner(component);
         $A.enqueueAction(action);
    },
    
    loadQuestions : function(component) {
    	var questions = ["Organizational chart Completed?",	
                         "Do we have access to the Power Person?",
                         "Have we developed an eVP for the Power Person?",
                         "Validated the Power Person's decision making authority?",
                         "Have we confirmed the Power Person has access to the funds and budget (do not assume)?",
                         "Has the Business Value been quantified?",
                         "Has a cost justification or ROI been completed?",
                         "Do the prospect agree with the potential value to their business?",
                         "Was any personal value uncovered?",
                         "Do we understand the personal value of the ultimate decision maker / Power Person?",
                         "Business issue: Is it a business issue (versus a technical problem)? Can it be directly related to Revenue or Profit?",
                         "Has the prospect acknowledged the business issue?",
                         "Have we identified the problems or challenges that make this issue difficult to solve?",
                         "Have we identified problems that only we can solve?",
                         "Would the prospect say any of the solution requirements are unique or differentiated?",
                         "Has the plan been mutually developed and confirmed in writing with customer?",
                         "Has client agreed to a completion date that maps to their urgency to act or compelling event?",
                         "Has the power person agreed to a mutual plan of activities?",
                         "If this plan is with a sponsor, does it include access to the decision maker?",
                         "Are there logical checkpoints for Decision Maker review?" ];
    	//component.set("v.checklist", questions); 
    },
    
   
     handleSelChange : function(component, event) {
        var isInlineEdit =  event.getParam('inlineedit');
        if(!$A.util.isUndefinedOrNull(isInlineEdit) && isInlineEdit)   {
            // show spinner before saving
            var spinId = event.getSource().getLocalId()  + '_ajax'; 
            $A.util.removeClass(component.find(spinId),'slds-hide'); 
            
            var action = component.get("c.saveValuePrompter"); 
            var valPro = component.get("v.vprompter"); 
            action.setParams({'valpro' : valPro, 'OppId' : component.get("v.OppId")});  
            action.setCallback(this, function(a) {
                 $A.util.addClass(component.find(spinId),'slds-hide');
                
                 if(a.getState() == "SUCCESS") {
                    if(a.getReturnValue() != null) { 
                        var updateResp = a.getReturnValue();
                        console.log(updateResp);
                        if(!$A.util.isUndefinedOrNull(updateResp.Id)) {
                        	valPro.Id = updateResp.Id;  	    
                        }
                    	this.updateScore(component); 
                    }
                   var appEvent = $A.get("e.c:NotifyCommitmentRisk");
                    appEvent.setParams({
                        "Weightage" : 0 });
                    appEvent.fire();  
                     
                 } else if (a.getState() == "ERROR") { 
                    $A.log("Errors", a.getError()); 
                    console.log("update error" + a.getError());
                    console.log(a.getError());
                    this.showError(component, a.getError());
                } 
            });
            $A.enqueueAction(action);
         } else {
         	this.updateScore(component); 	   
         }
    },
    
    updateScore : function(component) { 
   		var valPro = component.get("v.vprompter");  
        var totalYes =    (valPro.Organizational_chart_Completed__c ? 1 : 0) +  (valPro.Access_to_the_Power_Person__c ? 1 : 0)  
                            + (valPro.Have_we_developed_an_eVP__c ? 1 : 0) +  (valPro.Validatd_Power_Person_decsion_authority__c ? 1 : 0) 
                            + (valPro.Power_Person_has_access_to_funds_bdgt__c ? 1 : 0) +  (valPro.Has_the_Business_Value_been_quantified__c ? 1 : 0) 
                            + (valPro.Has_a_cost_justification_been_completed__c ? 1 : 0) +  (valPro.Do_prospect_agreed_potential_buss_value__c? 1 : 0)  
                            + (valPro.Was_any_personal_value_uncovered__c ? 1 : 0) +  (valPro.Understand_personal_value_of_dec_maker__c ? 1 : 0) 
                            + (valPro.Can_it_be_related_to_Revenue_or_Profit__c ? 1 : 0) +  (valPro.Has_prspect_acknowledged_business_issue__c ? 1 : 0)
                            + (valPro.Find_prob_make_this_issue_hard_to_solve__c ? 1 : 0) +  (valPro.identified_prblm_that_only_we_can_solve__c ? 1 : 0) 
                            + (valPro.Is_prospect_req_any_unique_or_diff_sol__c ? 1 : 0) +  (valPro.Has_Plan_confirmed_with_customer__c ? 1 : 0)
                            + (valPro.Has_client_agreed_to_a_completion_date__c ? 1 : 0) +  (valPro.Has_power_person_agreed_on_mutual_plan__c ? 1 : 0)
                            + (valPro.Is_this_Plan_with_a_sponsor__c ? 1 : 0) +  (valPro.Are_checkpnts_for_Decision_Maker_review__c ? 1 : 0);
        component.set("v.vprompter.VPQ_Score__c", (totalYes*100)/20);
        this.updateSectionScore(component);
 	},
    
    updateSectionScore : function(component) {
        var valPro = component.get("v.vprompter"); 
    	var oppVisMatch = ((valPro.Can_it_be_related_to_Revenue_or_Profit__c ? 1 : 0)
							+ (valPro.Has_prspect_acknowledged_business_issue__c ? 1 : 0)
							+ (valPro.Find_prob_make_this_issue_hard_to_solve__c ? 1 : 0)
							+ (valPro.identified_prblm_that_only_we_can_solve__c ? 1 : 0)
							+ (valPro.Is_prospect_req_any_unique_or_diff_sol__c ? 1 : 0))*20;
        
		var oppValue = ((valPro.Has_the_Business_Value_been_quantified__c ? 1 : 0)
						+ (valPro.Has_a_cost_justification_been_completed__c ? 1 : 0)
						+ (valPro.Do_prospect_agreed_potential_buss_value__c ? 1 : 0)
						+ (valPro.Was_any_personal_value_uncovered__c ? 1 : 0)
						+ (valPro.Understand_personal_value_of_dec_maker__c ? 1 : 0))*20;
        
		var oppPower = ((valPro.Organizational_chart_Completed__c ? 1 : 0)
						+ (valPro.Access_to_the_Power_Person__c ? 1 : 0)
						+ (valPro.Have_we_developed_an_eVP__c ? 1 : 0)
						+ (valPro.Validatd_Power_Person_decsion_authority__c ? 1 : 0)
						+ (valPro.Power_Person_has_access_to_funds_bdgt__c ? 1 : 0))*20;
						
		var oppPlan = ((valPro.Has_Plan_confirmed_with_customer__c ? 1 : 0)
						+ (valPro.Has_client_agreed_to_a_completion_date__c ? 1 : 0)
						+ (valPro.Has_power_person_agreed_on_mutual_plan__c ? 1 : 0)
						+ (valPro.Is_this_Plan_with_a_sponsor__c ? 1 : 0)
						+ (valPro.Are_checkpnts_for_Decision_Maker_review__c ? 1 : 0))*20; 
        component.set("v.visMatchScore", oppVisMatch);
          component.set("v.valueScore", oppValue);
          component.set("v.powerScore", oppPower);
          component.set("v.planScore", oppPlan);
    },
    
    
    showError : function(component, errors) {
        var msgelem = component.find("errorMsg").getElement();
        
    	if(errors[0] && (!$A.util.isUndefinedOrNull(errors[0].message))) // To show other type of exceptions
            msgelem.innerHTML = errors[0].message;
        if(errors[0] && (!$A.util.isUndefinedOrNull(errors[0].pageErrors)) && (!$A.util.isEmpty(errors[0].pageErrors))) {// To show DML exceptions
            msgelem.innerHTML = errors[0].pageErrors[0].message;
        }
        if(errors[0] && (!$A.util.isUndefinedOrNull(errors[0].fieldErrors))) {// To show DML exceptions
            if($A.util.isArray(errors[0].fieldErrors) && (!$A.util.isEmpty(errors[0].fieldErrors)))
                msgelem.innerHTML = errors[0].fieldErrors[0].message;
            else if($A.util.isObject(errors[0].fieldErrors)) {
                var fielderrMap = errors[0].fieldErrors;
                for(key in fielderrMap) {
                    if((!$A.util.isUndefinedOrNull(fielderrMap[key][0].message))) {
                        msgelem.innerHTML = fielderrMap[key][0].message;   
                        break;
                    }
                }
            }
        }   
        
        $A.util.removeClass(component.find("errorMsgDiv"),'slds-hide');
        var modaldiv = document.getElementById('modal_content');
        modaldiv.scrollTop = 0;   
    },
    
    preLoadIcons : function(component) {
    	var iconarray = new Array();
        var arr= ["/img/slds-icons/v5.2.0/utility-sprite/svg/symbols.svg#info", "/img/slds-icons/v5.2.0/utility-sprite/svg/symbols.svg#close"];
        for (var i=0; i<arr.length; i++){
           iconarray[i] = document.createElement("img");  
           iconarray[i].src = arr[i];
        }
    },
    
    
    submitforApproval : function(component, event) { 
        var status = component.get("v.vprompter.Approval_Process_Status__c");
       
        if(component.get("v.qpbadge") == true) {
        var action = component.get("c.submitValPrmForApproval");
        var valPro = component.get("v.vprompter"); 
        action.setParams({'vpId' : valPro.Id}); 
        action.setCallback(this, function(a) {
            
            //this.hideSpinner(component);
        	if (a.getState() == "SUCCESS") {
                // reload component 
               var hlpr = this;
               this.validateUserProfile(component, function(){ 
                   					   		hlpr.showToastMsg("Record submitted for review successfully");
               							});
               //component.set("v.disabled", true);
               //$A.get('e.force:refreshView').fire();
            }  
            else if (a.getState() === "INCOMPLETE") {
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "type": "Warning",
                    "message": "Record already Approved."
                });
                toastEvent.fire();
               
            }
            else if (a.getState() === "ERROR") {
				var errorMsg = this.evalError(a.getError());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "message": errorMsg
                }).fire();                
            }       
        });
        this.showSpinner(component);
         $A.enqueueAction(action);
        }
        else {
            var promptDiv = component.find("prmptToAllFlds");
            $A.util.addClass(promptDiv, 'slds-show');
            $A.util.removeClass(promptDiv, 'slds-hide');
        }
    	
    },
    
    showToastMsg :  function(msg) {
    	var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "Success",
            "message": msg
        }).fire();
    },
	
	approvalRecall : function(component, event) { 
		var action = component.get("c.recallApprovalRequest");
        action.setParams({'vpId' : component.get("v.vprompter").Id}); 
		
        action.setCallback(this, function(a) {
			
        	if (a.getState() == "SUCCESS") {
				this.validateUserProfile(component);
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "Success",
                    "message": "Recalled approval request successfully."
                }).fire();*/
            } else if (a.getState() === "ERROR") {
                console.log(a.getError());
                var errorMsg = this.evalError(a.getError());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "message": errorMsg
                }).fire();
            }       
        });
        this.showSpinner(component);
        $A.enqueueAction(action);
	},
	
    hidePrompt:function(component, event, helper) {
         var promptDiv = component.find("prmptToAllFlds");
         $A.util.removeClass(promptDiv, 'slds-show');	
         $A.util.addClass(promptDiv, 'slds-hide');
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