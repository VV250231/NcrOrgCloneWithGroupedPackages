({
	GetKeycriteria : function(component, event, helper) {
		var action = component.get("c.getpickval_key_criteria"); 
        var inputsel = component.find("v.arrvals"); 
        var opts=[]; 
        
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({index: i ,value: a.getReturnValue()[i]});  
            }
            component.set("v.arrvals",opts);    
        });
        $A.enqueueAction(action);  
	},
    
    RightToLeft : function(component, event, helper) {
        var ss=component.get("v.arrvalsSelect");
        var avilablearry=component.get("v.arrvals"); 
        
        var selectvalue=event.target.innerHTML;
        
       
        var newarry=[];
        for(var j=0;j<avilablearry.length;j++){
            
            if(avilablearry[j].value === selectvalue)
            {
					  //avilablearry.splice(selectvalue,1);
                	  avilablearry.splice(j, 1);	 
                      
            }  
        }
        component.set("v.arrvals",avilablearry);
        
        var selectedopts=[];
        for(var i=0;i<ss.length;i++){
                if(ss[i].value !=  selectvalue){
                    selectedopts.push({index: i ,value : ss[i].value});
                    
                }	 
            }      
        selectedopts.push({index : parseInt(ss.length+1) ,value  : selectvalue});
        component.set("v.arrvalsSelect",selectedopts);   
        this.fireComponentEvent(component, event);
    },
    LeftToRight:function(component, event, helper){
       var rightarry=component.get("v.arrvalsSelect");
       var leftarry=component.get("v.arrvals"); 
       var selectedfromLeft = event.target.innerHTML;  
       var temparry1=[]; 
        if(leftarry.length >0)
        {
            for(var i=0 ; i<leftarry.length ; i++)
        	{
                
            	temparry1.push({index : i, value : leftarry[i].value});
                
            }
                
        }
        
       var i=0;
       do {
    		if(leftarry.length === 0 && temparry1.length === 0)
            {
            
        		temparry1.push({index : i, value : selectedfromLeft});
               
                //alert('i am colprate 2');
			}
           
            if(leftarry.length>0 )
           { 
               
               temparry1.push({index : parseInt(temparry1.length+1), value : selectedfromLeft});
               //alert('i am colprate 3');
        	   break;
               
           }
           i++;
		}
		while (i <leftarry.length);
        component.set("v.arrvals",temparry1);
        
        
        for(var j=0;j<rightarry.length;j++)
            {
                if(rightarry[j].value == selectedfromLeft)
                {
                    rightarry.splice(j, 1);
                }
            }
        component.set("v.arrvalsSelect",rightarry);
        this.fireComponentEvent(component, event);
    },
    fireComponentEvent : function(cmp, event) { 
        
		var parentName = cmp.get("v.arrvalsSelect");
		// Look up event by name, not by type
        var compEvents = cmp.getEvent("componentEventFired");
        compEvents.setParams({ "context" : parentName });
        compEvents.fire();
        },
    wrapperMultiValue: function(component, event, helper){
        var opppid=component.get("v.parentOppId");
       
        var action = component.get("c.NewGetPicklistValue"); 
         action.setParams({ 
        	oppId : opppid     
    	});
        var rightarray=[]; 
        var leftarray=[]; 
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                
                if(a.getReturnValue()[i].Selecetd){
                     rightarray.push({index: i ,value: a.getReturnValue()[i].ListValue}); 
                }
                else{
                    leftarray.push({index: i ,value: a.getReturnValue()[i].ListValue});
                }
            }
            component.set("v.arrvals",leftarray);
            component.set("v.arrvalsSelect",rightarray);
        });
        $A.enqueueAction(action); 
    }
});