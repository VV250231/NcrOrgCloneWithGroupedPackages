({
    doInit : function(component, event, helper) {
       helper.getMyObjects(component);
       helper.getUserProfile(component);
       helper.getOppProducts(component);
       helper.getClosedProducts(component);
       helper.getMyObjectspurchased(component);
       helper.getMyObjectsNotSold(component);
       helper.getAccountLabel(component, event, helper);
       //helper.wrapperMultiValue(component); 
       //helper.getAccounTeamMembers(component);
    }, 
    updateAccount:function(component, event, helper) {  
        helper.updateAccount(component); 
            
    },  
    showModal: function(component, event, helper) {
         
    	helper.showModal(component);
        helper.loadAccount(component);
        
     },
    showEditAccountModal:function(component, event, helper) {
         
    	helper.showEditAccountModal(component); 
	},
   
    showEditCompetetors:function(component, event, helper) {
         
    	helper.showEditCompetetors(component); 
	},
    
    
    Cancelcompetetorsection: function(component, event, helper) {
         
    	helper.Cancelcompetetorsection(component);
               
    },
     
   showEditNotSoldvalues:function(component, event, helper) {
         
    	helper.showEditNotSoldvalues(component); 
	},
    
  handleComponentEventFired:function(component, event, helper) {
        
    	helper.handleComponentEventFired(component); 
	},
   handleComponentEventFired1:function(component, event, helper) {
        
    	helper.handleComponentEventFired1(component); 
	}
 
 
 
})