({
    doInit : function(component, event, helper) {
       
        helper.loadFinancialAccountDetail(component);        
        helper.getLabels1(component);
        helper.reset(component);  
        
    },
    openPrintApp: function(component, event, helper) {
      
        window.open('/c/TechnologyPrint.app?recordId='+component.get("v.recordId"),'_blank') ; 
        
    },
    //Collapse the sections on Editing.
    editMode : function(component, event, helper) {
        if(component.get("v.enterpriseshow")){
			helper.toggle(component,'enterprise_Edit_Section', 'enterprise_Section', false);
		}else{
			 helper.toggle(component,'enterprise_Edit_Section', 'enterprise_Section', true);
		}
		
		if(component.get("v.processorshow")){
			helper.toggle(component,'processor_Edit_Section', 'processor_Section', false);
		}else{
			 helper.toggle(component,'processor_Edit_Section', 'processor_Section', true);
		}
		
		if(component.get("v.dbankingshow")){
			helper.toggle(component,'digital_Banking_Edit_Section', 'digital_Banking_Section', false);
		}else{
			 helper.toggle(component,'digital_Banking_Edit_Section', 'digital_Banking_Section', true);
		}
		
		 if(component.get("v.atmshow")){
			helper.toggle(component,'atm_itm_Edit_Section', 'atm_itm_Section', false);
		}else{
			 helper.toggle(component,'atm_itm_Edit_Section', 'atm_itm_Section', true);
		}
		
		 if(component.get("v.chkshow")){
			helper.toggle(component,'check_Edit_Section', 'check_Section', false);
		}else{
			 helper.toggle(component,'check_Edit_Section', 'check_Section', true);
		}
		
		 if(component.get("v.branchshow")){
			helper.toggle(component,'branch_Edit_Section', 'branch_Section', false);
		}else{
			 helper.toggle(component,'branch_Edit_Section', 'branch_Section', true);
		} 
		
		component.set("v.edit", true);
		component.set("v.readOnly", false); 
        
    },    
    readOnlyMode : function(component, event, helper) {
        component.set("v.readOnly", true);
    },
    enterpriseToggle : function(component, event, helper) {
        if(component.get("v.enterpriseshow")){
            helper.toggle(component,'enterprise_Section', 'enterprise_Edit_Section', true);
            component.set("v.enterpriseshow", false);
        }else{
            helper.toggle(component,'enterprise_Section', 'enterprise_Edit_Section', false); 
            component.set("v.enterpriseshow", true);
        }         
    },
    
     processorToggle : function(component, event, helper) {
        if(component.get("v.processorshow")){
            helper.toggle(component,'processor_Section', 'processor_Edit_Section', true);
            component.set("v.processorshow", false);
        }else{
            helper.toggle(component,'processor_Section', 'processor_Edit_Section', false); 
            component.set("v.processorshow", true);
        }         
    }, 
    branchToggle :function(component, event, helper) {
        if(component.get("v.branchshow")){
            helper.toggle(component,'branch_Section', 'branch_Edit_Section', true);
            component.set("v.branchshow", false);
        }else{
            helper.toggle(component,'branch_Section', 'branch_Edit_Section', false); 
            component.set("v.branchshow", true);
        }         
    }, 
    
    
    dbankingToggle : function(component, event, helper) {
        if(component.get("v.dbankingshow")){
            helper.toggle(component,'digital_Banking_Section', 'digital_Banking_Edit_Section', true);
            component.set("v.dbankingshow", false);
        }else{
            helper.toggle(component,'digital_Banking_Section', 'digital_Banking_Edit_Section', false); 
            component.set("v.dbankingshow", true);
        }         
    }
    ,
    atmToggle : function(component, event, helper) {
        if(component.get("v.atmshow")){
            helper.toggle(component,'atm_itm_Section', 'atm_itm_Edit_Section', true);
            component.set("v.atmshow", false);
        }else{
            helper.toggle(component,'atm_itm_Section', 'atm_itm_Edit_Section', false); 
            component.set("v.atmshow", true);
        }         
    }
    ,
    chkToggle : function(component, event, helper) {
        if(component.get("v.chkshow")){
            helper.toggle(component,'check_Section', 'check_Edit_Section', true);
            component.set("v.chkshow", false);
        }else{
            helper.toggle(component,'check_Section', 'check_Edit_Section', false); 
            component.set("v.chkshow", true);
        }         
    },
    saveAccount1 : function(component,event, helper) {
        var action = component.get("c.saveAccount"); 
       action.setParams({ 
            "acc" : component.get("v.account")       
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {   
                component.set("v.account", a.getReturnValue());
                component.set("v.savedaccountversion", a.getReturnValue());
                helper.getLabels1(component);
                //component.set("v.readOnly", true);
       		    //component.set("v.edit", false);
               	helper.saveOnEdit(component);
                helper.hideSpinner(component) ;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Technology Information was successfully saved.',
                    duration:' 4000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                 
                
            } else if (a.getState() === "ERROR") { 
                helper.hideSpinner(component) ;
                var errors = a.getError();
                var errMsg; 
                if (errors) {
                    if (errors[0] && errors[0].message && !$A.util.isUndefinedOrNull(errors[0].message)) {
                        errMsg=errors[0].message;
                    }
                    else {
                        errMsg='Due to unknown exception, You maynot have permission to update Account, Please contact Salesforce Support or use Need Help.'
                    } 
                } else {
                    errMsg='Due to unknown exception, You maynot have permission to update Account, Please contact Salesforce Support or use Need Help.'
                } 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Failure',
                    message: 'Failed to save: '+errMsg,
                    duration:' 6000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            
        });
        helper.showSpinner(component) ;
        $A.enqueueAction(action);
        helper.loadFinancialAccountDetail(component);
    }
    ,
    cancel1 : function(component, event, helper) {
        helper.showSpinner(component) ;
        helper.loadFinancialAccountDetail(component);
        helper.reset(component);
        helper.hideSpinner(component) ;
        //helper.getLabels1(component);
        $A.util.addClass(component.find("enterprise_Section"), 'slds-hide');
        $A.util.addClass(component.find("processor_Section"), 'slds-hide');
        $A.util.addClass(component.find("digital_Banking_Section"), 'slds-hide');
        $A.util.addClass(component.find("check_Section"), 'slds-hide');
        $A.util.addClass(component.find("atm_itm_Section"), 'slds-hide');
        $A.util.addClass(component.find("branch_Section"), 'slds-hide');
        
    }
    
})