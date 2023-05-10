{
	doInit : function(component, event, helper) {
        helper.wrapperMultiValue(component, event, helper); 
           
	}, 
    
    RightToLeft:function(component, event, helper){
        helper.RightToLeft(component, event, helper);
        
    },
    LeftToRight:function(component, event, helper){
        helper.LeftToRight(component, event, helper); 
        
    },
    CancelNotSoldSection: function(component, event, helper) {
         
    	helper.CancelNotSoldSection(component);
               
    }, 
      setNotSoldvalues:function(component, event, helper) {  
         helper.setNotSoldvalues(component, event, helper); 
    },
      saveNotSold:function(component, event, helper){
         helper.saveNotSold(component, event, helper);
          
        }  
    
})