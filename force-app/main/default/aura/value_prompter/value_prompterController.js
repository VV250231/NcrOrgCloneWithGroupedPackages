({
    doInit : function(component, event, helper) {
        helper.preLoadIcons(component);
        helper.validateUserProfile(component);
       
    },
    
    loadValuePrompter : function(component, event, helper) {
    	var vpProfile = component.get("v.validUserProfile"); 
        if(vpProfile.valproaccess == true) {
            helper.loadValuePrompter(component);    
        }
    },
    
	inputKeyUp : function(component, event, helper) {
       helper.updateBadgeBar(component);
	},
    
    inputFocusChange :function(component, event, helper) {
       helper.txtFocusChange(component, event);
    },
    
    
    showEditModel : function(component, event, helper) {
        helper.showEditModel(component);
	},
    
    showModal :function(component, event, helper) {
       helper.showModal(component);  
       helper.loadValuePrompter(component);
    },
    
    updateValuePrompter :function(component, event, helper) { 
    	helper.updateValuePrompter(component);   
    }, 
    
    emailValuePrompter :function(component, event, helper) { 
    	helper.emailValuePrompter(component);   
    },
    
    helpmouseover :function(component, event, helper) {
        var tooltip = component.find('email_tooltip');
        $A.util.removeClass(tooltip,'slds-hidden');
    }, 
    
    helpmouseout :function(component, event, helper) {
        var tooltip = component.find('email_tooltip');
        $A.util.addClass(tooltip,'slds-hidden');
    },
    
    handleSelChange :function(component, event, helper) {
    	helper.handleSelChange(component, event); 
        event.stopPropagation();
	},
    
    submitforApproval :function(component, event, helper) {
    	helper.submitforApproval(component, event); 
    },
    
    recallApprvlRqst :function(component, event, helper) {
    	helper.approvalRecall(component, event);	 
    },
    
    hidePrompt:function(component, event, helper) {
    	helper.hidePrompt(component, event); 
    },
    handleApplicationEventParent:function(component, event, helper){
        helper.preLoadIcons(component);
        helper.validateUserProfile(component);
    }
})