({
	doInit : function(component, event, helper) {
		//helper.GetKeycriteria(component, event, helper); 
        helper.wrapperMultiValue(component, event, helper); 
	},
    
    RightToLeft:function(component, event, helper){
        helper.RightToLeft(component, event, helper);
        
    },
    LeftToRight:function(component, event, helper){
        helper.LeftToRight(component, event, helper);
        
    }
    
})