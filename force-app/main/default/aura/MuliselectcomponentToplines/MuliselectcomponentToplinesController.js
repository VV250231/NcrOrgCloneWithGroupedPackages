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
    Cancelcompetetorsection: function(component, event, helper) {
         
    	helper.Cancelcompetetorsection(component);
               
    },
    
    setHwCompetetors:function(component, event, helper) {  
        helper.setHwCompetetors(component); 
    },
        
    saveHwCompetetors:function(component, event, helper) {  
        helper.saveHwCompetetors(component); 
    }
   
    
})