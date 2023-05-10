({
    	
    
    hidePopupModal: function(component, componentId, className){
        var modal = component.find( componentId );
        $A.util.addClass( modal, className+'hide' );
        $A.util.removeClass( modal, className+'open' );
        component.set("v.body", "");
    },
    
    
    getpicklistvalueDR: function(component){ 
        
        var action = component.get("c.getpickvalDR");
        var recordId = component.get("v.recordId");
        
        action.setParams({
            recordId: recordId
        });
        var inputsel = component.find("DR"); 
        var opts=[];
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                //opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                 if(a.getReturnValue()[i].Selected === true){
                  
                   opts.push({"class": "optionClass", label: a.getReturnValue()[i].ListValue, value: a.getReturnValue()[i].ListValue,selected:true});
                   component.set("v.DisContinueReason", a.getReturnValue()[i].ListValue);  
                     
                }
                else{
                  opts.push({"class": "optionClass", label: a.getReturnValue()[i].ListValue, value: a.getReturnValue()[i].ListValue});  
                }  
            }
            inputsel.set("v.options", opts);  
            
        });     
        $A.enqueueAction(action); 
    }, 
    
    getInputDR:function(component, event, helper)
    {  
        var DisContinueReason=component.find("DR").get("v.value");
        
        component.set("v.DisContinueReason", DisContinueReason); 
    },
    getDisableCheck:function(component)
    {
    	var action = component.get("c.getIsdisabled");
        
        action.setCallback(this, function(a) {            
            component.set("v.DisableVariable",a.getReturnValue());            
        });
        $A.enqueueAction(action); 
	},
    getPicklistOptions:function(component)
    {
        var action = component.get("c.getOpts");         
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {                
                component.set("v.fieldMapOptions", a.getReturnValue());
                component.set("v.callChild", true);
            } else if (a.getState() === "ERROR") { 
                $A.log("Errors", a.getError());   
            }
            
        });
        $A.enqueueAction(action);
	},
    
    CreateReasonCodeArray:function(component,event,helper,ReasonString){
        var str_array="";
        if(ReasonString){
            str_array= ReasonString.split(';');
        }  
         
        var object=[];
        var action = component.get("c.getReasonForHwandSW");
         
        action.setCallback(this, function(a) {            
            var state = a.getState();
			if (state === "SUCCESS") {  
            	for(var i=0;i<a.getReturnValue().length;i++){
                    if(str_array[i] === a.getReturnValue()[i]){ 
                        //alert('yes'+str_array[i]);
                       	
                        object.push({options:a.getReturnValue()[i].replace(/^\s*/, "").replace(/\s*$/, ""),Check:true });
                    }
                    else{
                       object.push({options:a.getReturnValue()[i].replace(/^\s*/, "").replace(/\s*$/, ""),Check:false }); 
                    }    
                        
                    
            	}
                component.set("v.AttachReasonCode",object); 
            }
  
        });
        
        $A.enqueueAction(action); 
        	
        }
        
    
    
})