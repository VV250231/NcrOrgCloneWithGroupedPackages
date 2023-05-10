({
    loadFinancialAccountDetail : function(component) {
        
        var action = component.get("c.getAccount"); 
        action.setParams({ 
            "Accountid" : component.get("v.AccountId")          
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                if(a.getReturnValue()==null){
                    component.set("v.nonfinancial", true); 
                } else{
                    component.set("v.account", a.getReturnValue());
                    component.set("v.savedaccountversion", a.getReturnValue());
                    this.loadOptionFields(component);
                    
                }                
                
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());   
            }
            
        });
        $A.enqueueAction(action);
    },
    loadFinancialAccountDetailOnCancel : function(component) {
        var action = component.get("c.getAccount"); 
        action.setParams({ 
            "Accountid" : component.get("v.AccountId")       
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                if(a.getReturnValue()==null){
                    component.set("v.nonfinancial", true); 
                } else{
                    component.set("v.account", a.getReturnValue());
                    component.set("v.savedaccountversion", a.getReturnValue());
                    //this.loadOptionFields(component);
                    
                }                
                
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());   
            }
            
        });
        $A.enqueueAction(action);
    },
    getLabels1 : function(component) {
        var action = component.get("c.getLabels"); 
        
        action.setCallback(this, function(a) {
            console.log(a.getState());
            if (a.getState() === "SUCCESS") {    
                component.set("v.labels", a.getReturnValue());
                console.log(component.get("v.labels"));
                console.log(a.getReturnValue());
                
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());   
            }
            
        });
        $A.enqueueAction(action);
    },
    reset : function(component) {         
        component.set("v.readOnly", true);
        component.set("v.edit", false);
        component.set("v.enterpriseshow", false);
        component.set("v.branchshow", false);
       	component.set("v.processorshow", false);
        component.set("v.dbankingshow", false);
        component.set("v.atmshow", false);
        component.set("v.chkshow", false);
        component.set("v.nonfinancial", false);
    },
    toggle : function(component, target, editTarget, action){
        var cmpTarget = component.find(target);
        var cmpTarget1 = component.find(editTarget);
        
        if(action){            
            if(component.get("v.readOnly")){
                $A.util.removeClass(cmpTarget, 'slds-show');
                $A.util.addClass(cmpTarget, 'slds-hide');
            }else{               
                $A.util.removeClass(cmpTarget1, 'slds-show');
                $A.util.addClass(cmpTarget1, 'slds-hide'); 
            }         
            
        }else{
            if(component.get("v.readOnly")){
                $A.util.removeClass(cmpTarget, 'slds-hide');
                $A.util.addClass(cmpTarget, 'slds-show');   
            }else{
                $A.util.removeClass(cmpTarget1, 'slds-hide');
                $A.util.addClass(cmpTarget1, 'slds-show');
            }
        }            
        
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.showSpinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.showSpinner", false);
    },
    loadOptionFields : function(component) {
        
        component.set("v.callChild", false);
        var action = component.get("c.getOpts"); 
        
        action.setParams({ 
            "regn" : component.get("v.account.Account_Region__c"),
             "Accountid" : component.get("v.AccountId")   
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {    
                //console.log('after success'+JSON.stringify(a.getReturnValue()));
                component.set("v.fieldMapOptions", a.getReturnValue());
                component.set("v.callChild", true);
                
                // For testing
                var compEvent = component.getEvent("notifyEvent");
               // compEvent.fire();
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());   
            }
            
        });
               $A.enqueueAction(action);
    },
    saveOnEdit : function(component) {
        if(component.get("v.enterpriseshow")){
			this.toggle(component,'enterprise_Edit_Section', 'enterprise_Section', false);
		}else{
			 this.toggle(component,'enterprise_Edit_Section', 'enterprise_Section', true);
		}
		
		if(component.get("v.processorshow")){
			this.toggle(component,'processor_Edit_Section', 'processor_Section', false);
		}else{
			 this.toggle(component,'processor_Edit_Section', 'processor_Section', true);
		}
		
		if(component.get("v.dbankingshow")){
			this.toggle(component,'digital_Banking_Edit_Section', 'digital_Banking_Section', false);
		}else{
			 this.toggle(component,'digital_Banking_Edit_Section', 'digital_Banking_Section', true);
		}
		
		 if(component.get("v.atmshow")){
			this.toggle(component,'atm_itm_Edit_Section', 'atm_itm_Section', false);
		}else{
			 this.toggle(component,'atm_itm_Edit_Section', 'atm_itm_Section', true);
		}
		
		 if(component.get("v.chkshow")){
			this.toggle(component,'check_Edit_Section', 'check_Section', false);
		}else{
			 this.toggle(component,'check_Edit_Section', 'check_Section', true);
		}
		
		 if(component.get("v.branchshow")){
			this.toggle(component,'branch_Edit_Section', 'branch_Section', false);
		}else{
			 this.toggle(component,'branch_Edit_Section', 'branch_Section', true);
		}

		
		component.set("v.edit", false);
		component.set("v.readOnly", true); 
        
    }    
   })