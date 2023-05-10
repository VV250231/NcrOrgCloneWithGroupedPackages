({
	GetNotification : function(component,event, helper) {
        
        var action1 = component.get("c.getOppDetails");   
        action1.setParams({
            oppId : component.get("v.OpportunityId")
        });
        action1.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && response.getReturnValue().length>0){                
                var retResponse = response.getReturnValue();
                component.set("v.OppIndustry",retResponse[0].Industry__c);
                var action = component.get("c.getNotification");  
        
        action.setParams({ 
            OpportunityId : component.get("v.OpportunityId")    
       });
          
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {                
                var count= (a.getReturnValue().match(/Warning/g) || []).length;                 
                 component.set("v.MessageCount", count);
                 component.set("v.Message", a.getReturnValue());
                //alert(component.get("v.Message"));
                if((component.get("v.Message").includes("CLM process")) && component.get("v.OppIndustry")!='Payments & Network'){
                    component.set("v.ShowButton", true);
                }               	
                var fltMsg = component.find( 'outerDiv' );
        		$A.util.addClass( fltMsg, 'aftLoad' );
                $A.util.removeClass( fltMsg, 'initLoad' );
        		component.set("v.body","");
                
                
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());
            }
            
       });
        $A.enqueueAction(action);
                
            }
        });
        $A.enqueueAction(action1);  
	},
    hideMsg: function(component, componentId, className){
        var fltMsg = component.find( componentId );
        $A.util.addClass( fltMsg, className );
        component.set("v.body", "");
    }
});