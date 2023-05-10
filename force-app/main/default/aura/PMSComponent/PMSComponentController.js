({
	doInit : function(component, event, helper) {
        helper.loadStatusPickListVals(component, event);
        helper.loadPartnerMaturityLevels(component, event, helper.hideSpinner);
    },
   
    showEditModal : function(component, event, helper) {
        var editbtn =  event.getSource().get("v.name");
        if(!$A.util.isEmpty(editbtn)) {
        	var editbtnindex = editbtn.split('-');
            helper.showEditModal(component, parseInt(editbtnindex[1]));
        }
    },
    
    submitApprovalClick : function(component, event, helper) {
        helper.submitForApproval(component);
    },
    
    modalCancelClick : function(component, event, helper) {
    	helper.modalCancel(component);
    },
    
    modalSaveClick : function(component, event, helper) {
        helper.saveMatLevel(component, event);  
    },
    
    accordHeaderClick : function(component, event, helper) {
       var elem = event.target || event.srcElement;
       var srcelem = helper.findElement(elem, 'section');
    
       if (srcelem != undefined && srcelem.id != undefined) {
           if ($A.util.hasClass(srcelem,'slds-is-open')) {
              $A.util.toggleClass(srcelem,'slds-is-open');    
           } else {
              var accrdSections = document.querySelectorAll("section.slds-accordion__section");
              for(var i=0; i < accrdSections.length;i++) $A.util.removeClass(accrdSections[i],'slds-is-open');
              $A.util.toggleClass(srcelem,'slds-is-open');  
              srcelem.scrollTop = 0;
           }
           if(!$A.util.isEmpty(srcelem.id)) {
              var currIndex = srcelem.id.split('-')[1]; 
              component.set("v.activeMatLvl", component.get("v.matLvlRecords")[currIndex].level);  
           }	     
       }
	},
    
    hidePrompt:function(component, event, helper) {
    	helper.hidePrompt(component); 
    },
    
    compDateChange:function(component, event, helper) {
        var compdate = event.getSource().get("v.value");
        
        try {
            if((!$A.util.isUndefinedOrNull(compdate)) && (compdate != '')) {
                var frmdateval = $A.localizationService.formatDate(compdate, "YYYY-MM-DD");
                var dateval = new Date(frmdateval);
                var now = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                var today = new Date(now);
                
                if(dateval <= today)  {
                    $A.util.removeClass(event.getSource(), "pmsinputError");      
                }
            } else {
            	$A.util.removeClass(event.getSource(), "pmsinputError");    
            }
        } catch(e) {
            console.error(e.message);
        }
            
    }
    
})